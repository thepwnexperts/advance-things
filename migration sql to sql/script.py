import mysql.connector
import argparse

# Define the command-line arguments
parser = argparse.ArgumentParser()
parser.add_argument("--source-host", help="Source MySQL hostname", required=True)
parser.add_argument("--source-user", help="Source MySQL username", required=True)
parser.add_argument("--source-password", help="Source MySQL password", required=True)
parser.add_argument("--source-db", help="Source MySQL database name", required=True)
parser.add_argument("--target-host", help="Target MySQL hostname", required=True)
parser.add_argument("--target-user", help="Target MySQL username", required=True)
parser.add_argument("--target-password", help="Target MySQL password", required=True)
parser.add_argument("--target-db", help="Target MySQL database name", required=True)
args = parser.parse_args()

# Connect to the source MySQL database
source_conn = mysql.connector.connect(
  host=args.source_host,
  user=args.source_user,
  password=args.source_password,
  database=args.source_db
)
source_cursor = source_conn.cursor()

# Connect to the target MySQL database
target_conn = mysql.connector.connect(
  host=args.target_host,
  user=args.target_user,
  password=args.target_password,
  database=args.target_db
)
target_cursor = target_conn.cursor()

# Get the names of all tables in the source MySQL database
source_cursor.execute("SHOW TABLES")
tables = source_cursor.fetchall()

# Loop through the tables and export the data to the target MySQL database
for table in tables:
  table_name = table[0]
  try:
    # Get the data from the source table
    source_cursor.execute(f"SELECT * FROM {table_name}")
    rows = source_cursor.fetchall()

    # Create the table in the target database if it doesn't exist
    target_cursor.execute(f"CREATE TABLE IF NOT EXISTS {table_name} LIKE {args.source_db}.{table_name}")

    # Insert the data into the target table
    for row in rows:
        target_cursor.execute(f"INSERT INTO {table_name} VALUES {row}")

  except mysql.connector.errors.ProgrammingError as error:
    print(f"Error exporting data from {table_name}: {error}")

# Close the connections
source_cursor.close()
source_conn.close()
target_cursor.close()
target_conn.close()
