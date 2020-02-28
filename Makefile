export DOCKER_MONGO_TAG=4.2.3-bionic
export DOCKER_ROCKET_CHAT_TAG=3.0.2
export DOCKER_NETWORK=my-rocketchat-network

.PHONY: network
network:
	docker network ls | grep ${DOCKER_NETWORK} || docker network create ${DOCKER_NETWORK}

.PHONY: mongo
mongo: network
	docker run \
    --detach \
    --rm \
    --tty \
    --publish 27017:27017 \
    --name mongo \
    --net ${DOCKER_NETWORK} \
    mongo:${DOCKER_MONGO_TAG} \
    mongod \
      --storageEngine wiredTiger \
      --oplogSize 128 \
      --replSet rs0 \
      --bind_ip 0.0.0.0

.PHONY: init-mongo
init-mongo: network
	docker run \
    --rm \
    --tty \
    --mount type=bind,source=${PWD}/mongodb/,target=/mongodb/ \
    --workdir /mongodb \
    --entrypoint "/mongodb/init-mongo.sh" \
    --name mongo-initializer \
    --net ${DOCKER_NETWORK} \
    mongo:${DOCKER_MONGO_TAG}

.PHONY: rocketchat
rocketchat: network
	docker run \
    --rm \
    --tty \
    --publish 3000:3000 \
    --mount type=bind,source=${PWD}/rocketchat/,target=/rocketchat/ \
    --name rocketchat \
    --env PORT=3000 \
    --env ROOT_URL=http://localhost:3000 \
    --env MONGO_URL=mongodb://mongo:27017/rocketchat \
    --env MONGO_OPLOG_URL=mongodb://mongo:27017/local \
    --env MAIL_URL=smtp://smtp.email \
    --net ${DOCKER_NETWORK} \
    --entrypoint "/rocketchat/start.sh" \
    rocketchat/rocket.chat:${DOCKER_ROCKET_CHAT_TAG}

.PHONY: down
down:
	docker container ps --quiet --filter "name=mongo"             | xargs docker stop
	docker container ps --quiet --filter "name=mongo-initializer" | xargs docker stop
	docker container ps --quiet --filter "name=rocketchat"        | xargs docker stop
	docker network ls --quiet --filter "name=${DOCKER_NETWORK}"   | xargs docker network rm
