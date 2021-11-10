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

# echo "1. Please ensure "
# echo "2. Set the <HideAdminServiceWSDLs> element to false in the <PRODUCT_HOME>/repository/conf/carbon.xml file."

auth=$(printf '%s' $username:$password | base64)

###################################################################################################
######     SecretKey                                                                          #####
###################################################################################################

# echo ""
# echo "Creating claim: SecretKey"

soapResponse=$(curl -s -X POST -k \
    -H "Content-Type: application/soap+xml;charset=UTF-8;action=\"urn:addLocalClaim\"" \
    -H "SOAPAction: urn:addLocalClaim" \
    -H "Authorization: Basic $auth" \
    --data @claims/SecretKey.xml \
    https://$host:$port/services/ClaimMetadataManagementService.ClaimMetadataManagementServiceHttpsSoap12Endpoint/ \
    --insecure)



###################################################################################################
######     2fa-enrolled (local)                                                               #####
###################################################################################################

# echo ""
# echo "Creating claim: 2fa-enrolled (local)"

soapResponse=$(curl -s -X POST -k \
    -H "Content-Type: application/soap+xml;charset=UTF-8;action=\"urn:addLocalClaim\"" \
    -H "SOAPAction: urn:addLocalClaim" \
    -H "Authorization: Basic $auth" \
    --data @claims/2fa-enrolled.xml \
    https://$host:$port/services/ClaimMetadataManagementService.ClaimMetadataManagementServiceHttpsSoap12Endpoint/ \
    --insecure)



###################################################################################################
######     2fa-enrolled (external)                                                            #####
###################################################################################################

# echo ""
# echo "Creating claim: 2fa-enrolled (external)"

soapResponse=$(curl -s -X POST -k \
    -H "Content-Type: application/soap+xml;charset=UTF-8;action=\"urn:addExternalClaim\"" \
    -H "SOAPAction: urn:addExternalClaim" \
    -H "Authorization: Basic $auth" \
    --data @claims/2fa-enrolledExternal.xml \
    https://$host:$port/services/ClaimMetadataManagementService.ClaimMetadataManagementServiceHttpsSoap12Endpoint/ \
    --insecure)



###################################################################################################
######     askPassword (local)                                                                #####
###################################################################################################

# echo "" 
# echo "Verifying claim: Ask Password"

soapResponse=$(curl -s -X POST -k \
    -H "Content-Type: application/soap+xml;charset=UTF-8;action=\"urn:getLocalClaims\"" \
    -H "Authorization: Basic $auth" \
    --data @claims/getLocalClaims.xml \
    https://$host:$port/services/ClaimMetadataManagementService.ClaimMetadataManagementServiceHttpsSoap12Endpoint/ \
    --insecure)
claimURI="http://wso2.org/claims/identity/askPassword"

if echo "$soapResponse" | grep -q "$claimURI"; then
    # echo "- askPassword claim already exists, updating"

    soapResponse=$(curl -s -X POST -k \
        -H "Content-Type: application/soap+xml;charset=UTF-8;action=\"urn:updateLocalClaim\"" \
        -H "Authorization: Basic $auth" \
        --data @claims/askPassword.xml \
        https://$host:$port/services/ClaimMetadataManagementService.ClaimMetadataManagementServiceHttpsSoap12Endpoint/ \
        --insecure)

else
    # echo "- askPassword claim doesn't exist, creating"

    soapResponse=$(curl -s -X POST -k \
        -H "Content-Type: application/soap+xml;charset=UTF-8;action=\"urn:addLocalClaim\"" \
        -H "Authorization: Basic $auth" \
        --data @claims/askPassword.xml \
        https://$host:$port/services/ClaimMetadataManagementService.ClaimMetadataManagementServiceHttpsSoap12Endpoint/ \
        --insecure)

fi

###################################################################################################
######     askPassword (external)                                                             #####
###################################################################################################

# echo ""
# echo "Creating claim: Ask Password (external)"

soapResponse=$(curl -s -X POST -k \
    -H "Content-Type: application/soap+xml;charset=UTF-8;action=\"urn:addExternalClaim\"" \
    -H "SOAPAction: urn:addExternalClaim" \
    -H "Authorization: Basic $auth" \
    --data @claims/askPasswordExternal.xml \
    https://$host:$port/services/ClaimMetadataManagementService.ClaimMetadataManagementServiceHttpsSoap12Endpoint/ \
    --insecure)


###################################################################################################
######     role                                                                        #####
###################################################################################################

# echo ""
# echo "Updating claim: Role"

# soapResponse=$(curl -s -X POST -k \
#     -H "Content-Type: application/soap+xml;charset=UTF-8;action=\"urn:updateLocalClaim\"" \
#     -H "Authorization: Basic $auth" \
#     --data @claims/role.xml \
#     https://$host:$port/services/ClaimMetadataManagementService.ClaimMetadataManagementServiceHttpsSoap12Endpoint/ \
#     --insecure)

# case "$soapResponse" in
#     *return* )                  echo "- claim updated";;
#     *errorCode* )               echo "- claim update failed";;
#     *"Authentication failed"*)  echo "- authentication failure";;
#     *)                          echo "- error occurred during creation";;
# esac


# echo ""



