FROM eclipse-temurin:17-jre-alpine
RUN apk add --no-cache wget unzip
RUN wget -q "https://ec.europa.eu/cefdigital/artifact/repository/esignaturedss/eu/europa/ec/joinup/sd-dss/dss-demo-bundle/6.4+20260415/dss-demo-bundle-6.4+20260415.zip" \
    -O /tmp/dss.zip && \
    unzip /tmp/dss.zip -d /app && \
    rm /tmp/dss.zip
WORKDIR /app/dss-demo-bundle-6.4
RUN mkdir -p apache-tomcat-11.0.21/temp/dss-tsl-loader && \
    wget -q "https://ec.europa.eu/tools/lotl/eu-lotl.xml" \
    -O apache-tomcat-11.0.21/temp/dss-tsl-loader/eu-lotl.xml
RUN sed -i 's/port="8005"/port="-1"/' apache-tomcat-11.0.21/conf/server.xml
RUN sed -i 's/address="127.0.0.1"//g' apache-tomcat-11.0.21/conf/server.xml
EXPOSE 8080
CMD ["sh", "-c", "JAVA_OPTS='-Xmx350m -Xms128m' && export JAVA_OPTS && sh apache-tomcat-11.0.21/bin/catalina.sh run"]