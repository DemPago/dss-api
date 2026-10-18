# ──────────────────────────────────────────────
# Stage 1: Download e preparazione artefatti
# ──────────────────────────────────────────────
FROM eclipse-temurin:17-jre-alpine AS builder

ARG DSS_VERSION=6.4+20260415
ARG TOMCAT_VERSION=11.0.21

RUN apk add --no-cache wget unzip

RUN wget -q "https://ec.europa.eu/cefdigital/artifact/repository/esignaturedss/eu/europa/ec/joinup/sd-dss/dss-demo-bundle/${DSS_VERSION}/dss-demo-bundle-${DSS_VERSION}.zip" \
    -O /tmp/dss.zip && \
    unzip /tmp/dss.zip -d /app && \
    rm /tmp/dss.zip && \
    mv /app/dss-demo-bundle-* /app/dss-bundle

WORKDIR /app/dss-bundle

RUN mkdir -p apache-tomcat-${TOMCAT_VERSION}/temp/dss-tsl-loader && \
    sed -i 's/port="8005"/port="-1"/' apache-tomcat-${TOMCAT_VERSION}/conf/server.xml && \
    sed -i 's/ address="127\.0\.0\.1"//g' apache-tomcat-${TOMCAT_VERSION}/conf/server.xml

# ──────────────────────────────────────────────
# Stage 2: Immagine finale (senza wget/unzip)
# ──────────────────────────────────────────────
FROM eclipse-temurin:17-jre-alpine

ARG DSS_VERSION=6.4+20260415
ARG TOMCAT_VERSION=11.0.21

LABEL description="DSS Demo Bundle - EU Digital Signature Service" \
      version="${DSS_VERSION}"

# Utente non-root
RUN addgroup -S tomcat && adduser -S tomcat -G tomcat

COPY --from=builder /app /app
RUN chown -R tomcat:tomcat /app

WORKDIR /app/dss-bundle

ENV TOMCAT_VERSION=${TOMCAT_VERSION}

# JVM options esternalizzate e override via -e JAVA_OPTS=...
ENV JAVA_OPTS="-Xmx512m -Xms256m -XX:+UseContainerSupport -Djava.security.egd=file:/dev/./urandom"

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

USER tomcat

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=10s --start-period=90s --retries=3 \
    CMD wget -qO- http://localhost:8080/ > /dev/null || exit 1

ENTRYPOINT ["/entrypoint.sh"]
