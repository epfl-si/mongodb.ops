#!/usr/bin/env bash
####### A adapter #######
env=test
DB=wp-veritas-test
dumps_folder=${DUMPS_FOLDER:-../dumps}
source_mongo_srv=test-mongodb-svc-1.epfl.ch
destination_mongo_srv=itsidevfsd0038.xaas.epfl.ch
######################
cd "$(dirname "$0")"; cd "$(/bin/pwd)"
_now=$(date +"%Y-%m-%d_%H:%M:%S")
mkdir -p $dumps_folder/logs/ || true
_log_file=$dumps_folder/logs/${_now}_${DB}.log
touch $_log_file
echo -e "--------------------------------------------------------------------------------" >> $_log_file
echo -e "-- Started at ${_now}"  >> $_log_file
echo -e "-- Variables"  >> $_log_file
echo -e "--  - env: ${env}"  >> $_log_file
echo -e "--  - DB: ${DB}"  >> $_log_file
echo -e "--  - source_mongo_srv: ${source_mongo_srv}"  >> $_log_file
echo -e "--  - destination_mongo_srv: ${destination_mongo_srv}"  >> $_log_file
echo -e "--------------------------------------------------------------------------------" >> $_log_file

echo "Dumping $DB from $source_mongo_srv and restoring it on $destination_mongo_srv"
source_db_user=`cat /keybase/team/epfl_mongodb/mongodb_db_inventory-$env.yml | grep -A2 $DB | grep user | sed 's/  user: //'`
source_db_password=`cat /keybase/team/epfl_mongodb/mongodb_db_inventory-$env.yml | grep -A2 $DB | grep password | sed 's/  password: //'`

echo -e "\n--------------------------------------------------\n-- mongodump\n--------------------------------------------------" >> $_log_file
mongodump --uri="mongodb://$source_db_user:$source_db_password@$source_mongo_srv/$DB" --out $dumps_folder/$DB &>> $_log_file

destination_db_root=`cat /keybase/team/epfl_mongodb/mongodb_db_inventory-$env.yml | grep -A2 admin | grep user | sed 's/  user: //'`
destination_db_root_password=`cat /keybase/team/epfl_mongodb/mongodb_db_inventory-$env.yml | grep -A2 admin | grep password | sed 's/  password: //'`

echo -e "\n--------------------------------------------------\n-- dropDatabase $DB\n--------------------------------------------------" >> $_log_file
mongosh "mongodb://$destination_db_root:$destination_db_root_password@$destination_mongo_srv" --eval "use $DB" --eval "db.dropDatabase()" &>> $_log_file

echo -e "\n--------------------------------------------------\n-- mongorestore\n--------------------------------------------------" >> $_log_file
mongorestore --uri="mongodb://$destination_db_root:$destination_db_root_password@$destination_mongo_srv" $dumps_folder/$DB &>> $_log_file

echo "See logs in $(realpath $_log_file)"
