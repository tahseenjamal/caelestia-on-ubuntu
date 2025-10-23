````markdown
# 🌌 Building Caelestia Shell on Ubuntu 25.10

Caelestia Shell is a modern Wayland desktop shell and UI framework designed for Hyprland-based setups.  
It includes QML-based widgets, system controls, and optional real-time audio visualization via **CAVA**.

This guide walks you through building Caelestia Shell from source and ensuring all dependencies (including `cavacore.h`) are correctly installed.

---

## 🧰 1. Prerequisites

Make sure you have a working Hyprland environment and up-to-date system:

```bash
sudo apt update && sudo apt upgrade -y
````

Then install core build tools and libraries:

```bash
sudo apt install -y \
  build-essential cmake ninja-build pkgconf git \
  qt6-base-dev qt6-declarative-dev qt6-tools-dev qt6-svg-dev \
  libgl1-mesa-dev libpipewire-0.3-dev libqalculate-dev libaubio-dev \
  wireplumber trash-cli jq eza btop fish starship fastfetch \
  adwaita-icon-theme papirus-icon-theme qt5ct qt6ct
```

---

## 🎧 2. Install the CAVA Development Files

Ubuntu packages only include the `cava` binary, **not** the development headers (`cavacore.h`) that Caelestia needs.
We’ll compile CAVA from source and install its headers manually.

### 2.1 Build CAVA

```bash
cd ~
git clone https://github.com/karlstav/cava.git
cd cava

sudo apt install -y autoconf automake libtool libfftw3-dev libasound2-dev \
  libpulse-dev libiniparser-dev libncursesw5-dev libjack-jackd2-dev
./autogen.sh
./configure --prefix=/usr/local
make -j"$(nproc)"
sudo make install
sudo ldconfig
```

### 2.2 Install the missing header and pkg-config metadata

```bash
# Create required directories
sudo mkdir -p /usr/local/include/cava /usr/local/lib/pkgconfig

# Copy the main header
sudo cp ~/cava/cavacore.h /usr/local/include/cava/

# Create the pkg-config file
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

# Refresh linker and pkg-config cache
sudo ldconfig
export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH
```

### 2.3 Verify

```bash
pkg-config --cflags cava
```

You should see output similar to:

```
-I/usr/local/include/cava
```

If so, CAVA is ready.

---

## 💫 3. Clone and Build Caelestia Shell

```bash
git clone https://github.com/caelestia-dots/shell.git ~/.config/caelestia-shell
cd ~/.config/caelestia-shell
cmake -B build -G Ninja -DCMAKE_BUILD_TYPE=Release
cmake --build build
sudo cmake --install build
```

---

## 🧪 4. Test the Build

Check that the binary is installed:

```bash
which caelestia
```

Then run:

```bash
caelestia --help
```

If you see help output, your build succeeded 🎉

---

## 🎨 5. Install Caelestia Dotfiles (Optional)

To get the Hyprland, Waybar, and widget setup:

```bash
git clone https://github.com/caelestia-dots/caelestia.git ~/.config/caelestia
```

You can symlink or copy configurations from `~/.config/caelestia/` into your actual `~/.config/` directory.

---

## 🧩 6. Troubleshooting

| Problem                                                   | Fix                                                                                |
| --------------------------------------------------------- | ---------------------------------------------------------------------------------- |
| `fatal error: cava/cavacore.h: No such file or directory` | Ensure header exists at `/usr/local/include/cava/`                                 |
| `pkg-config cava not found`                               | Verify `/usr/local/lib/pkgconfig/cava.pc` exists and `PKG_CONFIG_PATH` includes it |
| `Manually-specified variables were not used: WITH_CAVA`   | Caelestia Shell always builds with CAVA; no flag to disable                        |
| `libqalculate not found`                                  | `sudo apt install libqalculate-dev`                                                |
| `libpipewire-0.3 not found`                               | `sudo apt install libpipewire-0.3-dev`                                             |

---

## ✅ Summary

After completing these steps, your system has:

* All required dependencies for Caelestia Shell
* Properly registered CAVA development files
* A working build and installation of Caelestia Shell

Now you can launch it inside your Hyprland session or integrate its widgets into your Caelestia configuration.

---

**Enjoy your Caelestia desktop!** 🌠

```
