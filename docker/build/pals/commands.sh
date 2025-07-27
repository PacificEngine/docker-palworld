#!/bin/bash
source /build/pals/config.sh

getApiHost() {
  echo '127.0.0.1'
}

getApiPort() {
  getConfig 'RESTAPIPort'
}

getApiUser() {
  echo 'admin'
}

getApiPassword() {
  getConfig 'AdminPassword'
}

# https://docs.palworldgame.com/api/rest-api/info
getServerInfo() {
  curl --insecure --fail --request GET "http://$(getApiHost):$(getApiPort)/v1/api/info" \
    --user "$(getApiUser):$(getApiPassword)" \
    --header 'Accept: application/json'
}

# https://docs.palworldgame.com/api/rest-api/metrics
getServerStatus() {
  curl --insecure --fail --request GET "http://$(getApiHost):$(getApiPort)/v1/api/metrics" \
    --user "$(getApiUser):$(getApiPassword)" \
    --header 'Accept: application/json'
}

# https://docs.palworldgame.com/api/rest-api/players
getServerPlayerList() {
  curl --insecure --fail --request GET "http://$(getApiHost):$(getApiPort)/v1/api/players" \
    --user "$(getApiUser):$(getApiPassword)" \
    --header 'Accept: application/json'
}

# https://docs.palworldgame.com/api/rest-api/save
saveGame() {
  curl --insecure --fail --request POST "http://$(getApiHost):$(getApiPort)/v1/api/save" \
    --user "$(getApiUser):$(getApiPassword)" \
    --header 'Accept: application/json'
}

# https://docs.palworldgame.com/api/rest-api/shutdown
shutdownGracefully() {
  local time="${1:-1}"
  local message="${2:-"Server is shutting down in ${time} seconds."}"
  curl --insecure --fail --request POST "http://$(getApiHost):$(getApiPort)/v1/api/shutdown" \
    --user "$(getApiUser):$(getApiPassword)" \
    --header 'Accept: application/json' \
    --header 'Content-Type: application/json' \
    --data '{"waittime": '"${time}"', "message": "'"${message}"'"}'
}

# https://docs.palworldgame.com/api/rest-api/stop
shutdownForcefully() {
  curl --insecure --fail --request POST "http://$(getApiHost):$(getApiPort)/v1/api/stop" \
    --user "$(getApiUser):$(getApiPassword)" \
    --header 'Accept: application/json'
}