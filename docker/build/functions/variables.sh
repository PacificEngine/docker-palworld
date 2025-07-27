#!/bin/bash
source /server/properties.sh

INSTALL_DIRECTORY="$(getProperty "INSTALL_DIRECTORY")"
LOG_DIRECTORY="$(getProperty "LOG_DIRECTORY")"
CONFIG_DIRECTORY="$(getProperty "CONFIG_DIRECTORY")"
USERNAME="$(getProperty "USERNAME")"
USERGROUP="$(getProperty "USERGROUP")"
GAME_ID="$(getProperty "GAME_ID")"

IP_SERVER="${IP_SERVER:-$(getProperty "IP_SERVER")}"
PORT_SERVER="${PORT_SERVER:-$(getProperty "PORT_SERVER")}"
PORT_API="${PORT_API:-$(getProperty "PORT_API")}"
PORT_PUBLIC="${PORT_PUBLIC:-$(getProperty "PORT_PUBLIC")}"
PORT_QUERY="${PORT_QUERY:-$(getProperty "PORT_QUERY")}"
AUTO_UPDATE="${AUTO_UPDATE:-$(getProperty "AUTO_UPDATE")}"
THREAD_COUNT="${THREAD_COUNT:-$(getProperty "THREAD_COUNT")}"
PLAYER_COUNT="${PLAYER_COUNT:-$(getProperty "PLAYER_COUNT")}"
ADDITIONAL_COMMANDS=''
if [[ "${IS_PUBLIC:-$(getProperty "IS_PUBLIC")}" == 'true' ]]; then
  ADDITIONAL_COMMANDS="${ADDITIONAL_COMMANDS} -publiclobby -publicip=${IP_SERVER} -publicport=${PORT_PUBLIC}"
fi
if [[ "${THREAD_COUNT}" -gt '1' ]]; then
  ADDITIONAL_COMMANDS="${ADDITIONAL_COMMANDS} -useperfthreads -NoAsyncLoadingThread -UseMultithreadForDS"
fi

DATE="$(date "+%F-%H:%M:%S")"
LOG_DATE_FORMAT="+%FT%H:%M:%S"
INPUT_FILE="${LOG_DIRECTORY}/input.log"
UPDATE_LOG_FILE="${LOG_DIRECTORY}/update.log"
SIMPLE_LOG_FILE="${LOG_DIRECTORY}/simple.log"
CURRENT_USERS_FILE="${LOG_DIRECTORY}/user.csv"
MAIN_LOG_FILE="${LOG_DIRECTORY}/PalWorld.log"
PROCESS_ID_FILE="${INSTALL_DIRECTORY}/process.id"
PROCESS_STATUS_FILE="${INSTALL_DIRECTORY}/process.status"
UPDATE_SCRIPT="${INSTALL_DIRECTORY}/update.script"
START_SCRIPT="${INSTALL_DIRECTORY}/PalServer.sh"
START_ARGUMENTS="-port=${PORT_SERVER} -queryport=${PORT_QUERY} -players=${PLAYER_COUNT} ${ADDITIONAL_COMMANDS} -NumberOfWorkerThreadsServer=${THREAD_COUNT} -logformat=text"
