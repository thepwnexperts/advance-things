MySQL to MongoDB Data Migration Tool
A simple Python script to export data from a MySQL database and import it into a MongoDB database. The script can handle different data types, including Decimal, and can be run from the command line.

Features
Connect to a MySQL database and retrieve all the tables.
Export each table to a separate MongoDB collection.
Option to update an existing collection or replace it with new data.
Option to set a limit on the number of rows to fetch from the MySQL database at once.
Option to set a timeout for the MongoDB connection.
Convert Decimal type to float.
Prerequisites
Python 3.x
MySQL Connector Python
PyMongo
Usage
css
Copy code
python mysql_to_mongo.py --sql-host HOST --sql-user USER --sql-password PASSWORD --sql-db DB --mongo-url URL --mongo-db DB [--timeout TIMEOUT] [--limit LIMIT] [--update]
Command-Line Arguments
--sql-host: SQL hostname
--sql-user: SQL username
--sql-password: SQL password
--sql-db: SQL database name
--mongo-url: MongoDB URL
--mongo-db: MongoDB database name
--timeout (optional): MongoDB connection timeout in seconds (default: 10)
--limit (optional): Number of rows to fetch from the MySQL database at once (default: 1000)
--update (optional): Update the collection if it already exists (default: False)
Example
css
Copy code
python mysql_to_mongo.py --sql-host localhost --sql-user root --sql-password 12345 --sql-db test --mongo-url mongodb://localhost:27017/ --mongo-db test_db --timeout 20 --limit 5000 --update
License
This project is licensed under the MIT License.
