import pymongo
import argparse

# Define the command-line arguments
parser = argparse.ArgumentParser()
parser.add_argument("--src-mongo-url", help="Source MongoDB URL", required=True)
parser.add_argument("--src-mongo-db", help="Source MongoDB database name", required=True)
parser.add_argument("--src-mongo-collection", help="Source MongoDB collection name", required=True)
parser.add_argument("--dst-mongo-url", help="Destination MongoDB URL", required=True)
parser.add_argument("--dst-mongo-db", help="Destination MongoDB database name", required=True)
parser.add_argument("--dst-mongo-collection", help="Destination MongoDB collection name", required=True)
parser.add_argument("--timeout", help="MongoDB connection timeout in seconds", default=10, type=int)
parser.add_argument("--update", help="Update collection if it already exists", default=False, action='store_true')
args = parser.parse_args()

# Connect to the source MongoDB
src_client = pymongo.MongoClient(args.src_mongo_url, serverSelectionTimeoutMS=args.timeout*1000)
src_mongodb = src_client[args.src_mongo_db]

# Connect to the destination MongoDB
dst_client = pymongo.MongoClient(args.dst_mongo_url, serverSelectionTimeoutMS=args.timeout*1000)
dst_mongodb = dst_client[args.dst_mongo_db]


# Export the data from the source MongoDB to the destination MongoDB
for collection_name in collections:
    src_collection = src_db[collection_name]
    data = src_collection.find()
    if dst_collection.count_documents({}) > 0:
      if args.update:
        dst_collection.insert_many(data)
      else:
        print(f'Collection {args.dst_mongo_collection} already exists in the MongoDB database. Use the --update argument to update the collection.')
    else:
      dst_collection.insert_many(data)
    dst_collection = dst_db[collection_name]
    data = list(src_collection.find())
    dst_collection.insert_many(data)


# Close the connections
src_client.close()
dst_client.close()
