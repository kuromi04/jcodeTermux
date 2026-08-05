# jcodeTermux 📱⚡

<p align="center">
  <img src="banner.jpg" alt="jcodeTermux Banner" width="100%">
</p>

[![Platform: Termux](https://img.shields.io/badge/Platform-Termux-green.svg?style=for-the-badge&logo=android)](https://termux.dev)
[![Ecosystem: i-HakLab](https://img.shields.io/badge/Ecosystem-i--HakLab-blue.svg?style=for-the-badge)](https://github.com/ivam3)
[![Glibc Wrapper: Optimized](https://img.shields.io/badge/Glibc%20Wrapper-Optimized-magenta.svg?style=for-the-badge)](docs/skills.md)
[![Status: Production-Ready](https://img.shields.io/badge/Status-Production--Ready-brightgreen.svg?style=for-the-badge)](#)

Optimización, instalación y entorno automatizado para ejecutar **JCode** (el arnés de desarrollo y agente de IA ultraligero escrito en Rust) dentro de **Android** vía **Termux** de forma estable, fluida y sin fallas visuales.

---

## ⚠️ Requisito Crítico: Descarga de Termux

> [!IMPORTANT]
> **¡NO USES la versión de Google Play Store!** La versión de Termux en Google Play está descontinuada y desactualizada, lo que causará fallos graves en los repositorios de paquetes e incompatibilidades con el entorno `glibc`.

Para que `jcodeTermux` funcione correctamente, debes descargar Termux únicamente de sus fuentes oficiales activas:
*   📥 **[Descargar Termux desde F-Droid](https://f-droid.org/packages/com.termux/)**(Recomendado)
*   📥 **[Descargar Termux desde GitHub Releases](https://github.com/termux/termux-app/releases)**

---

## 🌟 ¿Por qué recomendamos JCode? (Nuestra Recomendación)

**JCode** destaca sobre otros arneses de IA tradicionales debido a su diseño de alto rendimiento centrado en terminales:
*   **Velocidad y Fluidez Excepcional:** Escrito en **Rust**, inicia en milisegundos y consume una fracción de la memoria RAM que requerirían herramientas pesadas basadas en Node.js o Python.
*   **Multitud de Modelos y Proveedores:** Soporta configuración inmediata y cambio en caliente (mediante `/model`) de casi cualquier proveedor líder de LLM en el mercado:
    *   *Comerciales:* OpenAI (ChatGPT Pro), Claude (Anthropic Max), Google Gemini.
    *   *Agregadores y Nube:* OpenRouter, Deepinfra, TogetherAI, Fireworks, Groq.
    *   *Locales (Sin Conexión):* LM Studio, Ollama, y servidores compatibles con OpenAI.
*   **Pensado para Power Users:** Su interfaz de terminal interactiva (TUI) te permite codificar en parejas, administrar archivos y ejecutar comandos sin perder el enfoque ni abandonar la consola.

---

## 📊 Comparativa de Eficiencia (jcode.sh)

A continuación se presenta un resumen de las métricas oficiales de rendimiento de JCode en comparación con otras herramientas CLI de agentes de IA y copitotos de código:

### 1. Consumo de Memoria por Sesión Adicional (PSS)
*Mide la cantidad de memoria RAM adicional requerida por cada sesión nueva.*

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

### 2. Tiempo de Espera para el Primer Input
*Tiempo que transcurre desde el comando de inicio hasta que el usuario puede escribir en pantalla.*

| Herramienta | Tiempo de Respuesta | Retraso Comparado |
| :--- | :--- | :--- |
| **jcode** | **48.7 ms** | **Instantáneo (Línea Base)** |
| Antigravity CLI | 383.7 ms | 7.9× más lento |
| pi | 596.4 ms | 12.2× más lento |
| Codex CLI | 905.8 ms | 18.6× más lento |
| OpenCode | 1047.9 ms | 21.5× más lento |
| GitHub Copilot CLI | 1583.4 ms | 32.5× más lento |
| Cursor Agent | 1978.7 ms | 40.6× más lento |
| Claude Code | 3512.8 ms | 72.2× más lento |

### 3. Tiempo para el Renderizado del Primer Frame
*Tiempo necesario para que la interfaz TUI realice el primer dibujado completo en pantalla.*

| Herramienta | Tiempo de Renderizado | Retraso Comparado |
| :--- | :--- | :--- |
| **jcode** | **14.0 ms** | **Línea Base** |
| Antigravity CLI | 383.5 ms | 27.4× más lento |
| pi | 590.7 ms | 42.2× más lento |
| Codex CLI | 882.8 ms | 63.1× más lento |
| OpenCode | 1035.9 ms | 74.0× más lento |
| GitHub Copilot CLI | 1518.6 ms | 108.5× más lento |
| Cursor Agent | 1949.7 ms | 139.3× más lento |
| Claude Code | 3436.9 ms | 245.5× más lento |

---

## 📖 ¿Por qué es necesario jcodeTermux?

El binario oficial de **JCode** está compilado nativamente para arquitecturas GNU/Linux estándar enlazadas contra **glibc**. Al intentar ejecutarlo en Android/Termux, ocurren los siguientes problemas:
1. **Incompatibilidad de libc:** Android utiliza **Bionic libc**, lo que causa fallos de enlazado dinámico.
2. **Shebangs Corruptos:** El instalador genera wrappers apuntando a `#!/usr/bin/env bash`, ruta que no existe de forma nativa en Termux.
3. **TUI Glitch (Inestabilidad Visual):** Los terminales emulados en móviles colapsan ante actualizaciones continuas de alta frecuencia (como las animaciones de carga e idle a 25+ FPS), ocultando el texto del chat.

**jcodeTermux** soluciona esto aplicando las reglas de la base de conocimiento de **Termux-Oracle**.

---

## 🛠️ El Configurador Interactivo (`setup.sh`)

El repositorio incluye un script con interfaz de menú interactivo en el terminal:

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
 5) Desinstalar JCode y Borrar Todo
 6) Salir

 Elige una opción [1-6]: 
```

---

## 🚀 Instalación Rápida

Ejecuta la siguiente secuencia de comandos en tu terminal de Termux:

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

El asistente modifica automáticamente tu archivo `~/.jcode/config.toml` con parámetros ajustados para Termux:

*   **`idle_animation = false`**: Detiene las animaciones continuas en reposo, garantizando que el texto del chat permanezca visible.
*   **`prompt_entry_animation = false`**: Evita la corrupción y el desfase del cursor al escribir prompts.
*   **`disabled_animations = []`**: Mantiene activa la animación de presentación inicial (splash screen) en el arranque.
*   **`animation_fps = 10` y `redraw_fps = 12`**: Modera el tráfico de redibujados, logrando fluidez gráfica y protegiendo la batería del móvil.
*   **`mouse_capture = false`**: Permite realizar scroll y copia de texto nativa táctil de Android sin bloqueos.

---

## 📚 Documentación Técnica & Skills (Termux-Oracle)

Para profundizar en la ingeniería y políticas de adaptación de binarios y wrappers, consulta nuestra [Guía Experta de Adaptación](docs/skills.md) basada en **Termux-Oracle**, que detalla:
*   Mapeo de intérpretes dinámicos de ELF con `patchelf`.
*   Ajustes y resolución de variables críticas (`GLIBC_TUNABLES`, `LD_PRELOAD`).
*   Troubleshooting y solución de errores en Termux.

---

## 💖 Créditos y Agradecimientos

Este repositorio y sus parches no serían posibles sin el soporte técnico y aportes de la comunidad de desarrollo en Android:

*   **[Ivam3](https://github.com/ivam3) (Sponsor):** Diseñador de la suite **i-HakLab** y creador de Termux-Oracle, mantenedor de repositorios de paquetes optimizados que suministran glibc base para Termux.
*   **Comunidad i-HakLab / AI-HakLab:** Por testear los límites de los scripts de IA en entornos móviles y reportar fallas comunes.
*   **[kuromi04](https://github.com/kuromi04) (Autor):** Creador del repositorio y desarrollador de los scripts de adaptación, automatizaciones de configuración visual y el menú táctico de instalación/desinstalación para Termux.

---

## 📄 Licencia

Este proyecto está bajo la Licencia MIT. Consulta el archivo `LICENSE` para más detalles.
