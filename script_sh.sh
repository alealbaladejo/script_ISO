#!/usr/bin/env sh
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
    opcion="0"
    while [ "$opcion" -ne 7 ]; do
        echo "${verde}-------------------------MENU-------------------------${reset}"
        echo "${verde}Opción 1:${reset} Mostrar información de la CPU"
        echo "${verde}Opción 2:${reset} Mostrar información de la memoria RAM"
        echo "${verde}Opción 3:${reset} Mostrar información de los discos"
        echo "${verde}Opción 4:${reset} Mostrar información de las interfaces de red"
        echo "${verde}Opción 5:${reset} Mostrar información de las tarjetas gráficas"
        echo "${verde}Opción 6:${reset} Mostrar TODO"
        echo "${verde}Opción 7:${reset} Salir del script"
        echo "${verde}------------------------------------------------------${reset}"
        printf "Introduce la opción que quieras mostrar: "
        read opcion

        case "$opcion" in
            1) mostrar_informacion_cpu 
                opcion=7;;
            2) mostrar_memoria_ram 
                opcion=7;;
            3) mostrar_informacion_discos 
                opcion=7;;
            4) mostrar_informacion_interfaces_red 
                opcion=7;;
            5) mostrar_informacion_tarjetas_graficas
                opcion=7;;
            6)
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
                opcion=7
                ;; 
            7) 
                echo "${rojo}Saliendo del script...${reset}"
                sleep 1
                ;;
            *) 
                echo "${rojo}Opción no válida. Por favor, selecciona una opción del 1 al 7.${reset}"
                sleep 2
                clear
                ;;
        esac
    done
}


asegurar_apt_file() {
    if ! command -v apt-file >/dev/null 2>&1; then
        printf "El comando apt-file no está instalado, ¿Deseas instalarlo? (si/no): "
        read confirmacion
        if [ "$confirmacion" = "si" ]; then
            echo "${amarillo}El paquete 'apt-file' no está instalado. Procediendo a instalarlo...${reset}"
            sudo apt update && sudo apt install -y apt-file
            if [ $? -eq 0 ]; then
                echo "${verde}El paquete 'apt-file' se ha instalado correctamente.${reset}"
                sudo apt-file update
                clear
            else
                echo "${rojo}Error:${reset} No se pudo instalar el paquete 'apt-file'."
                exit 1
            fi
        fi
    else
        echo "${verde}El paquete 'apt-file' ya está instalado, pasaremos a actualizarlo.${reset}"
        sleep 1
        sudo apt-file update
        clear
    fi
}

buscar_paquete_por_comando() {
    comando="$1"
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

verificar_comando() {
    comando="$1"
    if apt-file search "$comando" >/dev/null 2>&1; then
        if ! command -v "$comando" >/dev/null 2>&1; then
            echo "${rojo}Error:${reset} El comando '$comando' no está disponible o no se encuentra en la ruta de búsqueda."
            printf "El comando '$comando' no está instalado, ¿Deseas instalarlo? (si/no): "
            read confirmacion
            if [ "$confirmacion" = "si" ]; then
                if buscar_paquete_por_comando "$comando"; then
                    printf "Introduce el nombre del paquete que quieres instalar: "
                    read paquete
                    if [ -n "$paquete" ]; then
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

instalar_paquete() {
    paquete="$1"
    if [ "$(id -u)" -ne 0 ]; then
        printf "Este paso requiere privilegios de superusuario. ¿Deseas continuar? (si/no): "
        read confirmar
        if [ "$confirmar" = "si" ]; then
            instalar_paquete_con_privilegios "$paquete"
        else
            echo "${rojo}Error:${reset} Se requieren privilegios de superusuario para continuar. Saliendo del script."
            exit 1
        fi
    else
        instalar_paquete_con_privilegios "$paquete"
    fi
}

instalar_paquete_con_privilegios() {
    paquete="$1"
    comprobar_conexion
    sudo apt update && sudo apt install -y "$paquete"
    if [ $? -eq 0 ]; then
        echo "${verde}El paquete $paquete se ha instalado correctamente.${reset}"
        clear
    else
        echo "${rojo}Error:${reset} No se pudo instalar el paquete $paquete."
        exit 1
    fi
}

comprobar_conexion() {
    if ! ping -c 1 8.8.8.8 >/dev/null 2>&1; then
        echo "${rojo}Error:${reset} No se detecta conexión a internet. Por favor, verifica tu conexión e inténtalo nuevamente."
        exit 1
    fi
}

imprimir_encabezado() {
    encabezado="$1"
    echo "\n${azul}== $encabezado ==${reset}"
}

mostrar_informacion() {
    mensaje="$1"
    echo "\n${amarillo}${mensaje}${reset}"
    printf "Presiona 'S' para continuar o cualquier otra tecla para salir..."
    read REPLY
    echo ""
    if [ "$REPLY" != "S" ]; then
        echo "${rojo}No has pulsado 'S'. ¿Seguro que quieres salir del script?${reset}"
        printf "Presiona 'S' para continuar o cualquier otra tecla para salir..."
        read REPLY
        echo ""
        if [ "$REPLY" != "S" ]; then
            exit 1
        else
            clear
        fi
    else
        clear
    fi
}

mostrar_memoria_ram() {
    imprimir_encabezado "Información de la RAM"
    if [ -n "$(cat /proc/swaps | grep -v '^Filename')" ]; then
        echo "¡Espacio de intercambio (swap) está configurado en el sistema!"
        echo "Mostrando toda la información con respecto a la Memoria Ram y a la SWAP..."
        sleep 1
        free -h
    else
        echo "No se encontró espacio de intercambio (swap) configurado en el sistema."
        echo "Mostrando la información con respecto a la Memoria RAM..."
        sleep 1
        free -h | head -n 2
    fi
}

mostrar_informacion_cpu() {
    imprimir_encabezado "Información de la CPU"
    echo "${amarillo}Obteniendo información de la CPU...${reset}"
    lscpu
}

mostrar_informacion_discos() {
    imprimir_encabezado "Información de los Discos"
    echo "${amarillo}Obteniendo información de los Discos...${reset}"
    df -h
}

mostrar_informacion_interfaces_red() {
    imprimir_encabezado "Información de las Interfaces de Red"
    echo "${amarillo}Obteniendo información de las Interfaces de Red...${reset}"
    ip addr show
}

mostrar_informacion_tarjetas_graficas() {
    imprimir_encabezado "Información de las Tarjetas Gráficas"
    echo "${amarillo}Obteniendo información de las Tarjetas Gráficas...${reset}"
    lshw -C display
}

# Verificar la existencia de los comandos necesarios
echo "${amarillo}Verificando la existencia del comando apt-file...${reset}"
asegurar_apt_file
echo "${amarillo}Verificando la existencia de los comandos necesarios...${reset}"
verificar_comando lscpu 
verificar_comando free 
verificar_comando df
verificar_comando lshw
verificar_comando ip

echo "${verde}Todos los comandos necesarios están disponibles.${reset}"

# Llamar a cada función de mostrar información
mostrar_menu

echo "${verde}Fin del script.${reset}"
