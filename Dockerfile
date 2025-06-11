FROM jenkins/jenkins:jdk17

# Running as root to have an easy support for Docker
USER root

# Jenkins init scripts
COPY security.groovy /usr/share/jenkins/ref/init.groovy.d/

# Install Jenkins plugins
COPY plugins.txt /usr/share/jenkins/plugins.txt
#RUN /usr/local/bin/install-plugins.sh $(cat /usr/share/jenkins/plugins.txt) && \
#    mkdir -p /usr/share/jenkins/ref/ && \
#    echo lts > /usr/share/jenkins/ref/jenkins.install.UpgradeWizard.state && \
#    echo lts > /usr/share/jenkins/ref/jenkins.install.InstallUtil.lastExecVersion

RUN jenkins-plugin-cli -f /usr/share/jenkins/plugins.txt && \
echo 2.0 > /usr/share/jenkins/ref/jenkins.install.UpgradeWizard.state

RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
    apt-get install -y gnupg2 python3-pip sshpass git openssh-client && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean

RUN python3 -m pip install --upgrade pip cffi && \
    pip3 install ansible-core>=2.18.6 ansible>=11.6.0 ansible-lint==25.4.0 && \
    pip3 install mitogen jmespath && \
    pip install --upgrade pywinrm
RUN ansible-galaxy collection install ibm.ibm_zos_core \
    && ansible-galaxy collection install ibm.ibm_zhmc \
    && ansible-galaxy collection install ibm.ibm_zos_cics \
    && ansible-galaxy collection install ibm.ibm_zos_ims \
    && ansible-galaxy collection install ibm.ibm_zosmf

# Install Docker, kubectl and helm
#RUN apt-get -qq update && \
#    apt-get -qq -y install curl && \
#    curl -sSL https://get.docker.com/ | sh && \
#    curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl && \
#    chmod +x ./kubectl && \
#    mv ./kubectl /usr/local/bin/kubectl

