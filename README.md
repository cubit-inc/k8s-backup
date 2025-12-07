### Kubernetes Cron Job Backup

![license](https://img.shields.io/github/license/cubit-inc/k8s-backup?label=License)

This repository contains Docker images designed for use with Kubernetes CronJobs to automate backups of various services.


# MySQL Backup
```yaml

apiVersion: batch/v1
kind: CronJob
metadata:
  name: mysql-backup-cronjob
spec:
  schedule: "0 */12 * * *" # Runs every 12 hours
  jobTemplate:
    spec:
      template:
        spec:
          restartPolicy: OnFailure
          containers:
            - name: mysql-backup
              image: ghcr.io/cubit-inc/k8s-backup/k8s-backup-mysql:latest
              env:
                - name: DATABASE_HOST
                  value: mydb.example.com
                - name: DATABASE_PASSWORD
                  value: <secret>
                - name: AWS_BUCKET_URI
                  value: https://mybackups.s3.some-region.amazonaws.com
                - name: AWS_BUCKET_BACKUP_PATH
                  value: sql-backups
                - name: AWS_ACCESS_KEY_ID
                  value: <secret>
                - name: AWS_SECRET_ACCESS_KEY
                  value: <secret>
```
You can get more info from [mysql/README.md](mysql/README.md).

# Postgres Backup

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
              image: ghcr.io/cubit-inc/k8s-backup/k8s-backup-postgres-17:latest
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
You can get more info from [postgres/README.md](postgres/README.md).

## Contributing

We welcome contributions! Feel free to submit issues and pull requests to enhance this project.

## License

This project is licensed under the MIT License.

<br />
<p align="center">
 Built with 🤍 <br> <a href="https://github.com/cubit-in">@cubit.inc</a>
</p>
