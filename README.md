# jcodeTermux 📱⚡

<p align="center">
  <img src="banner.jpg" alt="jcodeTermux Banner" width="100%">
</p>

[![Platform: Termux](https://img.shields.io/badge/Platform-Termux-green.svg?style=for-the-badge&logo=android)](https://termux.dev)
[![Status: Production-Ready](https://img.shields.io/badge/Status-Production--Ready-brightgreen.svg?style=for-the-badge)](#)
[![Glibc: Compatible](https://img.shields.io/badge/Glibc-Patched%20%26%20Auto--Healing-blue.svg?style=for-the-badge)](#)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](LICENSE)

Optimización, instalación y entorno automatizado para ejecutar **JCode** (Framework de desarrollo y agente de IA en Rust) y **Walkie-Termux** (Orquestación de Agentes de IA P2P descentralizados) dentro de **Android** vía **Termux** de forma fluida, estable y con auto-reparación de binarios.

---

## ⚠️ Requisito Crítico: Descarga de Termux

> [!IMPORTANT]
> **¡NO USES la versión de Google Play Store!** La versión de Termux en Google Play está discontinuada y desactualizada, lo que provocará fallos graves con repositorios de paquetes e incompatibilidades con el entorno `glibc`.

Descarga Termux únicamente desde sus fuentes oficiales actualizadas:

*   📥 **[Descargar Termux desde GitHub Releases](https://github.com/termux/termux-app/releases)** (Recomendado)
*   📥 **[Descargar Termux desde F-Droid](https://f-droid.org/packages/com.termux/)**

---

## 🌟 ¿Qué es jcodeTermux?

El binario oficial de **JCode** está compilado nativamente en Rust contra **GNU glibc** para distribuciones Linux convencionales. Al ejecutarse directamente en Android/Termux, surgen tres barreras fundamentales:

1. **Incompatibilidad de libc (Bionic vs GLIBC):** Android opera bajo Bionic libc y carece del intérprete dinámico estándar de Linux (`/lib/ld-linux-aarch64.so.1`), arrojando errores inmediatos de `cannot execute: required file not found`.
2. **Inestabilidad TUI en móviles (Glitches gráficos):** Animaciones a altas tasas de refresco (25+ FPS), redibujados continuos y captura de ratón desestabilizan el emulador de terminal en pantallas táctiles y sobrecalientan el dispositivo.
3. **Pérdida de compatibilidad en auto-actualizaciones:** Cuando JCode se actualiza a sí mismo, descarga un nuevo binario crudo sin adaptar, rompiendo la ejecución previa.

**jcodeTermux resuelve todo esto automáticamente:**
* 🔧 **Parcheo ELF Nativo:** Reasigna el intérprete a `$PREFIX/glibc/lib/ld-linux-aarch64.so.1` y define el RPATH a las librerías glibc vía `grun` o `patchelf`.
* 🛡️ **Wrapper con Auto-Reparación:** El lanzador (`~/.local/bin/jcode`) detecta dinámicamente si una actualización sobreescribió el binario, parchándolo en milisegundos de forma transparente o ejecutándolo con fallback seguro.
* ⚡ **Optimización TUI para Termux:** Previene colapsos gráficos en `~/.jcode/config.toml`, bloqueando animaciones en idle y ajustando el redibujado a 10–12 FPS con scrolling táctil fluido.
* 🛰️ **Integración P2P con Walkie-Termux:** Acceso directo a chats colaborativos y agentes de IA autónomos descentralizados desde el terminal o navegador web local.

---

## 🚀 Instalación Rápida

### 1. Preparar dependencias del sistema en Termux
Asegúrate de contar con el entorno glibc y herramientas esenciales:

```bash
pkg update && pkg install git nodejs termux-glibc glibc-runner patchelf -y
```

### 2. Clonar e iniciar el Configurador Táctico

```bash
# Clonar el repositorio
git clone https://github.com/kuromi04/jcodeTermux.git

# Entrar al directorio
cd jcodeTermux

# Dar permisos de ejecución e iniciar el menú
chmod +x setup.sh
./setup.sh
```

---

## 🛠️ El Configurador Interactivo (`setup.sh`)

Al ejecutar `./setup.sh`, dispondrás de un menú táctico interactivo con 8 opciones optimizadas:

```text
======================================================================
         __                 __  ______                                
        / /____  ____  ____/ / /_  __/___  ________ ___  __  ___  __  
   __  / / ___/ / __ \/ __  /   / / / _  \/ ___/ __ `__ \/ / / / |/_/  
  / /_/ / /__  / /_/ / /_/ /   / / /  __/ /   / / / / / / /_/ />  <    
  \____/\___/  \____/\__,_/   /_/  \___/_/   /_/ /_/ /_/\__,_/_/|_|    
                                                                      
     Tactical JCode & Walkie Installer & Configurator for Termux       
======================================================================
 Soporte: JCode & Walkie-Termux | Sponsor: Ivam3 | Estado: Termux-Optimized
----------------------------------------------------------------------

 1) Instalar / Reinstalar JCode (Termux Patch)
 2) Optimizar Pantalla y Animaciones de JCode
 3) Administrar Servidor Daemon JCode
 4) Instalar / Reinstalar Walkie-Termux (P2P Client)
 5) Ejecutar Walkie-Termux (Chat, Agente o Web UI)
 6) Diagnóstico de Sistema y Autenticación
 7) Desinstalar Todo (JCode & Walkie)
 8) Salir

 Elige una opción [1-8]: 
