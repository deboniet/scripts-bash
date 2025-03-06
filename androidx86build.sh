#!/bin/bash

# Copyright (C) 2024-2025 deboniet

# This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or any later version.

# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

# You should have received a copy of the GNU General Public License along with this program; if not, write to the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.

##################################################
# Descripción del script: Crear una imagen ISO arrancable de Android para equipos x86.
# Instrucciones de compilación basadas en: www.android-x86.org/source.html
# Compatibilidad: CPUs x86 de 64 bits que ejecuten Debian 11 o superior, o Ubuntu 20.04 o superior. Es también compatible con cualquier otra distribución que use los repositorios de alguna de estas dos distribuciones.
# Requisitos mínimos calculados: 202 GiB de espacio y 15,4 GiB de RAM (menos de esta cantidad puede ocasionar fallos al compilar ciertos componentes).
# Recomendaciones previas: Consultar el espacio disponible con el comando df y tener un fichero de memoria de intercambio de, al menos, la mitad de la memoria RAM.
# NOTA: El dominio de www.android-x86.org así como el dominio que aloja el código fuente no siempre están disponibles, por lo que puede que el script no funcione en ciertos momentos.
##################################################
# Esto permitirá ejecutar comandos con permisos de súper-usuario sin necesidad de poner la contraseña una y otra vez. Si has configurado sudoers para que este tipo de "trucos" no funcione, esto será inútil.
sudo echo 1>/dev/null
echo "Comprobando si es necesario instalar paquetes."
# En Debian es necesario tener habilitados los paquetes de la rama contrib.
sudo apt update 1>/dev/null 2>/dev/null
sudo apt -y install git gnupg flex bison build-essential zip curl zlib1g-dev libc6-dev-i386 libncurses6 x11proto-core-dev libx11-dev lib32z1-dev libgl1-mesa-dev libxml2-utils xsltproc unzip fontconfig repo gcc make m4 lib32stdc++6 libelf-dev mtools libssl-dev python3-mako syslinux-utils openssh-client python-is-python3 pkgconf genisoimage squashfs-tools coreutils bash libncurses5 libselinux1-dev libsepol-dev
# Comprobación para saber que versión de Java instalar al no estar todavía OpenJDK 21 en los repositorios de Debian estable.
version=$(cat /etc/os-release | grep VERSION_ID | cut -c 13-14,16-17)
distribucion=$(cat /etc/os-release | grep -w ID | cut -c 4-)
if [ $version -ge 11 -a $distribucion == debian ];
then
	sudo apt -y install openjdk-17-jdk
else
	sudo apt -y install openjdk-21-jdk
fi
clear
echo "NOTA: Se creará automáticamente un sub-directorio en el lugar que especifiques a continuación."
read -p "Introduce el directorio donde se alojara la compilación: " directorio
cd "$directorio"
echo
read -p "Introduce el directorio donde se alojara el resultado final: " resultado
echo
# El resto de versiones requieren de programas más antiguos para poder ser compiladas. Para más información, consulta el apartado "Building the image" en www.android-x86.org/source.html
echo "Versiones disponibles:"
echo "r-x86 --> Android 11"
echo "q-x86 --> Android 10"
echo "pie-x86 --> Android 9"
echo "oreo-x86 --> Android 8.1"
echo "nougat-x86 --> Android 7.1"
echo "marshmallow-x86 --> Android 6"
echo "lollipop-x86 --> Android 5.1"
echo
read -p "Introduce la versión: " android
echo
echo "Arquitecturas disponibles:"
echo "android_x86 --> 32 bits"
echo "android_x86_64 --> 64 bits"
echo
read -p "Introduce la arquitectura: " arquitectura
echo
echo "Targets:"
echo "user --> Acceso limitado, como en las imágenes reales de Android."
echo "userdebug --> Igual que user, pero con acceso root y menos limitado."
echo "eng --> Acceso ilimitado, ideal para desarrollo."
echo
read -p "Introduce el target: " target
echo
mkdir android-x86 2>/dev/null && cd android-x86
# Estos dos comandos son necesarios para la ejecución de Git. Si tienes configurado estos parámetros, comenta la siguiente línea.
git config --global user.email "" && git config --global user.name ""
repo init -u http://scm.osdn.net/gitroot/android-x86/manifest -b $android
repo sync --no-tags --no-clone-bundle
source build/envsetup.sh
lunch $arquitectura-$target
echo
# El parámetro nproc usará todos los núcleos del procesador para la compilación, lo que puede llegar a saturar el sistema en ciertos momentos. Otra opción recomendable puede ser: $(($(nproc) - 1)) que usa todos los núcleos excepto uno.
make -j$(nproc) iso_img
# Mover el resultado final, dependiendo de la arquitectura elegida anteriormente.
if [ $arquitectura == android_x86_64 ];
then
	mv out/target/product/x86_64/android_x86_64.iso "$resultado"
elif [ $arquitectura == android_x86 ];
then
	mv out/target/product/x86/android_x86.iso "$resultado"
fi
echo "Imagen ISO creada. Está situada en: $resultado"
