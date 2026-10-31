#!/bin/sh
set -e

export JAVA_OPTS="${JAVA_OPTS:--Xmx512m -Xms256m -XX:+UseContainerSupport -Djava.security.egd=file:/dev/./urandom}"

CATALINA=$(find /app/dss-bundle -name "catalina.sh" -maxdepth 4 | head -1)
exec "$CATALINA" run
