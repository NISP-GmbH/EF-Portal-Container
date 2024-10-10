#!/bin/bash
################################################################################
# Copyright (C) 2019-2024 NI SP GmbH
# All Rights Reserved
#
# info@ni-sp.com / www.ni-sp.com
#
# We provide the information on an as is basis.
# We provide no warranties, express or implied, related to the
# accuracy, completeness, timeliness, useability, and/or merchantability
# of the data and are not liable for any loss, damage, claim, liability,
# expense, or penalty, or for any direct, indirect, special, secondary,
# incidental, consequential, or exemplary damages or lost profit
# deriving from the use or misuse of this information.
################################################################################

# global vars
docker_compose_file_name="docker-compose.yml"
env_file_name=".env"
messages_separator="#########################################"
user_answer=
services_list="LSF SLURM SSSD"
service_lsf_setup=
service_slurm_setup=
service_sssd_setup=
RED='\033[0;31m'; GREEN='\033[0;32m'; GREY='\033[0;37m'; BLUE='\034[0;37m'; NC='\033[0m'
ORANGE='\033[0;33m'; BLUE='\033[0;34m'; WHITE='\033[0;97m'; UNLIN='\033[0;4m'

# efp vars
EFP_HOSTNAME=$(hostname)
EFP_SETUP_BASIC="true"
EFP_PORT=8553
EFP_EULA_TERMS=accept
EFP_ADMIN_USER="efadmin"
EFP_ADMIN_PASSWORD="demo@#@@##"
EFP_LICENSE="license.ef"
EFP_SESSIONS_DATA_DIR=
EFP_SPOOLERS_DATA_DIR=
EFP_UID=
EFP_GID=
LSF_SERVICE_ENABLED=false
SSSD_SERVICE_ENABLED=false
SSSD_CONF_FILE=/etc/sssd/sssd.conf
SLURM_SERVICE_ENABLED=false
SLURM_BIN_DIR=/usr/sbin
SLURM_CONF_DIR=/etc/slurm
SLURM_SPOOL_DIR=/var/spool/slurm/
SLURM_PLUGIN_DIR=/usr/lib/slurm
SLURM_MUNGE_KEY=/etc/munge/munge.key
SLURM_MUNGE_SOCKET_DIR=/var/run/munge

# functions
user_exists() {
    id "$1" &>/dev/null
}

group_exists() {
    getent group "$1" &>/dev/null
}

finishMessage()
{
    echo $messages_separator
    echo -e "${GREEN}The $env_file_name and $docker_compose_file_name files were created with success!${NC}"
    echo -e "${ORANGE}Do not forget to add your license in the license.ef file!${NC}"
    echo -e "After start the container, you can access EF Portal from this URL: https://yourip:${EFP_PORT}"
    echo -e "User: ${EFP_ADMIN_USER}"
    echo -e "Password: ${EFP_ADMIN_PASSWORD}"
    echo -e "${GREEN}- To execute the EF Portal container, you can execute: docker compose up -d${NC}"
    echo -e "${GREEN}- To close the EF Portal container, you can execute: docker compose down${NC}"
    echo -e "${GREEN}- To remove the EF Portal container, you can execute: docker rm docker-id${NC}"
    echo -e "${GREEN}- To check all dockers ids: docker ps -a${NC}"
    echo "Important notes:"
    echo "- Do not you have docker command/service installed? Open our git and check the tools/ directory! Link: https://github.com/NISP-GmbH/EF-Portal-Container/ "
    echo "- Unless you know what you are doing, do not edit docker-compsoe.yml file!"
    echo "- You can change all variables inside of $env_file_name if you want to customize something."
    echo "Any other questions you can send an e-mail: https://www.ni-sp.com/contact/"
    echo "Check all of our guides: https://github.com/NISP-GmbH/Guides"
    echo $messages_separator
}

