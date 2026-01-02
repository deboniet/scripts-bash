#!/bin/bash

# Copyright (C) 2026 deboniet

# This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or any later version.

# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

# You should have received a copy of the GNU General Public License along with this program; if not, write to the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.

##################################################
# Descripción del script: Muestra una notificación cuando Timeshift inicie una copia de seguridad usando rsync.
# Compatibilidad: CPUs x86 de 64 bits que ejecuten Debian 11 o superior, o Ubuntu 20.04 o superior. Es también compatible con cualquier otra distribución que use los repositorios de alguna de estas dos distribuciones.
# Requisitos necesarios:
#	1. Tener instalado y configurado Timeshift, usando rsync.
#	2. Tener instalados procps, coreutils, libnotify y bash.
# NOTA: El script no diferencia entre las operaciones de Timeshift y las de cualquier otra con rsync. Si en el sistema se realiza otra operación con rsync que tenga permisos de súper-usuario, la notificación también aparecerá. Recomiendo poner el script para que se ejecute al inicio de sesión del usuario y así poder sacarle el máximo partido, ya que comprueba cada hora si se está realizando una copia o no.
##################################################
while true;
do
	sleep 1
	# Comprobación para saber si hay un proceso rsync que se ejecute con el usuario root.
	if pgrep -u root -x rsync > /dev/null
		then
			notify-send "Realizando copia de seguridad"
			# Timeshift realiza predeterminadamente copias cada hora. El bucle se encargará de que cada hora se compruebe si rsync está en ejecución, o no.
			sleep 3600
	fi
done
