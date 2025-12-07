FROM alpine:3

ARG POSTGRES_VERSION

RUN apk add --no-cache postgresql$POSTGRES_VERSION-client aws-cli

WORKDIR /home

COPY ./backup.sh backup.sh
RUN chmod +x backup.sh

ENV DATABASE_USER="postgres"
ENV DATABASE_PORT=5432
CMD ["sh", "backup.sh"]