welcomeMessage()
{
    echo $messages_separator
    echo -e "${GREEN}Welcome to EF Portal container setup!${NC}"
    echo -e "${GREEN}This script will help you creating a $docker_compose_file_name and $env_file_name files that will support your requirements.${NC}"
    echo -e "${ORANGE}Do you want to proceed with Basic or Advanced setup?${NC}"
    echo -e "${ORANGE}(1) Basic setup:${NC}"
    echo "- Just setup EF Portal container without any questions."
    echo "- The best option if you just want to explore the solution."
    echo -e "${ORANGE}(2) Advanced setup:${NC}"
    echo "The script will ask some questions to guide you to have a more complete integration with EF Portal and third solutions."
    echo "- This is the best solution for production environments."
    echo "- You can load SLURM or LSF from the Host inside of the container."
    echo "- You can load SSSD service to integrate LDAP/AD users."
    echo "- You can mount external directories (sessions and spoolers) into the container."
    echo $messages_separator
    echo -e "${ORANGE}If you do not know which option to choose, then the option (1) is the best for you.${NC}"
    echo "You can execute this script multiple times to understand better the difference."
    echo "This script will not touch anything in your Host. It just creates the files to start a docker container!"
    echo $messages_separator
    echo -e "${GREEN}Please type 1 for Basic setup or 2 for Advanced setup.${NC}"
    read efp_setup_type

    case $efp_setup_type in
        "1")
            EFP_SETUP_BASIC="true"
            welcomeMessageBasic
        ;;
        "2")
            EFP_SETUP_BASIC="false"            
            welcomeMessageAdvanced
        ;;
        *)
            echo "Only 1 or 2 are possible answers. Please execute the script again. Exiting..."
            exit 4
        ;;
    esac
}

welcomeMessageBasic()
{
    echo $messages_separator
    echo "If you already have a $env_file_name or $docker_compose_file_name file in the same directory, the script will quit."
    echo -e "${GREEN}The script will create create the files...${NC}"
}

welcomeMessageAdvanced()
{
    echo $messages_separator
    echo -e "${GREEN}Welcome to EF Portal Advanced container setup!${NC}"
    echo "- This script must be executed in the same server that you want to run the container; It needs to extract some Host info to make possible run third services like SLURM or LSF."
    echo "- The script will ask some stuffs and based in the answers it will create both files."
    echo "- If you already have a $env_file_name or $docker_compose_file_name file in the same directory, the script will quit."
    echo "Important:"
    echo -e "${GREEN}- This script support these services: PAM and SSSD, so you can map LDAP/AD users.${NC}"
    echo -e "${GREEN}- This script support these schedulers: LSF and SLURM.${NC}"
    echo "- Just one secheduler per time is supported by this script. You can cave both using EF Portal, but not through this script."
    echo -e "${GREEN}What will I be asked?${NC}"
    echo "- Which Host directory do you want to store EnginFrame Portal sessions and spoolers data. If you did not decide yet, please provide a path to store that data. You can eventually move to another place and fix the $env_file_name file with the new path."
    for service_name in $services_list
    do
        echo "- If you want to load ${service_name}."
    done
    echo -e "${ORANGE}Recommendation: Open two terminals with your host. One to execute this script, and another one that can support the script execution.${NC}"
    echo "Press enter to proceed or ctrl+c to quit."
    echo $messages_separator
    read pressenter
}

serviceDescription()
{
    service_name=$(echo $1 | tr '[:upper:]' '[:lower:]')

    case $service_name in
        "slurm")
            echo -e "${GREEN}This script can bind Host Slurm and Munge binaries, slurm config files and munge key inside of the container, so you will have exactly same host configuration.${NC}"
        ;;
        "sssd")
            echo -e "${GREEN}This script can bind your sssd.conf and startup SSSD service, so you can have your users mapped to this container.${NC}"
        ;;
        "lsf")
            echo -e "${GREEN}This script can configure your LSF inside of the container.${NC}"
        ;;
    esac
}

askService()
{
    service_name=$1
    while_guardian="true"
    while $while_guardian
    do
        echo -e "${GREEN}Do you want to use $(echo $service_name | tr '[:lower:]' '[:upper:]')? [yes/no]${NC}"
        read user_answer
        
        if echo $user_answer | grep -Eiq "^(yes|no)$"
        then
            while_guardian="false"
        else
            echo "Invalid answer. Must be \"yes\" or \"no\"."
        fi
    done

    if echo $user_answer | grep -Eiq "^yes$"
    then
        user_answer="true"
    else
        user_answer="false"
    fi

    echo $messages_separator
}

checkEfpDirectoryPermissions()
{
    dir=$1
    required_perms=$2
    actual_perms=$(stat -c "%a" "$dir")
    
    if [ "$actual_perms" != "$required_perms" ]
    then
        echo -e "${RED}Error: $dir does not have the required permissions.${NC}"
        echo "Current permissions: $actual_perms. Required: $required_perms"
        return 1
    else
        return 0
    fi
}

