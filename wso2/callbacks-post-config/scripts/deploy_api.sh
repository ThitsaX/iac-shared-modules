#! /bin/bash

# fail if any env var is not set
set -u

#Loading the configurations from the environment.config file.

BASEDIR=$(dirname "$0")
#echo "$BASEDIR"

while getopts u:p:e: option; do
    case "${option}" in
    u) username=${OPTARG} ;;
    p) password=${OPTARG} ;;
    e) environment=${OPTARG} ;;
    esac
done

#This is the DCR payload that will be used to register a client
dcr_request_payload="{
    \"callbackUrl\": \"www.example.com\",
    \"clientName\": \"rest_api_publisher$environment\",
    \"owner\": \"$username\",
    \"grantType\": \"password refresh_token\",
    \"saasApp\": true
    }"

log_error() {
    if [ $# == 1 ]; then
        if [ $1 != 0 ]; then
            echo "Error occurred while connecting to the WSO2 service"
        fi
    elif [ $# == 2 ]; then
        if [ $1 != 0 ]; then
            echo "Error occurred while $2 from WSO2 service"
            exit $1
        fi
    elif [ $# == 3 ]; then
        echo "$3"
    fi
}

add_sequences() {
    api_mediation_sequence_add_all_payload=""

    if [ -z "$(ls -A $4/mediation/in/$environment.* | xargs -n 1 basename)" ]; then
        echo "In sequences not found for API : \"$api_name\""
    else
        echo ""
        echo "In sequences found for API : \"$api_name\""

        for sequence_file_name in "$4/mediation/in/$environment.*"; do
            echo "- adding sequence: $sequence_file_name"
            sequence_file_content=$(cat $sequence_file_name | sed -e 's/\\/\\\\/g' | sed -e 's/\"/\\"/g')
            sequence_file_content_no_escape=$(cat $sequence_file_name)

            sequence_name=$(echo $sequence_file_content_no_escape | awk -F'name="' '{print $2}' | cut -d'"' -f 1 | tr -d '[:space:]')

            echo "Adding in sequence : $sequence_name for API : \"$api_name\""

            add_sequence_request_payload="{\"name\": \""$sequence_name"\",\"type\": \"in\",\"config\": \""$sequence_file_content"\"}"
            add_sequence_request_payload_minimum="{\"name\": \""$sequence_name"\",\"type\": \"in\"}"

            #adding the mediation policy
            api_mediation_sequence_add_endpoint="https://$internal_gateway_hostname":"$api_gateway_rest_endpoint_port$base_api_context"/"$1/policies/mediation"

            #Create a temp file with the payload.
            $(echo $add_sequence_request_payload | cat >"$environment-mediation_data.json")
            api_mediation_sequence_add_endpoint_response=$(curl -s -X POST -k -H "Authorization: Bearer $3" -H "Content-Type: application/json" -d @"$environment-mediation_data.json" $api_mediation_sequence_add_endpoint)

            log_error $? "adding in sequences for API : \"$api_name\""
            #rm "$environment-mediation_data.json"

            #Payload construction for the update API with mediation policies
            api_mediation_sequence_add_all_payload=$api_mediation_sequence_add_all_payload$add_sequence_request_payload_minimum","

            echo "Successfully added in sequence : $sequence_name for API : \"$api_name\""
            echo ""
        done
    fi

    if [ -z "$(ls -A $4/mediation/out/$environment.* | xargs -n 1 basename)" ]; then
        echo "Out sequences not found for API : \"$api_name\""
    else
        echo "Out sequences found for API : \"$api_name\""

        for sequence_file_name in "$4/mediation/out"/*; do
            sequence_file_content=$(cat $sequence_file_name | sed -e 's/\\/\\\\/g' | sed -e 's/\"/\\"/g')
            sequence_file_content_no_escape=$(cat $sequence_file_name)

            sequence_name=$(echo $sequence_file_content_no_escape | awk -F'name="' '{print $2}' | cut -d'"' -f 1 | tr -d '[:space:]')

            echo "Adding out sequence : $sequence_name for API : \"$api_name\""

            add_sequence_request_payload="{\"name\": \""$sequence_name"\",\"type\": \"out\",\"config\": \""$sequence_file_content"\"}"
            add_sequence_request_payload_minimum="{\"name\": \""$sequence_name"\",\"type\": \"out\"}"

            #adding the mediation policy
            api_mediation_sequence_add_endpoint="https://$internal_gateway_hostname":"$api_gateway_rest_endpoint_port$base_api_context"/"$1/policies/mediation"

            #Create a temp file with the payload.
            $(echo $add_sequence_request_payload | cat >"$environment-mediation_data.json")
            api_mediation_sequence_add_endpoint_response=$(curl -s -X POST -k -H "Authorization: Bearer $3" -H "Content-Type: application/json" -d @"$environment-mediation_data.json" $api_mediation_sequence_add_endpoint)
            log_error $? "adding out sequences for API : \"$api_name\""
            rm "$environment-mediation_data.json"

            #Payload construction for the update API with mediation policies
            api_mediation_sequence_add_all_payload=$api_mediation_sequence_add_all_payload$add_sequence_request_payload_minimum","

            echo "Successfully added out sequence : $sequence_name for API : \"$api_name\""
        done
    fi

    if [ -z "$(ls -A $4/mediation/fault/$environment.* | xargs -n 1 basename)" ]; then
        echo "Fault sequences not found for API : \"$api_name\""
    else

        echo "Fault sequences found for API : \"$api_name\""

        for sequence_file_name in "$4/mediation/fault"/*; do
            sequence_file_content=$(cat $sequence_file_name | sed -e 's/\\/\\\\/g' | sed -e 's/\"/\\"/g')
            sequence_file_content_no_escape=$(cat $sequence_file_name)

            sequence_name=$(echo $sequence_file_content_no_escape | awk -F'name="' '{print $2}' | cut -d'"' -f 1 | tr -d '[:space:]')

            echo "Adding fault sequence : $sequence_name for API : \"$api_name\""

            add_sequence_request_payload="{\"name\": \""$sequence_name"\",\"type\": \"fault\",\"config\": \""$sequence_file_content"\"}"
            add_sequence_request_payload_minimum="{\"name\": \""$sequence_name"\",\"type\": \"fault\"}"

            #adding the mediation policy
            api_mediation_sequence_add_endpoint="https://$internal_gateway_hostname":"$api_gateway_rest_endpoint_port$base_api_context"/"$1/policies/mediation"

            #Create a temp file with the payload.
            $(echo $add_sequence_request_payload | cat >"$environment-mediation_data.json")
            api_mediation_sequence_add_endpoint_response=$(curl -s -X POST -k -H "Authorization: Bearer $3" -H "Content-Type: application/json" -d @"$environment-mediation_data.json" $api_mediation_sequence_add_endpoint)
            log_error $? "adding fault sequences for API : \"$api_name\""
            rm "$environment-mediation_data.json"

            #Payload construction for the update API with mediation policies
            api_mediation_sequence_add_all_payload=$api_mediation_sequence_add_all_payload$add_sequence_request_payload_minimum","

            echo "Successfully added fault sequence : $sequence_name for API : \"$api_name\""
        done
    fi

    api_mediation_sequence_add_all_payload_final="["${api_mediation_sequence_add_all_payload%?}"]"

    update_api_with_mediation_policy "$1" "$2" "$3" "$api_mediation_sequence_add_all_payload_final"
}

update_api_with_mediation_policy() {
    echo "Updating API : \"$api_name\" with mediation policies"

    api_creation_payload_content_with_mediation_updated=$(echo $2 | awk -F'"sequences":' '{print $1}')"\"sequences\":"$4$(echo $2 | awk -F'"sequences":' '{print $2}' | sed -e "s/\[\([^]]*\)\]//")

    api_update_mediation_endpoint="https://"$internal_gateway_hostname":"$api_gateway_rest_endpoint_port$base_api_context"/"$1

    #Create a temp file with the payload.
    $(echo $api_creation_payload_content_with_mediation_updated | cat >"$environment-updated_data.json")
    api_update_endpoint_response=$(curl -X PUT -k -s -H "Authorization: Bearer $3" -H "Content-Type: application/json" -d @"$environment-updated_data.json" $api_update_mediation_endpoint)
    log_error $? "updating the API : \"$api_name\" with mediation policies"
    rm "$environment-updated_data.json"

    echo "Successfully updated API : \"$api_name\" with mediation policies"
}

deploy_api_definition() {
    api_base_path=$(echo $1 | cut -d'/' -f 1)
    api_creation_payload_template_file=$BASEDIR"/"$api_base_path"/$environment.api_template.json"

    #extracting the API Name from swagger definition
    api_context_value=$(grep "context" $api_creation_payload_template_file | cut -d':' -f 2 | tr -d '[:space:]' | awk -F'"' '{print $2}')

    #constructing the API search parameter
    search_parameter="context:"$api_context_value

    echo "Searching API with \"$search_parameter\""

    #searching the API
    search_endpoint="https://"$internal_gateway_hostname":"$api_gateway_rest_endpoint_port$base_api_context"?query="$search_parameter
    api_search_api_response=$(curl -s -k -H "Authorization: Bearer $api_view_access_token" $search_endpoint)
    log_error $? "searching api with $search_parameter"

    #Filter the API response to see whether there are APIs with the given context.
    api_search_api_count=$(echo $api_search_api_response | awk -F'"count":' '{print $2}' | cut -d',' -f 1 | tr -d '[:space:]')

    if [ -n "$api_search_api_count" ] && [ $api_search_api_count -gt 0 ]; then
        api_id=$(echo $api_search_api_response | awk -F'"id":' '{print $2}' | cut -d',' -f 1 | tr -d '[:space:]' | awk -F'"' '{print $2}')
        api_name=$(echo $api_search_api_response | awk -F'"name":' '{print $2}' | cut -d',' -f 1 | tr -d '[:space:]' | awk -F'"' '{print $2}')

        echo "API \"$api_name\" ($api_id) found for API context : \"$api_context_value\""

        #Get Mediation policies of the API.
        api_mediation_sequences_get_endpoint="https://$internal_gateway_hostname":"$api_gateway_rest_endpoint_port$base_api_context"/"$api_id/policies/mediation"
        api_mediation_sequences_get_response=$(curl -k -s -H "Authorization: Bearer $api_view_access_token" $api_mediation_sequences_get_endpoint)

        log_error $? "getting the mediation sequences list for API : $api_name"

        api_mediation_sequence_count=$(echo $api_mediation_sequences_get_response | awk -F'"count":' '{print $2}' | cut -d',' -f 1)

        api_update_endpoint="https://"$internal_gateway_hostname":"$api_gateway_rest_endpoint_port$base_api_context"/"$api_id
        api_creation_payload_content=$(cat $api_creation_payload_template_file)

        #setting the new swagger definition
        api_specification_swagger_updated=$(cat $BASEDIR"/"$1 | sed -e 's/\\/\\\\/g' | sed -e 's/\"/\\"/g')

        #Update both the API definition and the API ID.
        api_creation_payload_content_updated=$(echo $api_creation_payload_content | awk -F'"apiDefinition":' '{print $1}')"\"id\": \""$api_id"\",\"apiDefinition\":\""$api_specification_swagger_updated$(echo $api_creation_payload_content | awk -F'"apiDefinition":' '{print $2}' | sed -e "s/\"{{SWAGGER_PAYLOAD}}//g")

        #Create a temp file with the payload.
        $(echo $api_creation_payload_content_updated | cat >"$environment-data.json")
        api_update_endpoint_response=$(curl -X PUT -k -s -H "Authorization: Bearer $api_create_access_token" -H "Content-Type: application/json" -d @"$environment-data.json" $api_update_endpoint)
        log_error $? "updating the API : $api_name with the latest swagger definition"
        rm "$environment-data.json"

        #Deleting all the existing API specific mediation policies
        if [ -n "$api_mediation_sequence_count" ] && [ $api_mediation_sequence_count -gt 0 ]; then
            echo "Mediation policies found for API : $api_name"
            api_mediation_sequence_elements_list=$(echo $api_mediation_sequences_get_response | awk -F'"list"' '{print $2}' | sed -r 's/(.*)}/\1/' | sed "s/[][]//g")
            api_mediation_sequence_elements=$(echo $api_mediation_sequence_elements_list | tr "}" "\n")

            echo "Removing the existing mediation policies for API : $api_name"
            for mediation_sequence_element in $api_mediation_sequence_elements; do
                mediation_sequence_id=$(echo $mediation_sequence_element | awk -F'"id":' '{print $2}' | cut -d',' -f 1 | tr -d '[:space:]' | awk -F'"' '{print $2}')
                api_mediation_delete_endpoint="https://"$internal_gateway_hostname":"$api_gateway_rest_endpoint_port$base_api_context"/"$api_id"/policies/mediation/"$mediation_sequence_id
                api_mediation_delete_response=$(curl -s -k -H "Authorization: Bearer $api_create_access_token" -X DELETE $api_mediation_delete_endpoint)

                log_error $? "removing mediation policies for API : $api_name"

                echo "Mediation policy id : $mediation_sequence_id for API : $api_name removed"
            done
        else
            echo "Mediation policies not found for API : $api_name"
        fi

        add_sequences "$api_id" "$api_creation_payload_content_updated" "$api_create_access_token" "$BASEDIR/$api_base_path"
        echo "Successfully updated the API definition for API : $api_name"

    else
        echo "API Not Found for search parameter \"$search_parameter\""
        api_name=$(grep "name" $api_creation_payload_template_file | cut -d':' -f 2 | tr -d '[:space:]' | awk -F'"' '{print $2}')

        api_creation_endpoint="https://"$internal_gateway_hostname":"$api_gateway_rest_endpoint_port$base_api_context
        api_creation_payload_content=$(cat $api_creation_payload_template_file)

        #setting the new swagger definition
        api_specification_swagger_updated=$(cat $BASEDIR"/"$1 | sed -e 's/\\/\\\\/g' | sed -e 's/\"/\\"/g')
        api_creation_payload_content_updated=$(echo $api_creation_payload_content | awk -F'"apiDefinition":' '{print $1}')"\"apiDefinition\":\""$api_specification_swagger_updated$(echo $api_creation_payload_content | awk -F'"apiDefinition":' '{print $2}' | sed -e "s/\"{{SWAGGER_PAYLOAD}}//g")

        #Create a temp file with the payload.
        $(echo $api_creation_payload_content_updated | cat >"$environment-data.json")
        api_creation_endpoint_response=$(curl -X POST -k -s -H "Authorization: Bearer $api_create_access_token" -H "Content-Type: application/json" -d @"$environment-data.json" $api_creation_endpoint)
        log_error $? "creating the API"
        rm "$environment-data.json"

        api_id=$(echo $api_creation_endpoint_response | awk -F'"id":' '{print $2}' | cut -d',' -f 1 | tr -d '[:space:]' | awk -F'"' '{print $2}')
        add_sequences "$api_id" "$api_creation_payload_content_updated" "$api_create_access_token" "$BASEDIR/$api_base_path"

        echo "Successfully added the API definition for API : $api_name"
    fi

    #Publishing the API
    api_publish_request="https://"$internal_gateway_hostname":"$api_gateway_rest_endpoint_port$base_api_context"/change-lifecycle?apiId="$api_id"&action=Publish"
    #api_publish_request="https://"$internal_gateway_hostname":"$api_gateway_rest_endpoint_port$base_api_context"/change-lifecycle?apiId="$api_id"&action=Deploy%20as%20a%20Prototype"
    api_publish_response=$(curl -X POST -k -s -H "Authorization: Bearer $api_publish_access_token" $api_publish_request)
    log_error $? "publishing the API : $api_name"

    #echo
    #echo "api_publish_request: $api_publish_request"
    #echo

    echo "Successfully published the API definition for API : $api_name"
    echo

    # echo "Configuring registry entries for 2-legged authentication:"
    # echo "- setting _system/governance/api-backend-credentials/$api_name/access_Token"
    # #curl -k -X PUT -H "Authorization: Basic $dcr_authorization_header" -H "Content-Type: **application/atomcoll+xml**" -d '' https://$internal_gateway_hostname:$api_gateway_rest_endpoint_port/resource/1.0.0/artifact/_system/governance/api-backend-credentials/$api_name/access_Token
    # #echo "curl -k -X PUT -H \"Authorization: Basic $dcr_authorization_header\" -H \"Content-Type: **application/atomcoll+xml**\" -d '' https://$internal_gateway_hostname:$api_gateway_rest_endpoint_port/resource/1.0.0/artifact/_system/governance/api-backend-credentials/$api_name/access_Token"
    # curl -k -X PUT -H "Authorization: Basic $dcr_authorization_header" -H "Content-Type: text/plain" -H 'Media-type: text/plain' -d '' https://$internal_gateway_hostname:$api_gateway_rest_endpoint_port/resource/1.0.0/artifact/_system/governance/api-backend-credentials/$api_name/access_Token
    # #echo "curl -k -X PUT -H \"Authorization: Basic $dcr_authorization_header\" -H \"Content-Type: text/plain\" -H 'Media-type: text/plain' -d '' https://$internal_gateway_hostname:$api_gateway_rest_endpoint_port/resource/1.0.0/artifact/_system/governance/api-backend-credentials/$api_name/access_Token"
    # echo ""
    # echo "- setting _system/governance/api-backend-credentials/$api_name/generated_Time"
    # curl -k -X PUT -H "Authorization: Basic $dcr_authorization_header" -H 'Content-Type: text/plain' -H 'Media-type: text/plain' -d '0' https://$internal_gateway_hostname:$api_gateway_rest_endpoint_port/resource/1.0.0/artifact/_system/governance/api-backend-credentials/$api_name/generated_Time

    echo
    echo
}

#Invoking DCR
dcr_endpoint="https://${internal_gateway_hostname}:${api_gateway_rest_endpoint_port}${dcr_api_context}"
dcr_authorization_header=$(echo -n "${username}:${password}" | base64)

dcr_response=$(curl -s -k -X POST -H "Authorization: Basic $dcr_authorization_header" -H "Content-Type: application/json" -d "$dcr_request_payload" $dcr_endpoint)

log_error $? "invoking DCR endpoint"

client_id=$(echo $dcr_response | awk -F'"clientId":' '{print $2}' | cut -d',' -f 1 | tr -d '[:space:]' | awk -F'"' '{print $2}')
client_secret=$(echo $dcr_response | awk -F'"clientSecret":' '{print $2}' | cut -d',' -f 1 | tr -d '[:space:]' | awk -F'"' '{print $2}')

#invoking the token endpoint
token_endpoint="https://"$int_token_gateway_hostname":"$api_gateway_token_endpoint_port$token_api_context
token_request_authorization_header=$(echo -n "$client_id":"$client_secret" | base64)

api_view_token_response=$(curl -s -k -d "grant_type=password&username=$username&password=$password&scope=apim:api_view" -H "Authorization: Basic $token_request_authorization_header" $token_endpoint)
log_error $? "getting API view access token"

api_create_token_response=$(curl -s -k -d "grant_type=password&username=$username&password=$password&scope=apim:api_create" -H "Authorization: Basic $token_request_authorization_header" $token_endpoint)
log_error $? "getting API create access token"

api_publish_token_response=$(curl -s -k -d "grant_type=password&username=$username&password=$password&scope=apim:api_publish" -H "Authorization: Basic $token_request_authorization_header" $token_endpoint)
log_error $? "getting API publish access token"

api_view_access_token=$(echo $api_view_token_response | awk -F'"access_token":' '{print $2}' | cut -d',' -f 1 | tr -d '[:space:]' | awk -F'"' '{print $2}')
api_create_access_token=$(echo $api_create_token_response | awk -F'"access_token":' '{print $2}' | cut -d',' -f 1 | tr -d '[:space:]' | awk -F'"' '{print $2}')
api_publish_access_token=$(echo $api_publish_token_response | awk -F'"access_token":' '{print $2}' | cut -d',' -f 1 | tr -d '[:space:]' | awk -F'"' '{print $2}')

#api_view_access_token=$(. getoauth.sh -e $environment -g $internal_gateway_hostname -u $username -p $password -s apim:api_view)
#api_create_access_token=$(. getoauth.sh -e $environment -g $internal_gateway_hostname -u $username -p $password -s apim:api_create)
#api_publish_access_token=$(. getoauth.sh -e $environment -g $internal_gateway_hostname -u $username -p $password -s apim:api_publish)

# echo " api_view_access_token: $api_view_access_token"
# echo " api_create_access_token: $api_create_access_token"
# echo " api_publish_access_token: $api_publish_access_token"

#echo $api_specification_swagger_files_list

api_definition_files=$(echo $api_specification_swagger_files_list | tr "," "\n")
for api_specification_swagger_file in $api_definition_files; do
    echo
    echo "deploying API definition : \"$api_specification_swagger_file\""
    deploy_api_definition "$api_specification_swagger_file"
    echo
done

#deploy_api_definition "$api_specification_swagger_file"
