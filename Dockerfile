FROM jenkins:1.642.2

COPY plugins.txt /usr/share/jenkins/plugins.txt
RUN /usr/local/bin/plugins.sh /usr/share/jenkins/plugins.txt

#Copy plugins
COPY plugins/*.hpi /usr/share/jenkins/ref/plugins/

COPY config/jenkins.properties /usr/share/jenkins/

# remove executors in master
COPY config/*.groovy /usr/share/jenkins/ref/init.groovy.d/

# lets configure and add default jobs
COPY config/*.xml $JENKINS_HOME/

USER root
COPY start.sh /root/
COPY postStart.sh /root/
RUN chown -R jenkins:jenkins $JENKINS_HOME/

ENV JAVA_OPTS="-Djava.util.logging.config.file=/var/jenkins_home/log.properties -Ddocker.host=unix:/var/run/docker.sock"

EXPOSE 8000
# Date : 23 Feb 2016
# Principle, clone the /var/jenkins_home/ area into a ref area
# Allowing to map this area to a persistent storage :
#   When mapped to an empty area, then fill it with the mandatory files from the ref area.
#
RUN cp -r /var/jenkins_home/ /var/ref_jenkins_home
RUN rm -rf /var/jenkins_home/*
RUN sed -i '2iif [ ! -f "/var/jenkins_home/config.xml" ]; then cp -r /var/ref_jenkins_home/* /var/jenkins_home/;fi' /root/start.sh

ENTRYPOINT ["/root/start.sh"]