askServiceEfp()
{
    echo -e "${GREEN} Now you will be asked about EF Portal sessions and spoolers directories to be mounted into the container.${NC}"
    echo "Why mount external data instead of just use the container?"
    echo "Because these directories can grow in size quickly, so you need to decide the best place to store them."
    echo -e "${GREEN}Important:${NC}"
    echo "- The sessions directory must be mapped to efnobody as user, efnobody as group and have the chmod 3755."
    echo "- The spoolers directory must be mapped to efnobody as user, efnobody as group and have the chmod 0755."
    echo "- You can not use same directory. You need to inform different paths (example: /mystorage/efp/sessions and /mystorage/efp/spoolers)."
    echo -e "${ORANGE}- DO NOT use sessions and spoolers directories from another EnginFrame setup; This is not officially supported and can damage your files!${NC}"
    while_guardian="true"
    while $while_guardian
    do
        echo -e "${GREEN}Please indicate an existing absolut path to store EF Portal >>> SESSIONS <<< data: ${NC}"
        read ef_portal_sessions_data_dir
        ef_portal_sessions_data_dir="${ef_portal_sessions_data_dir%"${ef_portal_sessions_data_dir##*[!/]}"}"

        echo -e "${GREEN}Please indicate an existing absolut path to store EF Portal >>> SPOOLERS <<< data: ${NC}"
        read ef_portal_spoolers_data_dir
        ef_portal_spoolers_data_dir="${ef_portal_spoolers_data_dir%"${ef_portal_spoolers_data_dir##*[!/]}"}"

        if [ -d $ef_portal_sessions_data_dir ]
        then
            if [ -d $ef_portal_spoolers_data_dir ]
            then
                if [[ "$ef_portal_sessions_data_dir" != "$ef_portal_spoolers_data_dir" ]]
                then
                    permissions_check=0
                    output=$(checkEfpDirectoryPermissions "$ef_portal_sessions_data_dir" "3755")
                    return_value=$?
                    permissions_check=$((permissions_check+return_value))
                    output=$(checkEfpDirectoryPermissions "$ef_portal_spoolers_data_dir" "755")
                    return_value=$?
                    permissions_check=$((permissions_check+return_value))

                    if [ $permissions_check -eq 0 ]
                    then
                        EFP_SESSIONS_DATA_DIR=$ef_portal_sessions_data_dir
                        EFP_SPOOLERS_DATA_DIR=$ef_portal_spoolers_data_dir
                        while_guardian="false"
                    else
                        echo -e "${RED}Error: You need to fix the directory(ies) permission(s) before continue.${NC}"
                        echo "After fixed, press enter to continue."
                        read pressenter
                    fi
                else
                    echo "Error: The directories are the same, and this is not possible for this script."
                fi
            else
                echo "Error: The directory >>> $ef_portal_spoolers_data_dir <<< does not exist."
            fi
        else
                echo "Error: The directory >>> $ef_portal_sessions_data_dir <<< does not exist."
        fi
    done

    echo -e "${GREEN}Getting the UID and GID of the directories... They must be a number greater than 1000!${NC}"
    while_guardian="true"
    while $while_guardian
    do
        EFP_GID=$(stat -c '%g' "$EFP_SESSIONS_DATA_DIR")
        EFP_UID=$(stat -c '%u' "$EFP_SESSIONS_DATA_DIR")
        if [ $EFP_GID -lt 1000 ] || [ $EFP_UID -lt 1000 ]
        then
            echo -e "${RED}Error: UID and GID must be greater than 1000. Current UID: ${EFP_UID}. Current GID: ${EFP_GID}.${NC}"
            echo "Please fix this and then press enter to try again."
            read pressenter
        else
            while_guardian="false"
            echo "Permissions are good!"
        fi
    done

    while_guardian="true"
    while $while_guardian
    do
        echo -e "${GREEN}Which port do you want to use with EF Portal? The port must not be in use in the host.${NC}"
        echo "For example: if you write 8553, then the EF Portal will be accessible in https://ip:8553"
        echo "If you just press enter, the default port will be >>> $EFP_PORT <<<."
        read user_answer_efp_port

        if [[ "${user_answer_efp_port}x" != "x" ]]
        then
            if echo $user_answer_efp_port | egrep -iq "^[0-9]+$"
            then
                if [ "$user_answer_efp_port" -gt 1024 ] && [ "$user_answer_efp_port" -lt 65536 ]
                then
                    while_guardian="false"
                    EFP_PORT=$user_answer_efp_port
                else
                    echo "${RED}Error: The port needs to be between 1024 and 65536!${NC}"
                fi
            else
                echo "${RED}Error: You need to type an integer!${NC}"
            fi
        else
            while_guardian="false"
        fi
    done

    echo $messages_separator
}

serviceList()
{
    if ! $EFP_SETUP_BASIC
    then
        for service_name in $services_list
        do
            serviceDescription $service_name
            askService $service_name
            user_answer=$(echo $user_answer | tr '[:upper:]' '[:lower:]')
            variable_name="service_$(echo $service_name | tr '[:upper:]' '[:lower:]')_setup"
            eval "$variable_name=$user_answer"
        done

        askServiceEfp
    fi
}

processServices()
{
    if ! $EFP_SETUP_BASIC
    then
        if [ "$service_lsf_setup" = true ] && [ "$service_slurm_setup" = true ]
        then
            echo -e "${RED}Error: This script does not support load LSF and SLURM at the same time. You can set just one scheduler.${NC}"
            echo -e "${RED}Exiting...${NC}"
            exit 1
        fi
    fi
}

docker_compose_build()
{

    if $EFP_SETUP_BASIC
    then
        cat << EOF > $docker_compose_file_name
services:
  enginframe:
    container_name: efportal-nisp
    hostname: $EFP_HOSTNAME
    image: nispgmbh/ef-dcv-container:efportal
    expose:
      - "\${EFP_PORT}"
    ports:
      - "\${EFP_PORT}:8443/tcp"
    restart: 'always'
    volumes:
      - enginframe_data:/opt/nisp/enginframe/data/
      - enginframe_conf:/opt/nisp/enginframe/conf/
      - enginframe_logs:/opt/nisp/enginframe/logs/
      - enginframe_sessions:/opt/nisp/enginframe/sessions/
      - enginframe_spoolers:/opt/nisp/enginframe/spoolers/
      - type: bind
        source: ${EFP_LICENSE}
        target: /opt/container-tools/license.ef
EOF
    fi

    if ! $EFP_SETUP_BASIC
    then
    cat << EOF > $docker_compose_file_name
services:
  enginframe:
    container_name: efportal-nisp
    hostname: $EFP_HOSTNAME
    image: nispgmbh/ef-dcv-container:efportal
    expose:
      - "\${EFP_PORT}"
    ports:
      - "\${EFP_PORT}:8443/tcp"
    restart: 'always'
    volumes:
      - enginframe_data:/opt/nisp/enginframe/data/
      - enginframe_conf:/opt/nisp/enginframe/conf/
      - enginframe_logs:/opt/nisp/enginframe/logs/
      - type: bind
        source: ${EFP_LICENSE}
        target: /opt/container-tools/license.ef
      - \${EFP_SESSIONS_DATA_DIR}:/opt/nisp/enginframe/sessions
      - \${EFP_SPOOLERS_DATA_DIR}:/opt/nisp/enginframe/spoolers
EOF
    fi

    if ! $EFP_SETUP_BASIC
    then
        if $service_sssd_setup
        then
            cat << EOF >> $docker_compose_file_name
      - type: bind
        source: ${SSSD_CONF_FILE}
        target: /etc/sssd/sssd.conf
EOF
        fi
    fi

    if ! $EFP_SETUP_BASIC
    then
        if $service_slurm_setup
        then
    
        for slurm_binary in srun sbatch squeue scontrol slurmd sinfo slurmctld slurmstepd
        do
        
            if [ -f /usr/bin/${slurm_binary} ]
            then
                cat << EOF >> $docker_compose_file_name
      - type: bind
        source: /usr/bin/${slurm_binary}
        target: /usr/bin/${slurm_binary}
EOF
            else
                cat << EOF >> $docker_compose_file_name
      - type: bind
        source: /usr/sbin/${slurm_binary}
        target: /usr/sbin/${slurm_binary}
EOF
            fi
        done

        cat << EOF >> $docker_compose_file_name
      - type: bind
        source: \${SLURM_SPOOL_DIR}
        target: \${SLURM_SPOOL_DIR}
      - type: bind
        source: \${SLURM_PLUGIN_DIR}
        target: \${SLURM_PLUGIN_DIR}
      - type: bind
        source: \${SLURM_CONF_DIR}/slurm.conf
        target: \${SLURM_CONF_DIR}/slurm.conf
      - type: bind
        source: \${SLURM_CONF_DIR}/cgroup.conf
        target: \${SLURM_CONF_DIR}/cgroup.conf
      - type: bind
        source: \${SLURM_MUNGE_KEY}
        target: /etc/munge/munge.key
      - type: bind
        source: \${SLURM_MUNGE_SOCKET_DIR}
        target: /var/run/munge
        read_only: false
EOF
        fi
    fi

    if ! $EFP_SETUP_BASIC
    then
        if $service_lsf_setup
        then
            cat << EOF >> $docker_compose_file_name
    # TODO
EOF
        fi
    fi

    if ! $EFP_SETUP_BASIC
    then
        cat << EOF >> $docker_compose_file_name
    env_file:
      - $env_file_name
    command: ["/bin/bash", "/opt/container-tools/enginframe_init_script.sh"]

volumes:
  enginframe_data:
  enginframe_conf:
  enginframe_logs:
EOF
    fi

    if $EFP_SETUP_BASIC
    then
        cat << EOF >> $docker_compose_file_name
    env_file:
      - $env_file_name
    command: ["/bin/bash", "/opt/container-tools/enginframe_init_script.sh"]

volumes:
  enginframe_data:
  enginframe_conf:
  enginframe_logs:
  enginframe_sessions:
  enginframe_spoolers:
network_mode: host
EOF
    fi
}

env_build()
{
    if $EFP_SETUP_BASIC
    then
        cat << EOF > $env_file_name
######## EFP CONFIG
EFP_HOSTNAME=$EFP_HOSTNAME
EFP_SETUP_BASIC=$EFP_SETUP_BASIC
EFP_PORT=$EFP_PORT
EFP_EULA_TERMS=accept
EFP_ADMIN_PASSWORD=$EFP_ADMIN_PASSWORD
EFP_LICENSE=$EFP_LICENSE
EFP_SESSIONS_DATA_DIR=$EFP_SESSIONS_DATA_DIR
EFP_SPOOLERS_DATA_DIR=$EFP_SPOOLERS_DATA_DIR
EOF
    fi

    if ! $EFP_SETUP_BASIC
    then
        cat << EOF > $env_file_name
######## EFP CONFIG
EFP_HOSTNAME=$EFP_HOSTNAME
EFP_SETUP_BASIC=$EFP_SETUP_BASIC
EFP_PORT=$EFP_PORT
EFP_EULA_TERMS=accept
EFP_ADMIN_PASSWORD=$EFP_ADMIN_PASSWORD
EFP_LICENSE=$EFP_LICENSE
EFP_SESSIONS_DATA_DIR=$EFP_SESSIONS_DATA_DIR
EFP_SPOOLERS_DATA_DIR=$EFP_SPOOLERS_DATA_DIR
EOF
    fi

    if ! $EFP_SETUP_BASIC
    then
        if $service_sssd_setup
        then
            cat << EOF >> $env_file_name
######## SSSD CONFIG
# If false, will not use SSSD service
# If true, it will use SSSD service.
# Note: You need to map the sssd.conf file into $docker_compose_file_name file
SSSD_SERVICE_ENABLED=true
SSSD_CONF_FILE=$SSSD_CONF_FILE
EOF
        fi

        if $service_lsf_setup
        then
            cat << EOF >> $env_file_name
LSF_SERVICE_ENABLED=true
EOF
        fi

        if $service_slurm_setup
        then
            cat << EOF >> $env_file_name
######## SLURM EXTERNAL SERVICE
# If false, it will not try to use slurm service from the host
# If true, it will try to start slurm service
SLURM_SERVICE_ENABLED=true
SLURM_BIN_DIR=$SLURM_BIN_DIR
SLURM_PLUGIN_DIR=$SLURM_PLUGIN_DIR
SLURM_CONF_DIR=$SLURM_CONF_DIR
SLURM_SPOOL_DIR=$SLURM_SPOOL_DIR
SLURM_MUNGE_KEY=$SLURM_MUNGE_KEY
SLURM_MUNGE_SOCKET_DIR=$SLURM_MUNGE_SOCKET_DIR
EOF
        fi
    fi

    touch $EFP_LICENSE
}

checkCurrentDir()
{
    if [ -f $env_file_name ]
    then
        echo -e "${RED}Error: .env file already exist!${NC}"
        echo -e "${RED}Exiting...${NC}"
        exit 2
    fi

    if [ -f $docker_compose_file_name ]
    then
        echo -e "${RED}Error: $docker_compose_file_name file already exist!${NC}"
        echo -e "${RED}Exiting...${NC}"
        exit 3
    fi
}

main()
{
    welcomeMessage
    checkCurrentDir
    serviceList
    processServices
    env_build
    docker_compose_build
    finishMessage
    exit 0
}

main

# unknown error
exit 255
