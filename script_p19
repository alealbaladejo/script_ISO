#!/usr/bin/env bash
#Autores del script: Alejandro Albaladejo y Raúl Herrera
#Descripción:  	script que muestre por pantalla las características de los elementos
# 		fundamentales de hardware:
#			 CPU
# 			 Memoria RAM
#			 Listado de discos (Tipo y capacidad)
# 			 Listado de interfaces de red (mostrando chip)
# 			 Listado de tarjetas gráficas (mostrando chip)


# Variables para colores
rojo='\e[1;31m'
verde='\e[1;32m'
amarillo='\e[1;33m'
azul='\e[1;34m'
morado='\e[1;35m'
cyan='\e[1;36m'
reset='\e[0m'

# Función para verificar la existencia de un comando
verificar_comando() {
    if ! command -v $1 &> /dev/null; then
        echo -e "${rojo}Error:${reset} $1 no está instalado o no se encuentra en la ruta de búsqueda."
        exit 1
    fi
}

# Función para imprimir encabezados con formato
imprimir_encabezado() {
    local encabezado="$1"
    echo -e "\n${azul}$encabezado${reset}"
}

memoria_ram() {
	free -h
}

# Verificar la existencia de comandos necesarios
	echo -e "${amarillo}Verificando la existencia de los comandos necesarios...${reset}"
	sleep 2
	verificar_comando lscpu
	echo -e "${verde}¡Todos los comandos necesarios están disponibles!${reset}"
	sleep 2
# Imprimir información de la CPU
	imprimir_encabezado "Información de la CPU"
	echo -e "${amarillo}Obteniendo información de la CPU...${reset}"
	lscpu
	sleep 2
	clear
#MEMORIA RAM
	echo -e "${morado}\n Comprobando si existen los comandos"
	verificar_comando free -h


# Verifica si hay espacio de intercambio
if [[ -n "$(cat /proc/swaps | grep -v '^Filename')" ]]; then
    echo "¡Espacio de intercambio (swap) está configurado en el sistema!"
        memoria_ram "INFORMACIÓN CON SWAP"
else
    echo "No se encontró espacio de intercambio (swap) configurado en el sistema."

fi
