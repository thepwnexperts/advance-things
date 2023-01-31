import mysql.connector
import pymongo
import argparse

# Define the command-line arguments
parser = argparse.ArgumentParser()
parser.add_argument("--sql-host", help="SQL hostname", required=True)
parser.add_argument("--sql-user", help="SQL username", required=True)
parser.add_argument("--sql-password", help="SQL password", required=True)
parser.add_argument("--sql-db", help="SQL database name", required=True)
parser.add_argument("--mongo-url", help="MongoDB url", required=True)
parser.add_argument("--mongo-db", help="MongoDB database name", required=True)
args = parser.parse_args()

# Connect to MySQL
mydb = mysql.connector.connect(
  host=args.sql_host,
  user=args.sql_user,
  password=args.sql_password,
  database=args.sql_db
)

# Connect to MongoDB
client = pymongo.MongoClient(args.mongo_url)
mongodb = client[args.mongo_db]

# Get the names of all tables in the SQL database
cursor = mydb.cursor()
cursor.execute("SHOW TABLES")
tables = cursor.fetchall()

# Loop through the tables and export the data to JSON
for table in tables:
    table_name = table[0]
    cursor.execute("SELECT * FROM " + table_name)
    rows = cursor.fetchall()

    data = []
    for row in rows:
        data.append(dict(zip(cursor.column_names, row)))

    # Insert the data into the corresponding collection in MongoDB
    collection = mongodb[table_name]

    collection.insert_many(data)

# Close the connections
cursor.close()
mydb.close()
client.close()

