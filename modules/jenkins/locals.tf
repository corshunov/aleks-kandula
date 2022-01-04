locals {
  server_user_data = <<USERDATA
#!/bin/bash

sudo apt-get update -y

sudo apt install -y apt-transport-https ca-certificates curl 
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update -y
sudo apt-get install -y kubectl awscli

sudo apt install -y docker.io
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ubuntu

mkdir -p "/home/ubuntu/jenkins_home"
sudo chown -R 1000:1000 "/home/ubuntu/jenkins_home"

sudo docker run -d --restart=always -p 80:8080 -p 50000:50000 \
                -v "/home/ubuntu/jenkins_home:/var/jenkins_home" \
                -v "/var/run/docker.sock:/var/run/docker.sock" \
                --env "JAVA_OPTS='-Djenkins.install.runSetupWizard=false'" \
                jenkins/jenkins
USERDATA

  agent_user_data = <<USERDATA
#!/bin/bash

sudo apt-get update -y

sudo apt install -y apt-transport-https ca-certificates curl 
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update -y
sudo apt-get install -y kubectl awscli

sudo apt install -y docker.io git openjdk-8-jdk
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ubuntu
USERDATA
}
