locals {
  server_user_data = <<USERDATA
#!/bin/bash

sudo apt-get update -y

sudo apt install docker.io -y
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

sudo apt install docker.io git openjdk-8-jdk -y
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ubuntu
USERDATA
}
