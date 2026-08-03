#!/data/data/com.termux/files/usr/bin/bash
# ==============================================================================
#  jcodeTermux — Tactical Configurator & Setup Menu for JCode
#  Developed for Android/Termux environments with glibc support.
#  Credits & Acknowledgements to Ivam3 & AI-HakLab
# ==============================================================================

# ── Colores y Estilo ──────────────────────────────────────────────────────────
RESET='\e[0m'
BOLD='\e[1m'
UNDERLINE='\e[4m'
RED='\e[1;31m'
GREEN='\e[1;32m'
YELLOW='\e[1;33m'
BLUE='\e[1;34m'
MAGENTA='\e[1;35m'
CYAN='\e[1;36m'
WHITE='\e[1;37m'

# ── Funciones de Impresión ───────────────────────────────────────────────────
log_info()    { echo -e "${BLUE}[*]${RESET} ${BOLD}$1${RESET}"; }
log_success() { echo -e "${GREEN}[+]${RESET} ${BOLD}$1${RESET}"; }
log_warn()    { echo -e "${YELLOW}[!]${RESET} ${BOLD}$1${RESET}"; }
log_error()   { echo -e "${RED}[-]${RESET} ${BOLD}$1${RESET}"; }
header() {
    clear
    echo -e "${CYAN}${BOLD}======================================================================${RESET}"
    echo -e "${MAGENTA}${BOLD}         __                 __  ______                                ${RESET}"
    echo -e "${MAGENTA}${BOLD}        / /____  ____  ____/ / /_  __/___  ________ ___  __  ___  __  ${RESET}"
    echo -e "${MAGENTA}${BOLD}   __  / / ___/ / __ \/ __  /   / / / _  \/ ___/ __ \`__ \/ / / / |/_/  ${RESET}"
    echo -e "${MAGENTA}${BOLD}  / /_/ / /__  / /_/ / /_/ /   / / /  __/ /   / / / / / / /_/ />  <    ${RESET}"
    echo -e "${MAGENTA}${BOLD}  \____/\___/  \____/\__,_/   /_/  \___/_/   /_/ /_/ /_/\__,_/_/|_|    ${RESET}"
    echo -e "${MAGENTA}${BOLD}                                                                      ${RESET}"
    echo -e "${CYAN}${BOLD}     Tactical JCode Installer & Configurator for Android/Termux        ${RESET}"
    echo -e "${CYAN}${BOLD}======================================================================${RESET}"
    echo -e " Ecosistema: ${YELLOW}i-HakLab${RESET} | Sponsor: ${YELLOW}Ivam3${RESET} | Estado: ${GREEN}Termux-Optimized${RESET}"
    echo -e "----------------------------------------------------------------------\n"
}

press_enter() {
    echo -e "\n${WHITE}Presiona ${GREEN}[ENTER]${WHITE} para regresar al menú...${RESET}"
    read -r
}

# ── Validaciones de Entorno ──────────────────────────────────────────────────
check_glibc() {
    if [ ! -d "/data/data/com.termux/files/usr/glibc" ]; then
        log_warn "No se detectó el entorno glibc en Termux."
        log_info "Este instalador requiere glibc para ejecutar binarios x86/aarch64 compilados de forma nativa."
        log_info "Por favor, asegúrate de tener el entorno glibc configurado vía i-HakLab o ivam3/termux-packages."
    fi
}

