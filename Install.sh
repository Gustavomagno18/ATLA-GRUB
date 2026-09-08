#!/bin/bash

set -e

THEME_NAME="ATLA-GRUB"
THEME_DIR="/boot/grub/themes/$THEME_NAME"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# -----------------------------------------------------------------------------
# 0. Selección de Idioma / Language Selection
# -----------------------------------------------------------------------------
echo "Select language / Selecciona el idioma:"
echo "1) Español"
echo "2) English"
read -rp "Option / Opción [1-2]: " lang_choice

case $lang_choice in
    2)
        MSG_ROOT_ERR="Error: This script must be run as root."
        MSG_RES_TITLE="Select screen resolution:"
        MSG_RES_PROMPT="Enter your choice [1-4]: "
        MSG_RES_INVALID="Invalid option. Using default resolution (1920x1080x32)."
        MSG_BG_TITLE="Select background wallpaper:"
        MSG_BG_1="1) Avatar gang wallpaper"
        MSG_BG_2="2) Temple of Air"
        MSG_BG_3="3) Avatar Island"
        MSG_BG_4="4) Tui and La"
        MSG_BG_5="5) Avatar Korra"
        MSG_BG_6="6) Avatar Wang"
        MSG_BG_PROMPT="Enter your choice [1-6]: "
        MSG_BG_INVALID="Invalid option. Using default wallpaper."
        MSG_BG_WARN="Warning: $SELECTED_BG not found, keeping original background."
        MSG_INSTALLING="Installing GRUB theme to $THEME_DIR..."
        MSG_CONFIGURING="Configuring /etc/default/grub..."
        MSG_UPDATING="Updating GRUB configuration..."
        MSG_GRUB_WARN="Warning: Default grub.cfg path not found. Run grub-mkconfig manually."
        MSG_SUCCESS="The $THEME_NAME theme was successfully installed!"
        ;;
    *)
        MSG_ROOT_ERR="Error: Este script debe ejecutarse como root."
        MSG_RES_TITLE="Selecciona la resolución de pantalla:"
        MSG_RES_PROMPT="Ingresa tu opción [1-4]: "
        MSG_RES_INVALID="Opción no válida. Se usará la resolución por defecto (1920x1080x32)."
        MSG_BG_TITLE="Selecciona el fondo de pantalla:"
        MSG_BG_1="1) Equipo Avatar"
        MSG_BG_2="2) Templo del Aire"
        MSG_BG_3="3) Isla del Avatar"
        MSG_BG_4="4) Tui y La"
        MSG_BG_5="5) Avatar Korra"
        MSG_BG_6="6) Avatar Wang"
        MSG_BG_PROMPT="Ingresa tu opción [1-6]: "
        MSG_BG_INVALID="Opción no válida. Se usará el fondo por defecto."
        MSG_BG_WARN="Advertencia: No se encontró $SELECTED_BG, se mantendrá el fondo original."
        MSG_INSTALLING="Instalando el tema de GRUB en $THEME_DIR..."
        MSG_CONFIGURING="Configurando /etc/default/grub..."
        MSG_UPDATING="Actualizando la configuración de GRUB..."
        MSG_GRUB_WARN="Advertencia: No se encontró la ruta por defecto de grub.cfg. Ejecuta grub-mkconfig manualmente."
        MSG_SUCCESS="¡El tema $THEME_NAME se ha instalado correctamente!"
        ;;
esac

# -----------------------------------------------------------------------------
# 1. Verificar privilegios de root
# -----------------------------------------------------------------------------
if [ "$(id -u)" -ne 0 ]; then
    echo "$MSG_ROOT_ERR" >&2
    exit 1
fi

# -----------------------------------------------------------------------------
# 2. Selección de resolución
# -----------------------------------------------------------------------------
echo ""
echo "$MSG_RES_TITLE"
echo "1) HD (1280x720-1366x768)"
echo "2) Full HD (1920x1080)"
echo "3) 2K (2560x1440)"
echo "4) 4K (3840x2160)"
read -rp "$MSG_RES_PROMPT" res_choice

case $res_choice in
    1) GFXMODE="1366x768x32,1280x720x32,auto" ;;
    2) GFXMODE="1920x1080x32,auto" ;;
    3) GFXMODE="2560x1440x32,auto" ;;
    4) GFXMODE="3840x2160x32,auto" ;;
    *)
        echo "$MSG_RES_INVALID"
        GFXMODE="1920x1080x32,auto"
        ;;
esac

# -----------------------------------------------------------------------------
# 2.1 Selección de fondo de pantalla
# -----------------------------------------------------------------------------
echo ""
echo "$MSG_BG_TITLE"
echo "$MSG_BG_1"
echo "$MSG_BG_2"
echo "$MSG_BG_3"
echo "$MSG_BG_4"
echo "$MSG_BG_5"
echo "$MSG_BG_6"

read -rp "$MSG_BG_PROMPT" bg_choice

case $bg_choice in
    1) SELECTED_BG="bg1.png" ;;
    2) SELECTED_BG="bg2.png" ;;
    3) SELECTED_BG="bg3.png" ;;
    4) SELECTED_BG="bg4.png" ;;
    5) SELECTED_BG="bg5.png" ;;
    6) SELECTED_BG="bg6.png" ;;
    *)
        echo "$MSG_BG_INVALID"
        SELECTED_BG="bg1.png"
        ;;
esac

# -----------------------------------------------------------------------------
# 3. Instalación de archivos del tema
# -----------------------------------------------------------------------------
echo ""
echo "$MSG_INSTALLING"
mkdir -p "$THEME_DIR"

# Copiar el contenido del directorio del script al directorio del tema
cp -r "$SCRIPT_DIR/"* "$THEME_DIR/"

# Aplicar el fondo seleccionado sobre el fondo principal
if [ -f "$SCRIPT_DIR/backgrounds/$SELECTED_BG" ]; then
    cp "$SCRIPT_DIR/backgrounds/$SELECTED_BG" "$THEME_DIR/assets/background.png"
else
    echo "$MSG_BG_WARN"
fi

# Limpiar archivos de desarrollo e instaladores en el destino
rm -rf "$THEME_DIR/.git" "$THEME_DIR/.gitignore" "$THEME_DIR/preview.png" "$THEME_DIR/backgrounds" "$THEME_DIR/Install.sh" 2>/dev/null || true

# -----------------------------------------------------------------------------
# 4. Actualizar /etc/default/grub
# -----------------------------------------------------------------------------
echo "$MSG_CONFIGURING"

# Limpiar entradas previas
sed -i '/^[[:space:]]*#\?[[:space:]]*GRUB_THEME=/d' /etc/default/grub
sed -i '/^[[:space:]]*#\?[[:space:]]*GRUB_GFXMODE=/d' /etc/default/grub

# Añadir las nuevas configuraciones
{
    echo "GRUB_THEME=\"$THEME_DIR/theme.txt\""
    echo "GRUB_GFXMODE=\"$GFXMODE\""
} >> /etc/default/grub

# -----------------------------------------------------------------------------
# 5. Regenerar configuración de GRUB
# -----------------------------------------------------------------------------
echo "$MSG_UPDATING"

if command -v update-grub &> /dev/null; then
    update-grub
elif [ -f /boot/grub/grub.cfg ]; then
    grub-mkconfig -o /boot/grub/grub.cfg
elif [ -f /boot/grub2/grub.cfg ]; then
    grub-mkconfig -o /boot/grub2/grub.cfg
else
    echo "$MSG_GRUB_WARN"
fi

echo ""
echo "$MSG_SUCCESS"
