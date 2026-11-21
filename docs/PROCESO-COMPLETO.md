# Proceso completo de configuración

Esta guía resume una configuración real de Termux en una Huawei MediaPad T3 KOB-W09 con Android 7.0, ARM64, 1.8 GiB de RAM y almacenamiento interno limitado.

## 1. Diagnóstico inicial

Comprobar la instalación sin modificar Android:

```bash
termux-info
df -h
free -h
dpkg --audit
```

Si `dpkg --audit` no imprime nada, no hay paquetes incompletos. Las particiones `/system`, `/vendor`, `/product` y `/cust` son de Android: no limpiarlas ni modificarlas desde Termux.

## 2. Instalación reproducible

Usar el instalador de este repositorio:

```bash
pkg install -y curl
curl -L https://raw.githubusercontent.com/IA-0/termux-low-resource-android7/main/scripts/bootstrap-termux.sh -o bootstrap-termux.sh
bash bootstrap-termux.sh --dev
```

El perfil `--dev` añade Node.js LTS y npm. Sin `--dev`, se instala la base con Python y herramientas CLI.

## 3. Permiso de almacenamiento

Cuando Android muestre el permiso, pulsar **Permitir**. Termux crea enlaces en `~/storage`; el almacenamiento compartido se usa mediante `~/storage/shared`.

## 4. Organización

La instalación crea:

```text
~/proyectos/web
~/proyectos/python
~/proyectos/node
~/scripts
~/descargas
~/documentos
~/respaldos
~/logs
```

## 5. Primer proyecto web

Crear o editar `~/proyectos/web/index.html`:

```bash
cd ~/proyectos/web
nano index.html
web-iniciar
```

Abrir en el navegador de la misma tablet:

```text
http://127.0.0.1:8080
```

Comprobar o detener:

```bash
web-estado
web-detener
```

## 6. Trabajo con Python y Node

Python:

```bash
mkdir -p ~/proyectos/python/mi-proyecto
cd ~/proyectos/python/mi-proyecto
nano main.py
python main.py
```

Node:

```bash
mkdir -p ~/proyectos/node/mi-proyecto
cd ~/proyectos/node/mi-proyecto
npm init -y
nano main.js
node main.js
```

## 7. Sesiones resistentes

Android puede suspender o cerrar procesos. Para trabajo prolongado:

```bash
tmux new -s trabajo
```

Desconectar sin cerrar:

```text
Ctrl+B, D
```

Volver:

```bash
tmux attach -t trabajo
```

También conviene desactivar la optimización de batería para Termux desde Ajustes si el sistema mata sus procesos.

## 8. Acceso desde la red local

SSH se ejecuta en el puerto `8022`:

```bash
ssh-iniciar
ssh-estado
```

El servidor de archivos usa el puerto `8081` y muestra `~/storage/shared`:

```bash
archivos-iniciar
# http://IP-DE-LA-TABLET:8081
archivos-detener
```

En Android 7 algunas ROM no permiten descubrir la IP desde Termux. Consultarla en **Ajustes > Wi-Fi > red conectada**. Solo usar estos servicios en una red de confianza.

## 9. Respaldos

Antes de cambios importantes:

```bash
respaldo
```

El archivo `.tar.gz` se guarda en `~/storage/shared/Termux-respaldos`. No incluye el enlace `storage` ni cachés para evitar copias recursivas.

## 10. Asistente de mantenimiento

El instalador deja comandos simples para el mantenimiento:

```bash
estado
memoria
espacio
respaldo
```

## 11. Límites esperables

Esta plataforma es excelente para aprendizaje, páginas ligeras, scripts, APIs pequeñas, Git y pruebas locales. No es adecuada para Android Studio, Docker, escritorios gráficos completos, bases de datos grandes, compilaciones móviles pesadas o producción expuesta a Internet.
