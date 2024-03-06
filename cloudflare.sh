#!/bin/bash

# Load the environment variables
source /home/coworking/scripts/env.sh

# The URL pattern to purge (use "purge_everything": true to purge everything)
PURGE_DATA='{"purge_everything":true}'

echo "Purge cloudflare"

curl -s -S -X POST "https://api.cloudflare.com/client/v4/zones/$CF_ZONE_ID/purge_cache" \
     -H "Authorization: Bearer $CF_API_KEY" \
     -H "Content-Type: application/json" \
     --data "$PURGE_DATA"  > /dev/null 2>&1

