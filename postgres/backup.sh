#/bin/sh

ExcludeDatabases="postgres"

NOW=$(date +%Y-%m-%d-%H-%M-%S)

cd /home

DUMP_DIR="$NOW"
BUNDLE="$NOW.psql.tar.gz"

export PGPASSWORD=$DATABASE_PASSWORD

mkdir -p $DUMP_DIR 

if dump_output=$(pg_dumpall -h $DATABASE_HOST -U $DATABASE_USER -p $DATABASE_PORT --globals-only > $DUMP_DIR/postgres_globals.sql  2>&1)
then
    echo -e "dumped: globals at $(date +'%d-%m-%Y %H:%M:%S')."
else
    echo -e "Unable to dump globals: at $(date +'%d-%m-%Y %H:%M:%S') $dump_output."
    exit 1
fi

# Perform the database backup. Put the output to a variable. If successful upload the backup to S3, if unsuccessful print an entry to the console and the log, and set has_failed to true.
if databases=`psql -h $DATABASE_HOST -U $DATABASE_USER -p $DATABASE_PORT -t -c "select datname from pg_database where not datistemplate" | grep '\S' | awk '{$1=$1};1' | egrep -v $ExcludeDatabases`
then
    for db in $databases; do
        echo "Dumping database: $db at $(date +'%d-%m-%Y %H:%M:%S')."
        if dump_output=$(pg_dump -h $DATABASE_HOST -U $DATABASE_USER -p $DATABASE_PORT $db > $DUMP_DIR/$db.sql 2>&1)
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


if bundle_output=$(tar -zcvf $BUNDLE  $DUMP_DIR 2>&1)
then
    echo -e "created a tarball: $BUNDLE at $(date +'%d-%m-%Y %H:%M:%S')."
else
    echo -e "Unable to create tarball: at $(date +'%d-%m-%Y %H:%M:%S') $bundle_output."
    exit 1
fi

if awsoutput=$(aws s3 cp $BUNDLE s3://$AWS_BUCKET_BACKUP_PATH --endpoint-url $AWS_BUCKET_URI 2>&1)
then
    echo -e "Database backup successfully uploaded: $AWS_BUCKET_URI$AWS_BUCKET_BACKUP_PATH/$BUNDLE at $(date +'%d-%m-%Y %H:%M:%S')."
    exit 0
else
    echo -e "Database backup failed to upload at $(date +'%d-%m-%Y %H:%M:%S'). Error: $awsoutput"
    exit 1
fi