#!/bin/bash

# Install docker and add Docker user with permissions
sudo apt-get update
sudo apt install curl -y
curl https://get.docker.com | sudo bash
sudo useradd -m -s /bin/bash docker
sudo usermod -aG sudo docker
echo "docker installed successfully"
echo "downloading k8s"
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
echo "k8s downloaded successfully, validating binary..."
curl -LO "https://dl.k8s.io/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check
echo "installing k8s"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
kubectl version --client
kubectl cluster-info




# Install jenkins and add jenkins user with permissions

if type apt > /dev/null; then
    pkg_mgr=apt
    if [ $(uname -v) == *Debian* ]; then
      java="default-jre"
    else
      java="openjdk-11-jre"
    fi
elif type yum /dev/null; then
    pkg_mgr=yum
    java="java"
fi
echo "updating and installing dependencies"
sudo ${pkg_mgr} update
sudo ${pkg_mgr} install -y ${java} wget git > /dev/null
echo "configuring jenkins user"
sudo useradd -m -s /bin/bash jenkins
echo "downloading latest jenkins WAR"
sudo su - jenkins -c "curl -L https://updates.jenkins-ci.org/latest/jenkins.war --output jenkins.war"
echo "setting up jenkins service"
sudo tee /etc/systemd/system/jenkins.service << EOF > /dev/null
[Unit]
Description=Jenkins Server

[Service]
User=jenkins
WorkingDirectory=/home/jenkins
ExecStart=/usr/bin/java -jar /home/jenkins/jenkins.war

[Install]
WantedBy=multi-user.target
EOF
sudo systemctl daemon-reload
sudo systemctl enable jenkins
sudo systemctl restart jenkins
sudo su - jenkins << EOF
until [ -f .jenkins/secrets/initialAdminPassword ]; do
    sleep 1
    echo "waiting for initial admin password"
done
until [[ -n "\$(cat  .jenkins/secrets/initialAdminPassword)" ]]; do
    sleep 1
    echo "waiting for initial admin password"
done
echo "initial admin password: \$(cat .jenkins/secrets/initialAdminPassword)"
EOF

sudo usermod -aG sudo jenkins

#add docker and jenkins to sudoers
sudo sh -c "echo \"docker   ALL=(ALL:ALL) NOPASSWD: ALL\" >> /etc/sudoers"
sudo sh -c "echo \"jenkins   ALL=(ALL:ALL) NOPASSWD: ALL\" >> /etc/sudoers"