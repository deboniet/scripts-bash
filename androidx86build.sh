#!/bin/bash

# Copyright (C) 2024-2025 deboniet

# This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or any later version.

# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

# You should have received a copy of the GNU General Public License along with this program; if not, write to the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.

##################################################
# Descripción del script: Crear una ISO arrancable de Android para equipos x86.
# Instrucciones de compilación basadas en: www.android-x86.org/source.html
# Compatibilidad: CPUs x86 de 64 bits que ejecuten Debian 11 o superior, o Ubuntu 20.04 o superior. Es también compatible con cualquier otra distribución que use los repositorios de alguna de estas dos distribuciones.
# Requisitos mínimos calculados para la rama r-x86: 185 GiB de espacio y 16 GiB de RAM (menos de esta cantidad puede ocasionar fallos al compilar ciertos componentes).
# Recomendaciones previas: Consultar el espacio disponible en disco, la disponibilidad de Python 2/3 y tener un fichero de memoria de intercambio de, al menos, la mitad de la memoria RAM.

# Opciones adicionales. 0 es desactivado. 1 es activado.
# Usar Python 2 (Solo disponible en Debian 11 y Ubuntu 20.04).
python2=0
# Usar Java 8 (Solo disponible en Ubuntu).
java8=0

##################################################
# Esto permitirá ejecutar comandos con permisos de súper-usuario sin necesidad de poner la contraseña una y otra vez. Si has configurado sudoers para que este tipo de "trucos" no funcione, esto será inútil.
sudo echo 1>/dev/null
echo "Comprobando si es necesario instalar paquetes."
sudo apt update 1>/dev/null 2>/dev/null
sudo apt -y install git gnupg flex bison build-essential zip curl zlib1g-dev libc6-dev-i386 libncurses6 libx11-dev lib32z1-dev libxml2-utils xsltproc unzip fontconfig gcc make m4 lib32stdc++6 libelf-dev mtools libssl-dev syslinux-utils openssh-client pkgconf genisoimage squashfs-tools coreutils bash libncurses5 libselinux1-dev libsepol-dev wget unzip gettext java-common bc
# Comprobación para saber qué versión de Java instalar, al no estar OpenJDK 21 en los repositorios de Debian estable. La compilación no da errores con estas versiones recientes de Java, pero sí da ciertas advertencias por usarlas. Si esto te preocupa, cambia a la versión 8 de Java.
version=$(cat /etc/os-release | grep VERSION_ID | cut -c 13-14,16-17)
distribucion=$(cat /etc/os-release | grep -w ID | cut -c 4-)
if [ $java8 = 1 ];
then
	sudo apt -y install openjdk-8-jdk
	sudo update-java-alternatives --set java-1.8.0-openjdk-amd64
elif [ $version -ge 11 -a $distribucion = debian -a $java8 = 0 ];
then
	sudo apt -y install openjdk-17-jdk
else
	sudo apt -y install openjdk-21-jdk
	sudo update-java-alternatives --set java-1.21.0-openjdk-amd64
fi
# Instalación de paquetes dependiendo de la versión de Python elegida.
if [ $python2 = 1 ];
then
	sudo apt -y install python2 python-is-python2 python-mako python-enum34
elif [ $python2 = 0 ];
then
	sudo apt -y install python-is-python3 python3-mako
fi
clear
echo "NOTA: Se creará un directorio con la rama elegida en el lugar que especifiques a continuación."
read -p "Introduce el directorio donde se alojará la compilación: " directorio
cd "$directorio"
echo
read -p "Introduce el directorio donde se moverá la ISO: " resultado
echo
# El resto de versiones requieren de una versión de Java muy antigua para poder ser compiladas. Para más información, consulta el apartado "Building the image" en www.android-x86.org/source.html
echo "Versiones disponibles:"
echo "r-x86 --> Android 11"
echo "q-x86 --> Android 10"
echo "pie-x86 --> Android 9 (Requiere Python 2)"
echo "oreo-x86 --> Android 8.1 (Requiere Python 2 y Java 8)"
echo "nougat-x86 --> Android 7.1 (Requiere Python 2 y Java 8)"
echo
read -p "Introduce la versión: " android
echo
echo "Arquitecturas disponibles:"
echo "android_x86 --> 32 bits"
echo "android_x86_64 --> 64 bits"
echo
read -p "Introduce la arquitectura: " arquitectura
echo
echo "Destinos disponibles:"
echo "user --> Acceso limitado, como en las imágenes reales de Android."
echo "userdebug --> Igual que user, pero más adecuada para desarrollo."
echo "eng --> Acceso ilimitado, ideal para desarrollo."
echo
read -p "Introduce el target: " target
echo
mkdir $android 2>/dev/null
cd $android
# Descarga desde Internet Archive, del kernel y otros ficheros, al no estar disponibles en el espejo de GitHub.
echo "Descargando y extrayendo los ficheros necesarios para la rama $android. Espera."
# Las descargas desde Internet Archive pueden ser lentas a veces. La solución está en reintentarlo hasta que se consiga una velocidad de descarga decente.
echo "NOTA: Si la descarga es muy lenta, prueba a ejecutar de nuevo el script."
if [ $android = r-x86 ];
then
	rm -r kernel 2>/dev/null
	rm r-x86_kernel.zip 2>/dev/null
	wget https://archive.org/download/androidx86-build-files/r-x86_kernel.zip 2>/dev/null
	unzip -q r-x86_kernel.zip
	mv android-x86-kernel-227c2c1aa5184f2cd1872d079ab9d96790bcaf69 kernel
	rm r-x86_kernel.zip
