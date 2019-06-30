#
# A convenience Makefile with commonly used commands for the WAN speed monitor
#
# A network WAN speed test monitor daemon container that feeds data
# into couchdb.
#
# Written by Glen Darling (mosquito@darlingevil.com), December 2018.
#


# Some bits from https://github.com/MegaMosquito/netstuff/blob/master/Makefile
LOCAL_DEFAULT_ROUTE     := $(shell sh -c "ip route | grep default")
LOCAL_IP_ADDRESS        := $(word 7, $(LOCAL_DEFAULT_ROUTE))


# Configure all of these "MY_" variables for your personal situation

MY_COUCHDB_ADDRESS        := $(LOCAL_IP_ADDRESS)
MY_COUCHDB_PORT           := 5984
MY_COUCHDB_USER           := 'admin'
MY_COUCHDB_PASSWORD       := 'p4ssw0rd'
MY_COUCHDB_DATABASE       := 'wan_speed'
MY_COUCHDB_TIME_FORMAT    := '%Y-%m-%d %H:%M:%S'

MY_SECONDS_BETWEEN_TESTS  := 600
MY_SPEEDTEST_CACHE_SIZE   := 2000


# Running `make` with no target builds and runs speedmon as a restarting daemon
all: build run

# Build the container and tag it, "speedmon".
build:
	docker build -t speedmon .

# Running `make dev` will setup a working environment, just the way I like it.
# On entry to the container's bash shell, run `cd /outside/src` to work here.
dev: build
	-docker rm -f speedmon 2> /dev/null || :
	docker run -it --privileged --net=host \
	    --name speedmon \
	    -e MY_COUCHDB_ADDRESS=$(MY_COUCHDB_ADDRESS) \
	    -e MY_COUCHDB_PORT=$(MY_COUCHDB_PORT) \
	    -e MY_COUCHDB_USER=$(MY_COUCHDB_USER) \
	    -e MY_COUCHDB_PASSWORD=$(MY_COUCHDB_PASSWORD) \
	    -e MY_COUCHDB_DATABASE=$(MY_COUCHDB_DATABASE) \
	    -e MY_COUCHDB_TIME_FORMAT=$(MY_COUCHDB_TIME_FORMAT) \
	    -e MY_SECONDS_BETWEEN_TESTS=$(MY_SECONDS_BETWEEN_TESTS) \
	    -e MY_SPEEDTEST_CACHE_SIZE=$(MY_SPEEDTEST_CACHE_SIZE) \
	    --volume `pwd`:/outside speedmon /bin/sh

# Run the container as a daemon (build not forecd here, sp must build it first)
run:
	-docker rm -f speedmon 2>/dev/null || :
	docker run -d --privileged --net=host \
	    --name speedmon --restart unless-stopped \
	    -e MY_COUCHDB_ADDRESS=$(MY_COUCHDB_ADDRESS) \
	    -e MY_COUCHDB_PORT=$(MY_COUCHDB_PORT) \
	    -e MY_COUCHDB_USER=$(MY_COUCHDB_USER) \
	    -e MY_COUCHDB_PASSWORD=$(MY_COUCHDB_PASSWORD) \
	    -e MY_COUCHDB_DATABASE=$(MY_COUCHDB_DATABASE) \
	    -e MY_COUCHDB_TIME_FORMAT=$(MY_COUCHDB_TIME_FORMAT) \
	    -e MY_SECONDS_BETWEEN_TESTS=$(MY_SECONDS_BETWEEN_TESTS) \
	    -e MY_SPEEDTEST_CACHE_SIZE=$(MY_SPEEDTEST_CACHE_SIZE) \
	    speedmon

# Enter the context of the daemon container
exec:
	docker exec -it speedmon /bin/sh

# Stop the daemon container
stop:
	-docker rm -f speedmon 2>/dev/null || :

# Stop the daemon container, and cleanup
clean: stop
	-docker rmi speedmon 2>/dev/null || :

# Declare all non-file-system targets as .PHONY
.PHONY: all build dev run exec stop clean

