#!/bin/bash
source /server/variables.sh

runCommandAsLocalUser() {
  su --login "${USERNAME}" --shell /bin/bash --command "${@}"
}

log() {
  runCommandAsLocalUser "echo '[$(date "${LOG_DATE_FORMAT}")] ${1}' >> '${SIMPLE_LOG_FILE}'"
}

saveLogFiles() {
  if [[ -f "${INPUT_FILE}" ]]; then
    runCommandAsLocalUser "mv '${INPUT_FILE}' '${LOG_DIRECTORY}/$(head --lines=1 "${INPUT_FILE}")'"
  fi
  if [[ -f "${UPDATE_LOG_FILE}" ]]; then
    runCommandAsLocalUser "mv '${UPDATE_LOG_FILE}' '${LOG_DIRECTORY}/$(head --lines=1 "${UPDATE_LOG_FILE}")'"
  fi
  if [[ -f "${SIMPLE_LOG_FILE}" ]]; then
    runCommandAsLocalUser "mv '${SIMPLE_LOG_FILE}' '${LOG_DIRECTORY}/$(head --lines=1 "${SIMPLE_LOG_FILE}")'"
  fi
  runCommandAsLocalUser "rm ${CURRENT_USERS_FILE}"
}

createLogFiles() {
  saveLogFiles
  runCommandAsLocalUser "echo 'input.${DATE}.log' > '${INPUT_FILE}'"
  runCommandAsLocalUser "echo 'update.${DATE}.log' > '${UPDATE_LOG_FILE}'"
  runCommandAsLocalUser "echo 'simple.${DATE}.log' > '${SIMPLE_LOG_FILE}'"
  runCommandAsLocalUser "touch '${CURRENT_USERS_FILE}'"
}