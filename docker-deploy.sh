#!/bin/bash

function start() {
  MIX_ENV=prod mix do deps.get, compile, release
  docker build --rm -t thumbifier_docker_image .
  docker run -d -p 80:80 --name thumbifier_docker thumbifier_docker_image
}

function kill() {
  docker stop thumbifier_docker && docker rm thumbifier_docker
}

function_exists() {
  declare -f -F $1 > /dev/null
  return $?
}

if [ $# -lt 1 ]
then
  echo "Usage : $0 start|kill"
  exit
fi

case "$1" in
  start) function_exists start && start
         ;;
  kill)  function_exists kill && kill
         ;;
  *)     echo "Invalid command"
         ;;
esac
