#!/bin/bash

url="https://$1/status"

http_code=$(curl -s -k --connect-timeout 20 -o /dev/null --write-out '%{http_code}' $url)
if [[ $http_code != *"401"* ]]; then
  echo "CRITICAL: kibana [$url] not responding:  $http_code"
  exit 2
fi

echo "Kibana on $1 OK: $http_code"
exit 0
