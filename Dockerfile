FROM openjdk:8-jdk

ARG user=jenkins
ARG group=jenkins
ARG uid=2000
ARG gid=33

ENV JENKINS_HOME /home/jenkins

RUN useradd -d "$JENKINS_HOME" -u ${uid} -g ${gid} -m -s /bin/bash ${user}

RUN apt-get -y update && \
    apt-get -y install unzip tar curl openssh-server git ruby && \
    apt-get clean

# Install program to configure locales
RUN apt-get install -y locales
RUN dpkg-reconfigure locales && \
  locale-gen C.UTF-8 && \
  /usr/sbin/update-locale LANG=C.UTF-8

# Install needed default locale for Makefly
RUN echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen && \
  locale-gen

# Set default locale for the environment
ENV LC_ALL C.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8

RUN sed -i 's|session required pam_loginuid.so|session optional pam_loginuid.so|g' /etc/pam.d/sshd
RUN mkdir -p /var/run/sshd
RUN echo "jenkins:jenkins" | chpasswd
RUN mkdir /home/jenkins/.ssh ; chmod 700 /home/jenkins/.ssh ; printf "Host review.upaid.pl\n  KexAlgorithms +diffie-hellman-group1-sha1" >/home/jenkins/.ssh/config

USER jenkins

RUN mkdir "$JENKINS_HOME/.m2"

COPY files/settings.xml "$JENKINS_HOME/.m2"

USER root

EXPOSE 2022

CMD env | grep _SETTINGS_ >> /etc/environment && /usr/sbin/sshd -p 2022 -D
