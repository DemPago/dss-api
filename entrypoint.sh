#!/bin/sh
set -e

export JAVA_OPTS="${JAVA_OPTS:--Xmx512m -Xms256m -XX:+UseContainerSupport -Djava.security.egd=file:/dev/./urandom}"

exec apache-tomcat-11.0.21/bin/catalina.sh run
