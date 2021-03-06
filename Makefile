# Makefile for Golang Network Stack

SHELL = /bin/bash

# Variables
NAME := network
PKGS := $(shell go list ./...) # tr '\n' ' ' ?

# Basic building
install: clean setup depend build
reinstall: clean setup build
list:
	@echo $(PKGS)

depend:
	go get -u github.com/hsheth2/logs
	go get -u github.com/hsheth2/notifiers
	go get -u github.com/pkg/profile
	go get -u github.com/hsheth2/water
	go get -u github.com/hsheth2/water/waterutil
	go get golang.org/x/tools/cmd/...
	-go get -t ./...
build:
	go clean ./...
	go install ./...
clean:
	-rm -rf *.static.orig
	-rm -rf *.static
	-rm -f *.test
	-rm -f *.cover
	-rm -f *.html
	-rm -f httpTest
	-rm -rf tapip
	go clean ./...
setup:
	./tap_setup.sh
	./arp_setup.sh

# line counting
lines:
	find ./ -name '*.go' | xargs wc -l

# Checks for style and errors
check: fmt lint vet errcheck

fmt:
	@echo "Formatting Files..."
	goimports -l -w ./
	@echo "Finished Formatting"
vet:
	go vet ./...
lint:
	go get github.com/golang/lint/golint
	golint ./...
errcheck:
	errcheck $(PKGS)

# start documentation
doc:
	godoc -http=:6060

# Different tests that could be run on the network's code
test: test_network
test_deps:
	./run_test.sh github.com/hsheth2/logs
	./run_test.sh github.com/hsheth2/notifiers
test_network: test_udp test_tcp test_ping
test_udp:
	./run_test.sh github.com/hsheth2/gonet/udp
test_tcp:
	./run_test.sh github.com/hsheth2/gonet/tcp
test_ping:
	./run_test.sh github.com/hsheth2/gonet/ping
test_tap:
	# for testing water
	./run_test.sh github.com/hsheth2/gonet/physical
