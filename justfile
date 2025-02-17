set dotenv-load

default:
    @just --list

tag:= "$(git rev-parse --short HEAD)"
imageRepo:= "ghcr.io/cubit-inc/k8s-backup"

build-push-mysql:
    docker build -t {{imageRepo}}/mysql:latest -t {{imageRepo}}/mysql:{{tag}} -f mysql/Dockerfile mysql
    docker image push --all-tags {{imageRepo}}/mysql