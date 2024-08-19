#!/bin/bash

# Copyright (C) 2024 deboniet

# This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.

# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

# You should have received a copy of the GNU General Public License along with this program; if not, write to the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.

##################################################
# Descripción del script: Comprueba si hay conexión a Internet (resolviendo un dominio) y muestra en una notificación el número de paquetes actualizables, si es que los hay.
# Compatibilidad: CPUs x86 de 64 bits que ejecuten Debian 11 o superior, o Ubuntu 20.04 o superior. Es también compatible con cualquier otra distribución que use los repositorios de alguna de estas dos distribuciones.
# Requisitos necesarios: 
# 	1. Tener instalado libnotify, net-tools, grep y bash.
# 	2. Configurar sudoers con la siguiente línea: <usuario que ejecute el script> ALL=NOPASSWD:/usr/bin/apt update
# NOTA: El script puede usarse espontáneamente si se desea, pero recomiendo ponerlo al inicio de sesión del usuario para poder sacarle el máximo partido.
##################################################
while true;
do
	# Notificación cuando la resolución de nombres funcione.
	if nslookup google.com > /dev/null 2>&1;
		then
			notify-send "Resolución de nombres operativa"
			# Una vez haya resolución de nombres, actualizar la caché de repositorios, extraer el número de paquetes por actualizar y mostrar una notificación con dicho número, si es que hay paquetes por actualizar. Requiere configurar sudoers para que APT se ejecute sin pedir privilegios. Consulta los requisitos necesarios arriba mencionados.
			paquetes=$(sudo apt update 2>/dev/null | grep -o "Se pueden actualizar .* paquetes" | grep -oE '[0-9]{1,5}')
			if [ -z $paquetes ];
			then
				notify-send "No hay paquetes por actualizar"
				break
			else
				notify-send "Hay $paquetes paquetes por actualizar"
				break
			fi
	fi
done
