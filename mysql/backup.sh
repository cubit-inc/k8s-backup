#/bin/sh

ExcludeDatabases="Database|information_schema|performance_schema|mysql"

NOW=$(date +%Y-%m-%d-%H-%M-%S)

cd /home

DUMP_DIR="$(pwd)/$NOW"
BUNDLE="$NOW.tar.gz"

BUNDLE_DIR="$(pwd)/$BUNDLE"
echo $DUMP_DIR

sleep 2

mkdir -p $DUMP_DIR 

# Perform the database backup. Put the output to a variable. If successful upload the backup to S3, if unsuccessful print an entry to the console and the log, and set has_failed to true.
if databases=`mariadb -h$DATABASE_HOST -P$DATABASE_PORT  -u$DATABSE_USER -p$DATABSE_PASSWORD --skip-ssl -e "SHOW DATABASES;" | tr -d "| " | egrep -v $ExcludeDatabases`
then
    for db in $databases; do
        echo "Dumping database: $db at $(date +'%d-%m-%Y %H:%M:%S')."
        if dump_output=$(mysqldump -h $DATABASE_HOST -P $DATABASE_PORT -u $DATABSE_USER -p$DATABSE_PASSWORD --skip-ssl --databases $db > $DUMP_DIR/$db.sql 2>&1)
        then
            echo -e "Database dumped: $db at $(date +'%d-%m-%Y %H:%M:%S')."
        else
            echo -e "Database dump failed: $db at $(date +'%d-%m-%Y %H:%M:%S') $dump_output."
            exit 1
        fi
    done
else
    echo -e "Unable to get database names at $(date +'%d-%m-%Y %H:%M:%S'). Error: $databases"
    exit 1;
fi

if bundle_output=$(tar -zcvf $BUNDLE $DUMP_DIR  2>&1)
then
    echo -e "created a tarball: $BUNDLE at $(date +'%d-%m-%Y %H:%M:%S')."
else
    echo -e "Unable to create tarball: at $(date +'%d-%m-%Y %H:%M:%S') $bundle_output."
    exit 1
fi

if [ "$has_failed" = true ]
then
    echo -e "s3-mysql-backup encountered 1 or more errors. Exiting with status code 1."
    exit 1
fi

if awsoutput=$(aws s3 cp s3://$AWS_BUCKET_BACKUP_PATH --endpoint-url $AWS_BUCKET_URI 2>&1)
then
    echo -e "Database backup successfully uploaded: $AWS_BUCKET_URI$AWS_BUCKET_BACKUP_PATH/$BUNDLE at $(date +'%d-%m-%Y %H:%M:%S')."
    exit 0
else
    echo -e "Database backup failed to upload at $(date +'%d-%m-%Y %H:%M:%S'). Error: $awsoutput"
    exit 1
fi