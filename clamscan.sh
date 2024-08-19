#!/bin/bash

# Copyright (C) 2024 deboniet

# This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or any later version.

# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

# You should have received a copy of the GNU General Public License along with this program; if not, write to the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.

##################################################
# Descripción del script: Ejecutar un análisis de malware con ClamAV.
# Compatibilidad: CPUs x86 de 64 bits que ejecuten Debian 11 o superior, o Ubuntu 20.04 o superior. Es también compatible con cualquier otra distribución que use los repositorios de alguna de estas dos distribuciones.
##################################################
# Esto permitirá ejecutar comandos con permisos de súper-usuario sin necesidad de poner la contraseña una y otra vez. Si has configurado sudoers para que este tipo de "trucos" no funcione, esto será inútil.
sudo echo 1>/dev/null
echo "Comprobando si es necesario instalar paquetes."
sudo apt update 1>/dev/null 2>/dev/null
sudo apt -y install clamav clamav-freshclam coreutils moreutils util-linux grep sudo bash
# Comprobación de versión para saber si instalar 7zip o p7zip, ya que 7zip solo está disponible a partir de la versión 12 de Debian y la 22.04 de Ubuntu.
version=$(cat /etc/os-release | grep VERSION_ID | cut -c 13-14,16-17)
distribucion=$(cat /etc/os-release | grep -w ID | cut -c 4-)
if [ $version -ge 2204 -a $distribucion == ubuntu ];
then
	sudo apt -y install 7zip
elif [ $version -ge 12 -a $distribucion == debian ];
then
	sudo apt -y install 7zip
else
	sudo apt -y install p7zip-full
fi
clear
# Se utilizará el argumento indicado a continuación de la ejecución de este script.
echo "Se analizará:" "$1"
echo
# Comandos necesarios para ejecutar freshclam, si los registros de freshclam han sido eliminados anteriormente.
echo "Actualizando bases de datos de malware."
echo
sudo mkdir -p /var/log/clamav 2>/dev/null
sudo touch /var/log/clamav/freshclam.log
sudo chown -R clamav:clamav /var/log/clamav
sudo pkill freshclam 1>/dev/null
sudo freshclam 1>/dev/null
# Creacion de variables para automatizar la creación de directorios y registros.
fecha=$(date +%-e-%-m-%g)
hora=$(date +%-H-%M-%S)
mkdir -p ~/"Documentos/Logs/ClamAV/$fecha $hora/"
mkdir -p ~/"Documentos/Logs/ClamAV/$fecha $hora/GREP/"
# Inicio de clamscan. También se registra el inicio y el final en el journal del sistema.
# NOTA: En algunas versiones de Debian hay límite de tamaño para el análisis de 2 GB, en vez de 4 GB.
echo "Iniciado un escáner de ClamAV por parte de $USER." | logger
sudo clamscan -v -o --official-db-only=yes -r -z --cross-fs --follow-dir-symlinks=0 --follow-file-symlinks=0 --bytecode --detect-pua=yes --exclude-pua=Doc --scan-mail --heuristic-alerts --scan-pe --scan-elf --scan-ole2 --scan-pdf --scan-swf --scan-html --scan-xmldocs --scan-hwp3 --scan-archive --alert-encrypted=yes --alert-macros=yes --alert-exceeds-max=yes --alert-partition-intersection=yes --max-scantime=900000 --max-files=100000 --max-recursion=100 --max-dir-recursion=100 --max-embeddedpe=4000M --max-filesize=4000M --max-scansize=4000M --alert-broken-media=no "$1" | ts %H:%M:%S | tee ~/"Documentos/Logs/ClamAV/$fecha $hora/ClamScan $fecha $hora (tmp).txt"
echo "Finalizado el escáner de ClamAV por parte de $USER, iniciado a las $hora del $fecha" | logger
# Filtrado del registro original para reducir su tamaño.
grep -v -e /proc ~/"Documentos/Logs/ClamAV/$fecha $hora/ClamScan $fecha $hora (tmp).txt" > ~/"Documentos/Logs/ClamAV/$fecha $hora/ClamScan $fecha $hora.txt"
# Filtrado de los positivos.
grep " FOUND" ~/"Documentos/Logs/ClamAV/$fecha $hora/ClamScan $fecha $hora.txt" > ~/"Documentos/Logs/ClamAV/$fecha $hora/GREP/ClamScan (Positivos) $fecha $hora.txt"
# Filtrado de las exclusiones.
grep " Excluded" ~/"Documentos/Logs/ClamAV/$fecha $hora/ClamScan $fecha $hora.txt" > ~/"Documentos/Logs/ClamAV/$fecha $hora/GREP/ClamScan (Exclusiones) $fecha $hora.txt"
# Filtrado de los ficheros vacíos.
grep " Empty file" ~/"Documentos/Logs/ClamAV/$fecha $hora/ClamScan $fecha $hora.txt" > ~/"Documentos/Logs/ClamAV/$fecha $hora/GREP/ClamScan (Vacíos) $fecha $hora.txt"
# Comprimir con 7zip en formato 7Z los registros resultantes.
rm -r ~/"Documentos/Logs/ClamAV/$fecha $hora/ClamScan $fecha $hora (tmp).txt"
7z a -t7z -m0=LZMA2 -mmt=on -mx1 -md=256k -mfb=273 -ms=e -mqs=on -mtc=on -mta=on "-w/home/$USER/Documentos/Logs/ClamAV" ~/"Documentos/Logs/ClamAV/$fecha $hora.7z" ~/"Documentos/Logs/ClamAV/$fecha $hora/ClamScan $fecha $hora.txt" ~/"Documentos/Logs/ClamAV/$fecha $hora/GREP" 1>/dev/null
# Eliminar los registros, una vez compresos.
rm -r ~/"Documentos/Logs/ClamAV/$fecha $hora"
