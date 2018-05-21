FROM ubuntu:16.04

LABEL MAINTAINER Le Anh Tuan "latuannetnam@gmail.com"

ENV JAVA_HOME       /usr/lib/jvm/java-8-oracle
ENV LANG            en_US.UTF-8
ENV LC_ALL          en_US.UTF-8

ENV SONAR_VERSION=7.1 \
    SONARQUBE_HOME=/opt/sonarqube \
    # Database configuration
    # Defaults to using H2
    SONARQUBE_JDBC_USERNAME=sonar \
    SONARQUBE_JDBC_PASSWORD=sonar \
    SONARQUBE_JDBC_URL=

# Http port
EXPOSE 9000

# Java installation
RUN apt-get update && \
  apt-get install -y --no-install-recommends locales  apt-utils && \
  locale-gen en_US.UTF-8 && \
  apt-get dist-upgrade -y && \
  apt-get --purge remove openjdk* && \
  echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | debconf-set-selections && \
  echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu xenial main" > /etc/apt/sources.list.d/webupd8team-java-trusty.list && \
  apt-key adv --keyserver keyserver.ubuntu.com --recv-keys EEA14886 && \
  apt-get update
RUN  apt-get install -y --no-install-recommends oracle-java8-installer oracle-java8-set-default
RUN  apt-get install -y curl unzip
RUN  apt-get clean all

RUN groupadd -r sonarqube && useradd -r -g sonarqube sonarqube

# SonarQube installation
# Source: https://github.com/SonarSource/docker-sonarqube/blob/master/7.1/Dockerfile
# grab gosu for easy step-down from root
RUN set -x \
    && curl -Lo /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/1.10/gosu-$(dpkg --print-architecture)" \
    && curl -Lo /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/1.10/gosu-$(dpkg --print-architecture).asc" \
    && export GNUPGHOME="$(mktemp -d)" \
    && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
    && gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
    && rm -rf "$GNUPGHOME" /usr/local/bin/gosu.asc \
    && chmod +x /usr/local/bin/gosu \
    && gosu nobody true

RUN set -x \
    # pub   2048R/D26468DE 2015-05-25
    #       Key fingerprint = F118 2E81 C792 9289 21DB  CAB4 CFCA 4A29 D264 68DE
    # uid                  sonarsource_deployer (Sonarsource Deployer) <infra@sonarsource.com>
    # sub   2048R/06855C1D 2015-05-25
    && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys F1182E81C792928921DBCAB4CFCA4A29D26468DE \
    && cd /opt \
    && curl -o sonarqube.zip -fSL https://sonarsource.bintray.com/Distribution/sonarqube/sonarqube-$SONAR_VERSION.zip \
    && curl -o sonarqube.zip.asc -fSL https://sonarsource.bintray.com/Distribution/sonarqube/sonarqube-$SONAR_VERSION.zip.asc \
    && gpg --batch --verify sonarqube.zip.asc sonarqube.zip \
    && unzip sonarqube.zip \
    && mv sonarqube-$SONAR_VERSION sonarqube \
    && chown -R sonarqube:sonarqube sonarqube \
    && rm sonarqube.zip* \
    && rm -rf $SONARQUBE_HOME/bin/*

VOLUME "$SONARQUBE_HOME/data"
WORKDIR $SONARQUBE_HOME

#Plugins
#Source: https://github.com/webdizz/docker-sonarqube-plugins/blob/master/Dockerfile
ENV FINDBUGS_PLUGIN_VERSION=3.7.0
RUN cd $SONARQUBE_HOME/extensions/plugins/ && \
	# Findbugs
	curl -Lo ./sonar-findbugs-plugin-${FINDBUGS_PLUGIN_VERSION}.jar \
	https://github.com/spotbugs/sonar-findbugs/releases/download/${FINDBUGS_PLUGIN_VERSION}/sonar-findbugs-plugin-${FINDBUGS_PLUGIN_VERSION}.jar

# Post configuration
COPY assets/run.sh $SONARQUBE_HOME/bin/
RUN chmod +x $SONARQUBE_HOME/bin/run.sh
COPY assets/sonar.properties $SONARQUBE_HOME/conf/

ENTRYPOINT ["./bin/run.sh"]