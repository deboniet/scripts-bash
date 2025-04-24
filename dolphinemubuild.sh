#!/bin/bash

# Copyright (C) 2024-2025 deboniet

# This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or any later version.

# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

# You should have received a copy of the GNU General Public License along with this program; if not, write to the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.

##################################################
# Descripción del script: Instalar o actualizar Dolphin Emulator.
# Instrucciones de compilación basadas en: github.com/dolphin-emu/dolphin/wiki/Building-for-Linux
# Compatibilidad: CPUs x86 de 64 bits que ejecuten Debian 12 o superior, o Ubuntu 22.04 o superior. Es también compatible con cualquier otra distribución que use los repositorios de alguna de estas dos distribuciones.
##################################################
# Debido a que la compilación será de un solo uso, se realizará en /tmp, de manera que al reinicio ya no esté almacenado.
cd /tmp
# Esto permitirá ejecutar comandos con permisos de súper-usuario sin necesidad de poner la contraseña una y otra vez. Si has configurado sudoers para que este tipo de "trucos" no funcione, esto será inútil.
sudo echo 1>/dev/null
echo "Comprobando si es necesario instalar paquetes."
sudo apt update 1>/dev/null 2>/dev/null
sudo apt -y install build-essential curl git gcc cmake make ffmpeg libavcodec-dev libavformat-dev libavutil-dev libswscale-dev libevdev-dev libusb-1.0-0-dev libxrandr-dev libxi-dev libpangocairo-1.0-0 qt6-base-private-dev libbluetooth-dev libasound2-dev libpulse-dev libgl1-mesa-dev libcurl4-openssl-dev libpipewire-0.3-dev libsystemd-dev libdrm-dev libsndio-dev libwayland-dev libzstd-dev liblz4-dev libsfml-dev libgtest-dev libsdl2-dev libbz2-dev liblzma-dev libpugixml-dev libcubeb-dev libmbedtls-dev libhidapi-dev libvulkan-dev libunwind-dev gettext coreutils sudo bash
# Comprobación para saber qué paquete instalar, ya que el nombre difiere entre Ubuntu y Debian.
version=$(cat /etc/os-release | grep VERSION_ID | cut -c 13-14,16-17)
distribucion=$(cat /etc/os-release | grep -w ID | cut -c 4-)
if [ $version -ge 12 -a $distribucion = debian ];
then
	sudo apt -y install qt6-svg-dev
elif [ $version -ge 2404 -a $distribucion = ubuntu ];
then
	sudo apt -y install qt6-svg-dev
else
	sudo apt -y install libqt6svg6-dev
fi
clear
# Clonación del repositorio y de los submódulos necesarios, dependiendo de la versión que se desee.
read -p "Elige entre la versión (E)stable o de (D)esarollo: " version
if [ $version = Estable -o $version = estable -o $version = E -o $version = e ];
then
	echo
	echo "Seleccionada la versión estable. Descargando."
	git clone --branch 2503a --single-branch https://github.com/dolphin-emu/dolphin
elif [ $version = Desarrollo -o $version = desarrollo -o $version = D -o $version = d ];
then
	echo
	echo "Seleccionada la versión de desarrollo. Descargando."
	git clone https://github.com/dolphin-emu/dolphin
fi
cd dolphin
git -c submodule."Externals/Qt".update=none \
-c submodule."Externals/FFmpeg-bin".update=none \
-c submodule."Externals/libadrenotools".update=none \
submodule update --init --recursive \
&& git pull --recurse-submodules
sudo rm -r build 2>/dev/null
mkdir build && cd build
# El argumento -Wno-dev suprime algunos mensajes irrelevantes.
cmake .. -Wno-dev
echo
# El parámetro nproc usará todos los núcleos del procesador para la compilación, lo que puede llegar a saturar el sistema en ciertos momentos. Otra opción recomendable puede ser: $(($(nproc) - 1)) que usa todos los núcleos excepto uno.
make -j$(nproc)
echo
sudo make install
# Al terminar la instalación, el directorio es propiedad y acceso solo para el usuario root. Por ello, hay que dar permisos de lectura y ejecución para otros.
sudo chmod 755 /usr/local/share/dolphin-emu
echo
echo "Dolphin Emulator instalado."
