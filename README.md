# Omarchy KDE Edition — Test VM QEMU

Configuration prête à l'emploi pour tester Omarchy KDE Edition sous QEMU.

## Description

Ce répertoire contient tout ce qu'il faut pour démarrer une VM QEMU avec Omarchy KDE Edition :
- KDE Plasma Wayland préconfiguré
- SDDM comme display manager
- Thème Breeze Dark par défaut
- Autres paquets Omarchy (outils, apps)

## Prérequis

### Sur Arch Linux / Manjaro
```bash
sudo pacman -S qemu-base cloud-init guestfish virt-utils
```

### Sur Debian/Ubuntu
```bash
sudo apt install qemu-system-x86 cloud-image-utils libguestfs-tools
```

### Sur Fedora
```bash
sudo dnf install qemu-kvm cloud-utils guestfs-tools
```

## Méthode 1 — Test rapide avec cloud-init (recommandé)

Cette méthode utilise une image Arch Cloud officielle + cloud-init pour installer KDE au premier boot.

### Étape 1 : Télécharger l'image Arch Cloud

```bash
# Créer le dossier de sortie
mkdir -p /tmp/omarchy-kde-test/output

# Télécharger l'image Arch Cloud (remplacez la date par la dernière disponible)
wget https://mirror.pkgbuild.com/archlinux/iso/2024.01.01/archlinux-2024.01.01-x86_64-cloud.img.gz -P /tmp/omarchy-kde-test/output/

# Décompresser
gunzip /tmp/omarchy-kde-test/output/archlinux-*-x86_64-cloud.img.gz

# Renommer pour simplifier
mv /tmp/omarchy-kde-test/output/archlinux-*-x86_64-cloud.img \
   /tmp/omarchy-kde-test/output/base-arch.raw
```

### Étape 2 : Lancer la VM avec cloud-init

```bash
cd /tmp/omarchy-kde-test

# Générer l'ISO cloud-init
cloud-localds output/cloud-init.iso cloud-init/omarchy-kde.cfg

# Démarrer QEMU
qemu-system-x86_64 \
    -enable-kvm \
    -m 4096 \
    -smp 4 \
    -cpu host \
    -machine type=q35,accel=kvm \
    -drive file=output/base-arch.raw,format=raw,if=virtio \
    -drive file=output/cloud-init.iso,format=raw,media=cdrom \
    -netdev user,id=net0,hostfwd=tcp::2222-:22 \
    -device virtio-net-pci,netdev=net0,mac=52:54:00:12:34:56 \
    -display gtk,gl=on \
    -device virtio-gpu-pci \
    -soundhw ac97
```

### Étape 3 : Connexion SSH (après boot)

```bash
# La VM démarre avec cloud-init qui configure tout
# Une fois KDE prêt, connectez-vous en SSH :
ssh -p 2222 omarchy@localhost

# Mot de passe par défaut : omarchy (à changer !)
```

## Méthode 2 — Script automatisé

Le script `scripts/build-qemu.sh` automatise tout le processus.

```bash
chmod +x scripts/build-qemu.sh
./scripts/build-qemu.sh create   # Créer l'image
./scripts/build-qemu.sh run      # Démarrer la VM
```

## Configuration cloud-init

Le fichier `cloud-init/omarchy-kde.cfg` applique automatiquement :

- **Paquets KDE** : plasma-desktop, sddm, konsole, dolphin, ark, plasma-nm, plasma-pa, kate, kscreen, spectacle, xdg-desktop-portal-kde
- **Display Manager** : SDDM activé
- **Services** : NetworkManager, Bluetooth, systemd-oomd
- **Thème** : Breeze Dark (couleurs, icônes, curseurs, polices)
- **Locale** : fr_FR.UTF-8
- **Utilisateur** : omarchy (mot de passe à modifier au premier login)

## Ressources Qemu

| Ressource | Valeur | Notes |
|-----------|--------|-------|
| RAM | 4096 Mo | 4 Go — suffisant pour KDE Plasma |
| CPU | 4 cœurs | host CPU passthrough |
| Disque | 20 Go | QCOW2 (dynamique) |
| Affichage | GTK + OpenGL | Accélération 3D |
| Son | AC97 | Audio de base |
| Réseau | User/NAT | Port 2222 → 22 (SSH) |

## Personnalisation

### Modifier les ressources

Éditez les variables dans `scripts/build-qemu.sh` :
```bash
VM_RAM="8192"          # 8 Go RAM
VM_CPUS="8"            # 8 cœurs
VM_DISK_SIZE="40G"     # 40 Go disque
```

### Modifier les paquets cloud-init

Éditez `cloud-init/omarchy-kde.cfg` :
```yaml
packages:
  - <ajouter-ou-retirer-des-paquets>
```

### Ajouter un pont réseau (accès réseau complet)

Remplacez le `-netdev user` par :
```bash
-netdev bridge,id=net0,br=virbr0 \
-device virtio-net-pci,netdev=net0,mac=52:54:00:12:34:56
```

## Dépannage

### VM ne démarre pas
```bash
# Vérifier que KVM est disponible
ls -l /dev/kvm
# Si absent : sudo modprobe kvm_intel (ou kvm_amd)

# Vérifier les droits
sudo usermod -aG kvm \$USER
# Puis déconnecter/reconnecter
```

### Pas d'affichage graphique
```bash
# Essayer avec VNC à la place de GTK
qemu-system-x86_64 ... -vnc :0 -display none
# Puis connecter un client VNC sur localhost:5900
```

### Cloud-init ne s'exécute pas
```bash
# Vérifier que l'ISO est bien montée
qemu-system-x86_64 ... -drive file=output/cloud-init.iso,format=raw,media=cdrom

# Vérifier les logs cloud-init dans la VM
ssh -p 2222 omarchy@localhost
sudo journalctl -u cloud-init
```

## Accès direct aux fichiers

Après le premier boot avec cloud-init, vous pouvez accéder à :
- `/home/omarchy/.config/kdeglobals` — Configuration KDE
- `/etc/sddm.conf.d/omarchy.conf` — Configuration SDDM
- `/usr/share/wayland-sessions/omarchy-kde.desktop` — Session Wayland

## Alternatives sans cloud-init

Si vous ne voulez pas utiliser cloud-init, vous pouvez :
1. Créer une image Arch Linux classique avec `archinstall`
2. Installer KDE Plasma manuellement
3. Appliquer les configurations manuellement

Cette approche est plus longue mais donne un contrôle total.

---

## Notes

- L'image Arch Cloud officielle est ~200 Mo (vide) et s'installe via cloud-init
- La méthode cloud-init est la plus rapide pour tester KDE Plasma
- Pour une ISO complète bootable, voir `../archiso/` (nécessite archiso + environnement de build)
