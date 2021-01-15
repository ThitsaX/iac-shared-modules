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
######     SecretKey                                                                          #####
###################################################################################################

# echo ""
# echo "Removing claim: SecretKey"

soapResponse=$(curl -s -X POST -k \
    -H "Content-Type: application/soap+xml;charset=UTF-8;action=\"urn:removeLocalClaim\"" \
    -H "Authorization: Basic $auth" \
    --data @cleanup/remove-secretKey.xml \
    https://$host:$port/services/ClaimMetadataManagementService.ClaimMetadataManagementServiceHttpsSoap12Endpoint/ \
    --insecure)

###################################################################################################
######     2fa-enrolled                                                                       #####
###################################################################################################

# echo ""
# echo "Removing claim: 2fa-enrolled"

soapResponse=$(curl -s -X POST -k \
    -H "Content-Type: application/soap+xml;charset=UTF-8;action=\"urn:removeLocalClaim\"" \
    -H "SOAPAction: urn:addLocalClaim" \
    -H "Authorization: Basic $auth" \
    --data @cleanup/remove-2fa-enrolled.xml \
    https://$host:$port/services/ClaimMetadataManagementService.ClaimMetadataManagementServiceHttpsSoap12Endpoint/ \
    --insecure)

# echo ""
