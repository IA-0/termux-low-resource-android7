#!/data/data/com.termux/files/usr/bin/bash
set -u

DEV=0
if [ "${1:-}" = "--dev" ]; then DEV=1; fi

PREFIX="${PREFIX:-/data/data/com.termux/files/usr}"
HOME_DIR="${HOME:-/data/data/com.termux/files/home}"
BASHRC="$HOME_DIR/.bashrc"
MARKER="# TERMUX_LOW_RESOURCE_SETUP"

say() { printf '\n==> %s\n' "$1"; }

say "Actualizando paquetes"
pkg update -y || exit 1

BASE_PACKAGES="git curl wget nano tmux jq tree unzip zip htop procps openssh python"
if [ "$DEV" -eq 1 ]; then BASE_PACKAGES="$BASE_PACKAGES nodejs-lts"; fi

say "Instalando herramientas"
pkg install -y $BASE_PACKAGES || exit 1

say "Solicitando acceso al almacenamiento"
termux-setup-storage || true

say "Creando estructura de trabajo"
mkdir -p "$HOME_DIR"/{proyectos,scripts,descargas,documentos,respaldos,logs,proyectos/web,proyectos/python,proyectos/node}

if [ -f "$BASHRC" ]; then
  cp "$BASHRC" "$BASHRC.respaldo-$(date +%Y%m%d-%H%M%S)"
fi
touch "$BASHRC"

if ! grep -qF "$MARKER" "$BASHRC"; then
cat >> "$BASHRC" <<'EOF'

# TERMUX_LOW_RESOURCE_SETUP
export HISTSIZE=1000
export HISTFILESIZE=2000
export HISTCONTROL=ignoredups:erasedups
shopt -s histappend
export PS1='\[\033[1;36m\]\u@\h\[\033[0m\]:\[\033[1;33m\]\w\[\033[0m\]\$ '
alias ll='ls -lah --color=auto'
alias la='ls -A'
alias c='clear'
alias casa='cd ~'
alias proyectos='cd ~/proyectos'
alias memoria='free -h'
alias espacio='df -h "$HOME"'
alias fecha='date "+%d-%m-%Y %H:%M:%S"'
EOF
fi

cat > "$HOME_DIR/scripts/estado" <<'EOF'
#!/data/data/com.termux/files/usr/bin/bash
printf 'Fecha: '; date '+%d-%m-%Y %H:%M:%S'
echo; echo 'Memoria:'; free -h
echo; echo 'Almacenamiento:'; df -h "$HOME"
echo; echo 'Procesos:'; ps -A | head -n 12
echo; echo 'Uptime:'; uptime
EOF

cat > "$HOME_DIR/scripts/respaldo" <<'EOF'
#!/data/data/com.termux/files/usr/bin/bash
DESTINO="$HOME/storage/shared/Termux-respaldos"
FECHA=$(date '+%Y%m%d-%H%M%S')
mkdir -p "$DESTINO"
ARCHIVO="$DESTINO/termux-home-$FECHA.tar.gz"
tar -czf "$ARCHIVO" --exclude='./storage' --exclude='./.cache' --exclude='./tmp' -C "$HOME" . && echo "Respaldo creado: $ARCHIVO"
EOF

cat > "$HOME_DIR/scripts/web-iniciar" <<'EOF'
#!/data/data/com.termux/files/usr/bin/bash
PIDFILE="$HOME/.servidor-web.pid"; LOG="$HOME/logs/servidor-web.log"; PORT=8080
if [ -f "$PIDFILE" ] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then echo "Web activo en $PORT"; exit 0; fi
mkdir -p "$HOME/proyectos/web" "$HOME/logs"; cd "$HOME/proyectos/web" || exit 1
nohup python -m http.server "$PORT" --bind 0.0.0.0 >>"$LOG" 2>&1 & echo $! >"$PIDFILE"; sleep 1
kill -0 "$(cat "$PIDFILE")" 2>/dev/null && echo "Web activo: http://127.0.0.1:$PORT" || { rm -f "$PIDFILE"; exit 1; }
EOF

cat > "$HOME_DIR/scripts/web-estado" <<'EOF'
#!/data/data/com.termux/files/usr/bin/bash
PIDFILE="$HOME/.servidor-web.pid"
if [ -f "$PIDFILE" ] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then echo "Servidor web ACTIVO (8080)"; else echo "Servidor web INACTIVO"; fi
EOF

