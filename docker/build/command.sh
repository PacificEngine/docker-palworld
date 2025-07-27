#!/bin/bash
source /build/server.sh

if [[ "${1}" == 'getServerInfo' ]]; then
  getServerInfo
elif [[ "${1}" == 'getServerStatus' ]]; then
  getServerStatus
elif [[ "${1}" == 'getServerPlayerList' ]]; then
  getServerStatus
elif [[ "${1}" == 'saveGame' ]]; then
  saveGame
elif [[ "${1}" == 'getConfig' ]]; then
  getConfig "${2}"
fi