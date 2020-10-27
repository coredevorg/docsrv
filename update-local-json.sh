#!/bin/bash
# enable secret token
SECRET="${1:-onlyoffice}"
FILE=/etc/onlyoffice/documentserver/local.json
ENABLE=true

JSON=$(cat $FILE)

JSON=$(echo $JSON | jq ".services.CoAuthoring.token.enable.request.inbox = $ENABLE") 
JSON=$(echo $JSON | jq ".services.CoAuthoring.token.enable.request.outbox = $ENABLE") 
JSON=$(echo $JSON | jq ".services.CoAuthoring.token.enable.browser = $ENABLE") 

JSON=$(echo $JSON | jq ".services.CoAuthoring.secret.inbox.string = \"$SECRET\"") 
JSON=$(echo $JSON | jq ".services.CoAuthoring.secret.outbox.string = \"$SECRET\"") 
JSON=$(echo $JSON | jq ".services.CoAuthoring.secret.session.string = \"$SECRET\"") 

echo $JSON | jq . > /etc/onlyoffice/documentserver/local.json