SHELL := /bin/bash

.DEFAULT_GOAL := build
fmt :
		go fmt ./...
.PHONY:fmt

lint : fmt
		golint ./...
.PHONY : lint

vet : fmt
		go vet ./...
.PHONY :vet

build : vet
		go build -ldflags "-X main.build=local" ./...
.PHONY:build
	go build -ldflags "-X main.build=local" ./...
run :
	go run main.go

VERSION := 1.0

all: service

service:
	docker build \
		-f zarf/docker/Dockerfile \
		-t service-amd64:$(VERSION) \
		--build-arg BUILD_REF=$(VERSION) \
		--build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
		.

# Running from within k8s/kind

KIND_CLUSTER := ardan-starter-cluster

kind-up:
	kind create cluster \
		--image kindest/node:v1.24.1 \
		--name $(KIND_CLUSTER) \
		--config zarf/k8s/kind/kind-config.yaml 

kind-down:
	kind delete cluster --name $(KIND_CLUSTER)


kind-status:
	kubectl get nodes -o wide
	kubectl get svc -o wide
	kubectl get pods -o wide --watch --all-namespaces

kind-load:
	kind load docker-image service-api-amd64:$(VERSION) --name $(KIND_CLUSTER)

kind-apply:
	kustomize build zarf/k8s/kind/service-pod | kubectl apply -f -

kind-logs:
	kubectl logs -l app=service --all-containers=true -f --tail=100 | go run app/tooling/logfmt/main.go


test:
	go test ./... -count=1
	staticcheck -checks=all ./...
