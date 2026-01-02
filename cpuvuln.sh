#!/bin/bash

# Copyright (C) 2026 deboniet

# This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or any later version.

# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

# You should have received a copy of the GNU General Public License along with this program; if not, write to the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.

##################################################
# Descripción del script: Ejecutar un análisis de vulnerabilidades Spectre, Meltdown y derivadas. También descarga y ejecuta un comprobador de vulnerabilidades de CSME para equipos con chipset Intel.
# Compatibilidad: CPUs x86 de 64 bits que ejecuten Debian 11 o superior, o Ubuntu 20.04 o superior. Es también compatible con cualquier otra distribución que use los repositorios de alguna de estas dos distribuciones.
# Recomendaciones previas: Si no se elimina después, es posible que chkrootkit detecte este contenido descargado como malware. Es un falso positivo, debido a estar almacenado en /tmp.
##################################################
# Debido a que los códigos que se descarguen son de un solo uso, se ejecutarán en /tmp, de manera que al reinicio ya no estén almacenados.
cd /tmp
# Variable para descargar y ejecutar los códigos solo si el procesador es de Intel.
procesador=$(cat /proc/cpuinfo | grep vendor_id | head -n 1 | cut -c 13-)
# Esto permitirá ejecutar comandos con permisos de súper-usuario sin necesidad de poner la contraseña una y otra vez. Si has configurado sudoers para que este tipo de "trucos" no funcione, esto será inútil.
sudo echo 1>/dev/null
echo "Comprobando si es necesario instalar paquetes."
sudo apt update 1>/dev/null 2>/dev/null
sudo apt -y install wget python3 coreutils tar sudo bash
mkdir cpuvuln 2>/dev/null && cd cpuvuln
# Descarga de los comprobadores de Spectre y Meltdown, y vulnerabilidades de CSME.
wget https://meltdown.ovh -O spectre-meltdown-checker.sh 1>/dev/null 2>/dev/null
chmod 700 spectre-meltdown-checker.sh
if [ $procesador = GenuineIntel ];
then
	wget https://downloadmirror.intel.com/28632/CSME_Version_Detection_Tool_Linux.tar.gz 1>/dev/null 2>/dev/null
fi
clear
# Descompresión y ejecución de los scripts.
sudo ./spectre-meltdown-checker.sh
if [ $procesador = GenuineIntel ];
then
	tar -xf CSME_Version_Detection_Tool_Linux.tar.gz
	python3 intel_csme_version_detection_tool
else
	echo
	echo "Tu equipo no cuenta con chipset Intel, por lo que no opta al análisis de CSME."
fi
