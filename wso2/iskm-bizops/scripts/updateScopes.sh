#! /bin/bash

while getopts h:r:u:p: option
do	
    case "${option}" in	
        h) host=${OPTARG};;
        r) port=${OPTARG};;
        u) username=${OPTARG};;        	
        p) password=${OPTARG};;
    esac	
done

if [ -z $host ] || [ -z $port ] || [ -z $username ] || [ -z $password ] 
then
    echo " "
    echo "Missing arguments"
    echo "usage: ./createClaims.sh -h host -r port -u username -p password"
    echo " "
    exit 1
fi

auth=$(printf '%s' $username:$password | base64)

###################################################################################################
######     openid                                                                             #####
###################################################################################################

# echo ""
# echo "Updating scope: openid"
# echo "- cleaning up"

soapResponse=$(curl -s -X POST -k \
    -H "Content-Type: application/soap+xml;charset=UTF-8;action=\"urn:updateScope\"" \
    -H "SOAPAction: urn:updateScope" \
    -H "Authorization: Basic $auth" \
    --data @scopes/openidRemove.xml \
    https://$host:$port/services/OAuthAdminService.OAuthAdminServiceHttpsSoap12Endpoint/ \
    --insecure)


# echo "- adding claims"

soapResponse=$(curl -s -X POST -k \
    -H "Content-Type: application/soap+xml;charset=UTF-8;action=\"urn:updateScope\"" \
    -H "SOAPAction: urn:updateScope" \
    -H "Authorization: Basic $auth" \
    --data @scopes/openidAdd.xml \
    https://$host:$port/services/OAuthAdminService.OAuthAdminServiceHttpsSoap12Endpoint/ \
    --insecure)