cat > "$HOME_DIR/scripts/web-detener" <<'EOF'
#!/data/data/com.termux/files/usr/bin/bash
[ -f "$HOME/.servidor-web.pid" ] && kill "$(cat "$HOME/.servidor-web.pid")" 2>/dev/null || true
rm -f "$HOME/.servidor-web.pid"; echo "Servidor web detenido"
EOF

cat > "$HOME_DIR/scripts/archivos-iniciar" <<'EOF'
#!/data/data/com.termux/files/usr/bin/bash
PIDFILE="$HOME/.servidor-archivos.pid"; LOG="$HOME/logs/servidor-archivos.log"; PORT=8081
if [ -f "$PIDFILE" ] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then echo "Archivos activo en $PORT"; exit 0; fi
mkdir -p "$HOME/storage/shared" "$HOME/logs"; cd "$HOME/storage/shared" || exit 1
nohup python -m http.server "$PORT" --bind 0.0.0.0 >>"$LOG" 2>&1 & echo $! >"$PIDFILE"; sleep 1
echo "Archivos activo: http://127.0.0.1:$PORT"
EOF

cat > "$HOME_DIR/scripts/archivos-estado" <<'EOF'
#!/data/data/com.termux/files/usr/bin/bash
PIDFILE="$HOME/.servidor-archivos.pid"
if [ -f "$PIDFILE" ] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then echo "Servidor de archivos ACTIVO (8081)"; else echo "Servidor de archivos INACTIVO"; fi
EOF

cat > "$HOME_DIR/scripts/archivos-detener" <<'EOF'
#!/data/data/com.termux/files/usr/bin/bash
[ -f "$HOME/.servidor-archivos.pid" ] && kill "$(cat "$HOME/.servidor-archivos.pid")" 2>/dev/null || true
rm -f "$HOME/.servidor-archivos.pid"; echo "Servidor de archivos detenido"
EOF

cat > "$HOME_DIR/scripts/ssh-iniciar" <<'EOF'
#!/data/data/com.termux/files/usr/bin/bash
mkdir -p "$HOME/.ssh"; chmod 700 "$HOME/.ssh"; ssh-keygen -A >/dev/null 2>&1 || true
sshd && echo "SSH activo en el puerto 8022 para $(whoami)"
EOF

cat > "$HOME_DIR/scripts/ssh-estado" <<'EOF'
#!/data/data/com.termux/files/usr/bin/bash
pgrep -x sshd >/dev/null 2>&1 && echo 'SSH ACTIVO (8022)' || echo 'SSH INACTIVO'
EOF

cat > "$HOME_DIR/scripts/ssh-detener" <<'EOF'
#!/data/data/com.termux/files/usr/bin/bash
pkill -x sshd 2>/dev/null || true; echo 'SSH detenido'
EOF

for f in "$HOME_DIR"/scripts/{estado,respaldo,web-iniciar,web-estado,web-detener,archivos-iniciar,archivos-estado,archivos-detener,ssh-iniciar,ssh-estado,ssh-detener}; do chmod +x "$f"; done

if ! grep -qF "alias estado=" "$BASHRC"; then
cat >> "$BASHRC" <<'EOF'
alias estado='bash ~/scripts/estado'
alias respaldo='bash ~/scripts/respaldo'
alias web-iniciar='bash ~/scripts/web-iniciar'
alias web-estado='bash ~/scripts/web-estado'
alias web-detener='bash ~/scripts/web-detener'
alias archivos-iniciar='bash ~/scripts/archivos-iniciar'
alias archivos-estado='bash ~/scripts/archivos-estado'
alias archivos-detener='bash ~/scripts/archivos-detener'
alias ssh-iniciar='bash ~/scripts/ssh-iniciar'
alias ssh-estado='bash ~/scripts/ssh-estado'
alias ssh-detener='bash ~/scripts/ssh-detener'
EOF
fi

. "$BASHRC" 2>/dev/null || true
say "Configuración terminada"
echo "Base lista. Para desarrollo completo: bash bootstrap-termux.sh --dev"
echo "Comandos: estado, respaldo, web-iniciar, archivos-iniciar, ssh-iniciar"
