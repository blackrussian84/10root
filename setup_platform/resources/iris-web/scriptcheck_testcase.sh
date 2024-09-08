#!/bin/bash

URL='https://127.0.0.1:8443/'
echo -n "HTTP request for IRIS at ${URL}..."

CODE=$(curl -ks -w '%{http_code}' -o /dev/null --url "${URL}")
_ERR_=${?}
IS_OK=$(echo "${CODE}>=200 && ${CODE}<=399 && ${_ERR_}==0" | bc)

if [[ "123${IS_OK}" = "1231" ]]
then
  exit 0
else
  echo "HTTP request failed! Error: ${_ERR_}; HTTP code: ${CODE}" > /dev/stderr
  exit 128
fi

