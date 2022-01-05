#! /bin/bash

while getopts h:r:u:p:n: option
do	
    case "${option}" in	
        h) host=${OPTARG};;
        r) port=${OPTARG};;
        u) username=${OPTARG};;        	
        p) password=${OPTARG};;
        n) applicationname=${OPTARG};;
    esac	
done

if [ -z $host ] || [ -z $port ] || [ -z $username ] || [ -z $password ] 
then
    echo " "
    echo "Missing arguments"
    echo "usage: ./deleteServiceProvider.sh -h host -r port -u username -p password -n applicationname"
    echo " "
    exit
fi

# echo "1. Please ensure "
# echo "2. Set the <HideAdminServiceWSDLs> element to false in the <PRODUCT_HOME>/repository/conf/carbon.xml file."

auth=$(printf '%s' $username:$password | base64)

# echo ""
# echo "Deleting application: $applicationname"

cp serviceProviders/deleteApplication.xml serviceProviders/deleteApplicationTemp.xml 
sed -i "s/@appname@/$applicationname/g" serviceProviders/deleteApplicationTemp.xml

soapResponse=$(curl -s -X POST -k \
    -H "Content-Type: application/soap+xml;charset=UTF-8;action=\"urn:deleteApplication\"" \
    -H "Authorization: Basic $auth" \
    --data @serviceProviders/deleteApplicationTemp.xml \
    https://$host:$port/services/IdentityApplicationManagementService.IdentityApplicationManagementServiceHttpsSoap12Endpoint/ \
    --insecure)

# rm serviceProviders/deleteApplicationTemp.xml 

# echo "- service provider removed"
# echo ""