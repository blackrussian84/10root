#!/bin/bash
# TODO:Do we really need this?

# TODO: {"statusCode":409,"error":"Conflict","message":"Saved object [index-pattern/artifact] conflict"}Done!
while [[ "$(curl -s -o /dev/null -w '%{http_code}' localhost:5601)" != "302" ]]; do 
  echo "Waiting on Kibana to be ready..."
  sleep 1
done
echo "Applying default config..."
response=$(curl -s -o /dev/null -w "%{http_code}" -XPOST localhost:5601/api/saved_objects/index-pattern/artifact -H 'kbn-xsrf: true' -H 'Content-Type: application/json' -d '{"attributes":{"timeFieldName":"@timestamp","title":"artifact*"}}')
if [[ "$response" -ne 200 ]]; then
  echo "Failed to apply default config. HTTP status code: $response"
  exit 1
fi
echo "Done!"
