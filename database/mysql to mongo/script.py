import mysql.connector
import pymongo
import argparse
import time
from decimal import Decimal

# Define the command-line arguments
parser = argparse.ArgumentParser()
parser.add_argument("--sql-host", help="SQL hostname", required=True)
parser.add_argument("--sql-user", help="SQL username", required=True)
parser.add_argument("--sql-password", help="SQL password", required=True)
parser.add_argument("--sql-db", help="SQL database name", required=True)
parser.add_argument("--mongo-url", help="MongoDB url", required=True)
parser.add_argument("--mongo-db", help="MongoDB database name", required=True)
parser.add_argument("--timeout", help="MongoDB connection timeout in seconds", default=10, type=int)
parser.add_argument("--limit", help="Number of rows to fetch at once", default=1000, type=int)
parser.add_argument("--update", help="Update collection if it already exists", default=False, action='store_true')
args = parser.parse_args()

# Connect to MySQL with a specified charset and collation
mydb = mysql.connector.connect(
  host=args.sql_host,
  user=args.sql_user,
  password=args.sql_password,
  database=args.sql_db,
  charset='utf8mb4',
  collation='utf8mb4_general_ci'
)

# Connect to MongoDB
client = pymongo.MongoClient(args.mongo_url, serverSelectionTimeoutMS=args.timeout*1000)
mongodb = client[args.mongo_db]

# Get the names of all tables in the SQL database
cursor = mydb.cursor()
cursor.execute("SHOW TABLES")
tables = cursor.fetchall()

# Loop through the tables and export the data to JSON
for table in tables:
  table_name = table[0]
  try:
    cursor.execute("SELECT * FROM " + table_name)
    rows = cursor.fetchall()
    data = []
    while rows:
        for row in rows:
            # Convert Decimal to float
            row = [float(item) if isinstance(item, Decimal) else item for item in row]
            data.append(dict(zip(cursor.column_names, row)))
        try:
          collection = mongodb[table_name]
          if data:
            if collection.count_documents({}) > 0:
              if args.update:
                collection.insert_many(data)
              else:
                print(f'Collection {table_name} already exists in the MongoDB database. Use the --update argument to update the collection.')
                break
            else:
              collection.insert_many(data)
            data = []
          else:
            print(f'Table {table_name} is empty')

          time.sleep(1)
          rows = cursor.fetchmany(args.limit)
        except mysql.connector.errors.InternalError as error:
          if "Unread result found" in str(error):
            break
  except mysql.connector.errors.InternalError as error:
      if "Unread result found" in str(error):
        break

# Close the connections
cursor.close()
mydb.close()
client.close()

