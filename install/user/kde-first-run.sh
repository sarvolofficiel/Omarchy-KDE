#!/bin/bash
# omarchy-kde-first-run.sh
# Pré-configuration KDE Plasma au premier lancement de session
# Applique le thème Breeze Dark par défaut et configura les paramètres
# essentiels pour une expérience cohérente dès la première ouverture.
#
# Ce script est destiné à être exécuté automatiquement au premier
# lancement de la session KDE Plasma (via autostart ou une unité systemd
# user activée par le script d'installation Omarchy).

set -euo pipefail

###############################################################################
# Configuration
###############################################################################

LOG_FILE="${XDG_CACHE_HOME:-$HOME/.cache}/omarchy-kde-first-run.log"
RUN_MARKER="${XDG_CONFIG_HOME:-$HOME/.config}/omarchy-kde-first-run-done"

info()  { echo "[$(date '+%H:%M:%S')] INFO: $*" | tee -a "$LOG_FILE"; }
warn()  { echo "[$(date '+%H:%M:%S')] WARN: $*" | tee -a "$LOG_FILE" >&2; }
error() { echo "[$(date '+%H:%M:%S')] ERROR: $*" | tee -a "$LOG_FILE" >&2; exit 1; }

###############################################################################
# Vérifications préliminaires
###############################################################################

# Ne pas exécuter si déjà fait (idempotence)
if [[ -f "$RUN_MARKER" ]]; then
    info "Configuration déjà appliquée (marqueur trouvé : $RUN_MARKER)"
    exit 0
fi

# S'assurer qu'on est dans une session KDE Plasma
if [[ -z "${XDG_CURRENT_DESKTOP:-}" ]] || [[ "$XDG_CURRENT_DESKTOP" != *"KDE"* ]]; then
    warn "Pas de session KDE détectée (XDG_CURRENT_DESKTOP=$XDG_CURRENT_DESKTOP)"
    warn "Ce script est destiné à être exécuté dans une session KDE Plasma."
    exit 0
fi

info "Démarrage de la pré-configuration KDE Plasma Omarchy..."

###############################################################################
# 1. Thème Breeze Dark (global)
###############################################################################

info "Application du thème Breeze Dark..."

# Appliquer le thème global Breeze Dark via kwriteconfig5
kwriteconfig5 --file kdeglobals --group General --key ColorScheme "BreezeDark"
kwriteconfig5 --file kdeglobals --group General --key Name "BreezeDark"

# Forcer la rechargement des configurations
kquitapp5 kded5 2>/dev/null || true

info "Thème Breeze Dark appliqué."

###############################################################################
# 2. Thème d'icônes Breeze
###############################################################################

info "Définition du thème d'icônes Breeze..."

kwriteconfig5 --file kdeglobals --group Icons --key Theme "Breeze"

###############################################################################
# 3. Thème de fenêtres Breeze
###############################################################################

info "Définition du thème de fenêtres Breeze..."

kwriteconfig5 --file kwinrc --group General --key theme "Breeze"

###############################################################################
# 4. Cursors Breeze
###############################################################################

info "Définition du thème de curseurs Breeze..."

kwriteconfig5 --file kdeglobals --group Cursor --key Theme "Breeze"

###############################################################################
# 5. Polices par défaut
###############################################################################

info "Configuration des polices par défaut..."

kwriteconfig5 --file kdeglobals --group General --key font "Noto Sans, 10"
kwriteconfig5 --file kdeglobals --group General --key fixedfont "JetBrains Mono Nerd Font, 10"

###############################################################################
# 6. Désactivation des animations (optionnel — Omarchy préfère le minimal)
###############################################################################

info "Configuration des animations KWin..."

kwriteconfig5 --file kwinrc --group Compositing --key "AnimationSpeed" "0.5"
kwriteconfig5 --file kwinrc --group Compositing --key "BorderHoverEffects" "false"

###############################################################################
# 7. Marqueur de fin
###############################################################################

touch "$RUN_MARKER"
info "Configuration terminée. Marqueur créé : $RUN_MARKER"
info "Voir le log complet : $LOG_FILE"
