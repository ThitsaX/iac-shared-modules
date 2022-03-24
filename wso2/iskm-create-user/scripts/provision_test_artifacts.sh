#! /bin/bash
 
debug="false" 
trace="false"

eval "$(jq -r '@sh "hostname=\(.host) adminport=\(.admin_port) adminuser=\(.admin_user) adminpassword=\(.admin_pass) account_username=\(.account_username) account_password=\(.account_password) account_email=\(.account_email)"')"


if [ -z $hostname ] || [ -z $adminport ] || [ -z $adminuser ] || [ -z $adminpassword ] || [ -z $account_username ] || [ -z $account_password ]
then
    echo " "
    echo "Missing arguments"
    echo "usage: ./provision_user.sh -d <debug> -t <trace> -h hostname -a adminport -u adminuser -p adminpassword -g account_username -w account_password -b subscribetoapis_csv"
    echo " "
    exit 100
fi

if [ $adminuser = $account_username ]
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

if [[ $debug = "true" ]]
then
    echo ""
    echo "Provisioning user account"

    echo ""
    echo "1.    obtaining admin account tokens"
fi


_admin_basic_header=$(printf '%s' $adminuser:$adminpassword | base64)
if [[ $debug = "true" ]]
then
    echo "      _admin_basic_header: $_admin_basic_header"
fi

# step 1:   does user exist?
if [[ $debug = "true" ]]
then
    echo ""
    echo "3.    verifying user account"
