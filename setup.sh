#!/data/data/com.termux/files/usr/bin/bash
# ==============================================================================
#  jcodeTermux — Tactical Configurator & Setup Menu for JCode & Walkie
#  Developed for Android/Termux environments.
#  Credits & Acknowledgements to Ivam3
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
    echo -e "${CYAN}${BOLD}     Tactical JCode & Walkie Installer & Configurator for Termux       ${RESET}"
    echo -e "${CYAN}${BOLD}======================================================================${RESET}"
    echo -e " Soporte: ${YELLOW}JCode & Walkie-Termux${RESET} | Sponsor: ${YELLOW}Ivam3${RESET} | Estado: ${GREEN}Termux-Optimized${RESET}"
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
        log_info "JCode requiere glibc para ejecutar su binario compilado nativamente."
        log_info "Por favor, asegúrate de tener el entorno glibc configurado en Termux vía ivam3/termux-packages."
    fi
}

# ── Opción 1: Instalar / Reinstalar JCode ─────────────────────────────────────
action_install_jcode() {
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
    
    local launcher_path="$HOME/.local/bin/jcode"
    local stable_binary="$HOME/.jcode/builds/stable/jcode"
    local real_binary
    real_binary="$(readlink -f "$stable_binary" 2>/dev/null || echo "$stable_binary")"

    # 2. Parchar el binario ELF con el cargador glibc
    log_info "Parchando el binario ELF con el cargador glibc..."
    if [ -f "$real_binary" ]; then
        if command -v grun >/dev/null 2>&1; then
            grun -c "$real_binary" >/dev/null 2>&1
            log_success "Binario ELF adaptado correctamente con grun."
        elif [ -x "/data/data/com.termux/files/usr/glibc/bin/patchelf" ]; then
            /data/data/com.termux/files/usr/glibc/bin/patchelf \
                --set-rpath "/data/data/com.termux/files/usr/glibc/lib" \
                --set-interpreter "/data/data/com.termux/files/usr/glibc/lib/ld-linux-aarch64.so.1" \
                "$real_binary" >/dev/null 2>&1
            log_success "Binario ELF adaptado correctamente con patchelf."
        else
            log_warn "No se encontró grun ni patchelf para adaptar el binario directamente."
        fi
    fi

    # 3. Corregir shebang y entorno en el wrapper de la CLI (con auto-reparación)
    log_info "Aplicando parche de Shebang y GLIBC en el Wrapper..."
    if [ -f "$launcher_path" ]; then
        cat << 'EOF' > "$launcher_path"
#!/data/data/com.termux/files/usr/bin/bash
# Wrapper optimizado para Termux (Bionic libc -> glibc compatibility)
unset LD_PRELOAD
unset LD_LIBRARY_PATH
export GLIBC_TUNABLES="glibc.rtld.dynamic_sort=1"

TARGET="$HOME/.jcode/builds/stable/jcode"
REAL_BIN="$(readlink -f "$TARGET" 2>/dev/null || echo "$TARGET")"

# Auto-reparación: Si una actualización descargó un binario nuevo sin parchar
if [ -f "$REAL_BIN" ]; then
    if readelf -l "$REAL_BIN" 2>/dev/null | grep -q '/lib/ld-linux'; then
        if command -v grun >/dev/null 2>&1; then
            grun -c "$REAL_BIN" >/dev/null 2>&1
        elif [ -x "/data/data/com.termux/files/usr/glibc/bin/patchelf" ]; then
            /data/data/com.termux/files/usr/glibc/bin/patchelf \
                --set-rpath "/data/data/com.termux/files/usr/glibc/lib" \
                --set-interpreter "/data/data/com.termux/files/usr/glibc/lib/ld-linux-aarch64.so.1" \
                "$REAL_BIN" >/dev/null 2>&1
        fi
    fi
fi

if [ -x "$TARGET" ]; then
    exec "$TARGET" "$@"
elif command -v grun >/dev/null 2>&1; then
    exec grun "$TARGET" "$@"
else
    exec "/data/data/com.termux/files/usr/glibc/lib/ld-linux-aarch64.so.1" --library-path "/data/data/com.termux/files/usr/glibc/lib" "$TARGET" "$@"
fi
EOF
        chmod +x "$launcher_path"
        log_success "Launcher wrapper corregido en: $launcher_path"
    else
        log_error "No se encontró el wrapper en $launcher_path para parchar."
    fi
    
    # 4. Mostrar versión instalada
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

# ── Opción 3: Iniciar / Detener / Reiniciar Servidor JCode ────────────────────
action_manage_server() {
    while true; do
        header
        local pid
        pid=$(pgrep -f "jcode.*serve" || echo "")
        
        if [ -n "$pid" ]; then
            echo -e " Estado del Servidor JCode: ${GREEN}${BOLD}ACTIVO (PID: $pid)${RESET}\n"
        else
            echo -e " Estado del Servidor JCode: ${RED}${BOLD}INACTIVO${RESET}\n"
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

# ── Opción 4: Instalar / Reinstalar Walkie-Termux ──────────────────────────────
action_install_walkie() {
    header
    log_info "Iniciando instalación de Walkie-Termux..."
    
    # 1. Instalar dependencias del sistema
    log_info "Verificando/instalando nodejs y git..."
    pkg update && pkg install nodejs git -y
    
    # 2. Clonar / actualizar el repositorio
    local walkie_dir="$HOME/walkieTermux"
    if [ ! -d "$walkie_dir" ]; then
        log_info "Clonando Walkie-Termux desde GitHub..."
        git clone https://github.com/kuromi04/walkieTermux.git "$walkie_dir"
    else
        log_info "El directorio $walkie_dir ya existe. Actualizando repositorio..."
        (cd "$walkie_dir" && git pull)
    fi
    
    # 3. Instalar dependencias de npm evitando wrappers
    log_info "Instalando dependencias de Node.js..."
    if [ -f "/data/data/com.termux/files/usr/bin/npm" ]; then
        (cd "$walkie_dir" && /data/data/com.termux/files/usr/bin/npm install)
    else
        (cd "$walkie_dir" && npm install)
    fi
    
    # 4. Enlazar globalmente y aplicar patch de shebang
    log_info "Enlazando binario global..."
    (cd "$walkie_dir" && npm install -g .)
    
    local global_walkie="$HOME/.npm-global/bin/walkie"
    if [ -f "$global_walkie" ]; then
        log_info "Aplicando termux-fix-shebang en $global_walkie..."
        termux-fix-shebang "$global_walkie"
    elif command -v walkie >/dev/null 2>&1; then
        local walkie_path
        walkie_path=$(which walkie)
        log_info "Aplicando termux-fix-shebang en $walkie_path..."
        termux-fix-shebang "$walkie_path"
    else
        log_warn "No se pudo localizar el binario global de walkie para corregir el shebang."
    fi
    
    log_success "¡Walkie-Termux instalado con éxito!"
    press_enter
}

# ── Opción 5: Ejecutar Walkie-Termux ──────────────────────────────────────────
action_run_walkie() {
    while true; do
        header
        echo -e "   --- Menú de Operación de Walkie-Termux ---"
        echo -e " ${CYAN}1)${RESET} Iniciar Chat de Terminal P2P (walkie chat)"
        echo -e " ${CYAN}2)${RESET} Iniciar Agente de IA P2P Listener (walkie agent)"
        echo -e " ${CYAN}3)${RESET} Iniciar Panel de Control Web UI (walkie web)"
        echo -e " ${CYAN}4)${RESET} Volver al menú principal"
        echo -e ""
        echo -ne " ${WHITE}Elige una opción [1-4]: ${RESET}"
        read -r w_opt
        
        case "$w_opt" in
            1)
                echo -ne " ${WHITE}Ingresa el nombre del canal P2P: ${RESET}"
                read -r channel
                if [ -n "$channel" ]; then
                    log_info "Iniciando chat interactivo en el canal '$channel'..."
                    walkie chat "$channel"
                else
                    log_error "El nombre del canal no puede estar vacío."
                    sleep 1.5
                fi
                ;;
            2)
                echo -ne " ${WHITE}Ingresa el nombre del canal P2P: ${RESET}"
                read -r channel
                if [ -n "$channel" ]; then
                    echo -e " Selecciona el cliente CLI de IA a usar:"
                    echo -e "   1) Codex (predeterminado)"
                    echo -e "   2) Claude"
                    echo -ne "   Elige una opción [1-2]: "
                    read -r cli_opt
                    local cli="codex"
                    [ "$cli_opt" = "2" ] && cli="claude"
                    
                    echo -ne "   Nombre del Agente [TermuxAgent]: "
                    read -r agent_name
                    [ -z "$agent_name" ] && agent_name="TermuxAgent"
                    
                    echo -ne "   System Prompt [Eres un asistente servicial de Termux]: "
                    read -r agent_prompt
                    [ -z "$agent_prompt" ] && agent_prompt="Eres un asistente servicial de Termux."
                    
                    log_info "Iniciando escucha del Agente de IA ($agent_name) en '$channel'..."
                    walkie agent "$channel" --cli "$cli" --name "$agent_name" --prompt "$agent_prompt"
                else
                    log_error "El nombre del canal no puede estar vacío."
                    sleep 1.5
                fi
                ;;
            3)
                log_info "Iniciando panel de control Web UI..."
                log_info "Accede a: http://127.0.0.1:3000/?v=4 en tu navegador."
                walkie web
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

