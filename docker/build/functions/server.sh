#!/bin/bash

source /build/functions/variables.sh
source /build/functions/log.sh
source /build/functions/commands.sh
source /build/functions/config.sh
source /server/regex.sh
source /server/process.sh

getServerProcessId() {
  local id="$(cat "${PROCESS_ID_FILE}")"
  if [[ -z "${id}" || -z "$(ps --pid ${id} --no-headers)" ]]; then
    id=$(getProcess '' '\sPal\s')
    runCommandAsLocalUser "echo '${id}' > '${PROCESS_ID_FILE}'"
  fi
  echo "${id}"
}

updateUser() {
  if [[ -n "${PUID}" ]]; then
    usermod --non-unique --uid "${PUID}" ${USERNAME}
  fi
  if [[ -n "${PGID}" ]]; then
    groupmod --non-unique --gid "${PGID}" ${USERGROUP}
  fi
  chown "${USERNAME}":"${USERGROUP}" -R "${INSTALL_DIRECTORY}"
  chown "${USERNAME}":"${USERGROUP}" -R "${CONFIG_DIRECTORY}"
  chown "${USERNAME}":"${USERGROUP}" "${LOG_DIRECTORY}"
}

updateServer() {
  cd "${INSTALL_DIRECTORY}"
  if [[ "${AUTO_UPDATE}" == "true" ]]; then
    chmod 777 -R /tmp
    log "Updating Server"
    runCommandAsLocalUser "steamcmd +runscript '${UPDATE_SCRIPT}' >> '${UPDATE_LOG_FILE}'"
  fi
}

shutdownServer() {
  saveGame
  shutdownGracefully 1
  sleep 10
}

stopServer() {
  local id=''
  local waitTime=0;
  local maximumWaitTime=30

  echo "STOPPING" > "${PROCESS_STATUS_FILE}"

  id="$(getServerProcessId)"
  if [[ -n "${id}" ]]; then
    log "Server Shutting Down"
    shutdownServer
    stopProcess "${id}"
    for (( waitTime=0; waitTime<=${maximumWaitTime}; waitTime++ )); do
      if [[ -z "$(ps --pid ${id} --no-headers)" ]]; then
        break
      fi
      sleep 1
    done

    if [[ -n "$(ps --pid ${id} --no-headers)" ]]; then
      killProcess "${id}"
      for (( waitTime=0; waitTime<=${maximumWaitTime}; waitTime++ )); do
        if [[ -z "$(ps --pid ${id} --no-headers)" ]]; then
          break
        fi
        sleep 1
      done
    fi

    killProcess "$(getProcess 'tail' "${INPUT_FILE}")"
    killProcess "$(getProcess 'tail' "${MAIN_LOG_FILE}")"
    killProcess "$(getProcess "${START_SCRIPT}")"

    tail --pid=${id} --follow=descriptor /dev/null
  else
    killProcess "$(getProcess 'steamcmd' "${UPDATE_SCRIPT}")"
  fi
}

startServer() {
  local id=''
  local line=''

  echo "STARTING" > "${PROCESS_STATUS_FILE}"

  trap "{ echo 'Quit Signal Received' ; /build/stop.sh ; }" SIGQUIT
  trap "{ echo 'Abort Signal Received' ; /build/stop.sh ; }" SIGABRT
  trap "{ echo 'Interrupt Signal Received' ; /build/stop.sh ; }" SIGINT
  trap "{ echo 'Terminate Signal Received' ; /build/stop.sh ; }" SIGTERM

  updateUser
  createLogFiles
  updateConfigSettings
  if [[ "$(cat "${PROCESS_STATUS_FILE}")" == "STARTING" ]]; then
    updateServer
  fi

  if [[ "$(cat "${PROCESS_STATUS_FILE}")" == "STARTING" ]]; then
    log "Booting Server"
    runCommandAsLocalUser "tail --follow=name --retry --lines=0 '${INPUT_FILE}' | '${START_SCRIPT}' ${START_ARGUMENTS} > '${MAIN_LOG_FILE}' 2>&1" &
    while [[ "$(cat "${PROCESS_STATUS_FILE}")" == "STARTING" ]]; do
      id="$(getServerProcessId)"
      if [[ -n "${id}" ]]; then
        break
      fi
      sleep 1
    done
    if [[ "$(cat "${PROCESS_STATUS_FILE}")" == "STARTING" && -n "${id}" ]]; then
      echo "STARTED" > "${PROCESS_STATUS_FILE}"
      sleep 10
      while [[ "$(cat "${PROCESS_STATUS_FILE}")" == "STARTED" ]]; do
        id="$(getServerProcessId)"
        if [[ -z "${id}" ]]; then
          break
        fi
        runCommandAsLocalUser "tail --pid=${id} --follow=name --lines +1 '${MAIN_LOG_FILE}' | perl /build/perl/logs.pl '${SIMPLE_LOG_FILE}' '${CURRENT_USERS_FILE}'"
        sleep 1
      done
    else
      stopServer
    fi
  fi
  log "Server Shutdown"
  echo "STOPPED" > "${PROCESS_STATUS_FILE}"

  saveLogFiles

  trap - SIGQUIT SIGABRT SIGINT SIGTERM
}