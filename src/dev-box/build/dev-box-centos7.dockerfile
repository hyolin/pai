# Copyright (c) Microsoft Corporation
# All rights reserved.
#
# MIT License
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
# documentation files (the "Software"), to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and
# to permit persons to whom the Software is furnished to do so, subject to the following conditions:
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED *AS IS*, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING
# BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
# DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

FROM centos:7

RUN yum -y install epel-release && yum clean all

RUN yum -y install python-pip && yum clean all

RUN yum install -y \
      nano \
      vim \
      joe \
      wget \
      curl \
      jq \
      gawk \
      psmisc \
      python \
      python-yaml \
      python-jinja2 \
      python-paramiko \
      python-urllib3 \
      python-tz \
      python-nose \
      python-prettytable \
      python-netifaces \
      python-devel \
      python-pip \
      python-mysqldb \
      openjdk-8-jre \
      openjdk-8-jdk \
      openssh-server \
      openssh-client \
      git \
      bash-completion \
      inotify-tools \
      rsync \
      realpath \
      net-tools && \
    mkdir -p /cluster-configuration &&\
    git clone https://github.com/hyolin/pai.git &&\
    pip install python-etcd docker kubernetes GitPython

WORKDIR /tmp

#ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
ENV JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.161-0.b14.el7_4.x86_64

RUN echo "source /usr/share/bash-completion/completions/git" >> ~/.bashrc

# Only node manager need this.#
RUN wget https://mirror.azure.cn/docker-ce/linux/static/stable/x86_64/docker-17.06.2-ce.tgz
RUN tar xzvf docker-17.06.2-ce.tgz
RUN mv docker/* /usr/local/bin/

# alert manager tool
RUN wget https://github.com/prometheus/alertmanager/releases/download/v0.15.2/alertmanager-0.15.2.linux-amd64.tar.gz
RUN tar xzvf alertmanager-0.15.2.linux-amd64.tar.gz
RUN mv alertmanager-0.15.2.linux-amd64/amtool /usr/local/bin

# install Azure CLI for deploy on  Azure AKS

RUN sh -c 'echo -e "[azure-cli]\nname=Azure CLI\nbaseurl=https://packages.microsoft.com/yumrepos/azure-cli\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/azure-cli.repo'

RUN yum install -y azure-cli

RUN sh -c 'echo -e "[kubernetes]\nname=Kubernetes\nbaseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/\nenabled=1\ngpgcheck=1\nrepo_gpgcheck=1\ngpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg" > /etc/yum.repos.d/azure-cli.repo'

RUN yum install -y kubectl

# reinstall requests otherwise will get error: `cannot import name DependencyWarning`
RUN echo y | pip uninstall requests && \
    echo y | pip install requests && \
    echo y | pip install docopt

RUN rm -rf /tmp/*

WORKDIR /
# checkout OpenPAI release branch at start-scrip
COPY build/start-script-centos7.sh /usr/local
RUN chmod u+x /usr/local/start-script.sh

CMD ["/usr/local/start-script.sh"]

