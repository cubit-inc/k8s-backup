set dotenv-load

default:
    @just --list

tag:= "$(git rev-parse --short HEAD)"
imageRepo:= "ghcr.io/cubit-inc/k8s-backup"

build-push-mysql:
    docker build -t {{imageRepo}}/k8s-backup-mysql:latest -t {{imageRepo}}/k8s-backup-mysql:{{tag}} -f mysql/Dockerfile mysql
    docker image push --all-tags {{imageRepo}}/k8s-backup-mysql

build-push-images: build-push-mysql