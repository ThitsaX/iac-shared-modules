#!/bin/bash

if [ ! -z "$DEBUG" ]; then
  set -x
fi

createServiceProvider="y"

eval "$(jq -r '@sh "host=\(.host) port=\(.rest_port) username=\(.admin_user) password=\(.admin_pass) createServiceProvider=\(.create_service_provider) callbackURL=\(.callback_url) appName=\(.app_name)"')"


if [ -z $host ] || [ -z $port ] || [ -z $username ] || [ -z $password ] || [ -z $createServiceProvider ] || [ -z $callbackURL ] || [ -z $appName ]
then
    echo " "
    echo "Missing arguments"
    echo " "
    exit 1
fi

# echo ""
# echo "1. Set the <HideAdminServiceWSDLs> element to false in the <PRODUCT_HOME>/repository/conf/carbon.xml file."

auth=$(printf '%s' $username:$password | base64)

# echo ""
# echo "Step 1: Registering service provider"
if [ "$createServiceProvider" = "y" ]; then
    ./registerServiceProvider.sh -h $host -r $port -u $username -p $password -c $callbackURL -a $appName
fi

# echo ""
# echo "Step 2: get secret and key"

auth=$(printf '%s' $username:$password | base64)

cp serviceProviders/getOAuthApplicationDataByAppName.xml serviceProviders/getOAuthApplicationDataByAppNameTemp.xml
# echo " - updating template"

sed -i "s/@appname@/$appName/g" serviceProviders/getOAuthApplicationDataByAppNameTemp.xml

soapResponse=$(curl -s -X POST -k \
    -H "Content-Type: application/soap+xml;charset=UTF-8;action=\"urn:getOAuthApplicationDataByAppName\"" \
    -H "Authorization: Basic $auth" \
    --data @serviceProviders/getOAuthApplicationDataByAppName.xml \
    https://$host:$port/services/OAuthAdminService.OAuthAdminServiceHttpsSoap12Endpoint/ \
    --insecure)

oauthConsumerSecret=$(echo $soapResponse | grep -oPm1 "(?<=oauthConsumerSecret>)[^<]+")
consumerKey=$(echo $soapResponse | grep -oPm1 "(?<=oauthConsumerKey>)[^<]+")

# Safely produce a JSON object containing the result value.
# jq will ensure that the value is properly quoted
# and escaped to produce a valid JSON string.

# echo ""
# echo "Configuration complete"

jq -n --arg oauthConsumerSecret $oauthConsumerSecret --arg consumerKey $consumerKey '{"oauthConsumerSecret":$oauthConsumerSecret,"consumerKey":$consumerKey}'
