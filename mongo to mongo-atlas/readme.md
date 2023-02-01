
# Connect to the source MongoDB database.

## Dump the data from the source database to a BSON file using the mongodump utility. For example:
```
mongodump --host <source_hostname>:<source_port> --db <source_database_name> --out <output_directory>
```

#  Transfer the BSON file to the destination server using a method such as scp, sftp, or other file transfer method.

# Restore the data to the destination MongoDB Atlas cluster using the mongorestore utility. For example:

```
mongorestore --host <destination_cluster_uri> --ssl --username <destination_username> --password <destination_password> --authenticationDatabase admin --db <destination_database_name> <input_directory>/<source_database_name>
```

# with url

# dump

```
mongodump --uri mongodb://<username>:<password>@<source_hostname>:<source_port>/<source_database_name>
```

```
mongodump --uri mongodb://<username>:<password>@<source_hostname>:<source_port>/<source_database_name> --out <output_directory>
```
## without ssl
```
mongodump --uri "mongodb://127.0.0.1:27017/?directConnection=true&serverSelectionTimeoutMS=2000&appName=mongosh+1.6.2"  --db test --out test
```

# restore 

#
```
mongorestore --uri mongodb+srv://<destination_username>:<destination_password>@<destination_cluster_uri>/<destination_database_name> --ssl --authenticationDatabase admin <input_directory>/<source_database_name>
```

## without ssl
```
mongorestore --uri "mongodb+srv://test:test@test.9rm4c.mongodb.net/ibharat?ssl=true&authSource=admin" --db  test  test/test
```
