#! /bin/bash
 
debug="false" 
trace="false"

eval "$(jq -r '@sh "tokenhostname=\(.token_host) hostname=\(.host) adminport=\(.admin_port) serviceport=\(.service_port) adminuser=\(.admin_user) adminpassword=\(.admin_pass) gatewayuser=\(.account_name) gatewaypassword=\(.account_pass) subscribetoapis=\(.api_list)"')"


if [ -z $tokenhostname ] [ -z $hostname ] || [ -z $adminport ] || [ -z $serviceport ] || [ -z $adminuser ] || [ -z $adminpassword ] || [ -z $gatewayuser ] || [ -z $gatewaypassword ] || [ -z $subscribetoapis ]
then
    echo " "
    echo "Missing arguments"
    echo "usage: ./provision_user.sh -d <debug> -t <trace> -t tokenhostname -h hostname -a adminport -s serviceport -u adminuser -p adminpassword -g gatewayuser -w gatewaypassword -b subscribetoapis_csv"
    echo " "
    exit 100
fi

if [ $adminuser = $gatewayuser ]
then
    echo "{ \"errorcode\" : \"001\", \"error\" : \"Cannot run script for admin user.\" }" | jq '.'
    exit 1
fi

###     testing connectivity to admin port

if [ $debug = "true" ]
then
    echo "Testing connectivity to admin port - https://$hostname:$adminport"
