# Docker Repo
https://hub.docker.com/r/pacificengine/satisfactory

# Usage
# Configuration Parameters
```shell
serverport=7777
reliableport=8888
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
touch "${directory}/GUID.ini"
chown $(id -u ${username}):$(id -g ${username}) -R "${directory}"
chmod 755 -R "${directory}"
```

# Docker Run Command
```shell
docker run -d --name ${service} \
  --publish ${serverport}:${serverport}/udp \
  --publish ${serverport}:${serverport}/tcp \
  --publish ${reliableport}:${reliableport}/tcp \
  --env PORT_SERVER=${serverport} \
  --env PORT_RELIABLE=${reliableport} \
  --env AUTO_UPDATE=true \
  --env PUID=$(id -u ${username}) \
  --env PGID=$(id -g ${username}) \
  --mount type=bind,source=${directory}/logs,target=/home/satisfactory/FactoryGame/Saved/Logs \
  --mount type=bind,source=${directory}/config,target=/home/satisfactory/FactoryGame/Saved/Config/LinuxServer \
  --mount type=bind,source=${directory}/saves,target=/home/satisfactory/.config/Epic/FactoryGame/Saved/SaveGames \
  --mount type=bind,source=${directory}/GUID.ini,target=/home/satisfactory/.config/Epic/FactoryGame/GUID.ini \
  --restart unless-stopped pacificengine/satisfactory:${version}
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
VERSION=0.6.1
docker build --file "build.Dockerfile" --tag "palworld:latest" --build-arg DISTRIBUTION=${DISTRIBUTION} .
docker image tag palworld:latest pacificengine/palworld:${DISTRIBUTION}-stable
docker image tag palworld:latest pacificengine/palworld:stable
docker image tag palworld:latest pacificengine/palworld:${DISTRIBUTION}-latest
docker image tag palworld:latest pacificengine/palworld:latest
docker image tag palworld:latest pacificengine/palworld:$(git rev-parse --short HEAD)-stable
docker image tag palworld:latest pacificengine/palworld:$(git rev-parse --short HEAD)
docker image tag palworld:latest pacificengine/palworld:${VERSION}-stable
docker image tag palworld:latest pacificengine/palworld:${VERSION}
docker push pacificengine/palworld:${DISTRIBUTION}-stable
docker push pacificengine/palworld:stable
docker push pacificengine/palworld:${DISTRIBUTION}-latest
docker push pacificengine/palworld:latest
docker push pacificengine/palworld:$(git rev-parse --short HEAD)-stable
docker push pacificengine/palworld:$(git rev-parse --short HEAD)
docker push pacificengine/palworld:${VERSION}-stable
docker push pacificengine/palworld:${VERSION}
```
