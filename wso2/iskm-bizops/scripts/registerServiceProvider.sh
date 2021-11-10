#! /bin/bash

while getopts h:r:u:p:c: option
do	
    case "${option}" in	
        h) host=${OPTARG};;
        r) port=${OPTARG};;
        u) username=${OPTARG};;        	
        p) password=${OPTARG};;
        c) callback_url=${OPTARG};;
    esac	
done

if [ -z $host ] || [ -z $port ] || [ -z $username ] || [ -z $password ] || [ -z $callback_url ] 
then
    echo " "
    echo "Missing arguments"
    echo "usage: ./registerServiceProvider.sh -h host -r port -u username -p password -c callback_url"
    echo " "
    exit 1
fi

# echo "1. Please ensure "
# echo "2. Set the <HideAdminServiceWSDLs> element to false in the <PRODUCT_HOME>/repository/conf/carbon.xml file."

auth=$(printf '%s' $username:$password | base64)

###################################################################################################
######     BOF_portal application                                                             #####
###################################################################################################

# echo ""
# echo "Creating application: BOF_portal"
cp serviceProviders/registerOAuthApplicationData.xml serviceProviders/registerOAuthApplicationDataTemp.xml
# echo " - updating template"

sed -i "s,@callbackurl@,$callback_url,g" serviceProviders/registerOAuthApplicationDataTemp.xml


soapResponse=$(curl -s -X POST -k \
    -H "Content-Type: application/soap+xml;charset=UTF-8;action=\"urn:registerOAuthApplicationData\"" \
    -H "Authorization: Basic $auth" \
    --data @serviceProviders/registerOAuthApplicationDataTemp.xml \
    https://$host:$port/services/services/OAuthAdminService.OAuthAdminServiceHttpsSoap12Endpoint/ \
    --insecure)

# echo "Getting OAuth application data"
soapResponse=$(curl -s -X POST -k \
    -H "Content-Type: application/soap+xml;charset=UTF-8;action=\"urn:getOAuthApplicationDataByAppName\"" \
    -H "Authorization: Basic $auth" \
    --data @serviceProviders/getOAuthApplicationDataByAppName.xml \
    https://$host:$port/services/OAuthAdminService.OAuthAdminServiceHttpsSoap12Endpoint/ \
    --insecure)

consumerKey=$(echo $soapResponse | grep -oPm1 "(?<=oauthConsumerKey>)[^<]+")
oauthConsumerSecret=$(echo $soapResponse | grep -oPm1 "(?<=oauthConsumerSecret>)[^<]+")
# echo "- consumerKey:    $consumerKey"
# echo "- consumerSecret: $oauthConsumerSecret"


###################################################################################################
######     BOF_portal service provider                                                        #####
###################################################################################################

# echo ""
# echo "Creating service provider: BOF_portal"

soapResponse=$(curl -s -X POST -k \
    -H "Content-Type: application/soap+xml;charset=UTF-8;action=\"urn:createApplication\"" \
    -H "Authorization: Basic $auth" \
    --data @serviceProviders/BOF_portal.xml \
    https://$host:$port/services/IdentityApplicationManagementService.IdentityApplicationManagementServiceHttpsSoap12Endpoint/ \
    --insecure)
# echo $soapResponse >> output/createClaim.txt
# echo " - creating working copy of [serviceProviders/getApplication.xml]"
cp serviceProviders/getApplication.xml serviceProviders/getApplicationTemp.xml
# echo " - updating template"

sed -i 's/@appname@/BOF_portal/g' serviceProviders/getApplicationTemp.xml

soapResponse=$(curl -s -X POST -k \
    -H "Content-Type: application/soap+xml;charset=UTF-8;action=\"urn:getApplication\"" \
    -H "Authorization: Basic $auth" \
    --data @serviceProviders/getApplicationTemp.xml \
    https://$host:$port/services/IdentityApplicationManagementService.IdentityApplicationManagementServiceHttpsSoap12Endpoint/ \
    --insecure)

appId=$(echo $soapResponse | grep -oPm1 "(?<=applicationID>)[^<]+")
# echo "applicationID: $appId"

rm serviceProviders/getApplicationTemp.xml

cp serviceProviders/updateApplication.xml serviceProviders/updateApplicationTemp.xml
sed -i "s/@appid@/$appId/g" serviceProviders/updateApplicationTemp.xml
sed -i "s/@appname@/BOF_portal/g" serviceProviders/updateApplicationTemp.xml
sed -i "s/@authkey@/$consumerKey/g" serviceProviders/updateApplicationTemp.xml
sed -i "s/@secret@/$oauthConsumerSecret/g" serviceProviders/updateApplicationTemp.xml

# echo "Adding claim to service provider"

soapResponse=$(curl -s -X POST -k \
    -H "Content-Type: application/soap+xml;charset=UTF-8;action=\"urn:updateApplication\"" \
    -H "Authorization: Basic $auth" \
    --data @serviceProviders/updateApplicationTemp.xml \
    https://$host:$port/services/IdentityApplicationManagementService.IdentityApplicationManagementServiceHttpsSoap12Endpoint/ \
    --insecure)
# rm serviceProviders/updateApplicationTemp.xml
