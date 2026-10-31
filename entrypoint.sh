#!/bin/sh
set -e

export JAVA_OPTS="${JAVA_OPTS:--Xmx512m -Xms256m -XX:+UseContainerSupport -Djava.security.egd=file:/dev/./urandom}"

exec "/app/dss-bundle/apache-tomcat-${TOMCAT_VERSION}/bin/catalina.sh" run
