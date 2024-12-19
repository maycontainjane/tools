#!/bin/bash
set -x

export TOKEN='kong-admin-token:handyshake'


# take arg 1 or $INJECTION_TYPES as TYPES
TYPES=${1:-$INJECTION_TYPES}

# take arg 2 or $LOCATIONS as LOCS
LOCS=${2:-$LOCATIONS}

#take arg 3 as plugin id or default to 346e1b64-ae65-48ec-a87d-e39eafd9bb70
PLUGIN_ID=${3:-$PLUGIN_ID}

# http PATCH :8001/plugins/${PLUGIN_ID} config:="{\"injection_types\": ["$TYPES"], \"locations\": ["$LOCS"]}" $TOKEN
http PATCH :8001/plugins/${PLUGIN_ID} config:="{\"locations\": ["$LOCS"]}" $TOKEN
