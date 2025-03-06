#!/bin/bash

# Copyright (C) 2024-2025 deboniet

# This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or any later version.

# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

# You should have received a copy of the GNU General Public License along with this program; if not, write to the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.

##################################################
# Descripción del script: Instalar o actualizar VMware Workstation.
# Compatibilidad: CPUs x86 de 64 bits que ejecuten Debian 11 o superior, o Ubuntu 20.04 o superior. Es también compatible con cualquier otra distribución que use los repositorios de alguna de estas dos distribuciones.
# NOTA: El script está pensado para usarse en equipos con Secure Boot activado (Lineas 38-50 del script).
##################################################
# Debido a que el ejecutable que se descargue es de un solo uso y de gran tamaño, se descargara en /tmp, de manera que al reinicio ya no esté almacenado.
cd /tmp
# Esto permitirá ejecutar comandos con permisos de súper-usuario sin necesidad de poner la contraseña una y otra vez. Si has configurado sudoers para que este tipo de "trucos" no funcione, esto será inútil.
sudo echo 1>/dev/null
echo "Comprobando si es necesario instalar paquetes."
sudo apt update 1>/dev/null 2>/dev/null
sudo apt -y install coreutils openssl mokutil wget tar sudo bash
clear
# Obtención y descompresión de la última versión del instalador de VMware Workstation.
echo "Descargando la versión más reciente del instalador. Espera."
wget https://softwareupdate.vmware.com/cds/vmw-desktop/ws/17.6.3/24583834/linux/core/VMware-Workstation-17.6.3-24583834.x86_64.bundle.tar 1>/dev/null 2>/dev/null
tar -xf VMware-Workstation-17.6.3-24583834.x86_64.bundle.tar
chmod 700 VMware-Workstation-17.6.3-24583834.x86_64.bundle
echo
# Desinstalar VMware Workstation y re-instalarlo.
echo "Q para cancelar, ENTER para seguir."
echo "(No hace falta pulsar ninguna tecla si no estaba previamente instalado)"
sudo vmware-installer -u vmware-workstation 1>/dev/null 2>/dev/null
echo "Instalando VMware Workstation 17."
sudo /tmp/VMware-Workstation-17.6.3-24583834.x86_64.bundle 1>/dev/null
echo "VMware Workstation 17 instalado."
echo
# Firmar los módulos vmmon y vmnet, para que funcionen con Secure Boot activado, con una duración de un siglo.
# NOTA: Algunos firmware no son compatibles con MOKs que tienen una longitud de clave de 4096 bits, si eso ocurriera, bajar el parámetro rsa a 2048.
echo "Creando el certificado para vmmon y vmnet."
openssl req -new -x509 -newkey rsa:4096 -keyout MOK.priv -outform DER -out MOK.der -nodes -days 36525 -subj "/CN=VMware/" 2>/dev/null
# En la primera instalación la firma de los módulos fallará porque no existen. Para solucionar esto, inicia VMware Workstation, acepta los errores de compilación de vmmon y vmnet, y a continuación inicia de nuevo el script. Ten en cuenta que al final esto crea 2 MOKs, por lo que habrá que eliminar el más viejo más adelante.
sudo /usr/src/linux-headers-`uname -r`/scripts/sign-file sha256 ./MOK.priv ./MOK.der $(modinfo -n vmmon)
sudo /usr/src/linux-headers-`uname -r`/scripts/sign-file sha256 ./MOK.priv ./MOK.der $(modinfo -n vmnet)
# Introducir una clave para añadir la firma en el reinicio.
echo "Introduce la clave para poder añadir el certificado en el reinicio:"
sudo mokutil --import MOK.der
mokutil --export ~/Descargas
echo
echo "Se han exportado los MOKs en Descargas, para posterior eliminación. Revisa el MOK antiguo y eliminalo. Después, reinicia el equipo para completar todas las operaciones en un solo reinicio."
