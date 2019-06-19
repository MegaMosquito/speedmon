#!/usr/bin/python3


import sys
import time
import datetime
import traceback


# Don't forget to `pip install couchdb`
import couchdb


# A class for our database of "host" documents
class DB:

  def __init__(self, address, port, user, password, database, time_format):
    self.db = None
    self.name = database
    self.time_format = time_format

    # Try forever to connect
    while True:
      print("Attempting to connect to CouchDB server at " + address + ":" + str(port) + "...")
      couchdbserver = couchdb.Server('http://%s:%s@%s:%d/' % ( \
        user, \
        password, \
        address, \
        port))
      if couchdbserver:
        break
      print("CouchDB server not accessible. Will retry...")
      time.sleep(10)

    # Connected!
    print("Connected to CouchDB server.")

    # Open or create our database
    print("Attempting to open the \"" + database + "\" DB...")
    if database in couchdbserver:
      self.db = couchdbserver[database]
    else:
      print("Creating the \"" + database + "\" DB...")
      self.db = couchdbserver.create(database)

    # Done!
    print('CouchDB database "' + database + '" is open and ready for use.')
    sys.stdout.flush()

  # Instance method to get an appropriately formatted string representing "now"
  def now(self):
    return datetime.datetime.now().strftime(self.time_format)

  # Instance method to write one speedtest document
  def put(self, n, doc):
    id = "t" + str(n)
    doc['_id'] = id
    try:
      if id in self.db:
        rev = self.db[id]['_rev']
        doc['_rev'] = rev
        # print("DB.put: [update] " + id)
        self.db[id] = doc
      else:
        # print("DB.put: [new] " + id)
        self.db.save(doc)
    except Exception as e:
      print("*** Exception during DB.put(" + str(id) + "):")
      traceback.print_exc()
      doc = None

  # Instance method for stringification
  def __str__(self):
    return "DB( name:" + self.name + ", docs:" + str(len(self.db.view('_all_docs'))) + " )"



