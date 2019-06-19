#!/usr/bin/python3
#
# A network WAN speed test monitor daemon container that feeds data
# into couchdb.
#
# Written by Glen Darling (mosquito@darlingevil.com), June 2019.
#


import os


# Configure all of these "MY_" environment variables for your situation

MY_COUCHDB_ADDRESS        = os.environ['MY_COUCHDB_ADDRESS']
MY_COUCHDB_PORT           = int(os.environ['MY_COUCHDB_PORT'])
MY_COUCHDB_USER           = os.environ['MY_COUCHDB_USER']
MY_COUCHDB_PASSWORD       = os.environ['MY_COUCHDB_PASSWORD']
MY_COUCHDB_DATABASE       = os.environ['MY_COUCHDB_DATABASE']
MY_COUCHDB_TIME_FORMAT    = os.environ['MY_COUCHDB_TIME_FORMAT']

MY_SPEEDTEST_CACHE_SIZE   = int(os.environ['MY_SPEEDTEST_CACHE_SIZE'])
MY_SECONDS_BETWEEN_TESTS  = int(os.environ['MY_SECONDS_BETWEEN_TESTS'])



import sys
import signal
import subprocess
import threading
import time
import datetime
import json
import traceback
import urllib.parse


# Get the DB class
from db import DB

# Get the Speed class (for its run_speedtest static method)
from speed.speedtest_server import Speed



# Instantiate the db object (i.e., connect to CouchDB, and open our DB)
db = DB( \
  MY_COUCHDB_ADDRESS,
  MY_COUCHDB_PORT,
  MY_COUCHDB_USER,
  MY_COUCHDB_PASSWORD,
  MY_COUCHDB_DATABASE,
  MY_COUCHDB_TIME_FORMAT)


# Save the WAN speed test results into the DB
def save(n, raw):
  try:
    results = {}
    results['time'] = db.now()
    results['upload'] = raw['upload']
    results['download'] = raw['download']
    results['ping'] = raw['ping']
    # print(str(n) + ": " + json.dumps(results))
    db.put(n, results)
  except Exception as e:
    print("*** Exception during saving: " + str(n))
    traceback.print_exc()
  sys.stdout.flush()


if __name__ == '__main__':

  print("Starting WAN speed test monitor daemon...")
  i = 0
  while True:
    results = Speed.run_speedtest()
    save(i, results)
    i = (i + 1) % MY_SPEEDTEST_CACHE_SIZE
    # print("Sleeping...")
    time.sleep(MY_SECONDS_BETWEEN_TESTS)

