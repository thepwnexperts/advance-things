import mysql.connector
import pymongo
import argparse
import time

# Define the command-line arguments
parser = argparse.ArgumentParser()
parser.add_argument("--sql-host", help="SQL hostname", required=True)
parser.add_argument("--sql-user", help="SQL username", required=True)
parser.add_argument("--sql-password", help="SQL password", required=True)
parser.add_argument("--sql-db", help="SQL database name", required=True)
parser.add_argument("--mongo-url", help="MongoDB url", required=True)
parser.add_argument("--mongo-db", help="MongoDB database name", required=True)
parser.add_argument("--timeout", help="MongoDB connection timeout in seconds", default=10, type=int)
parser.add_argument("--collection", help="MongoDB collection name", required=True)
args = parser.parse_args()

# Connect to MongoDB
client = pymongo.MongoClient(args.mongo_url, serverSelectionTimeoutMS=args.timeout*1000)
mongodb = client[args.mongo_db]
collection = mongodb[args.collection]

# Connect to MySQL
mydb = mysql.connector.connect(
  host=args.sql_host,
  user=args.sql_user,
  password=args.sql_password,
  database=args.sql_db
)

# Create the table in MySQL
cursor = mydb.cursor()
cursor.execute("DROP TABLE IF EXISTS " + args.collection)
columns = []
for key in collection.find_one().keys():
  columns.append(key + " TEXT")
columns = ", ".join(columns)
cursor.execute("CREATE TABLE " + args.collection + "(" + columns + ")")
mydb.commit()

# Insert the data into the table
for document in collection.find():
  values = []
  for key in document.keys():
    value = document[key]
    if isinstance(value, str):
      value = value.replace("'", "\\'")
      values.append("'" + value + "'")
    else:
      values.append(str(value))
  values = ", ".join(values)
  cursor.execute("INSERT INTO " + args.collection + " VALUES(" + values + ")")
mydb.commit()

# Close the connections
cursor.close()
mydb.close()
client.close()
