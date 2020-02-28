FROM ubuntu:18.04

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
        ghostscript \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && locale-gen en_US.UTF-8 \

# add user running Tomcat and DepositOnce
RUN useradd -u $userid dspace

ENV CATALINA_HOME="/usr/local/tomcat" \
    PATH="/usr/local/tomcat/bin:$PATH" \
    TOMCAT_MAJOR_VERSION=7 \
    TOMCAT_MINOR_VERSION=7.0.100 \
    APACHE_MIRROR="https://archive.apache.org/dist"

# install Tomcat
RUN wget -q --no-check-certificate "${APACHE_MIRROR}/tomcat/tomcat-${TOMCAT_MAJOR_VERSION}/v${TOMCAT_MINOR_VERSION}/bin/apache-tomcat-${TOMCAT_MINOR_VERSION}.tar.gz" -O /tmp/tomcat.tgz \
    && tar xzf /tmp/tomcat.tgz -C /tmp \
    && mv /tmp/apache-tomcat-${TOMCAT_MINOR_VERSION} $CATALINA_HOME \
    && rm /tmp/tomcat.tgz \
    && chown -R dspace $CATALINA_HOME

RUN sed -i -re 's#(<policy domain="resource"[^>]+>)#<!-- \1 -->#g' /etc/ImageMagick-6/policy.xml \
    && sed -i -re 's#<policy domain="coder" rights="[^"]*" pattern="PDF" />#<policy domain="coder" rights="read|write" pattern="PDF" />#g' /etc/ImageMagick-6/policy.xml \
    && GS_VERSION=$(gs --version) && cp /usr/share/ghostscript/${GS_VERSION}/iccprofiles/default_cmyk.icc /usr/share/ghostscript/${GS_VERSION}/iccprofiles/default_rgb.icc /usr/share/ghostscript/

WORKDIR $CATALINA_HOME

EXPOSE 8080

ENV JAVA_OPTS="-Xmx2G -Xms64M -Dfile.encoding=UTF-8"

VOLUME "$CATALINA_HOME/conf"
VOLUME "$CATALINA_HOME/webapps"

USER dspace

CMD ["catalina.sh", "run"]
