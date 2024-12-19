#!/bin/bash

TOKEN=kong-admin-token:handyshake
PLUGIN=$1
# checl if plugin argument is null
if [[ -z $PLUGIN ]]; then
    echo "Please provide plugin name as argument"
    exit 1
fi

# create services and routes
http :8001/services name=test-service url="http://httpbin/anything" $TOKEN
http :8001/services/test-service/routes name=test-route paths:='["/test"]' $TOKEN

# create auth plugin
http :8001/plugins/ name=key-auth $TOKEN

# create consumers 
http :8001/consumers username=in_consumer $TOKEN
http :8001/consumers username=out_consumer $TOKEN

# create consumer authentication
http :8001/consumers/in_consumer/key-auth key=in_key $TOKEN
http :8001/consumers/out_consumer/key-auth key=out_key $TOKEN

# create consumer group
http :8001/consumer_groups name=test $TOKEN


# create plugin for group
if [[ $PLUGIN == "ip-restriction" ]]; then
    IP=$2
    if [[ -z $IP ]]; then
        echo "Please provide IP address as second argument"
        exit 1
    fi
    http :8001/consumer_groups/test/plugins name=ip-restriction config\[deny\]:=\'["$IP"]\' $TOKEN
    #http :8001/consumer_groups/test/plugins name=ip-restriction config\[allow\]:=\'["$IP"]\' $TOKEN
elif [[ $PLUGIN == "rate-limiting" ]]; then
    http :8001/consumer_groups/test/plugins name=rate-limiting config\[hour\]:=10 $TOKEN
elif [[ $PLUGIN == "request-termination" ]]; then
    http :8001/consumer_groups/test/plugins name=request-termination config\[status_code\]:=503 config\[message\]="Whoopsieeeeee" $TOKEN
elif [[ $PLUGIN == "proxy-cache" ]]; then
    http :8001/consumer_groups/test/plugins name=proxy-cache config\[cache_ttl\]:=10 config\[strategy\]="memory" $TOKEN
elif [[ $PLUGIN == "proxy-cache-advanced" ]]; then
    http :8001/consumer_groups/test/plugins name=proxy-cache-advanced config\[cache_ttl\]:=10 config\[strategy\]="memory" $TOKEN
else 
    echo "Unknown plugin: $1"
fi

# add consumer to group
http :8001/consumers/in_consumer/consumer_groups group=test $TOKEN

echo "Ready to send request as consumer in_consumer or out_consumer"