```

### Opciones explicadas:
* **Opción 1 (Instalar JCode):** Descarga la versión oficial, re-enlaza el ELF a glibc, crea el launcher auto-reparable en `~/.local/bin/jcode` y verifica su funcionamiento.
* **Opción 2 (Optimizar Visuales):** Configura `~/.jcode/config.toml` con parámetros de baja latencia y alta estabilidad para pantallas táctiles.
* **Opción 3 (Servidor Daemon):** Inicia, detiene o reinicia el daemon en background de JCode para persistencia de sesiones.
* **Opción 4 (Instalar Walkie):** Clona e instala Walkie-Termux de forma global, aplicando `termux-fix-shebang`.
* **Opción 5 (Ejecutar Walkie):** Lanza chats P2P, agentes autónomos (Codex/Claude) o levanta el Web UI en `http://127.0.0.1:3000`.
* **Opción 6 (Diagnóstico):** Comprueba el estado del binario, el daemon, el entorno glibc y la autenticación activa.
* **Opción 7 (Desinstalar):** Limpieza completa de binarios, configuraciones y cachés.

---

## ⚙️ Optimización Visual Aplicada a JCode

El asistente aplica los siguientes parámetros en `~/.jcode/config.toml`:

```toml
[display]
idle_animation = false
prompt_entry_animation = false
disabled_animations = []
animation_fps = 10
redraw_fps = 12
mouse_capture = false
emoji = true
```

* **`idle_animation = false`**: Detiene animaciones continuas en reposo, evitando que el texto del chat desaparezca o parpadee.
* **`prompt_entry_animation = false`**: Evita la corrupción y el desfasamiento del cursor al tipear en teclados táctiles.
* **`disabled_animations = []`**: Mantiene la animación estética inicial de presentación (splash screen).
* **`animation_fps = 10` & `redraw_fps = 12`**: Modera el consumo de CPU y la temperatura del móvil, asegurando fluidez en los buffers de Termux.
* **`mouse_capture = false`**: Habilita el scroll y copiado nativo con gestos táctiles de Android.

---

## 🛰️ Walkie-Termux (Orquestación P2P)

**Walkie-Termux** te permite establecer canales P2P descentralizados sin servidores centrales desde tu smartphone:

* **Chat de Terminal P2P:**
  ```bash
  walkie chat canal-de-pruebas
  ```
* **Escucha del Agente de IA (Codex o Claude):**
  ```bash
  walkie agent canal-de-pruebas --cli codex --name "Asistente" --prompt "Eres un asistente servicial de Termux."
  ```
* **Panel de Control Web UI:**
  ```bash
  walkie web
  ```
  *Abre tu navegador en `http://127.0.0.1:3000/?v=4`.*

---

## 📊 Comparativa de Eficiencia Oficial (JCode)

JCode ofrece tiempos de arranque y consumos de RAM drásticamente inferiores frente a otros agentes de código:

### 1. Consumo de Memoria por Sesión (PSS)
| Herramienta | Consumo de RAM (Extra PSS) | Comparativa |
| :--- | :--- | :--- |
| **jcode (local embedding off)** | **~9.9 MB** | **Línea Base (Mínimo)** |
| **jcode (completo)** | **~10.4 MB** | 1.1× más RAM |
| Codex CLI | ~21.6 MB | 2.2× más RAM |
| pi | ~76.5 MB | 7.7× más RAM |
| Antigravity CLI | ~86.4 MB | 8.7× más RAM |
| Cursor Agent | ~157.5 MB | 15.9× más RAM |
| GitHub Copilot CLI | ~158.1 MB | 16.0× más RAM |
| Claude Code | ~212.7 MB | 21.5× más RAM |
| OpenCode | ~318.4 MB | 32.2× más RAM |

### 2. Tiempo de Espera para Primer Input (Latencia)
| Herramienta | Tiempo de Respuesta | Retraso Comparado |
| :--- | :--- | :--- |
| **jcode** | **48.7 ms** | **Instantáneo (Línea Base)** |
| Antigravity CLI | 383.7 ms | 7.9× más lento |
| pi | 596.4 ms | 12.2× más lento |
| Codex CLI | 905.8 ms | 18.6× más lento |
| OpenCode | 1047.9 ms | 21.5× más lento |
| Claude Code | 3512.8 ms | 72.2× más lento |

---

## 📚 Documentación Técnica & Skills

Para conocer los detalles profundos de ingeniería sobre el cargador dinámico, variables críticas (`GLIBC_TUNABLES`, `LD_PRELOAD`, `LD_LIBRARY_PATH`) y solución de problemas, revisa la **[Guía de Adaptación Técnica](docs/skills.md)**.

---

## 💖 Créditos y Agradecimientos

* **[kuromi04](https://github.com/kuromi04) (Autor):** Creador del repositorio, lógica de auto-reparación dinámica, automatización de setup y optimizaciones visuales para Android.
* **[Ivam3](https://github.com/ivam3):** Creador y mantenedor de repositorios de paquetes de compatibilidad y `termux-glibc` que hacen posible correr binarios Linux modernos en Termux.
* **Comunidad de Termux:** Por mantener el ecosistema Linux nativo más potente para Android.

---

## 📄 Licencia

Este proyecto está bajo la Licencia MIT. Consulta el archivo [LICENSE](LICENSE) para más detalles.
