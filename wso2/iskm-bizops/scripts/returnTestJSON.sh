#!/bin/bash

# Exit if any of the intermediate steps fail

oauthConsumerSecret=test
consumerKey=test

# Safely produce a JSON object containing the result value.
# jq will ensure that the value is properly quoted
# and escaped to produce a valid JSON string.

# echo ""
# echo "Configuration complete"

jq -n --arg oauthConsumerSecret $oauthConsumerSecret --arg consumerKey $consumerKey '{"oauthConsumerSecret":$oauthConsumerSecret,"consumerKey":$consumerKey}'
