# Define the command-line arguments
parser = argparse.ArgumentParser()
parser.add_argument("--src-host", help="Source SQL hostname", required=True)
parser.add_argument("--src-user", help="Source SQL username", required=True)
parser.add_argument("--src-password", help="Source SQL password", required=True)
parser.add_argument("--src-db", help="Source SQL database name", required=True)
parser.add_argument("--dest-host", help="Destination SQL hostname", required=True)
parser.add_argument("--dest-user", help="Destination SQL username", required=True)
parser.add_argument("--dest-password", help="Destination SQL password", required=True)
parser.add_argument("--dest-db", help="Destination SQL database name", required=True)
parser.add_argument("--timeout", help="SQL connection timeout in seconds", default=10, type=int)
parser.add_argument("--limit", help="Number of rows to fetch at once", default=1000, type=int)
parser.add_argument("--update", help="Update collection if it already exists", default=False, action='store_true')
args = parser.parse_args()

# Connect to source SQL
src_conn = mysql.connector.connect(
  host=args.src_host,
  user=args.src_user,
  password=args.src_password,
  database=args.src_db
)
src_cursor = src_conn.cursor()

# Connect to destination SQL
dest_conn = mysql.connector.connect(
  host=args.dest_host,
  user=args.dest_user,
  password=args.dest_password,
  database=args.dest_db
)
dest_cursor = dest_conn.cursor()

# Get the names of all tables in the source SQL database
src_cursor.execute("SHOW TABLES")
tables = src_cursor.fetchall()

# Loop through the tables and export the data to destination SQL
for table in tables:
  table_name = table[0]
  try:
    src_cursor.execute("SELECT * FROM " + table_name)

    rows = src_cursor.fetchall()
    while rows:
        values = ', '.join(['(' + ','.join([f'"{str(x)}"' for x in row]) + ')' for row in rows])
        dest_cursor.execute(f"INSERT INTO {table_name} VALUES {values}")
        dest_conn.commit()
        time.sleep(1)
        rows = src_cursor.fetchmany(args.limit)
  except mysql.connector.errors.InternalError as error:
      if "Unread result found" in str(error):
        break

# Close the connections
src_cursor.close()
src_conn.close()
dest_cursor.close()
dest_conn.close()
