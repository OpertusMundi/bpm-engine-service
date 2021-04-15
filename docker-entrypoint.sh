#!/bin/sh
set -u -e
set -x

function _gen_configuration()
{
    cat <<-EOD
	spring.datasource.url = jdbc:postgresql://${DATABASE_HOST:-localhost}:${DATABASE_PORT:-5432}/${DATABASE_NAME}
	spring.datasource.username = ${DATABASE_USERNAME}
	spring.datasource.password = $(cat ${DATABASE_PASSWORD_FILE} | tr -d '\n')
	
	camunda.bpm.admin-user.id = ${CAMUNDA_ADMIN_USERNAME}
	camunda.bpm.admin-user.password = $(cat ${CAMUNDA_ADMIN_PASSWORD_FILE} | tr -d '\n')
	EOD
}

default_java_opts="-server -Djava.security.egd=file:///dev/urandom -Xms128m"
java_opts="${JAVA_OPTS:-${default_java_opts}}"

runtime_profile=$(hostname | hexdump -e '"%02x"')
_gen_configuration > ./config/application-${runtime_profile}.properties

exec java ${java_opts} -cp "/app/classes:/app/dependency/*" eu.opertusmundi.bpm.server.Application \
  --spring.profiles.active=production,${runtime_profile}
