#!/bin/bash

# Copyright (C) 2024 deboniet

# This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or any later version.

# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

# You should have received a copy of the GNU General Public License along with this program; if not, write to the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.

##################################################
# Descripción del script: Ejecutar un análisis de vulnerabilidades en paquetes.
# Compatibilidad: CPUs x86 de 64 bits que ejecuten Debian 12 o superior, o Ubuntu 20.04 o superior. Es también compatible con cualquier otra distribución que use los repositorios de alguna de estas dos distribuciones.
##################################################
# Debido a que los OVAL que se descarguen son de un solo uso, se ejecutarán en /tmp, de manera que al reinicio ya no estén almacenados.
cd /tmp
# Esto permitirá ejecutar comandos con permisos de súper-usuario sin necesidad de poner la contraseña una y otra vez. Si has configurado sudoers para que este tipo de "trucos" no funcione, esto será inútil.
sudo echo 1>/dev/null
echo "Comprobando si es necesario instalar paquetes."
sudo apt update 1>/dev/null 2>/dev/null
sudo apt -y install wget bzip2 coreutils xdg-utils sudo bash
# Comprobación para saber que librería concreta de OpenSCAP instalar, ya que difiere dependiendo de la versión de cada una de las distribuciones.
version=$(cat /etc/os-release | grep VERSION_ID | cut -c 13-14,16-17)
distribucion=$(cat /etc/os-release | grep -w ID | cut -c 4-)
if [ $version -ge 12 -a $distribucion == debian ];
then
	sudo apt -y install openscap-scanner
elif [ $version -le 2204 -a $distribucion == ubuntu ];
then
	sudo apt -y install libopenscap8
elif [ $version -eq 2310 -a $distribucion == ubuntu ];
then
	sudo apt -y install libopenscap25
elif [ $version -ge 2404 -a $distribucion == ubuntu ];
then
	sudo apt -y install libopenscap25t64
fi
clear
# Descarga, descompresión y ejecución del OVAL más reciente dependiendo de la distribución usada.
if [ $distribucion == ubuntu ];
then
	wget https://security-metadata.canonical.com/oval/com.ubuntu.$(lsb_release -cs).usn.oval.xml.bz2 1>/dev/null 2>/dev/null
	bunzip2 com.ubuntu.$(lsb_release -cs).usn.oval.xml.bz2 2>/dev/null
	echo "Analizando vulnerabilidades en paquetes. En breves momentos el resultado se abrirá en el navegador predeterminado del sistema."
	oscap oval eval --report report-$(lsb_release -cs).html com.ubuntu.$(lsb_release -cs).usn.oval.xml 1>/dev/null 2>/dev/null
elif [ $distribucion == debian ];
then
	wget https://www.debian.org/security/oval/oval-definitions-$(lsb_release -cs).xml.bz2 1>/dev/null 2>/dev/null
	bunzip2 oval-definitions-$(lsb_release -cs).xml.bz2 2>/dev/null
	echo "Analizando vulnerabilidades en paquetes. En breves momentos el resultado se abrirá en el navegador predeterminado del sistema."
	oscap oval eval --report report$(lsb_release -cs).html oval-definitions-$(lsb_release -cs).xml 1>/dev/null 2>/dev/null
fi
xdg-open report-$(lsb_release -cs).html 1>/dev/null 2>/dev/null
