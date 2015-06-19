FROM ubuntu:14.04

RUN apt-get update
RUN apt-get install -y openssh-server vim supervisor git subversion
RUN mkdir /var/run/sshd
RUN echo 'root:root' |chpasswd
RUN sed -ri 's/^PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config
RUN echo 'StrictHostKeyChecking no' >> /etc/ssh/ssh_config
RUN mkdir -p ~/.ssh && ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa && cp ~/.ssh/id_rsa.pub ~/.ssh/authorized_keys

RUN mkdir -p /home/workspace && cd /home/workspace && wget -nv  --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u45-b14/jdk-8u45-linux-x64.tar.gz && tar zxf jdk-8u45-linux-x64.tar.gz  && rm -f jdk-8u45-linux-x64.tar.gz && ln -s  jdk1.8.0_45/ java
RUN cd /home/workspace && wget -nv  http://mirror.bit.edu.cn/apache/maven/maven-3/3.3.3/binaries/apache-maven-3.3.3-bin.tar.gz && tar zxf apache-maven-3.3.3-bin.tar.gz  && rm -f apache-maven-3.3.3-bin.tar.gz && ln -s apache-maven-3.3.3 maven


COPY sshd.conf /etc/supervisor/conf.d/sshd.conf
COPY bashrc /tmp/bashrc
RUN cat /tmp/bashrc >> ~/.bashrc

ENV WORKSPACE /home/workspace
ENV JAVA_HOME $WORKSPACE/java
ENV PATH $JAVA_HOME/bin:$PATH
ENV CLASSPATH $JAVA_HOME/lib/*.jar:$JAVA_HOME/jre/lib/*.jar


EXPOSE 22
CMD /usr/bin/supervisord -n
