# Postgres Backup to S3

This is designed to be used with K8s [CronJob](https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/) to automate Postgres database backups and upload them to an S3-compatible storage service.

## Environment Variables

| Variable Name            | Description                            | Default Value |
| ------------------------ | -------------------------------------- | ------------- |
| `DATABASE_HOST`          | Postgres database host                 | *Required*    |
| `DATABASE_USER`          | Postgres username                      | `root`        |
| `DATABASE_PORT`          | Postgres port                          | `5432`        |
| `DATABASE_PASSWORD`      | Postgres password                      | *Required*    |
| `AWS_BUCKET_URI`         | S3 bucket URI (e.g., `s3://my-bucket`) | *Required*    |
| `AWS_BUCKET_BACKUP_PATH` | Path inside the S3 bucket              | *Required*    |
| `AWS_ACCESS_KEY_ID`      | AWS access key ID                      | *Required*    |
| `AWS_SECRET_ACCESS_KEY`  | AWS secret access key                  | *Required*    |

## Usage

### Kubernetes CronJob

To schedule automatic database backups using a Kubernetes CronJob, use the following example configuration:

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: postgres-backup-cronjob
spec:
  schedule: "0 */12 * * *" # Runs every 12 hours
  jobTemplate:
    spec:
      template:
        spec:
          restartPolicy: OnFailure
          containers:
            - name: postgres-backup
              image: ghcr.io/cubit-inc/k8s-backup/k8s-backup-postgres:latest
              env:
                - name: DATABASE_HOST
                  value: mydb.example.com
                - name: DATABASE_PASSWORD
                  value: <secret>
                - name: AWS_BUCKET_URI
                  value: https://mybackups.s3.some-region.amazonaws.com
                - name: AWS_BUCKET_BACKUP_PATH
                  value: psql-backups
                - name: AWS_ACCESS_KEY_ID
                  value: <secret>
                - name: AWS_SECRET_ACCESS_KEY
                  value: <secret>
```

### Running with Docker

You can run the backup process manually using Docker:

```sh
docker run --rm \  
  -e DATABASE_HOST=mydb.example.com \  
  -e DATABASE_USER=root \  
  -e DATABASE_PASSWORD=secret \  
  -e AWS_BUCKET_URI=https://mybackups.s3.some-region.amazonaws.com \  
  -e AWS_BUCKET_BACKUP_PATH=db_backups \  
  -e AWS_ACCESS_KEY_ID=your-access-key \  
  -e AWS_SECRET_ACCESS_KEY=your-secret-key \  
  ghcr.io/cubit-inc/k8s-backup/k8s-backup-postgres
```

## How It Works

1. The script dumps individual databases from a Postgres instance into separate SQL dump files.
2. The SQL dumps are compressed into a tarball.
3. The tarball is then uploaded to the specified S3 bucket path.

## Contributing

We welcome contributions! Feel free to submit issues and pull requests to enhance this project.

## License

This project is licensed under the MIT License.

