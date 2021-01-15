#!/bin/bash

#Register WSO2 Service Provider for OAUTH2 authentication
echo "WSO2 Service Provider Registration"

BASEDIR=$(dirname "$0")
#echo "$BASEDIR"

while getopts h:r:u:p: option; do
    case "${option}" in
    h) hostname=${OPTARG} ;;
    r) port=${OPTARG} ;;
    u) username=${OPTARG} ;;
    p) password=${OPTARG} ;;
    esac
done

if [ -z $hostname ] || [ -z $port ] || [ -z $username ] || [ -z $password ]; then
    echo " "
    echo "Missing arguments"
    echo "usage: ./registerServiceProvider.sh -h hostname -r port -u username -p password"
    echo " "
    exit
fi

log_error() {
    if [ $# == 1 ]; then
        if [ $1 != 0 ]; then
            #echo "Error occurred while connecting to the WSO2 service"
            echo "$1"
        else
            echo "$2"
        fi
    elif [ $# == 2 ]; then
        echo "$2"
    fi
}

client_name="MCM_portal"
grant_types="password"

auth_header=$(echo $username:$password | base64)

#initialise script variables from environment.serviceprovider.config file
#service_provider_configuration_file_name="$BASEDIR/$environment.serviceprovider.config"
#. $service_provider_configuration_file_name
service_provider_registration_service_endpoint="https://"$hostname":"$port"/api/identity/oauth2/dcr/v1.1/register"
echo "client_name: $client_name"
ext_param_client_id=$(echo $client_name) | tr '-' _
echo "ext_param_client_id: $ext_param_client_id"
ext_param_client_secret=$(echo $ext_param_client_id | base64)
echo "ext_param_client_secret: $ext_param_client_secret"

#check whether service provider exists
service_provider_exists_response=$(curl -s -k -X GET -H "Authorization: Basic $auth_header" -H 'Content-Type: application/json' -d \"{}\" $service_provider_registration_service_endpoint?client_name=$client_name)

service_provider_exists=$(echo $service_provider_exists_response | awk -F'"client_name":"' '{print $2}' | cut -d',' -f 1 | tr -d '"')
if [ "$service_provider_exists" = $client_name ]; then
    echo "Service provider : \"$client_name\" already exists"
else
    echo "Service provider : \"$client_name\" does not exist"
    service_provider_registration_payload="{ \"client_name\": \"$client_name\", \"grant_types\": [\"$grant_types\"], \"ext_param_client_id\":\"$ext_param_client_id\", \"ext_param_client_secret\":\"$ext_param_client_secret\", requested_claims: [ ] }"
    service_provider_registration_response=$(curl -s -k -X POST -H "Authorization: Basic $auth_header" -H 'Content-Type: application/json' -d "$service_provider_registration_payload" $service_provider_registration_service_endpoint)
    log_error $service_provider_registration_response "Successfully registered service provider : \"$client_name\"" "Service provider registration for \"$client_name\" failed"

    if [[ $service_provider_registration_response == *"error"* ]]; then
        echo "ERROR Service provider registration for \"$client_name\" failed"
        echo "      $service_provider_registration_response"
    else
        echo "Successfully registered service provider : \"$client_name\""
    fi
fi

echo
