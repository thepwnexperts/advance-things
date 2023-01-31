
##use


```
    python script.py --sql-host hostname --sql-user username --sql-password password --sql-db databasename --mongo-url mongodb+srv://username:password@cluster-url/database --mongo-db mongodatabasename 
 ```
```
   python script.py --sql-host=sql.example.com --sql-user=user --sql-password=secret --sql-db=database --mongo-url=mongodb://mongodb.example.com:27017/ --mongo-db=mongo_database_name
```

##use with limit
<pre>
  <code id="code">
python script.py --sql-host=sql.example.com --sql-user=user --sql-password=secret --sql-db=database --mongo-url=mongodb://mongodb.example.com:27017/ --mongo-db=mongo_database_name --timeout=60 --limit=1000

  </code>
</pre>


