FROM ubuntu:16.04

ARG userid=1000

ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'

# install tools
RUN apt-get update \
    && apt-get install -y \
        openjdk-8-jdk \
        git ant maven \
        acl \
        wget \
        locales \
        imagemagick \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && locale-gen en_US.UTF-8

# add user running Tomcat and DepositOnce
RUN useradd -u $userid dspace

ENV CATALINA_HOME="/usr/local/tomcat" \
    PATH="/usr/local/tomcat/bin:$PATH" \
    TOMCAT_MAJOR_VERSION=7 \
    TOMCAT_MINOR_VERSION=7.0.82 \
    APACHE_MIRROR="https://archive.apache.org/dist"

# install Tomcat
RUN wget -q --no-check-certificate "${APACHE_MIRROR}/tomcat/tomcat-${TOMCAT_MAJOR_VERSION}/v${TOMCAT_MINOR_VERSION}/bin/apache-tomcat-${TOMCAT_MINOR_VERSION}.tar.gz" -O /tmp/tomcat.tgz \
    && tar xzf /tmp/tomcat.tgz -C /tmp \
    && mv /tmp/apache-tomcat-${TOMCAT_MINOR_VERSION} $CATALINA_HOME \
    && rm /tmp/tomcat.tgz \
    && chown -R dspace $CATALINA_HOME

WORKDIR $CATALINA_HOME

EXPOSE 8080

ENV JAVA_OPTS="-Xmx512M -Xms64M -Dfile.encoding=UTF-8"

VOLUME "$CATALINA_HOME/conf"
VOLUME "$CATALINA_HOME/webapps"

USER dspace

CMD ["catalina.sh", "run"]
