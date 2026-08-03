# Guía Experta de Adaptación y Skills: JCode en Termux

Esta guía documenta los conocimientos técnicos y habilidades necesarias para adaptar y solucionar problemas de **JCode** (y otros binarios nativos de alto rendimiento) dentro del entorno de Android usando **Termux**.

---

## 1. Comprendiendo el Entorno Android/Termux

Android se basa en el kernel de Linux, pero difiere significativamente de una distribución Linux de escritorio estándar:
- **Librería de C:** Android utiliza **Bionic libc** en lugar de GNU C Library (glibc).
- **Ruta de Intérprete:** Los binarios compilados para GNU/Linux estándar buscan cargadores dinámicos como `/lib/ld-linux-aarch64.so.1` o `/lib64/ld-linux-x86-64.so.2`, los cuales no existen en Android de forma nativa.
- **Shebangs:** En Termux, los scripts de shell no pueden usar shebangs rígidos como `#!/usr/bin/env bash` o `#!/bin/sh` porque estas rutas absolutas no existen. Las rutas reales comienzan con el prefijo del usuario de Termux: `#/data/data/com.termux/files/usr/...`.

---

## 2. El Patrón del Wrapper GLIBC

Para poder ejecutar `jcode` (que se compila contra glibc y se enlaza dinámicamente) sin compilar desde el código fuente nativo de Android:

1. **Intérprete Parchado:** El instalador usa herramientas como `patchelf` para alterar el intérprete ELF dentro del binario de JCode de modo que apunte a la ruta glibc adaptada por el ecosistema de Termux (`/data/data/com.termux/files/usr/glibc/lib/ld-linux-aarch64.so.1`).
2. **Wrapper de Entorno:** Se utiliza un wrapper en Bash (`~/.local/bin/jcode`) para limpiar y configurar el entorno de ejecución antes de lanzar el binario. Esto evita conflictos de carga de librerías.

### Estructura Correcta del Wrapper:
```bash
#!/data/data/com.termux/files/usr/bin/bash
# Limpiar variables nativas de Termux que interfieren con glibc
unset LD_PRELOAD
unset LD_LIBRARY_PATH

# Evitar problemas de ordenamiento dinámico de librerías en ejecutores heredados
export GLIBC_TUNABLES="glibc.rtld.dynamic_sort=1"

# Ejecutar el binario real pasando todos los argumentos
exec "/data/data/com.termux/files/home/.jcode/builds/stable/jcode" "$@"
```

---

## 3. Optimización Visual (Evitar Parpadeo y Corrupción de Letras)

Los terminales de Android como Termux pueden experimentar cuellos de botella de renderizado y fallos al procesar secuencias de escape ANSI complejas a altas tasas de fotogramas (FPS).

### Síntomas Comunes:
- Desaparición aleatoria de líneas de texto de chat.
- Superposición y corrupción de caracteres del Prompt.
- Bloqueo y lentitud al intentar hacer scroll vertical.

### Solución en `config.toml` (`[display]`):
- **`idle_animation = false`**: Desactiva las animaciones decorativas de fondo mientras el TUI está en reposo. Esto previene ciclos innecesarios de redibujado de pantalla.
- **`prompt_entry_animation = false`**: Desactiva transiciones animadas dentro de la caja de comandos, garantizando que los caracteres escritos se muestren estables y en su posición correcta.
- **`disabled_animations = []`**: Mantenerlo vacío asegura que la presentación inicial o logo splash (que se ejecuta una sola vez al inicio) se dibuje correctamente, pero sin afectar la sesión de chat posterior.
- **FPS Reducidos (`animation_fps = 10` y `redraw_fps = 12`)**: Alivia el buffer del terminal. El rendimiento se mantiene óptimo y reduce drásticamente el consumo de batería en dispositivos móviles.

---

## 4. Troubleshooting Frecuente

### Error: `bad interpreter: No such file or directory`
**Causa:** El wrapper de JCode fue instalado con el shebang estándar `#!/usr/bin/env bash` o el ejecutable del wrapper apunta a una ruta incorrecta.
**Solución:** Modifica la primera línea de `~/.local/bin/jcode` a `#!/data/data/com.termux/files/usr/bin/bash` o ejecuta el asistente de `jcodeTermux`.

### Error: `No tokens/providers left` o error de API compatible con OpenAI
**Causa:** El daemon no se ha iniciado con las credenciales cargadas o el backend local de LLM no está respondiendo.
**Solución:** Verifica que el token esté correctamente configurado con `jcode auth status` y reinicia el servidor daemon.
