#!/bin/bash

comprobar_paquete() {
    comando=$1
    paquetes=$(apt-cache search "$comando" | awk '{print $1}')
    if [ -z "$paquetes" ]; then
        echo "El comando '$comando' no está asociado a ningún paquete."
        return 1
    else
        echo "Los siguientes paquetes pueden proporcionar el comando '$comando':"
        echo "$paquetes"
        return 0
    fi
}

buscar_paquete() {
    paquete=$1
    if ! apt-cache show "$paquete" > /dev/null 2>&1; then
        echo "El paquete '$paquete' no existe en los repositorios."
        return 1
    else
        sudo apt update
        sudo apt install "$paquete"
    fi
}

main() {
    comando=$1
    if ! command -v "$comando" > /dev/null 2>&1; then
        read -p "¿Quieres instalar el paquete que proporciona '$comando' (s/n)?: " confirmacion
        if [ "$confirmacion" == "s" ]; then
            if comprobar_paquete "$comando"; then
                read -p "Introduce el nombre del paquete que quieres instalar: " paquete
                if [ -n "$paquete" ]; then
                    buscar_paquete "$paquete"
                else
                    echo "No se ha especificado un nombre de paquete válido."
                    return 1
                fi
            fi
        else
            echo "No se instalará ningún paquete."
            return 1
        fi
    else
        echo "El comando '$comando' ya existe en el sistema."
    fi
}

# Ejemplo de uso
main cmatrixasdad
