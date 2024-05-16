#!/usr/bin/env bash
# Autor: Alejandro Albaladejo y Raúl Herrera
# Descripción: Script para mostrar características del hardware.

# Colores para el formato del texto
rojo='\e[1;31m'
verde='\e[1;32m'
amarillo='\e[1;33m'
azul='\e[1;34m'
reset='\e[0m'

# Función para verificar si el comando está instalado y ofrecer su instalación
verificar_comando() {
    local comando="$1"
    if ! command -v "$comando" &> /dev/null; then
        echo -e "${rojo}Error:${reset} El comando '$comando' no está disponible o no se encuentra en la ruta de búsqueda."
        read -p "El comando '$comando' no está instalado, ¿Deseas instalarlo? (si/no): "
        if [[ $REPLY == "si" ]]; then
            instalar_paquete "$comando"
        else
            exit 1
        fi
    else
        return 0
    fi
}

# Función para instalar un paquete
instalar_paquete() {
    local paquete="$1"
    if [[ "$(id -u)" -ne 0 ]]; then
        read -p "Este paso requiere privilegios de superusuario. ¿Deseas continuar? (si/no): "
        if [[ $REPLY == "si" ]]; then
            instalar_paquete_con_privilegios "$paquete"
        else
            echo -e "${rojo}Error:${reset} Se requieren privilegios de superusuario para continuar. Saliendo del script."
            exit 1
        fi
    else
        instalar_paquete_con_privilegios "$paquete"
    fi
}

# Función para instalar un paquete con privilegios de superusuario
instalar_paquete_con_privilegios() {
    local paquete="$1"
    comprobar_conexion
    sudo apt-get update && sudo apt-get install -y "$paquete"
    if [[ $? -eq 0 ]]; then
        echo -e "${verde}El paquete $paquete se ha instalado correctamente.${reset}"
    else
        echo -e "${rojo}Error:${reset} No se pudo instalar el paquete $paquete."
        exit 1
    fi
}

# Función para comprobar la conexión a internet
comprobar_conexion() {
    if ! ping -c 1 8.8.8.8 &> /dev/null; then
        echo -e "${rojo}Error:${reset} No se detecta conexión a internet. Por favor, verifica tu conexión e inténtalo nuevamente."
        exit 1
    fi
}


# Función para imprimir encabezados con formato
imprimir_encabezado() {
    local encabezado="$1"
    echo -e "\n${azul}== $encabezado ==${reset}"
}

#Función para mostrar información
mostrar_informacion() {
    local mensaje="$1"
    echo -e "\n${amarillo}${mensaje}${reset}"
    read -n 1 -s -p "Presiona 'S' para continuar o cualquier otra tecla para salir..."
    echo ""
    if [[ $REPLY != "S" ]]; then
        echo -e "${rojo}No has pulsado 'S'. ¿Seguro que quieres salir del script?${reset}"
        read -n 1 -s -p "Presiona 'S' para continuar o cualquier otra tecla para salir..."
        echo ""
        if [[ $REPLY != "S" ]]; then
            exit 1
        fi
    fi
}


# Función para mostrar información de la memoria RAM
mostrar_memoria_ram() {
    mostrar_informacion "Pulsa 'S' para ver la información de la RAM."
    imprimir_encabezado "Información de la RAM"
    if [[ -n "$(cat /proc/swaps | grep -v '^Filename')" ]]; then
        echo "¡Espacio de intercambio (swap) está configurado en el sistema!"
        echo "Mostrando toda la información con respecto a la Memoria Ram y a la SWAP..."
        sleep 1
        memoria_ram "INFORMACIÓN CON SWAP"
        free -h
    else
        echo "No se encontró espacio de intercambio (swap) configurado en el sistema."
        echo "Mostrando la información con respecto a la Memoria RAM..."
        sleep 1
        free -h | head -n 2
    fi
}

# Función para mostrar información de la CPU
mostrar_informacion_cpu() {
    mostrar_informacion "Pulsa 'S' para ver la información de la CPU."
    imprimir_encabezado "Información de la CPU"
    echo -e "${amarillo}Obteniendo información de la CPU...${reset}"
    lscpu
}

# Función para mostrar información de los discos
mostrar_informacion_discos() {
    mostrar_informacion "Pulsa 'S' para ver la información de los discos."
    imprimir_encabezado "Información de los Discos"
    echo -e "${amarillo}Obteniendo información de los Discos...${reset}"
    df -h
}

# Función para mostrar información de las interfaces de red
mostrar_informacion_interfaces_red() {
    mostrar_informacion "Pulsa 'S' para ver la información de las tarjetas de red."
    imprimir_encabezado "Información de las Interfaces de Red"
    echo -e "${amarillo}Obteniendo información de las Interfaces de Red...${reset}"
    ip addr show
}

# Función para mostrar información de las tarjetas gráficas
mostrar_informacion_tarjetas_graficas() {
    mostrar_informacion "Pulsa 'S' para ver la información de las tarjetas graficas."
    imprimir_encabezado "Información de las Tarjetas Gráficas"
    echo -e "${amarillo}Obteniendo información de las Tarjetas Gráficas...${reset}"
    lshw -C display
}

# Verificar la existencia de los comandos necesarios
#echo -e "${amarillo}Verificando la existencia de los comandos necesarios...${reset}"
#verificar_comando lscpu instalar
#verificar_comando free instalar

#echo -e "${verde}Todos los comandos necesarios están disponibles.${reset}"

#Comprobación comandos
verificar_comando 'lscpu'

# Llamar a cada función de mostrar información
mostrar_informacion_cpu
mostrar_informacion_ram
mostrar_informacion_discos
mostrar_informacion_interfaces_red
mostrar_informacion_tarjetas_graficas

echo -e "${verde}Fin del script.${reset}"
