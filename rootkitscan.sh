#!/bin/bash

# Copyright (C) 2024 deboniet

# This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or any later version.

# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

# You should have received a copy of the GNU General Public License along with this program; if not, write to the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.

##################################################
# Descripción del script: Ejecutar tres tipos de análisis anti-malware con debsums, chkrootkit y rkhunter.
# Compatibilidad: CPUs x86 de 64 bits que ejecuten Debian 11 o superior, o Ubuntu 20.04 o superior. Es también compatible con cualquier otra distribución que use los repositorios de alguna de estas dos distribuciones.
##################################################
# Esto permitirá ejecutar comandos con permisos de súper-usuario sin necesidad de poner la contraseña una y otra vez. Si has configurado sudoers para que este tipo de "trucos" no funcione, esto será inútil.
sudo echo 1>/dev/null
echo "Comprobando si es necesario instalar paquetes."
sudo apt update 1>/dev/null 2>/dev/null
sudo apt -y install debsums chkrootkit rkhunter coreutils sudo grep bash
clear
mkdir -p ~/Documentos/Logs 2>/dev/null
# Comprobación de los ficheros de configuración cambiados, los ficheros de idioma faltantes y ficheros ELF modificados.
echo "Ejecutando: debsums"
echo
sudo debsums -acs --no-locale-purge --no-prelink | tee ~/Documentos/Logs/debsums.log
sudo chown $USER:$USER ~/Documentos/Logs/debsums.log
echo
# Ejecutar chkrootkit y solo mostrar los positivos. Si deseas añadir falsos positivos, añádelos al fichero chkrootkit.ignore situado en /etc/chkrootkit
echo "Ejecutando: chkrootkit"
echo
sudo chkrootkit -q | grep -v -f /etc/chkrootkit/chkrootkit.ignore | tee ~/Documentos/Logs/chkrootkit.log
sudo chown $USER:$USER ~/Documentos/Logs/chkrootkit.log
echo
# Actualizar las bases de datos de rkhunter, ejecutar un análisis automatizado y qué solo muestre los positivos.
echo "Ejecutando: rkhunter"
echo
sudo rkhunter --update 1>/dev/null
sudo rkhunter -c --sk --rwo
sudo chown $USER:$USER ~/Documentos/Logs/rkhunter.log 2>/dev/null
sudo rm ~/Documentos/Logs/rkhunter.log.old 2>/dev/null
