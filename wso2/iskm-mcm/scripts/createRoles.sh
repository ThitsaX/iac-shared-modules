#! /bin/bash

while getopts h:r:u:p: option; do
    case "${option}" in
    h) host=${OPTARG} ;;
    r) port=${OPTARG} ;;
    u) username=${OPTARG} ;;
    p) password=${OPTARG} ;;
    esac
done

if [ -z $host ] || [ -z $port ] || [ -z $username ] || [ -z $password ]; then
    echo " "
    echo "Missing arguments"
    echo "usage: ./createClaims.sh -h host -r port -u username -p password"
    echo " "
    exit 1
fi

auth=$(printf '%s' $username:$password | base64)

###################################################################################################
######     MTA                                                                                #####
###################################################################################################

# echo ""
# echo "Creating role: MTA"

soapResponse=$(curl -s -X POST -k \
    -H "Content-Type: application/soap+xml;charset=UTF-8;action=\"urn:addRole\"" \
    -H "SOAPAction: urn:addRole" \
    -H "Authorization: Basic $auth" \
    --data @roles/roleMTA.xml \
    https://$host:$port/services/RemoteUserStoreManagerService.RemoteUserStoreManagerServiceHttpsSoap12Endpoint/ \
    --insecure)

# echo "$soapResponse"

###################################################################################################
######     PTA                                                                                #####
###################################################################################################

# echo ""
# echo "Creating role: PTA"

soapResponse=$(curl -s -X POST -k \
    -H "Content-Type: application/soap+xml;charset=UTF-8;action=\"urn:addRole\"" \
    -H "SOAPAction: urn:addRole" \
    -H "Authorization: Basic $auth" \
    --data @roles/rolePTA.xml \
    https://$host:$port/services/RemoteUserStoreManagerService.RemoteUserStoreManagerServiceHttpsSoap12Endpoint/ \
    --insecure)

# echo "$soapResponse"