elif [ $android = q-x86 -o $android = pie-x86 -o $android = oreo-x86 ];
then
	rm -r kernel 2>/dev/null
	rm q-pie-oreo-x86_kernel.zip 2>/dev/null
	wget https://archive.org/download/androidx86-build-files/q-pie-oreo-x86_kernel.zip 2>/dev/null
	unzip -q q-pie-oreo-x86_kernel.zip
	mv android-x86-kernel-0676905e8791e9a838216e02d4974b2c965e3d4b kernel
	rm q-pie-oreo-x86_kernel.zip
elif [ $android = nougat-x86 ];
then
	# Primero, el kernel.
	rm -r kernel 2>/dev/null
	rm nougat-x86_kernel.zip 2>/dev/null
	wget https://archive.org/download/androidx86-build-files/nougat-x86_kernel.zip 2>/dev/null
	unzip -q nougat-x86_kernel.zip
	mv android-x86-kernel-dcaac9a77ef90bf7844559838a032b4dfd4db32c kernel
	rm nougat-x86_kernel.zip
	# Después, los ficheros de construcción.
	rm -r build 2>/dev/null
	rm nougat-x86_build.zip 2>/dev/null
	wget https://archive.org/download/androidx86-build-files/nougat-x86_build.zip 2>/dev/null
	unzip -q nougat-x86_build.zip
	mv android-x86-build-a5794035de9c287fe79404df4beb41575e6c23bd build
	mv build/core/root.mk Makefile
	rm nougat-x86_build.zip
fi
# Estos dos comandos son necesarios para la ejecución de Git. Si tienes configurados estos parámetros, comenta la siguiente línea.
git config --global user.email "" && git config --global user.name ""
echo
# Descarga de repo desde Google.
mkdir -p .repo/repo.tmp 2>/dev/null
wget https://storage.googleapis.com/git-repo-downloads/repo 2>/dev/null
mv repo .repo/repo.tmp
chmod a+rx .repo/repo.tmp/repo
.repo/repo.tmp/repo init 2>/dev/null
# Reemplazo de los antiguos manifiestos por unos funcionales.
.repo/repo/repo init --partial-clone -b $android -u https://github.com/deboniet/android-x86-manifest
.repo/repo/repo sync -c --no-tags --no-clone-bundle -j$(nproc)
echo
# Descarga de ficheros modificados necesarios para una compilación correcta.
if [ $android = q-x86 ];
then
	echo "Descargando y extrayendo ficheros modificados para la rama q-x86. Espera."
	rm -r q-x86_mod-files 2>/dev/null
	rm q-x86_mod-files.zip 2>/dev/null
	wget https://archive.org/download/androidx86-build-files/q-x86_mod-files.zip 2>/dev/null
	unzip -q q-x86_mod-files.zip
	mv q-x86_mod-files/gl_XML.py external/mesa/src/mapi/glapi/gen
	mv q-x86_mod-files/glX_XML.py external/mesa/src/mapi/glapi/gen
	mv q-x86_mod-files/drmhwctwo.cpp external/drm_hwcomposer
	mv q-x86_mod-files/config.go build/soong/ui/build/paths
	rm -r q-x86_mod-files 2>/dev/null
	rm q-x86_mod-files.zip 2>/dev/null
fi
source build/envsetup.sh
lunch $arquitectura-$target
# Arreglo para solucionar algunos casos en los cuales los comandos no se encuentran.
export PATH="$PATH:/usr/sbin"
echo
# El parámetro nproc usará todos los núcleos del procesador para la compilación, lo que puede llegar a saturar el sistema en ciertos momentos. Otra opción recomendable puede ser: $(($(nproc) - 1)) que usa todos los núcleos excepto uno.
make -j$(nproc) iso_img
# Mover el resultado final, dependiendo de la arquitectura elegida anteriormente.
if [ $arquitectura = android_x86_64 ];
then
	mv out/target/product/x86_64/android_x86_64.iso "$resultado"
elif [ $arquitectura = android_x86 ];
then
	mv out/target/product/x86/android_x86.iso "$resultado"
fi
echo "Imagen ISO creada. Está situada en: $resultado"
