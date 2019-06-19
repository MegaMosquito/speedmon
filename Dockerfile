#
# A network WAN speed test monitor daemon container that feeds data
# into couchdb.
#
# Written by Glen Darling (mosquito@darlingevil.com), June 2019.
#

# This should build and run on any Raspberry Pi0W, Pi2*, Pi3*, and other ARM.
FROM arm32v6/python:3-alpine
WORKDIR /speedmon

# Install required modules and tools
RUN apk --no-cache --update add nmap git

# Install the speedtest.net "speedtest-cli" library
RUN pip install speedtest-cli

# Install couchdb interface
RUN pip install couchdb

# Install my Speedtest-CLI wrapper
RUN git clone https://github.com/MegaMosquito/speed.git

# Install convenience tools (may omit these in production)
RUN apk --no-cache --update add vim curl jq

# Copy over the speedmon files
COPY ./*.py /speedmon/

# Start up the daemon process
CMD python speedmon.py

