# wso2-automation-iskm-mcm 
Configuration management repo to configure WSO2 Identity Server (with Key Management) to support OAuth2 integration for MCM

usage: ./configureMCM.sh -h host -r port -u username -p password -c createServiceProvider (y/n)"

*host* - WSO2-ISKM server url

*port* - TCP port exposed for admininstration access to the REST/SOAP apis (standard = 9443)

*username* - WSO2 administrator username

*password* - WSO2 administrator password

*createServiceProvider* - y/n switch to indicate whether a service provider should be created.  By default the service provider will be created without specifying a value.  [n] should only be specified if a service provider already exists and should not be recreated.
