# for dump
```
mysqldump -u [source_username] -p[source_password] [source_database_name] > [dump_file_name].sql
```

for restore
```
mysql -u [target_username] -p[target_password] [target_database_name] < [dump_file_name].sql
```
