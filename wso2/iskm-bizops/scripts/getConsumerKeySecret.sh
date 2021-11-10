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
    echo "usage: ./getConsumerKeySecret.sh -h host -r port -u username -p password"
    echo " "
    exit
fi

# echo "1. Please ensure "
# echo "2. Set the <HideAdminServiceWSDLs> element to false in the <PRODUCT_HOME>/repository/conf/carbon.xml file."

auth=$(printf '%s' $username:$password | base64)

soapResponse=$(curl -s -X POST -k \
    -H "Content-Type: application/soap+xml;charset=UTF-8;action=\"urn:getOAuthApplicationDataByAppName\"" \
    -H "Authorization: Basic $auth" \
    --data @serviceProviders/getOAuthApplicationDataByAppName.xml \
    https://$host:$port/services/OAuthAdminService.OAuthAdminServiceHttpsSoap12Endpoint/ \
    --insecure)

oauthConsumerSecret=$(echo $soapResponse | grep -oPm1 "(?<=oauthConsumerSecret>)[^<]+")
consumerKey=$(echo $soapResponse | grep -oPm1 "(?<=oauthConsumerKey>)[^<]+")

echo "- consumerSecret: $oauthConsumerSecret"
echo "- consumerKey:    $consumerKey"
