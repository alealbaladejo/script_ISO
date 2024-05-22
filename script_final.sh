#!/bin/bash
# Autor: Alejandro Albaladejo y Raúl Herrera
# Descripción: Script de menú para elegir entre el script de bash o sh.

# Ruta a los scripts
BASH_SCRIPT="./script_bash.sh"
SH_SCRIPT="./script_sh.sh"

# Función para mostrar el menú
mostrar_menu() {
    opcion="0"
    while [ "$opcion" -ne 3 ]; do
        echo "-------------------------MENU-------------------------"
        echo "Opción 1: Ejecutar script de bash"
        echo "Opción 2: Ejecutar script de sh"
        echo "Opción 3: Salir del menú"
        echo "------------------------------------------------------"
        printf "Introduce la opción que quieras ejecutar: "
        read opcion

        case "$opcion" in
            1)
                echo "Ejecutando script de bash..."
                bash "$BASH_SCRIPT"
		opcion=3
                ;;
            2)
                echo "Ejecutando script de sh..."
                sh "$SH_SCRIPT"
		opcion=3
                ;;
            3)
                echo "Saliendo del menú..."
                sleep 1
                ;;
            *)
                echo "Opción no válida. Por favor, selecciona una opción del 1 al 3."
                sleep 2
                clear
                ;;
        esac
    done
}

# Mostrar el menú
mostrar_menu