fi
_payload_isExistingUser="<soap:Envelope xmlns:soap=\"http://www.w3.org/2003/05/soap-envelope\" xmlns:ser=\"http://service.ws.um.carbon.wso2.org\"><soap:Header/><soap:Body><ser:isExistingUser><ser:userName>$account_username</ser:userName></ser:isExistingUser></soap:Body></soap:Envelope>"
_response_isExistingUser=$(curl -s -k -H "Authorization: Basic $_admin_basic_header" -d "$_payload_isExistingUser"  -H "Content-Type: application/soap+xml;charset=UTF-8;action=\"urn:isExistingUser\"" https://$hostname:$adminport/services/RemoteUserStoreManagerService.RemoteUserStoreManagerServiceHttpsSoap12Endpoint)
_user_exists=$(echo $_response_isExistingUser | grep -oPm1 "(?<=<ns:return>)[^<]+")

if [[ $trace = "true" ]]
then
    echo "      _payload_isExistingUser: $_payload_isExistingUser"
    echo "      __response_isExistingUser: $_response_isExistingUser"
fi

# step 2:   create user -or- reset password if user exists

user_created=false 
user_modified=false

if [[ $_user_exists = "true" ]]
then
    if [[ $debug = "true" ]]
    then
        echo "      user [$account_username] exists"
        echo ""
        echo "3.    not going to reset user password"
    fi

    # resetting user password to provided value

    # _resetpassword_payload="<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:ser=\"http://service.ws.um.carbon.wso2.org\"><soapenv:Header/><soapenv:Body><ser:updateCredentialByAdmin><ser:userName>$account_username</ser:userName><ser:newCredential>$account_password</ser:newCredential></ser:updateCredentialByAdmin></soapenv:Body></soapenv:Envelope>"
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

    # resetting user email to provided value

    # if [ -z $account_email ]
    # then
    if [[ $debug = "true" ]]
    then
        echo "      user [$account_username] exists"
        echo ""
        echo "8.    going to update the user email"
    fi

    _resetemail_payload="<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:ser=\"http://service.ws.um.carbon.wso2.org\"><soapenv:Header/><soapenv:Body><ser:setUserClaimValues><ser:userName>$account_username</ser:userName><ser:claims><ser:claimURI>http://wso2.org/claims/emailaddress</ser:claimURI><ser:value>$account_email</ser:value></ser:claims></ser:setUserClaimValues></soapenv:Body></soapenv:Envelope>"
    _resetemail_response=$(curl --silent --write-out "HTTPSTATUS:%{http_code}" -X POST -H "Content-Type: text/xml;charset=UTF-8" -H "SOAPAction: urn:setUserClaimValues" -H "Authorization: Basic $_admin_basic_header" --data "$_resetemail_payload" https://$hostname:$adminport/services/RemoteUserStoreManagerService --insecure)
    _resetemail_statuscode=$(echo $_resetemail_response | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')

    if [[ $debug = "true" ]]
    then
        echo "_resetemail_payload:"
        echo $_resetemail_payload
        echo "_resetemail_statuscode:"
        echo $_resetemail_statuscode
    fi

    if [ $_resetemail_statuscode != "202" ]
    then
        echo "{ \"errorcode\" : \"008\", \"error\" : \"The gateway user's email could not be reset\" }" | jq '.'
        exit 8
    else
        user_modified=true
    fi
    # fi

else
    if [[ $debug = "true" ]]
    then
        echo "      user [$account_username] does not exist"
        echo ""
        echo "4.    creating new user"
    fi

    _createuser_payload="<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:ser=\"http://service.ws.um.carbon.wso2.org\" xmlns:xsd=\"http://common.mgt.user.carbon.wso2.org/xsd\"><soapenv:Header/><soapenv:Body><ser:addUser><ser:userName>"$account_username"</ser:userName><ser:credential>"$account_password"</ser:credential><ser:roleList>Internal/everyone</ser:roleList><ser:claims><xsd:claimURI>http://wso2.org/claims/emailaddress</xsd:claimURI><xsd:value>"$account_email"</xsd:value></ser:claims><ser:claims><xsd:claimURI>http://wso2.org/claims/fullname</xsd:claimURI><xsd:value>"$account_email"</xsd:value></ser:claims><ser:profileName>default</ser:profileName><ser:requirePasswordChange>false</ser:requirePasswordChange></ser:addUser></soapenv:Body></soapenv:Envelope>"
    _createuser_response=$(curl -k -s -X POST https://$hostname:$adminport/services/RemoteUserStoreManagerService -H "Authorization: Basic $_admin_basic_header" -H 'Content-Type: text/xml' -H 'SOAPAction: urn:addUser' -d "$_createuser_payload")

    # verifying user is created
    _response_isExistingUser=$(curl -s -k -H "Authorization: Basic $_admin_basic_header" -d "$_payload_isExistingUser"  -H "Content-Type: application/soap+xml;charset=UTF-8;action=\"urn:isExistingUser\"" https://$hostname:$adminport/services/RemoteUserStoreManagerService.RemoteUserStoreManagerServiceHttpsSoap12Endpoint)
    _user_exists=$(echo $_response_isExistingUser | grep -oPm1 "(?<=<ns:return>)[^<]+")

    if [[ $_user_exists = "true" ]]
    then
        user_created=true
    fi

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
            echo "      user [$account_username] created"
        else
            echo "{ \"errorcode\" : \"007\", \"error\" : \"The user account could not be created.\" }" | jq '.'
            exit 6
        fi
    fi
fi

# Get userID of the created user
_getuserid_payload="<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:ser=\"http://service.ws.um.carbon.wso2.org\" xmlns:xsd=\"http://common.mgt.user.carbon.wso2.org/xsd\"><soapenv:Header/><soapenv:Body><ser:getUserClaimValue><ser:userName>"$account_username"</ser:userName><ser:claim>http://wso2.org/claims/userid</ser:claim><ser:profileName>default</ser:profileName></ser:getUserClaimValue></soapenv:Body></soapenv:Envelope>"
_getuserid_response=$(curl -k -s -X POST https://$hostname:$adminport/services/RemoteUserStoreManagerService -H "Authorization: Basic $_admin_basic_header" -H 'Content-Type: text/xml' -H 'SOAPAction: urn:getUserClaimValue' -d "$_getuserid_payload")
account_userid=$(echo $_getuserid_response | grep -oPm1 "(?<=<ns:return>)[^<]+")

if [[ $trace = "true" ]]
then
    echo "_getuserid_payload:"
    echo $_getuserid_payload
    echo "_getuserid_response:"
    echo $_getuserid_response
fi

if [[ $debug = "true" ]]
then
    echo "      UserID for the user [$account_userid]"
fi

jq -n --arg account_userid $account_userid --arg user_created $user_created --arg user_modified $user_modified '{"account_userid":$account_userid,"user_created":$user_created,"user_modified":$user_modified}'
