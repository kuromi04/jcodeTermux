# jcodeTermux 📱⚡

[![Platform: Termux](https://img.shields.io/badge/Platform-Termux-green.svg?style=for-the-badge&logo=android)](https://termux.dev)
[![Ecosystem: i-HakLab](https://img.shields.io/badge/Ecosystem-i--HakLab-blue.svg?style=for-the-badge)](https://github.com/ivam3)
[![Glibc Wrapper: Optimized](https://img.shields.io/badge/Glibc%20Wrapper-Optimized-magenta.svg?style=for-the-badge)](docs/skills.md)
[![Status: Production-Ready](https://img.shields.io/badge/Status-Production--Ready-brightgreen.svg?style=for-the-badge)](#)

Optimización, instalación y entorno automatizado para ejecutar **JCode** (el arnés de desarrollo y agente de IA ultraligero escrito en Rust) dentro de **Android** vía **Termux** de forma estable, fluida y sin fallas visuales.

---

## 📖 ¿Por qué es necesario jcodeTermux?

El binario oficial de **JCode** está compilado nativamente para arquitecturas GNU/Linux estándar enlazadas contra **glibc**. Al intentar ejecutarlo en Android/Termux, ocurren los siguientes problemas:
1. **Incompatibilidad de libc:** Android utiliza **Bionic libc**, lo que causa fallos inmediatos al intentar cargar dependencias de sistema dinámicas (`libc.so.6`, `libssl.so.3`, etc.).
2. **Shebangs Corruptos:** El instalador genera un script de inicio wrapper apuntando a `#!/usr/bin/env bash`, ruta absoluta que no existe en el sistema de archivos de usuario de Termux.
3. **Inestabilidad Visual (TUI Glitch):** Los terminales emulados en Android colapsan ante actualizaciones continuas de alta frecuencia en la interfaz gráfica (como las animaciones de carga e idle a 25+ FPS), provocando que los textos del chat desaparezcan o se superpongan.

**jcodeTermux** soluciona esto de manera automatizada mediante un script interactivo en Bash que parcha las cabeceras ELF, corrige las variables de entorno de `glibc` y aplica una configuración visual balanceada.

---

## 🛠️ El Configurador Interactivo (`setup.sh`)

Incluimos un script con interfaz de menú interactiva en el terminal que te permite administrar JCode sin ingresar comandos manuales complejos:

```text
======================================================================
         __                 __  ______                                
        / /____  ____  ____/ / /_  __/___  ________ ___  __  ___  __  
   __  / / ___/ / __ \/ __  /   / / / _  \/ ___/ __ \`__ \/ / / / |/_/  
  / /_/ / /__  / /_/ / /_/ /   / / /  __/ /   / / / / / / /_/ />  <    
  \____/\___/  \____/\__,_/   /_/  \___/_/   /_/ /_/ /_/\__,_/_/|_|    
                                                                      
     Tactical JCode Installer & Configurator for Android/Termux        
======================================================================
 Ecosistema: i-HakLab | Sponsor: Ivam3 | Estado: Termux-Optimized
----------------------------------------------------------------------

 1) Instalar / Reinstalar JCode (Termux Patch)
 2) Optimizar Pantalla y Animaciones (Evita parpadeos y letras invisibles)
 3) Administrar Servidor Daemon (Iniciar/Detener)
 4) Diagnóstico de Sistema y Autenticación
 5) Salir

 Elige una opción [1-5]: 
```

---

## 🚀 Instalación Rápida

Para clonar este repositorio e iniciar el asistente en tu dispositivo Android, ejecuta la siguiente secuencia de comandos en Termux:

```bash
# Clonar el repositorio
git clone https://github.com/kuromi04/jcodeTermux.git

# Entrar al directorio
cd jcodeTermux

# Hacer ejecutable e iniciar el configurador
chmod +x setup.sh
./setup.sh
```

---

## ⚙️ Optimización Visual Aplicada

El asistente de configuración modifica de forma segura tu archivo `~/.jcode/config.toml` con parámetros estudiados específicamente para Termux:

*   **`idle_animation = false`**: Detiene las animaciones infinitas en segundo plano, estabilizando el chat para que el texto sea siempre visible.
*   **`prompt_entry_animation = false`**: Evita la corrupción y el desfase del cursor de entrada mientras escribes tus prompts.
*   **`disabled_animations = []`**: Conserva activa la presentación y animación inicial (splash screen) en el arranque del sistema.
*   **`animation_fps = 10` y `redraw_fps = 12`**: Modera el tráfico de refresco del terminal, logrando un movimiento fluido y protegiendo el consumo de batería de tu smartphone.
*   **`mouse_capture = false`**: Permite realizar scrolling y copiar texto de manera nativa usando los gestos táctiles de Termux sin interferir con el agente.

---

## 📚 Documentación Técnica & Skills

Si deseas profundizar en la ingeniería detrás de la adaptación de binarios y wrappers, te invitamos a consultar nuestra [Guía Experta de Adaptación](docs/skills.md), donde se detalla:
*   Mapeo de intérpretes dinámicos de ELF con `patchelf`.
*   Ajustes y resolución de variables críticas (`GLIBC_TUNABLES`, `LD_PRELOAD`).
*   Solución a errores comunes en Termux.

---

## 💖 Créditos y Agradecimientos

Este repositorio y sus parches no serían posibles sin el esfuerzo continuo y soporte técnico de la comunidad de seguridad y desarrollo en habla hispana:

*   **[Ivam3](https://github.com/ivam3):** Creador y patrocinador de la suite **i-HakLab** y el repositorio de paquetes optimizados que proporcionan las librerías glibc base para Termux. Su incansable trabajo ha facilitado la ejecución de asistentes de IA nativos en Android.
*   **Comunidad i-HakLab / AI-HakLab:** Por testear los límites de los modelos, scripts y TUI en plataformas móviles y reportar soluciones a fallas comunes.

---

## 📄 Licencia

Este proyecto está bajo la Licencia MIT. Consulta el archivo `LICENSE` para más detalles.
