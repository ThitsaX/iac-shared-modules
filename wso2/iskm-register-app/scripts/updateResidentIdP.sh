#! /bin/bash

while getopts h:r:u:p:c: option
do	
    case "${option}" in	
        h) host=${OPTARG};;
        r) port=${OPTARG};;
        u) username=${OPTARG};;        	
        p) password=${OPTARG};;
        r) realm_id=${OPTARG};;
        e) entity_id=${OPTARG};;
    esac	
done

if [ -z $host ] || [ -z $port ] || [ -z $username ] || [ -z $password ] || [ -z $realm_id ] || [ -z $entity_id ]
then
    echo " "
    echo "Missing arguments"
    echo "usage: ./updateResidentIdP.sh -h host -r port -u username -p password -r realm_id -e entity_id"
    echo " "
    exit 1
fi

auth=$(printf '%s' $username:$password | base64)

# echo ""
# echo "Update Resident IdP"
cp serviceProviders/updateResidentIdP.xml serviceProviders/updateResidentIdPTemp.xml
# echo " - updating template"

sed -i "s,@realmid@,$realm_id,g" serviceProviders/updateResidentIdPTemp.xml
sed -i "s,@entityid@,$entity_id,g" serviceProviders/updateResidentIdPTemp.xml


soapResponse=$(curl -s -X POST -k \
    -H "Content-Type: application/soap+xml;charset=UTF-8;action=\"urn:updateResidentIdP\"" \
    -H "Authorization: Basic $auth" \
    --data @serviceProviders/updateResidentIdPTemp.xml \
    https://$host:$port/services/IdentityProviderMgtService?wsdl \
    --insecure)

# echo "done"