# ── Opción 6: Diagnóstico y Estado ────────────────────────────────────────────
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
    
    echo -ne " ${BOLD}Servidor Daemon JCode:${RESET} "
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
    
    echo -ne " ${BOLD}Comando Walkie:${RESET} "
    if command -v walkie >/dev/null 2>&1; then
        echo -e "${GREEN}Disponible en PATH${RESET}"
        echo -ne " ${BOLD}Ubicación:${RESET} "
        which walkie
    else
        echo -e "${RED}No encontrado en PATH${RESET}"
    fi
    
    echo -e "\n--- Estado de Autenticación de JCode ---"
    if command -v jcode >/dev/null 2>&1; then
        jcode auth status || log_error "No se pudo consultar el estado de autenticación."
    else
        log_error "Instala JCode primero para comprobar la autenticación."
    fi
    
    press_enter
}

# ── Opción 7: Desinstalación y Borrado Total ──────────────────────────────────
action_uninstall() {
    header
    log_warn "ESTÁS A PUNTO DE ELIMINAR COMPLETAMENTE JCODE Y WALKIE DE TU SISTEMA"
    echo -ne " ${WHITE}¿Estás seguro de que deseas desinstalar y borrar todo? [s/N]: ${RESET}"
    read -r confirm
    
    if [[ "$confirm" =~ ^[sS]$ ]]; then
        log_info "Iniciando la desinstalación completa..."
        
        # 1. Detener el servidor JCode
        log_info "Deteniendo el servidor JCode Daemon..."
        jcode server stop --force >/dev/null 2>&1 || true
        local pid
        pid=$(pgrep -f "jcode.*serve" || echo "")
        if [ -n "$pid" ]; then
            kill -9 "$pid" >/dev/null 2>&1 || true
        fi
        
        # 2. Borrar ejecutables y directorios de JCode
        log_info "Borrando binarios, tokens, caché y configuraciones locales de JCode..."
        rm -f "$HOME/.local/bin/jcode"
        rm -rf "$HOME/.jcode"
        rm -rf "$HOME/.config/jcode"
        
        # 3. Borrar ejecutables y directorios de Walkie-Termux
        log_info "Borrando Walkie-Termux y sus dependencias globales..."
        npm uninstall -g walkie-termux >/dev/null 2>&1 || true
        npm uninstall -g walkie >/dev/null 2>&1 || true
        rm -rf "$HOME/walkieTermux"
        rm -rf "$HOME/.npm-global/bin/walkie"
        
        log_success "¡JCode, Walkie-Termux y sus configuraciones asociadas han sido eliminadas!"
    else
        log_info "Operación cancelada."
    fi
    press_enter
}

