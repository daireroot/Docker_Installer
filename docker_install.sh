#!/bin/bash

installApps()
{
    clear
    OS="$REPLY" ## <-- Este $REPLY se refiere a la selección del sistema operativo
    echo "Podemos instalar Docker-CE y Docker-Compose."
    echo "Seleccione "y" para cada elemento que desee instalar."
    echo ""
    echo ""
    
    ISACT=$( (sudo systemctl is-active docker ) 2>&1 )
    ISCOMP=$( (docker-compose -v ) 2>&1 )

    #### Intenta comprobar si docker está instalado y en ejecución - no pregunta si lo está
    if [[ "$ISACT" != "active" ]]; then
        read -rp "Docker-CE (y/n): " DOCK
    else
        echo "Docker parece estar instalado y funcionando."
        echo ""
        echo ""
    fi

    if [[ "$ISCOMP" == *"command not found"* ]]; then
        read -rp "Docker-Compose (y/n): " DCOMP
    else
        echo "Docker-compose parece estar instalado."
        echo ""
        echo ""
    fi
    
    startInstall
}

startInstall() 
{
    clear
    echo "#######################################################"
    echo "###         Preparativos para la instalación        ###"
    echo "#######################################################"
    echo ""
    sleep 3s

#######################################################
###         Instalación para Debian / Ubuntu        ###
#######################################################

    if [[ "$OS" == [234] ]]; then
        echo "    1. Actualizando paquetes del sistema..."
        (sudo apt update && sudo apt upgrade -y) > ~/docker-script-install.log 2>&1 &
        ## Mostrar el progreso de la actividad
        pid=$! # Identificador de proceso del comando anterior
        spin='-\|/'
        i=0
        while kill -0 $pid 2>/dev/null
        do
            i=$(( (i+1) %4 ))
            printf "\r${spin:$i:1}"
            sleep .1
        done
        printf "\r"

        echo "    2. Instalar paquetes de requisitos previos..."
        sleep 2s

        sudo apt install curl wget git -y >> ~/docker-script-install.log 2>&1
        
        if [[ "$ISACT" != "active" ]]; then
            echo "   3. Instalando Docker-CE (Community Edition)..."
            sleep 2s

        
            curl -fsSL https://get.docker.com | sh >> ~/docker-script-install.log 2>&1
            echo "      - la versión de docker es:"
            DOCKERV=$(docker -v)
            echo "          "${DOCKERV}
            sleep 3s

            if [[ "$OS" == 2 ]]; then
                echo "    5. Iniciando el servicio Docker".
                sudo systemctl docker start >> ~/docker-script-install.log 2>&1
            fi
        fi

    fi
        
    
#######################################################
###           Instalación para CentOS 7 u 8         ###
#######################################################
    if [[ "$OS" == "1" ]]; then
        if [[ "$DOCK" == [yY] ]]; then
            echo "    1. Actualizando paquetes del sistema..."
            sudo yum check-update > ~/docker-script-install.log 2>&1

            echo "    2. Instalando Paquetes de Requisitos Previos..."
            sudo dnf install git curl wget -y >> ~/docker-script-install.log 2>&1

            if [[ "$ISACT" != "active" ]]; then
                echo "    3. Instalando Docker-CE (Community Edition)..."

                sleep 2s
                (curl -fsSL https://get.docker.com/ | sh) >> ~/docker-script-install.log 2>&1

                echo "    4. Iniciando el servicio Docker..."

                sleep 2s


                sudo systemctl start docker >> ~/docker-script-install.log 2>&1

                echo "    5. Habilitando el servicio Docker..."
                sleep 2s

                sudo systemctl enable docker >> ~/docker-script-install.log 2>&1

                echo "      - la versión de docker es:"
                DOCKERV=$(docker -v)
                echo "        "${DOCKERV}
                sleep 3s
            fi
        fi
    fi

#######################################################
###          Instalación para Arch Linux            ###
#######################################################

    if [[ "$OS" == "5" ]]; then
        read -rp "Do you want to install system updates prior to installing Docker-CE? (y/n): " UPDARCH
        if [[ "$UPDARCH" == [yY] ]]; then
            echo "    1. Actualizando paquetes del sistema..."
            (sudo pacman -Syu --noconfirm) > ~/docker-script-install.log 2>&1 &
           ## Mostrar el progreso de la actividad
            pid=$! # Identificador de proceso del comando anterior
            spin='-\|/'
            i=0
            while kill -0 $pid 2>/dev/null
            do
                i=$(( (i+1) %4 ))
                printf "\r${spin:$i:1}"
                sleep .1
            done
            printf "\r"
        else
            echo "   1. Omitiendo actualizaciones del sistema..."
            sleep 2s
        fi

        echo "    2. Instalando Paquetes de Requisitos Previos..."
        sudo pacman -Sy git curl wget --noconfirm >> ~/docker-script-install.log 2>&1

        if [[ "$ISACT" != "active" ]]; then
            echo "    3. Instalando Docker-CE (Community Edition)..."
            sleep 2s

            sudo pacman -Sy docker --noconfirm >> ~/docker-script-install.log 2>&1

            echo "    - la versión de docker es:"
            DOCKERV=$(docker -v)
            echo "        "${DOCKERV}
            sleep 3s
        fi
    fi

#######################################################
###            Instalación para Open Suse           ###
#######################################################

    if [[ "$OS" == "6" ]]; then
        # install system updates first
        read -rp "Do you want to install system updates prior to installing Docker-CE? (y/n): " UPDSUSE
        if [[ "$UPDSUSE" == [yY] ]]; then
            echo "    1. Actualizando paquetes del sistema..."

            (sudo zypper -n update) > docker-script-install.log 2>&1 &
           ## Mostrar el progreso de la actividad
            pid=$! # Identificador de proceso del comando anterior
            spin='-\|/'
            i=0
            while kill -0 $pid 2>/dev/null
            do
                i=$(( (i+1) %4 ))
                printf "\r${spin:$i:1}"
                sleep .1
            done
            printf "\r"
        else
            echo "   1. Omitiendo actualizaciones del sistema..."
            sleep 2s
        fi

        echo "    2. Instalando Paquetes de Requisitos Previos..."
        sudo zypper -n install git curl wget >> ~/docker-script-install.log 2>&1

        if [[ "$ISACT" != "active" ]]; then
            echo "    3. Instalando Docker-CE (Community Edition)..."
            sleep 2s

            sudo zypper -n install docker-compose >> ~/docker-script-install.log 2>&1
            sudo zypper -n remove docker-compose
            echo "Giving the Docker service time to start..."
        
            sudo systemctl start docker >> ~/docker-script-install.log 2>&1
            sleep 5s &
            pid=$! # Identificador de proceso del comando anterior
            spin='-\|/'
            i=0
            while kill -0 $pid 2>/dev/null
            do
                i=$(( (i+1) %4 ))
                printf "\r${spin:$i:1}"
                sleep .1
            done
            printf "\r"
            sudo systemctl enable docker >> ~/docker-script-install.log 2>&1

            echo "    - la versión de docker es:"
            DOCKERV=$(docker -v)
            echo "        "${DOCKERV}
            sleep 3s
        fi
    fi

    if [[ "$ISACT" != "active" ]]; then
        if [[ "$DOCK" == [yY] ]]; then
            # añade el usuario actual al grupo docker para que sudo no sea necesario
            echo ""
            echo "  - Intentando añadir el usuario actualmente conectado al grupo docker..."

            sleep 2s
            sudo usermod -aG docker "${USER}" >> ~/docker-script-install.log 2>&1
            echo "  - Tendrás que cerrar la sesión y volver a entrar para finalizar la adición de tu usuario al grupo docker."
            echo ""
            echo ""
            sleep 3s
        fi
    fi

    if [[ "$DCOMP" = [yY] ]]; then
        echo "############################################"
        echo "####   Instalacion de Docker-Compose    ####"
        echo "############################################"

        # instalar docker-compose
        echo ""
        echo "    1. Instalando Docker-Compose..."
        echo ""
        echo ""
        sleep 2s

        ######################################
        ### Instalacion en Debian / Ubuntu ###
        ######################################        
        
        if [[ "$OS" == "2" || "$OS" == "3" || "$OS" == "4" ]]; then
            VERSION=$(curl --silent https://api.github.com/repos/docker/compose/releases/latest | grep -Po '"tag_name": "\K.*\d')
		    sudo curl -SL https://github.com/docker/compose/releases/download/$VERSION/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
            #sudo curl -L "https://github.com/docker/compose/releases/download/$(curl https://github.com/docker/compose/releases | grep -m1 '<a href="/docker/compose/releases/download/' | grep -o 'v[0-9:].[0-9].[0-9]')/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

            sleep 2
            sudo chmod +x /usr/local/bin/docker-compose
        fi
        ######################################
        ###  Instalacion en CentOS 7 or 8  ###
        ######################################

        if [[ "$OS" == "1" ]]; then
            VERSION=$(curl --silent https://api.github.com/repos/docker/compose/releases/latest | grep -Po '"tag_name": "\K.*\d')
		    sudo curl -SL https://github.com/docker/compose/releases/download/$VERSION/docker-compose-linux-x86_64 -o /usr/bin/docker-compose >> ~/docker-script-install.log 2>&1

            sudo chmod +x /usr/bin/docker-compose >> ~/docker-script-install.log 2>&1
        fi

        ######################################
        ###   Instalacion en Arch Linux    ###
        ######################################

        if [[ "$OS" == "5" ]]; then
            sudo pacman -Sy docker-compose --noconfirm > ~/docker-script-install.log 2>&1
        fi

        ######################################
        ###   Instalacion en Open Suse     ###
        ######################################

        if [[ "$OS" == "6" ]]; then
            VERSION=$(curl --silent https://api.github.com/repos/docker/compose/releases/latest | grep -Po '"tag_name": "\K.*\d')
		    sudo curl -SL https://github.com/docker/compose/releases/download/$VERSION/docker-compose-linux-x86_64 -o /usr/bin/docker-compose >> ~/docker-script-install.log 2>&1

            sudo chmod +x /usr/bin/docker-compose >> ~/docker-script-install.log 2>&1
        fi

        echo ""

        echo "      - la versión de docker-compose es:" 
        DOCKCOMPV=$(docker-compose --version)
        echo "        "${DOCKCOMPV}
        echo ""
        echo ""
        sleep 3s
    fi

    ###########################################################
    #### Comprobar si se está ejecutando el servicio Docker ###
    ###########################################################
    ISACT=$( (sudo systemctl is-active docker ) 2>&1 )
    if [[ "$ISACt" != "active" ]]; then
        echo "Dando tiempo al servicio Docker para arrancar..."
        while [[ "$ISACT" != "active" ]] && [[ $X -le 10 ]]; do
            sudo systemctl start docker >> ~/docker-script-install.log 2>&1
            sleep 10s &
            pid=$! # Identificador de proceso del comando anterior
            spin='-\|/'
            i=0
            while kill -0 $pid 2>/dev/null
            do
                i=$(( (i+1) %4 ))
                printf "\r${spin:$i:1}"
                sleep .1
            done
            printf "\r"
            ISACT=`sudo systemctl is-active docker`
            let X=X+1
            echo "$X"
        done
    fi

    echo "################################################"
    echo "######       Creando Docker Network    #########"
    echo "################################################"

    sudo docker network create internal
    sleep 2s

    echo ""
    echo "Si añades más aplicaciones Docker a este servidor, asegúrate de añadirlas a la red internal".

    exit 1
}

echo ""
echo ""

clear

echo "Determinemos qué sistema operativo o distribución utiliza."
echo ""
echo ""
echo "    A partir de alguna información básica sobre su sistema, parece estar ejecutando: "
echo "        --  Nombre OS         " $(lsb_release -i)
echo "        --  Descripcion        " $(lsb_release -d)
echo "        --  Version de OS       " $(lsb_release -r)
echo "        --  Code Name        " $(lsb_release -c)
echo ""
echo "------------------------------------------------"
echo ""

PS3="Seleccione el número correspondiente a su sistema operativo o distribución: "
select _ in \
    "CentOS 7 / 8 / Fedora" \
    "Debian 10 / 11" \
    "Ubuntu 18.04" \
    "Ubuntu 20.04 / 21.04 / 22.04" \
    "Arch Linux" \
    "Open Suse"\
    "Finalizar Instalador"
do
  case $REPLY in
    1) installApps ;;
    2) installApps ;;
    3) installApps ;;
    4) installApps ;;
    5) installApps ;;
    6) installApps ;;
    7) exit ;;
    *) echo "Selección no válida, por favor inténtelo de nuevo..." ;;
  esac
done