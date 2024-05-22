#!/usr/bin/env bash
# Autor: Alejandro Albaladejo y Raúl Herrera
# Descripción: Script para mostrar características del hardware.

# Colores para el formato del texto
rojo='\e[1;31m'
verde='\e[1;32m'
amarillo='\e[1;33m'
azul='\e[1;34m'
reset='\e[0m'

# MENU
mostrar_menu() {
    local opcion="0"
    while [[ $opcion -ne 7 ]]; do
        echo -e "${verde}-------------------------MENU-------------------------${reset}"
        echo -e "${verde}Opción 1:${reset} Mostrar información de la CPU"
        echo -e "${verde}Opción 2:${reset} Mostrar información de la memoria RAM"
        echo -e "${verde}Opción 3:${reset} Mostrar información de los discos"
        echo -e "${verde}Opción 4:${reset} Mostrar información de las interfaces de red"
        echo -e "${verde}Opción 5:${reset} Mostrar información de las tarjetas gráficas"
        echo -e "${verde}Opción 6:${reset} Mostrar TODO"
        echo -e "${verde}Opción 7:${reset} Salir del script"
        echo -e "${verde}------------------------------------------------------${reset}"
        read -p "Introduce la opción que quieras mostrar: " opcion


        if [[ $opcion == 1 ]]; then
            mostrar_informacion_cpu
            opcion=7;
        elif [[ $opcion == 2 ]]; then
            mostrar_memoria_ram
            opcion=7;
        elif [[ $opcion == 3 ]]; then
            mostrar_informacion_discos
            opcion=7;
        elif [[ $opcion == 4 ]]; then
            mostrar_informacion_interfaces_red
            opcion=7;
        elif [[ $opcion == 5 ]]; then
            mostrar_informacion_tarjetas_graficas
            opcion=7;
        elif [[ $opcion == 6 ]]; then
            mostrar_informacion "Pulsa 'S' para ver la información de la CPU."
            mostrar_informacion_cpu
            mostrar_informacion "Pulsa 'S' para ver la información de la RAM."
            mostrar_memoria_ram
            mostrar_informacion "Pulsa 'S' para ver la información de los DISCOS."
            mostrar_informacion_discos
            mostrar_informacion "Pulsa 'S' para ver la información de las INTERFACES."
            mostrar_informacion_interfaces_red
            mostrar_informacion "Pulsa 'S' para ver la información de TARJETA GRAFICA."
            mostrar_informacion_tarjetas_graficas
            opcion=7;
        elif [[ $opcion == 7 ]]; then
            echo -e "${rojo}Saliendo del script...${reset}"
            sleep 1
        else
            echo -e "${rojo}Opción no válida. Por favor, selecciona una opción del 1 al 7.${reset}"
            sleep 2
            clear
        fi
    done
}


# Función para asegurar la instalación de apt-file
asegurar_apt_file() {
    if ! command -v apt-file &> /dev/null; then
        read -p "El comando apt-file no está instalado, ¿Deseas instalarlo? (si/no): " confirmacion
        if [[ $confirmacion == "si" ]]; then
            echo -e "${amarillo}El paquete 'apt-file' no está instalado. Procediendo a instalarlo...${reset}"
            sudo apt update && sudo apt install -y apt-file
            if [[ $? -eq 0 ]]; then
                echo -e "${verde}El paquete 'apt-file' se ha instalado correctamente.${reset}"
                sudo apt-file update
                clear
            else
                echo -e "${rojo}Error:${reset} No se pudo instalar el paquete 'apt-file'."
                exit 1
            fi
        fi
    else
        echo -e "${verde}El paquete 'apt-file' ya está instalado, pasaremos a actualizarlo.${reset}"
        sleep 1
        sudo apt-file update
        clear
    fi
}

# Función para buscar paquetes asociados a un comando
buscar_paquete_por_comando() {
    local comando="$1"
    paquetes=$(apt-file search "$comando" | awk -F: '{print $1}' | sort -u)
    if [ -z "$paquetes" ]; then
        echo "El comando '$comando' no está asociado a ningún paquete."
        return 1
    else
        echo "Los siguientes paquetes pueden proporcionar el comando '$comando':"
        echo "$paquetes"
        return 0
    fi
}

# Función para verificar si el comando está instalado y ofrecer su instalación
verificar_comando() {
    local comando="$1"
    if apt-file search "$comando" &> /dev/null; then
        if ! command -v "$comando" &> /dev/null; then
            echo -e "${rojo}Error:${reset} El comando '$comando' no está disponible o no se encuentra en la ruta de búsqueda."
            read -p -n 1 "El comando '$comando' no está instalado, ¿Deseas instalarlo? (si/no): " confirmacion
            if [[ $confirmacion == "si" ]]; then
                if buscar_paquete_por_comando "$comando"; then
                    read -p "Introduce el nombre del paquete que quieres instalar: " paquete
                    if [ -n $paquete ]; then
                        instalar_paquete "$paquete"
                    else
                        echo "No se ha especificado un nombre de paquete válido."
                        return 1
                    fi
                fi
            else
                exit 1
            fi
        else
            return 0
        fi
    else
        echo "No existe el comando '$comando'."
    fi
}

# Función para instalar un paquete
instalar_paquete() {
    local paquete="$1"
    if [[ "$(id -u)" -ne 0 ]]; then
        read -p "Este paso requiere privilegios de superusuario. ¿Deseas continuar? (si/no): " confirmar
        if [[ $confirmar == "si" ]]; then
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
    sudo apt update && sudo apt install -y $paquete
    if [[ $? -eq 0 ]]; then
        echo -e "${verde}El paquete $paquete se ha instalado correctamente.${reset}"
        clear
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
	else
		clear
        fi
    else
	clear
    fi
}


# Función para mostrar información de la memoria RAM
mostrar_memoria_ram() {
    
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
    imprimir_encabezado "Información de la CPU"
    echo -e "${amarillo}Obteniendo información de la CPU...${reset}"
    lscpu
}

# Función para mostrar información de los discos
mostrar_informacion_discos() {
    imprimir_encabezado "Información de los Discos"
    echo -e "${amarillo}Obteniendo información de los Discos...${reset}"
    df -h
}

# Función para mostrar información de las interfaces de red
mostrar_informacion_interfaces_red() {
    imprimir_encabezado "Información de las Interfaces de Red"
    echo -e "${amarillo}Obteniendo información de las Interfaces de Red...${reset}"
    ip addr show
}

# Función para mostrar información de las tarjetas gráficas
mostrar_informacion_tarjetas_graficas() {
    imprimir_encabezado "Información de las Tarjetas Gráficas"
    echo -e "${amarillo}Obteniendo información de las Tarjetas Gráficas...${reset}"
    lshw -C display
}

# Verificar la existencia de los comandos necesarios
echo -e "${amarillo}Verificando la existencia del comando apt-file...${reset}"
asegurar_apt_file
echo -e "${amarillo}Verificando la existencia de los comandos necesarios...${reset}"
verificar_comando lscpu 
verificar_comando free 
verificar_comando df
verificar_comando lshw
verificar_comando ip

echo -e "${verde}Todos los comandos necesarios están disponibles.${reset}"

# Llamar a cada función de mostrar información
mostrar_menu

echo -e "${verde}Fin del script.${reset}"
