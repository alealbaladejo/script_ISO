#!/usr/bin/env bash
# Autor: Alejandro Albaladejo y Raúl Herrera
# Descripción: Script para mostrar características del hardware.

# Colores para el formato del texto
rojo='\e[1;31m'
verde='\e[1;32m'
amarillo='\e[1;33m'
azul='\e[1;34m'
reset='\e[0m'

# Función para verificar la existencia de un comando
verificar_comando() {
    if ! command -v "$1" &> /dev/null; then
        echo -e "${rojo}Error:${reset} El comando '$1' no está disponible o no se encuentra en la ruta de búsqueda."
        if [[ "$2" == "instalar" ]]; then
            read -p "¿Deseas instalarlo? (si/no): " opcion
            if [[ "$opcion" == "si" ]]; then
                if [[ "$(id -u)" -ne 0 ]]; then
                    read -p "Este paso requiere privilegios de superusuario. ¿Deseas continuar? (si/no): " superusuario
                    if [[ "$superusuario" == "si" ]]; then
                        sudo apt-get update && sudo apt-get install -y "$1"
                        if [[ $? -eq 0 ]]; then
                            echo -e "${verde}El paquete $1 se ha instalado correctamente.${reset}"
                        else
                            echo -e "${rojo}Error:${reset} No se pudo instalar el paquete $1."
                            exit 1
                        fi
                    else
                        echo -e "${rojo}Error:${reset} Se requieren privilegios de superusuario para continuar. Saliendo del script."
                        exit 1
                    fi
                else
                    if ping -c 1 8.8.8.8 &> /dev/null; then
                        apt-get update && apt-get install -y "$1"
                        if [[ $? -eq 0 ]]; then
                            echo -e "${verde}El paquete $1 se ha instalado correctamente.${reset}"
                        else
                            echo -e "${rojo}Error:${reset} No se pudo instalar el paquete $1."
                            exit 1
                        fi
                    else
                        echo -e "${rojo}Error:${reset} No se detecta conexión a internet. Por favor, verifica tu conexión e inténtalo nuevamente."
                        exit 1
                    fi
                fi
            else
                echo -e "${rojo}Error:${reset} Sin el paquete $1, no se puede continuar. Saliendo del script."
                exit 1
            fi
        else
            exit 1
        fi
    fi
}

# Función para imprimir encabezados con formato
imprimir_encabezado() {
    local encabezado="$1"
    echo -e "\n${azul}== $encabezado ==${reset}"
}

# Función para mostrar información de la memoria RAM
mostrar_memoria_ram() {
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
    echo -e "Hola"
}

# Verificar la existencia de los comandos necesarios
echo -e "${amarillo}Verificando la existencia de los comandos necesarios...${reset}"
verificar_comando lscpu instalar
verificar_comando free instalar
echo -e "${verde}Todos los comandos necesarios están disponibles.${reset}"

#Función para seguir con el script


# Mensaje para avanzar al siguiente paso
echo -e "\nPresione ${amarillo}Enter${reset} para ver la siguiente información..."

# Esperar a que el usuario presione una tecla
read -s tecla

# Verificar si se presionó Enter
if [[ $tecla == "s" ]]; then
    clear
    mostrar_informacion_cpu
    echo -e "\n${azul}Presione ${cyan}Enter${azul} para continuar..."
    read tecla
else
    echo -e "${rojo}Error:${reset} Se esperaba que presionara Enter para ver la siguiente información."
    read -p "¿Deseas continuar con el script? Presiona Enter si desea continuar, si presionas otra tecla se cerrara el script: " tecla
    if [[ $tecla == "s" ]]; then
        mostrar_informacion_cpu
    else
	
    fi
fi

# Verificar si se presionó Enter nuevamente
if [[ $tecla == "s" ]]; then
    clear
    mostrar_memoria_ram
    echo -e "\n${azul}Presione ${cyan}Enter${azul} para continuar..."
    read tecla
else
    echo -e "${rojo}Error:${reset} Se esperaba que presionara Enter para ver la siguiente información."
    read -p "¿Deseas continuar con el script? Presiona Enter si desea continuar, si presionas otra tecla se cerrara el script: " tecla
    if [[ $tecla != "s" ]]; then
        exit 1
    fi
fi

# Verificar si se presionó Enter nuevamente
if [[ $tecla == "s" ]]; then
    clear
    mostrar_informacion_discos
    echo -e "\n${azul}Presione ${cyan}Enter${azul} para continuar..."
    read tecla
else
    echo -e "${rojo}Error:${reset} Se esperaba que presionara Enter para ver la siguiente información."
    read -p "¿Deseas continuar con el script? Presiona Enter si desea continuar, si presionas otra tecla se cerrara el script: " tecla
    if [[ $tecla != "s" ]]; then
        exit 1
    fi
fi

# Verificar si se presionó Enter nuevamente
if [[ $tecla == "s" ]]; then
    clear
    mostrar_informacion_interfaces_red
    echo -e "\n${azul}Presione ${cyan}Enter${azul} para continuar..."
    read tecla
else
    echo -e "${rojo}Error:${reset} Se esperaba que presionara Enter para ver la siguiente información."
    read -p "¿Deseas continuar con el script? Presiona Enter si desea continuar, si presionas otra tecla se cerrara el script: " tecla
    if [[ $tecla != "s" ]]; then
        exit 1
    fi
fi

# Verificar si se presionó Enter nuevamente
if [[ $tecla == "s" ]]; then
    clear
    mostrar_informacion_tarjetas_graficas
    echo -e "Nada"
    echo -e "\n${verde}Fin del script.${reset}"
    read tecla
else
    echo -e "${rojo}Error:${reset} Se esperaba que presionara Enter para ver la siguiente información."
    read -p "¿Deseas continuar con el script? Presiona Enter si desea continuar, si presionas otra tecla se cerrara el script: " tecla
    if [[ $tecla != "s" ]]; then
        exit 1
    fi
fi

