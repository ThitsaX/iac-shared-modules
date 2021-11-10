#! /bin/bash

createServiceProvider="y"

while getopts h:r:u:p:c: option
do	
    case "${option}" in	
        h) host=${OPTARG};;
        r) port=${OPTARG};;
        u) username=${OPTARG};;        	
        p) password=${OPTARG};;
        c) createServiceProvider=${OPTARG};;
    esac	
done

if [ -z $host ] || [ -z $port ] || [ -z $username ] || [ -z $password ] || [ -z $createServiceProvider ]
then
    echo " "
    echo "Missing arguments"
    echo "usage: ./createClaims.sh -h host -r port -u username -p password -c createServiceProvider (y/n)"
    echo " "
    exit
fi

echo ""
echo "1. Set the <HideAdminServiceWSDLs> element to false in the <PRODUCT_HOME>/repository/conf/carbon.xml file."

auth=$(printf '%s' $username:$password | base64)

echo ""
echo "Step 1: Creating claims"

./createClaims.sh -h $host -r $port -u $username -p $password


echo ""
echo "Step 2: Updating OIDC scopes"
./updateScopes.sh -h $host -r $port -u $username -p $password


echo ""
echo "Step 3: Registering service provider"
if [ "$createServiceProvider" = "y" ]; then
    ./registerServiceProvider.sh -h $host -r $port -u $username -p $password
else
    echo "- skipping"
fi

echo ""
echo "Step 4: Create roles"

./createRoles.sh -h $host -r $port -u $username -p $password

echo ""
echo "Configuration complete"