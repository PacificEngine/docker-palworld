# Docker Repo
https://hub.docker.com/r/pacificengine/palworld

# Usage
# Configuration Parameters
```shell
serverport=8211
apiport=8212
queryport=27015
directory=/home/palworld
username=palworld
service=palworld
version=release
```

# Setup Commands
```shell
mkdir -p "${directory}/logs"
mkdir -p "${directory}/config"
mkdir -p "${directory}/saves"
chown $(id -u ${username}):$(id -g ${username}) -R "${directory}"
chmod 755 -R "${directory}"
```

# Docker Run Command
```shell
docker run -d --name ${service} \
  --publish ${serverport}:${serverport}/udp \
  --publish ${apiport}:${apiport}/tcp \
  --publish ${queryport}:${queryport}/udp \
  --env PORT_SERVER=${serverport} \
  --env PORT_API=${apiport} \
  --env PORT_QUERY=${queryport} \
  --env AUTO_UPDATE=true \
  --env PUID=$(id -u ${username}) \
  --env PGID=$(id -g ${username}) \
  --mount type=bind,source=${directory}/logs,target=/home/palworld/Pal/Saved/Logs \
  --mount type=bind,source=${directory}/config,target=/home/palworld/Pal/Saved/Config/LinuxServer \
  --mount type=bind,source=${directory}/saves,target=/home/palworld/Pal/Saved/SaveGames \
  --restart unless-stopped pacificengine/palworld:${version}
```

# Build

## Clean Environment
```shell
docker rm $(docker ps -a -q)
docker rmi $(docker images -a -q)
docker volume prune
docker system prune -a
```

## Stable
```shell
DISTRIBUTION=ubuntu-20
GAME_VERSION=0.6.1
GIT_VERSION="$(git rev-parse --short HEAD)"
docker build --file "build.Dockerfile" --tag "palworld:latest" --build-arg DISTRIBUTION=${DISTRIBUTION} .
docker image tag palworld:latest pacificengine/palworld:${DISTRIBUTION}-stable
docker image tag palworld:latest pacificengine/palworld:stable
docker image tag palworld:latest pacificengine/palworld:${DISTRIBUTION}-latest
docker image tag palworld:latest pacificengine/palworld:latest
docker image tag palworld:latest pacificengine/palworld:${GIT_VERSION}-stable
docker image tag palworld:latest pacificengine/palworld:${GIT_VERSION}
docker image tag palworld:latest pacificengine/palworld:${GAME_VERSION}-stable
docker image tag palworld:latest pacificengine/palworld:${GAME_VERSION}
docker push pacificengine/palworld:${DISTRIBUTION}-stable
docker push pacificengine/palworld:stable
docker push pacificengine/palworld:${DISTRIBUTION}-latest
docker push pacificengine/palworld:latest
docker push pacificengine/palworld:${GIT_VERSION}-stable
docker push pacificengine/palworld:${GIT_VERSION}
docker push pacificengine/palworld:${GAME_VERSION}-stable
docker push pacificengine/palworld:${GAME_VERSION}
```
