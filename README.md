# Termux Low Resource Android 7

Configuración base, ligera y reproducible de Termux para convertir smartphones y tablets antiguos en estaciones portátiles de programación.

Probado en una Huawei MediaPad T3 KOB-W09 con Android 7.0, ARM64, 1.8 GiB de RAM y Termux 0.118.3 desde F-Droid. El objetivo es ofrecer una base útil para aprender, crear páginas web, ejecutar scripts y probar servicios localmente sin instalar un escritorio pesado.

## Qué instala

- Git, Curl, Wget, Nano, Tmux, JQ, Tree, Zip/Unzip, Htop, Procps, OpenSSH y Python.
- Node.js LTS y npm con el perfil opcional `--dev`.
- Carpetas `~/proyectos`, `~/scripts`, `~/documentos`, `~/descargas`, `~/respaldos` y `~/logs`.
- Aliases y comandos para estado, respaldos, servidor web local, servidor de archivos y SSH.
- Estructura segura para repetir la instalación sin duplicar configuración.

## Instalación rápida

En Termux actualizado desde F-Droid:

```bash
pkg install -y curl
curl -L https://raw.githubusercontent.com/IA-0/termux-low-resource-android7/main/scripts-bootstrap-termux.sh -o bootstrap-termux.sh
bash bootstrap-termux.sh --dev
```

Hasta que el repositorio tenga su URL definitiva, también se puede descargar el script desde la pestaña de archivos de GitHub o copiarlo manualmente a Termux.

El instalador pide permiso de almacenamiento. Pulsa **Permitir** cuando Android lo solicite.

## Uso diario

```bash
estado
cd ~/proyectos/web
nano index.html
web-iniciar
# abrir http://127.0.0.1:8080 en el navegador
respaldo
```

Para mantener procesos abiertos mientras se cambia de aplicación:

```bash
tmux new -s trabajo
# trabajar dentro de tmux
# Ctrl+B y después D para desconectar sin detenerlo
tmux attach -t trabajo
```

## Servicios locales

| Servicio | Comando | Dirección local |
|---|---|---|
| Web | `web-iniciar` | `http://127.0.0.1:8080` |
| Archivos compartidos | `archivos-iniciar` | `http://127.0.0.1:8081` |
| SSH | `ssh-iniciar` | puerto `8022` |

Para acceder desde otro dispositivo de la misma Wi-Fi, consulta la IP en **Ajustes > Wi-Fi > red conectada**. Termux en algunas ROM antiguas no puede descubrirla automáticamente.

Ejemplos:

```text
http://IP-DE-LA-TABLET:8080
http://IP-DE-LA-TABLET:8081
ssh -p 8022 u0_a96@IP-DE-LA-TABLET
```

El servidor de archivos expone `~/storage/shared` sin autenticación: úsalo solo en una red de confianza y detenlo cuando no sea necesario.

## Respaldos

```bash
respaldo
```

Los respaldos se guardan en `~/storage/shared/Termux-respaldos`. El archivo excluye `storage`, cachés y temporales para evitar copias recursivas e innecesarias.

## Limitaciones y seguridad

- No modificar `/system`, `/vendor`, `/product` ni otras particiones de Android.
- No exponer HTTP o SSH directamente a Internet.
- Android puede matar procesos en segundo plano; mantener Termux abierto y revisar la optimización de batería.
- Evitar Docker, escritorios gráficos, bases de datos pesadas y compilaciones grandes en equipos con 1–2 GB de RAM.
- `Termux:API` es opcional y debe instalarse desde la misma fuente que Termux si se necesitan datos de batería o sensores.
- El mensaje `No mirror or mirror group selected` puede ser solo un aviso: verificar que el mirror responda y que `pkg update` termine correctamente.

## Estructura

```text
scripts/bootstrap-termux.sh  # instalador idempotente
LICENSE                       # licencia MIT
README.md                     # guía para usuarios
```

## Contribuir

Se aceptan mejoras para Android antiguo, arquitecturas ARM, consumo de memoria, documentación y recuperación de errores. Probar siempre en un dispositivo no crítico y documentar la versión de Termux, Android y arquitectura.

## Licencia

MIT. Ver [LICENSE](LICENSE).
