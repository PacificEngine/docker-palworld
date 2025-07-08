ARG DISTRIBUTION='ubuntu-20'
FROM steamcmd/steamcmd:${DISTRIBUTION}

RUN apt-get update && \
  apt-get upgrade -y && \
  apt-get install -y \
    coreutils \
    curl \
    jq

ARG INSTALL_DIRECTORY='/home/palworld'
ARG LOG_DIRECTORY="${INSTALL_DIRECTORY}/FactoryGame/Saved/Logs"
ARG USERNAME='palworld'
ARG USERGROUP='palworld'
RUN mkdir --parents ${LOG_DIRECTORY} && \
  mkdir --parents ${INSTALL_DIRECTORY} && \
  groupadd ${USERGROUP} && \
  useradd --system --gid ${USERGROUP} --shell /usr/sbin/nologin ${USERNAME} && \
  chown ${USERNAME}:${USERGROUP} -R ${LOG_DIRECTORY} && \
  chown ${USERNAME}:${USERGROUP} -R ${INSTALL_DIRECTORY} && \
  chmod 755 -R ${LOG_DIRECTORY} && \
  chmod 755 -R ${INSTALL_DIRECTORY}

ARG GAME_ID='2394010'
COPY install ${INSTALL_DIRECTORY}
RUN cat "${INSTALL_DIRECTORY}/update.script.template" \
    | sed --regexp-extended "s/<%INSTALL_DIRECTORY%>/${INSTALL_DIRECTORY//\//\\/}/g" \
    | sed --regexp-extended "s/<%LOG_DIRECTORY%>/${LOG_DIRECTORY//\//\\/}/g" \
    | sed --regexp-extended "s/<%USERNAME%>/${USERNAME//\//\\/}/g" \
    | sed --regexp-extended "s/<%USERGROUP%>/${USERGROUP//\//\\/}/g" \
    | sed --regexp-extended "s/<%GAME_ID%>/${GAME_ID//\//\\/}/g" \
    > "${INSTALL_DIRECTORY}/update.script" && \
  rm "${INSTALL_DIRECTORY}/update.script.template" && \
  chmod 555 "${INSTALL_DIRECTORY}/update.script"

RUN chmod 777 -R /tmp && \
  su --login ${USERNAME} --shell /bin/bash --command "steamcmd +runscript '${INSTALL_DIRECTORY}/update.script'"

ARG PORT_SERVER=''
ARG PORT_RELIABLE=''
ARG AUTO_UPDATE=''
COPY docker /
RUN cat '/server/properties.template' \
    | sed --regexp-extended "s/<%INSTALL_DIRECTORY%>/${INSTALL_DIRECTORY//\//\\/}/g" \
    | sed --regexp-extended "s/<%LOG_DIRECTORY%>/${LOG_DIRECTORY//\//\\/}/g" \
    | sed --regexp-extended "s/<%USERNAME%>/${USERNAME//\//\\/}/g" \
    | sed --regexp-extended "s/<%USERGROUP%>/${USERGROUP//\//\\/}/g" \
    | sed --regexp-extended "s/<%GAME_ID%>/${GAME_ID//\//\\/}/g" \
    | sed --regexp-extended "s/<%IP_SERVER%>/${IP_SERVER:-0.0.0.0}/g" \
    | sed --regexp-extended "s/<%THREAD_COUNT%>/${THREAD_COUNT:-0.0.0.0}/g" \
    | sed --regexp-extended "s/<%PLAYER_COUNT%>/${PLAYER_COUNT:-32}/g" \
    | sed --regexp-extended "s/<%PORT_SERVER%>/${PORT_SERVER:-8211}/g" \
    | sed --regexp-extended "s/<%PORT_PUBLIC%>/${PORT_PUBLIC:-8212}/g" \
    | sed --regexp-extended "s/<%IS_PUBLIC%>/${IS_PUBLIC:-8888}/g" \
    | sed --regexp-extended "s/<%AUTO_UPDATE%>/${AUTO_UPDATE:-true}/g" \
    > '/server/properties' && \
  rm '/server/properties.template' && \
  chmod 555 /server/*.sh && \
  chmod 555 /build/*.sh

ENTRYPOINT ["/bin/bash", "/build/start.sh"]