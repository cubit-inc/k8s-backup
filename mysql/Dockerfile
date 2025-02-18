FROM alpine:3

RUN apk add --no-cache mysql-client mariadb-connector-c aws-cli

WORKDIR /home

COPY ./backup.sh backup.sh
RUN chmod +x backup.sh

ENV DATABSE_USER="root"
ENV DATABASE_PORT=3306
CMD ["sh", "backup.sh"]