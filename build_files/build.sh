#!/bin/bash

set -ouex pipefail

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/43/x86_64/repoview/index.html&protocol=https&redirect=1

# Install build dependencies for Emacs
sudo dnf5 --assumeyes builddep emacs-pgtk
sudo dnf5 --assumeyes install ImageMagick-devel

transaction_id=$(LANG=C sudo dnf history | grep 'builddep' | head -n 1 | awk '{print $1}')
installed_packages=$(LANG=C sudo dnf history info $transaction_id | grep "Install" | awk '{print $2}' | tr '\n' ' ')

# Get the latest Emacs tar
curl -o emacs.tar.xz -L https://ftpmirror.gnu.org/gnu/emacs/emacs-30.2.tar.xz
tar xJf emacs.tar.xz --one-top-level=emacs --strip-components=1
rm emacs.tar.xz
cd emacs

# Configure, build and install
./configure -C --with-native-compilation=aot --disable-gc-mark-trace --with-imagemagick --with-mailutils --with-tree-sitter --with-pgtk
sudo make install

# Remove the code
cd ..
rm -r ./emacs

# Remove build dependecies
sudo dnf5 --assumeyes remove ImageMagick-devel
#LANG=C sudo dnf5 --assumeyes builddep emacs 2>&1 | awk -F'"' '/^Package .* is already installed/ {print $2}' | xargs sudo dnf5 --assumeyes remove
sudo dnf5 --assumeyes $installed_packages


# Use a COPR Example:
#
# dnf5 -y copr enable ublue-os/staging
# dnf5 -y install package
# Disable COPRs so they don't end up enabled on the final image:
# dnf5 -y copr disable ublue-os/staging

#### Example for enabling a System Unit File

#systemctl enable podman.socket