# ── Menú Principal ────────────────────────────────────────────────────────────
main_menu() {
    while true; do
        header
        echo -e " ${CYAN}1)${RESET} Instalar / Reinstalar JCode (Termux Patch)"
        echo -e " ${CYAN}2)${RESET} Optimizar Pantalla y Animaciones de JCode"
        echo -e " ${CYAN}3)${RESET} Administrar Servidor Daemon JCode"
        echo -e " ${CYAN}4)${RESET} Instalar / Reinstalar Walkie-Termux (P2P Client)"
        echo -e " ${CYAN}5)${RESET} Ejecutar Walkie-Termux (Chat, Agente o Web UI)"
        echo -e " ${CYAN}6)${RESET} Diagnóstico de Sistema y Autenticación"
        echo -e " ${CYAN}7)${RESET} Desinstalar Todo (JCode & Walkie)"
        echo -e " ${CYAN}8)${RESET} Salir"
        echo -e ""
        echo -ne " ${WHITE}Elige una opción [1-8]: ${RESET}"
        read -r opt
        
        case "$opt" in
            1) action_install_jcode ;;
            2) action_configure_visuals ;;
            3) action_manage_server ;;
            4) action_install_walkie ;;
            5) action_run_walkie ;;
            6) action_diagnose ;;
            7) action_uninstall ;;
            8)
                header
                echo -e "${GREEN}${BOLD}¡Gracias por usar jcodeTermux! Saludos al gran Ivam3 por el soporte de la comunidad.${RESET}"
                echo -e "Saliendo...\n"
                exit 0
                ;;
            *)
                log_warn "Opción inválida. Elige un número del 1 al 8."
                sleep 1
                ;;
        esac
    done
}

# Ejecutar el menú
main_menu