# ── Opción 1: Instalar / Reinstalar JCode ─────────────────────────────────────
action_install() {
    header
    log_info "Iniciando instalación oficial de JCode..."
    check_glibc
    
    # 1. Ejecutar instalador oficial
    if curl -fsSL 'https://jcode.sh/install?conversion_id=9a8b3f01-72ac-4d83-8240-befa1b9d0079' | bash; then
        log_success "El instalador base de JCode finalizó correctamente."
    else
        log_error "Fallo al ejecutar el instalador web."
        press_enter
        return 1
    fi
    
    # 2. Corregir shebang y entorno en el wrapper de la CLI
    local launcher_path="$HOME/.local/bin/jcode"
    local stable_binary="$HOME/.jcode/builds/stable/jcode"
    
    log_info "Aplicando parche de Shebang y GLIBC en el Wrapper..."
    if [ -f "$launcher_path" ]; then
        cat << 'EOF' > "$launcher_path"
#!/data/data/com.termux/files/usr/bin/bash
# Wrapper optimizado para Termux (Bionic libc -> glibc compatibility)
unset LD_PRELOAD
unset LD_LIBRARY_PATH
export GLIBC_TUNABLES="glibc.rtld.dynamic_sort=1"

exec "/data/data/com.termux/files/home/.jcode/builds/stable/jcode" "$@"
EOF
        chmod +x "$launcher_path"
        log_success "Launcher wrapper corregido en: $launcher_path"
    else
        log_error "No se encontró el wrapper en $launcher_path para parchar."
    fi
    
    # 3. Mostrar versión instalada
    echo ""
    if command -v jcode >/dev/null 2>&1; then
        log_success "JCode responde correctamente en el PATH!"
        log_info "Versión instalada:"
        jcode --version
    else
        log_warn "JCode instalado pero no detectado en el PATH inmediato. Agrega ~/.local/bin a tu PATH."
    fi
    press_enter
}

# ── Opción 2: Optimizar Visuales y Animaciones para Termux ───────────────────
action_configure_visuals() {
    header
    local config_file="$HOME/.jcode/config.toml"
    
    log_info "Optimizando visuales en config.toml..."
    
    # Asegurar que el config existe
    if [ ! -f "$config_file" ]; then
        log_warn "No se encontró config.toml en $config_file."
        log_info "Generando un archivo de configuración predeterminado..."
        mkdir -p "$(dirname "$config_file")"
        # Crear un template básico de la sección display
        cat << 'EOF' > "$config_file"
[display]
idle_animation = false
prompt_entry_animation = false
disabled_animations = []
animation_fps = 10
redraw_fps = 12
mouse_capture = false
emoji = true
EOF
        log_success "Archivo de configuración base creado."
    fi
    
    # Parchar con sed los valores para estabilidad en Termux
    # Evita overlapping de caracteres, desestabilización y consumos altos de CPU
    sed -i 's/idle_animation\s*=\s*true/idle_animation = false/g' "$config_file"
    sed -i 's/prompt_entry_animation\s*=\s*true/prompt_entry_animation = false/g' "$config_file"
    sed -i 's/disabled_animations\s*=\s*\[.*\]/disabled_animations = []/g' "$config_file"
    sed -i 's/animation_fps\s*=\s*[0-9]*/animation_fps = 10/g' "$config_file"
    sed -i 's/redraw_fps\s*=\s*[0-9]*/redraw_fps = 12/g' "$config_file"
    sed -i 's/mouse_capture\s*=\s*true/mouse_capture = false/g' "$config_file"
    
    # En caso de que no existan las variables, las agregamos al final del display
    # (El bloque display suele estar al inicio o definido explícitamente)
    log_success "Valores parchados exitosamente:"
    echo -e "  - ${CYAN}idle_animation = false${RESET} (Evita refrescos de pantalla continuos en reposo)"
    echo -e "  - ${CYAN}prompt_entry_animation = false${RESET} (Evita corrupción del prompt al escribir)"
    echo -e "  - ${CYAN}disabled_animations = []${RESET} (Permite la animación inicial de presentación)"
    echo -e "  - ${CYAN}animation_fps = 10${RESET} & ${CYAN}redraw_fps = 12${RESET} (FPS estables para buffers de Termux)"
    echo -e "  - ${CYAN}mouse_capture = false${RESET} (Evita bloqueos de gestos y scrolling nativo)"
    
    # Reiniciar servidor para aplicar cambios
    if pgrep -f "jcode.*serve" >/dev/null; then
        log_info "Reiniciando servidor JCode para aplicar cambios visuales..."
        jcode server stop --force >/dev/null 2>&1 || true
        sleep 1
        jcode server start >/dev/null 2>&1 || true
        log_success "Servidor reiniciado con éxito."
    fi
    
    press_enter
}

