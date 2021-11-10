#! /bin/bash
# obtain an oauth token from the gateway for @user @password @scope
while getopts u:p:s:r:a:g:v: option
do  
    case "${option}" in   
        u) username=${OPTARG};;         
        p) password=${OPTARG};;  
        s) scope=${OPTARG};;
        r) restport=${OPTARG};;
        a) adminport=${OPTARG};;
        g) gateway_hostname=${OPTARG};;
        v) verbose=true;;        
    esac    
done
if [ -z $username ] || [ -z $password ] || [ -z $gateway_hostname ] || [ -z $restport ] || [ -z $adminport ]
then
    echo " "
    echo "Missing arguments"
    echo "usage: ./getoauth.sh -u wso2username -p wso2password -r apiport [8243] -a adminport [9443] -s scope <true> -g gateway_hostname -v verbose [true]"
    echo " "
    exit
fi
if [ "$verbose" = true ] ; then
    echo "- username: $username"
    echo "- password: $password"
fi
#api_gateway_rest_endpoint_port="9443"
api_gateway_rest_endpoint_port=$(echo $adminport)
#api_gateway_token_endpoint_port="8243"
api_gateway_token_endpoint_port=$(echo $restport)
base_api_context="/api/am/store/v0.14"
dcr_api_context="/client-registration/v0.14/register"
token_api_context="/token"
#admin_authorization_header=$(echo $username:$password | base64 );
admin_authorization_header=$(printf '%s' $username:$password | base64)
if [ "$verbose" = true ] ; then
    echo "- admin_authorization_header: $admin_authorization_header"
fi
# dcr_request_payload="{
#         \"callbackUrl\": \"$gateway_hostname\",
#         \"clientName\": \"MCM_portal\",
#         \"owner\": \"$username\",
#         \"grantType\": \"password\",
#         \"saasApp\": false
#         }"
# #   register client and get auth header
# if [ "$verbose" = true ] ; then
#     echo "register client and get auth header"
# fi
dcr_authorization_header=$( echo -n "$username":"$password" | base64 )
    #This is the DCR payload that will be used to register a client
    dcr_request_payload="{
        \"callbackUrl\": \"www.example.com\",
        \"clientName\": \"MCM_portal\",
        \"owner\": \"$username\",
        \"grantType\": \"password refresh_token\",
        \"saasApp\": false
        }"
    
    # echo "dcr_request_payload: $dcr_request_payload"
    # echo "dcr_endpoint: https://$gateway_hostname:$api_gateway_rest_endpoint_port$dcr_api_context"
    
    dcr_endpoint="https://"$gateway_hostname":"$api_gateway_rest_endpoint_port$dcr_api_context
    dcr_response=$(curl -s -k -X POST -H "Authorization: Basic $dcr_authorization_header" -H "Content-Type: application/json" -d "$dcr_request_payload" $dcr_endpoint)
    
    # echo "dcr_response: $dcr_response"
    client_id=$(echo $dcr_response | awk -F'"clientId":' '{print $2}' | cut -d',' -f 1 | tr -d '[:space:]' | awk -F'"' '{print $2}' )
    client_secret=$(echo $dcr_response | awk -F'"clientSecret":' '{print $2}' | cut -d',' -f 1 | tr -d '[:space:]' | awk -F'"' '{print $2}' )
    
    #invoking the token endpoint
    token_endpoint="https://"$gateway_hostname":"$api_gateway_token_endpoint_port$token_api_context
    token_request_authorization_header=$(echo -n "$client_id":"$client_secret" | base64 )
    token_authorization_header=$(printf '%s' $client_id:$password | base64)
    api_subscribe_token_response=$(curl -s -k -d "grant_type=password&username=$username&password=$password&scope=apim:subscribe" -H "Authorization: Basic $token_request_authorization_header" $token_endpoint)

    api_subscribe_token=$(echo $api_subscribe_token_response | awk -F'"access_token":' '{print $2}' | cut -d',' -f 1 | tr -d '[:space:]' | awk -F'"' '{print $2}' )
    echo "client id:     $client_id"
    echo "client secret: $client_secret"
    echo "bearer token:  $api_subscribe_token"