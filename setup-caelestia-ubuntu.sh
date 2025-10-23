#!/usr/bin/env bash
# ============================================================
#  setup-caelestia-ubuntu.sh
#  Build and install Caelestia Shell with CAVA support on Ubuntu 25.10+
# ============================================================

set -e

echo "🌌 Starting Caelestia Shell setup..."

# ------------------------------------------------------------
# 1. Core dependencies
# ------------------------------------------------------------
echo "📦 Installing core build tools and libraries..."
sudo apt update
sudo apt install -y \
  build-essential cmake ninja-build pkgconf git \
  qt6-base-dev qt6-declarative-dev qt6-tools-dev qt6-svg-dev \
  libgl1-mesa-dev libpipewire-0.3-dev libqalculate-dev libaubio-dev \
  wireplumber trash-cli jq eza btop fish starship fastfetch \
  adwaita-icon-theme papirus-icon-theme qt5ct qt6ct \
  autoconf automake libtool libfftw3-dev libasound2-dev \
  libpulse-dev libiniparser-dev libncursesw5-dev libjack-jackd2-dev

# ------------------------------------------------------------
# 2. Build and install CAVA from source
# ------------------------------------------------------------
echo "🎧 Building and installing CAVA (with dev headers)..."

if [ ! -d "$HOME/cava" ]; then
  git clone https://github.com/karlstav/cava.git "$HOME/cava"
fi

cd "$HOME/cava"
./autogen.sh
./configure --prefix=/usr/local
make -j"$(nproc)"
sudo make install
sudo ldconfig

# ------------------------------------------------------------
# 3. Manually install CAVA headers and pkg-config file
# ------------------------------------------------------------
echo "🧩 Installing CAVA development header and pkg-config file..."

sudo mkdir -p /usr/local/include/cava /usr/local/lib/pkgconfig
sudo cp "$HOME/cava/cavacore.h" /usr/local/include/cava/

sudo tee /usr/local/lib/pkgconfig/cava.pc > /dev/null <<'EOF'
prefix=/usr/local
exec_prefix=${prefix}
libdir=${exec_prefix}/lib
includedir=${prefix}/include

Name: cava
Description: Console Audio Visualizer library
Version: 0.8.0
Libs: -L${libdir}
Cflags: -I${includedir}/cava
EOF

sudo ldconfig
export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH

# Verify detection
if pkg-config --exists cava; then
  echo "✅ CAVA detected by pkg-config: $(pkg-config --cflags cava)"
else
  echo "⚠️  Warning: pkg-config could not find cava. Check /usr/local/lib/pkgconfig/cava.pc"
fi

# ------------------------------------------------------------
# 4. Clone and build Caelestia Shell
# ------------------------------------------------------------
echo "🌠 Cloning and building Caelestia Shell..."

if [ ! -d "$HOME/.config/caelestia-shell" ]; then
  git clone https://github.com/caelestia-dots/shell.git "$HOME/.config/caelestia-shell"
fi

cd "$HOME/.config/caelestia-shell"
rm -rf build
cmake -B build -G Ninja -DCMAKE_BUILD_TYPE=Release
cmake --build build
sudo cmake --install build

echo "✅ Caelestia Shell build complete."

# ------------------------------------------------------------
# 5. (Optional) Clone Caelestia Dots configs
# ------------------------------------------------------------
read -p "🖼️  Do you want to install Caelestia Hyprland configs too? [y/N]: " yn
case $yn in
    [Yy]* )
        git clone https://github.com/caelestia-dots/caelestia.git "$HOME/.config/caelestia" || true
        echo "🎨 Caelestia dotfiles installed in ~/.config/caelestia"
        ;;
    * )
        echo "⏩ Skipping dotfiles."
        ;;
esac

echo "✨ Setup finished! You can now run 'caelestia --help' to test."