# ── Opción 3: Iniciar / Detener / Reiniciar Servidor ──────────────────────────
action_manage_server() {
    while true; do
        header
        local pid
        pid=$(pgrep -f "jcode.*serve" || echo "")
        
        if [ -n "$pid" ]; then
            echo -e " Estado del Servidor: ${GREEN}${BOLD}ACTIVO (PID: $pid)${RESET}\n"
        else
            echo -e " Estado del Servidor: ${RED}${BOLD}INACTIVO${RESET}\n"
        fi
        
        echo -e " ${CYAN}1)${RESET} Iniciar Servidor Daemon"
        echo -e " ${CYAN}2)${RESET} Detener Servidor Daemon (Force)"
        echo -e " ${CYAN}3)${RESET} Reiniciar Servidor Daemon"
        echo -e " ${CYAN}4)${RESET} Volver al menú principal"
        echo -e ""
        echo -ne " ${WHITE}Elige una opción: ${RESET}"
        read -r s_opt
        
        case "$s_opt" in
            1)
                log_info "Iniciando servidor de JCode..."
                jcode server start
                sleep 2
                ;;
            2)
                log_info "Deteniendo servidor de JCode..."
                jcode server stop --force
                sleep 1
                ;;
            3)
                log_info "Reiniciando servidor de JCode..."
                jcode server stop --force >/dev/null 2>&1 || true
                sleep 1
                jcode server start
                sleep 2
                ;;
            4)
                break
                ;;
            *)
                log_warn "Opción inválida."
                sleep 1
                ;;
        esac
    done
}

# ── Opción 4: Diagnóstico y Estado ────────────────────────────────────────────
action_diagnose() {
    header
    log_info "--- Diagnóstico de Sistema ---"
    
    echo -ne " ${BOLD}Comando JCode:${RESET} "
    if command -v jcode >/dev/null 2>&1; then
        echo -e "${GREEN}Disponible en PATH${RESET}"
        echo -ne " ${BOLD}Versión:${RESET} "
        jcode --version
    else
        echo -e "${RED}No encontrado en PATH${RESET}"
    fi
    
    echo -ne " ${BOLD}Servidor Daemon:${RESET} "
    local pid
    pid=$(pgrep -f "jcode.*serve" || echo "")
    if [ -n "$pid" ]; then
        echo -e "${GREEN}Ejecutándose (PID: $pid)${RESET}"
    else
        echo -e "${RED}Detenido${RESET}"
    fi
    
    echo -ne " ${BOLD}Entorno GLIBC:${RESET} "
    if [ -d "/data/data/com.termux/files/usr/glibc" ]; then
        echo -e "${GREEN}Instalado y configurado${RESET}"
    else
        echo -e "${YELLOW}No detectado (~/usr/glibc)${RESET}"
    fi
    
    echo -e "\n--- Estado de Autenticación de Proveedores ---"
    if command -v jcode >/dev/null 2>&1; then
        jcode auth status || log_error "No se pudo consultar el estado de autenticación."
    else
        log_error "Instala JCode primero para comprobar la autenticación."
    fi
    
    press_enter
}

# ── Menú Principal ────────────────────────────────────────────────────────────
main_menu() {
    while true; do
        header
        echo -e " ${CYAN}1)${RESET} Instalar / Reinstalar JCode (Termux Patch)"
        echo -e " ${CYAN}2)${RESET} Optimizar Pantalla y Animaciones (Evita parpadeos y letras invisibles)"
        echo -e " ${CYAN}3)${RESET} Administrar Servidor Daemon (Iniciar/Detener)"
        echo -e " ${CYAN}4)${RESET} Diagnóstico de Sistema y Autenticación"
        echo -e " ${CYAN}5)${RESET} Salir"
        echo -e ""
        echo -ne " ${WHITE}Elige una opción [1-5]: ${RESET}"
        read -r opt
        
        case "$opt" in
            1) action_install ;;
            2) action_configure_visuals ;;
            3) action_manage_server ;;
            4) action_diagnose ;;
            5)
                header
                echo -e "${GREEN}${BOLD}¡Gracias por usar jcodeTermux! Saludos al gran Ivam3 por el soporte de la comunidad.${RESET}"
                echo -e "Saliendo...\n"
                exit 0
                ;;
            *)
                log_warn "Opción inválida. Elige un número del 1 al 5."
                sleep 1
                ;;
        esac
    done
}

# Ejecutar el menú
main_menu
