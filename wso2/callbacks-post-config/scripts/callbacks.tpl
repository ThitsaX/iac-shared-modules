{
    "name": "${sim_name}",
    "description": "Mojaloop back-end for ${host} API",
    "context": "/${host}",
    "version": "1.0",
    "provider": "admin",
    "status": "CREATED",
    "thumbnailUri": null,
    "apiDefinition": "{{SWAGGER_PAYLOAD}}",
    "wsdlUri": null,
    "responseCaching": null,
    "cacheTimeout": 0,
    "destinationStatsEnabled": null,
    "isDefaultVersion": false,
    "type": "HTTP",
    "transport": [
        "http",
        "https"
    ],
    "tags": [],
    "tiers": ["Unlimited"],
    "apiLevelPolicy": null,
    "authorizationHeader": null,
    "maxTps": null,
    "visibility": "PUBLIC",
    "visibleRoles": [],
    "visibleTenants": [],
    "endpointConfig": "{\"production_endpoints\":{\"url\":\"${sim_url}\",\"config\":null,\"template_not_supported\":false},\"endpoint_type\":\"http\"}",
    "endpointSecurity": null,
    "gatewayEnvironments": "Production and Sandbox",
    "labels": [],
    "sequences": [],
    "subscriptionAvailability": null,
    "subscriptionAvailableTenants": [],
    "additionalProperties": {},
    "accessControl": "NONE",
    "accessControlRoles": [],
    "businessInformation": {
        "businessOwner": null,
        "businessOwnerEmail": null,
        "technicalOwner": null,
        "technicalOwnerEmail": null
    },
    "corsConfiguration": {
        "corsConfigurationEnabled": false,
        "accessControlAllowOrigins": [
            "*"
        ],
        "accessControlAllowCredentials": false,
        "accessControlAllowHeaders": [
            "authorization",
            "Access-Control-Allow-Origin",
            "Content-Type",
            "SOAPAction"
        ],
        "accessControlAllowMethods": [
            "GET",
            "PUT",
            "POST",
            "DELETE",
            "PATCH",
            "OPTIONS"
        ]
    }
}