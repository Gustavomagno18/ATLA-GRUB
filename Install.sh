#!/bin/bash

set -e

THEME_NAME="ATLA-GRUB"
THEME_DIR="/boot/grub/themes/$THEME_NAME"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 1. Verificar privilegios de root
if [ "$(id -u)" -ne 0 ]; then
    echo "Error: Este script debe ejecutarse como root." >&2
    exit 1
fi

# 2. Selección de resolución
echo "Selecciona la resolución de pantalla:"
echo "1) HD (1280x720-1366x768)"
echo "2) Full HD (1920x1080)"
echo "3) 2K (2560x1440)"
echo "4) 4K (3840x2160)"
read -rp "Ingresa tu opción [1-4]: " res_choice

case $res_choice in
    1) GFXMODE="1366x768x32,1280x720x32,auto" ;;
    2) GFXMODE="1920x1080x32,auto" ;;
    3) GFXMODE="2560x1440x32,auto" ;;
    4) GFXMODE="3840x2160x32,auto" ;;
    *)
        echo "Opción no válida. Se usará la resolución por defecto (1920x1080x32)."
        GFXMODE="1920x1080x32,auto"
        ;;
esac

# 3. Instalación de archivos del tema
echo "Instalando el tema de GRUB en $THEME_DIR..."
mkdir -p "$THEME_DIR"

# Copiar el contenido del directorio del script al directorio del tema
cp -r "$SCRIPT_DIR/." "$THEME_DIR/"

# Limpiar archivos de desarrollo e instaladores en el destino
rm -rf "$THEME_DIR/install.sh" "$THEME_DIR/.git" "$THEME_DIR/.gitignore" 2>/dev/null || true

# 4. Actualizar /etc/default/grub
echo "Configurando /etc/default/grub..."

# Limpiar entradas previas de GRUB_THEME y GRUB_GFXMODE
sed -i '/^[[:space:]]*#\?[[:space:]]*GRUB_THEME=/d' /etc/default/grub
sed -i '/^[[:space:]]*#\?[[:space:]]*GRUB_GFXMODE=/d' /etc/default/grub

# Añadir las nuevas configuraciones
{
    echo "GRUB_THEME=\"$THEME_DIR/theme.txt\""
    echo "GRUB_GFXMODE=\"$GFXMODE\""
} >> /etc/default/grub

# 5. Regenerar configuración de GRUB
echo "Actualizando la configuración de GRUB..."

if command -v update-grub &> /dev/null; then
    update-grub
elif [ -f /boot/grub/grub.cfg ]; then
    grub-mkconfig -o /boot/grub/grub.cfg
elif [ -f /boot/grub2/grub.cfg ]; then
    grub-mkconfig -o /boot/grub2/grub.cfg
else
    echo "Advertencia: No se encontró la ruta por defecto de grub.cfg. Ejecuta grub-mkconfig manualmente."
fi

echo "¡El tema $THEME_NAME se ha instalado correctamente con resolución $GFXMODE!"
