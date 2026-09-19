#!/bin/bash
# Déploiement de l'autostart KDE pour le script de premier démarrage
# Copie le fichier .desktop dans /etc/xdg/autostart/ pour que tous les
# utilisateurs KDE profitent de la configuration par défaut Breeze Dark.

set -euo pipefail

autostart_dir="/etc/xdg/autostart"
desktop_file="$OMARCHY_PATH/default/autostart/omarchy-kde-first-run.desktop"
script_dest="/usr/share/omarchy/user/kde-first-run.sh"

# Déployer le script de premier démarrage KDE
if [[ -f "$OMARCHY_INSTALL/user/kde-first-run.sh" ]]; then
    mkdir -p "$(dirname "$script_dest")"
    cp -f "$OMARCHY_INSTALL/user/kde-first-run.sh" "$script_dest"
    chmod +x "$script_dest"
    echo "KDE first-run script déployé : $script_dest"
fi

# Déployer le fichier .desktop d'autostart
if [[ -f "$desktop_file" ]]; then
    mkdir -p "$autostart_dir"
    cp -f "$desktop_file" "$autostart_dir/omarchy-kde-first-run.desktop"
    echo "KDE autostart desktop file déployé : $autostart_dir/omarchy-kde-first-run.desktop"
else
    echo "Avertissement : fichier desktop introuvable : $desktop_file"
fi
