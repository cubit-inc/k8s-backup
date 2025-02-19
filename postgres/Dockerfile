FROM alpine:3

RUN apk add --no-cache postgresql-client aws-cli

WORKDIR /home

COPY ./backup.sh backup.sh
RUN chmod +x backup.sh

ENV DATABASE_USER="postgres"
ENV DATABASE_PORT=5432
CMD ["sh", "backup.sh"]