fi
_connectivity_response=$(curl --silent --write-out "HTTPSTATUS:%{http_code}" -X GET -H "Content-Type: text/xml;charset=UTF-8" https://$hostname:$adminport/carbon/admin/login.jsp --insecure)
_connectivity_statuscode=$(echo $_connectivity_response | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')
if [[ $_connectivity_statuscode = "200" ]]
then
    if [ $debug = "true" ]
    then
        echo "- connectivity to admin port established: $_connectivity_statuscode"
    fi
else
    echo "{ \"errorcode\" : \"002\", \"error\" : \"Cannot reach service on admin endpoint https://$hostname:$adminport/carbon/admin/login.jsp. (HTTP: $_connectivity_statuscode)\" }" | jq '.'
    exit 2
fi

###     testing connectivity to service port

if [ $debug = "true" ]
then
    echo "Testing connectivity to API gateway port - https://$tokenhostname:$serviceport"
fi
_connectivity_response=$(curl --silent --write-out "HTTPSTATUS:%{http_code}" -k https://$tokenhostname:$serviceport/token --insecure)
_connectivity_statuscode=$(echo $_connectivity_response | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')
if [ $_connectivity_statuscode = "200" ] || [ $_connectivity_statuscode = "405" ]
then
    if [ $debug = "true" ]
    then
        echo "- connectivity to admin port established: $_connectivity_statuscode"
    fi
else
    echo "{ \"errorcode\" : \"003\", \"error\" : \"Cannot reach service on service endpoint https://$tokenhostname:$serviceport/token. (HTTP: $_connectivity_statuscode)\" }" | jq '.'
    exit 3
fi

###     building json for apis to subscribe to

IFS=',' read -r -a array <<< "$subscribetoapis"
for element in "${array[@]}"
do
    if [[ -z $_subscribetoapis_json ]]
    then
        _subscribetoapis_json="[ \"${element}\""
    else    
        _subscribetoapis_json=${_subscribetoapis_json}", \"${element}\""
    fi
done
_subscribetoapis_json=${_subscribetoapis_json}" ]"


if [[ $debug = "true" ]]
then
    echo ""
    echo "Provisioning user account"

    echo ""
    echo "1.    obtaining admin account tokens"
fi

if [[ $trace = "true" ]]
then
    echo $_subscribetoapis_json
fi

# step 1:   get admin tokens

_admin_basic_header=$(printf '%s' $adminuser:$adminpassword | base64)
if [[ $debug = "true" ]]
then
    echo "      _admin_basic_header: $_admin_basic_header"
fi

###     registering service provider

if [[ $debug = "true" ]]
then

    echo ""
    echo "2.    registering service provider"
fi

_service_provider=$(curl -s -k -X POST -H "Authorization: Basic $_admin_basic_header" -H "Content-Type: application/json" -d '{ "callbackUrl": "", "clientName": "simulator_selfservice_'$gatewayuser'", "owner": "'$adminuser'", "grantType": "refresh_token urn:ietf:params:oauth:grant-type:saml2-bearer password client_credentials iwa:ntlm urn:ietf:params:oauth:grant-type:jwt-bearer", "saasApp": true }' https://$hostname:$adminport/client-registration/v0.14/register/)
_client_id=$(echo $_service_provider | grep -oP '(?<="clientId":")[^"]*')
_client_secret=$(echo $_service_provider | grep -oP '(?<="clientSecret":")[^"]*')
if [[ $debug = "true" ]]
then
    echo "      _client_id: $_client_id"
    echo "      _client_secret: $_client_secret"
fi

if [ -z $_client_id ] || [ -z $_client_secret ]
then
    echo "{ \"errorcode\" : \"004\", \"error\" : \"A service provider could not be registered to obtain a gateway token for the admin account.\" }" | jq '.'
    exit 3
fi

_admin_auth_header=$(printf '%s' $_client_id:$_client_secret | base64)
_token_response=$(curl -s -k -d "grant_type=password&username=$adminuser&password=$adminpassword&scope=apim:subscribe" -H "Authorization: Basic $_admin_auth_header" https://$tokenhostname:$serviceport/token )
_admin_token=$(echo $_token_response | grep -oP '(?<="access_token":")[^"]*')
if [[ $debug = "true" ]]
then
    echo "      $_admin_token"
fi

if [ -z $_admin_token ]
then
    echo "{ \"errorcode\" : \"005\", \"error\" : \"An admin token could not be obtained from the API gateway\" }" | jq '.'
    exit 4
fi

# step 2:   does user exist?
if [[ $debug = "true" ]]
then
    echo ""
    echo "3.    verifying user account"
fi
_payload_isExistingUser="<soap:Envelope xmlns:soap=\"http://www.w3.org/2003/05/soap-envelope\" xmlns:ser=\"http://service.ws.um.carbon.wso2.org\"><soap:Header/><soap:Body><ser:isExistingUser><ser:userName>$gatewayuser</ser:userName></ser:isExistingUser></soap:Body></soap:Envelope>"
_response_isExistingUser=$(curl -s -k -H "Authorization: Basic $_admin_basic_header" -d "$_payload_isExistingUser"  -H "Content-Type: application/soap+xml;charset=UTF-8;action=\"urn:isExistingUser\"" https://$hostname:$adminport/services/RemoteUserStoreManagerService.RemoteUserStoreManagerServiceHttpsSoap12Endpoint)
_user_exists=$(echo $_response_isExistingUser | grep -oPm1 "(?<=<ns:return>)[^<]+")

if [[ $trace = "true" ]]
then
    echo "      _payload_isExistingUser: $_payload_isExistingUser"
    echo "      __response_isExistingUser: $_response_isExistingUser"
fi

# step 3:   create user -or- reset password if user exists

if [[ $_user_exists = "true" ]]
then
    if [[ $debug = "true" ]]
    then
        echo "      user [$gatewayuser] exists"
        echo ""
        echo "3.    not going to reset user password"
    fi

    # resetting user password to provided value

    # _resetpassword_payload="<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:ser=\"http://service.ws.um.carbon.wso2.org\"><soapenv:Header/><soapenv:Body><ser:updateCredentialByAdmin><ser:userName>$gatewayuser</ser:userName><ser:newCredential>$gatewaypassword</ser:newCredential></ser:updateCredentialByAdmin></soapenv:Body></soapenv:Envelope>"
    # _resetpassword_response=$(curl --silent --write-out "HTTPSTATUS:%{http_code}" -X POST -H "Content-Type: text/xml;charset=UTF-8" -H "SOAPAction: urn:updateCredentialByAdmin" -H "Authorization: Basic $_admin_basic_header" --data "$_resetpassword_payload" https://$hostname:$adminport/services/RemoteUserStoreManagerService.RemoteUserStoreManagerServiceHttpsSoap11Endpoint/ --insecure)
    # _resetpassword_statuscode=$(echo $_resetpassword_response | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')

    # if [[ $debug = "true" ]]
    # then
    #     echo "      reset response: $_resetpassword_statuscode"
    # fi

    # if [ $_resetpassword_statuscode != "202" ]
    # then
    #     echo "{ \"errorcode\" : \"006\", \"error\" : \"The gateway user's password could not be reset\" }" | jq '.'
    #     exit 5
    # fi

else
    if [[ $debug = "true" ]]
    then
        echo "      user [$gatewayuser] does not exist"
        echo ""
        echo "4.    creating new user"
    fi

    _createuser_payload="<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:ser=\"http://service.ws.um.carbon.wso2.org\" xmlns:xsd=\"http://common.mgt.user.carbon.wso2.org/xsd\"><soapenv:Header/><soapenv:Body><ser:addUser><ser:userName>"$gatewayuser"</ser:userName><ser:credential>"$gatewaypassword"</ser:credential><ser:roleList>Internal/subscriber</ser:roleList><ser:roleList>Application/MTA</ser:roleList><ser:roleList>Application/PTA</ser:roleList><ser:profileName>default</ser:profileName><ser:requirePasswordChange>false</ser:requirePasswordChange></ser:addUser></soapenv:Body></soapenv:Envelope>"
    _createuser_response=$(curl -k -s -X POST https://$hostname:$adminport/services/RemoteUserStoreManagerService -H "Authorization: Basic $_admin_basic_header" -H 'Content-Type: text/xml' -H 'SOAPAction: urn:addUser' -d "$_createuser_payload")

    # verifying user is created
    _response_isExistingUser=$(curl -s -k -H "Authorization: Basic $_admin_basic_header" -d "$_payload_isExistingUser"  -H "Content-Type: application/soap+xml;charset=UTF-8;action=\"urn:isExistingUser\"" https://$hostname:$adminport/services/RemoteUserStoreManagerService.RemoteUserStoreManagerServiceHttpsSoap12Endpoint)
    _user_exists=$(echo $_response_isExistingUser | grep -oPm1 "(?<=<ns:return>)[^<]+")

    if [[ $trace = "true" ]]
    then
        echo "_createuser_payload:"
        echo $_createuser_payload
        echo "_createuser_response:"
        echo $_createuser_response
        echo "_response_isExistingUser:"
        echo $_response_isExistingUser
    fi

    if [[ $debug = "true" ]]
    then
        if [[ $_user_exists = "true" ]]
        then
            echo "      user [$gatewayuser] created"
        else
            echo "{ \"errorcode\" : \"007\", \"error\" : \"The user account could not be created.\" }" | jq '.'
            exit 6
        fi
    fi
fi

# step 4:   get tokens for self service gatewayaccount 
if [[ $debug = "true" ]]
then
    echo ""
    echo "5.    obtaining gateway user tokens"
fi

_gatewayaccount_basic_header=$(printf '%s' $gatewayuser:$gatewaypassword | base64)
if [[ $debug = "true" ]]
then
    echo "      _gatewayaccount_basic_header: $_gatewayaccount_basic_header"
fi

_gateway_service_provider=$(curl -s -k -X POST -H "Authorization: Basic $_gatewayaccount_basic_header" -H "Content-Type: application/json" -d '{ "callbackUrl": "", "clientName": "simulator_selfservice_'$gatewayuser'", "owner": "'$gatewayuser'", "grantType": "refresh_token client_credentials urn:ietf:params:oauth:grant-type:saml2-bearer iwa:ntlm password urn:ietf:params:oauth:grant-type:jwt-bearer", "saasApp": false }' https://$hostname:$adminport/client-registration/v0.14/register/)
_gateway_client_id=$(echo $_gateway_service_provider | grep -oP '(?<="clientId":")[^"]*')
_gateway_client_secret=$(echo $_gateway_service_provider | grep -oP '(?<="clientSecret":")[^"]*')
if [[ $debug = "true" ]]
then
    echo "      _gateway_client_id: $_gateway_client_id"
    echo "      _gateway_client_secret: $_gateway_client_secret"
fi

if [ -z $_gateway_client_id ] || [ -z $_gateway_client_secret ]
then
    echo "{ \"errorcode\" : \"008\", \"error\" : \"A service provider could not be created for the gateway account\" }" | jq '.'
    exit 7
fi

_gateway_auth_header=$(printf '%s' $_gateway_client_id:$_gateway_client_secret | base64)
_gateway_token_response=$(curl -s -k -d "grant_type=password&username=$gatewayuser&password=$gatewaypassword&scope=apim:subscribe" -H "Authorization: Basic $_gateway_auth_header" https://$tokenhostname:$serviceport/token )
_gateway_token=$(echo $_gateway_token_response | grep -oP '(?<="access_token":")[^"]*')
if [[ $debug = "true" ]]
then
    echo "      _gateway_token: $_gateway_token"

    echo ""
    echo "6.    check if application exist, get id"
fi

if [ -z $_gateway_token ]
then
    echo "{ \"errorcode\" : \"009\", \"error\" : \"A token could not be generated for the gateway user\" }" | jq '.'
    exit 8
fi

_application_response=$(curl -s -k -H "Authorization: Bearer $_gateway_token" https://$hostname:$adminport/api/am/store/v0.14/applications)
_application_list=$(echo $_application_response | jq -c '.["list"]')
_application_array=$(echo $_application_list | jq -c '.')

if [[ $trace = "true" ]]
then
    echo "      _application_array: $_application_array"
fi

_count=$(echo $_application_response | jq -r -c '.count')
if [[ $debug = "true" ]]
then
    echo "      _count: $_count applications exist"
fi

_application_id=""
for ((i=0;i<$_count;i++));
do    
    _application_name=$(echo $_application_array | jq -r -c '.['$i'].name')
    if [[ "$_application_name" = "DefaultApplication" ]]
    then
        _application_id=$(echo $_application_array | jq -r -c '.['$i'].applicationId')
    fi
done

if [ -z $_application_id ]; then
    echo "{ \"errorcode\" : \"010\", \"error\" : \"Could not retrieve user application id.\" }"
    exit 9
fi

if [[ $debug = "true" ]]
then
    echo "      _application_id: $_application_id"
fi

if [[ $debug = "true" ]]
then
    echo ""
    echo "7.    listing apis on server"
fi
_api_response=$(curl -s -k  https://$hostname:$adminport/api/am/store/v0.14/apis)
_api_list=$(echo $_api_response | jq -c '.["list"]')

if [[ $trace = "true" ]]
then
    echo "_api_response: $_api_response"
fi

_api_count=$(echo $_api_response | jq -r -c '.count')
if [[ $debug = "true" ]]
then
    echo "      _count: $_api_count apis exist"
fi

#_api_names_for_subscriptions=$(echo $subscribetoapis | jq '.[]')

for ((i=0;i<$_api_count;i++));
do    
    _api_name=$(echo $_api_list | jq -r -c '.['$i'].name')
    if [[ $trace = "true" ]]
    then
        echo "      _api_name: $_api_name"
    fi

    #echo "      _api_name: $_api_name"
    _api_index=$(echo $_subscribetoapis_json | jq 'index("'${_api_name}'")')
    #echo "_api_index: $_api_index"
    if [[ "$_api_index" != "null" ]]
    then
        _api_id=$(echo $_api_list | jq -r -c '.['$i'].id')

        if [[ $debug = "true" ]]
        then 
            echo ""
            echo "      removing existing subscriptions"
        fi
        _subscriptions_response=$(curl -s -k -H "Authorization: Bearer $_gateway_token" "https://$hostname:$adminport/api/am/store/v0.14/subscriptions?apiId=$_api_id")
        _subscriptions_list=$(echo $_subscriptions_response | jq -c '.["list"]')
        _subscription_count=$(echo $_subscriptions_response | jq -r -c '.count')

        if [[ $trace = "true" ]]
        then        
            echo $_subscriptions_response
        fi

        for ((j=0;j<$_subscription_count;j++));
        do
            _subscription_id=$(echo $_subscriptions_list | jq -r -c '.['$j'].subscriptionId')
            _subscription_delete_response=$(curl -s -k -H "Authorization: Bearer $_gateway_token" -X DELETE "https://$hostname:$adminport/api/am/store/v0.14/subscriptions/$_subscription_id")
            if [[ $trace = "true" ]]
            then
                echo ""
                echo $_subscription_delete_response
                echo ""
            fi
        done 

        if [[ $debug = "true" ]]
        then
            echo "      subscribing to api: $_api_id"
        fi 
        _subscription_payload="{ \"tier\": \"Unlimited\", \"apiIdentifier\": \"$_api_id\", \"applicationId\": \"$_application_id\" }"
        _subscription_response=$(curl -s -k -H "Authorization: Bearer $_gateway_token" -H "Content-Type: application/json" -X POST  -d "$_subscription_payload" "https://$hostname:$adminport/api/am/store/v0.14/subscriptions")
        _subscription_id=$(echo $_subscription_response | jq -r -c '.subscriptionId')
        _subscription_status=$(echo $_subscription_response | jq -r -c '.status')

        if [[ $debug = "true" ]]
        then
            echo "      _subscription_id: $_subscription_id"
            echo "      _subscription_status: $_subscription_status"
        fi

        if [[ $trace = "true" ]]
        then
            echo "      _subscription_response:"
            echo $_subscription_response
        fi
    fi
done

#   step 5:     creating / retrieving key and secret for default application
#   step 5.1    does production key exist?

_keysecret_response=$(curl --silent --write-out "HTTPSTATUS:%{http_code}" -H "Authorization: Bearer $_gateway_token" https://$hostname:$adminport/api/am/store/v0.14/applications/$_application_id/keys/PRODUCTION --insecure)
_keysecret_response_code=$(echo $_keysecret_response | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')

if [ $debug = "true" ]; then
    echo "_keysecret_response: $_keysecret_response"
fi

if [ $_keysecret_response_code = "200" ]; then
    _keysecret_response=$(curl --silent -H "Authorization: Bearer $_gateway_token" https://$hostname:$adminport/api/am/store/v0.14/applications/$_application_id/keys/PRODUCTION --insecure)
    
    if [ $debug = "true" ]; then
        echo "_keysecret_response: $_keysecret_response"
    fi

    _consumerKey=$(echo $_keysecret_response | jq -r -c '.consumerKey')
    _consumerSecret=$(echo $_keysecret_response | jq -r -c '.consumerSecret')
    _basicHeader=$(printf '%s' $_consumerKey:$_consumerSecret | base64)
else
    _keysecret_response=$(curl --silent -k -H "Authorization: Bearer $_gateway_token" -H "Content-Type: application/json" -X POST -d '{"validityTime": "3600","keyType": "PRODUCTION","accessAllowDomains": [ "ALL" ],"scopes": [ "am_application_scope", "default" ],"supportedGrantTypes": [ "urn:ietf:params:oauth:grant-type:saml2-bearer", "iwa:ntlm", "refresh_token", "client_credentials", "password" ]}' "https://$hostname:$adminport/api/am/store/v0.14/applications/generate-keys?applicationId=$_application_id")
    
    if [ $debug = "true" ]; then
        echo "_keysecret_response: $_keysecret_response"
    fi
    
    _consumerKey=$(echo $_keysecret_response | jq -r -c '.consumerKey')
    _consumerSecret=$(echo $_keysecret_response | jq -r -c '.consumerSecret')
    _basicHeader=$(printf '%s' $_consumerKey:$_consumerSecret | base64)
fi

echo "{ \"result\" : \"ok\", \"username\" : \"$gatewayuser\", \"password\" : \"$gatewaypassword\", \"clientId\" : \"$_consumerKey\", \"clientSecret\" : \"$_consumerSecret\", \"basicAuthHeader\": \"$_basicHeader\" } " | jq '.' > ${gatewayuser}_results
