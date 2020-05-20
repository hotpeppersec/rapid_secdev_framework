git clone https://github.com/hotpeppersec/rapid_secdev_framework.git

# make & python
sudo apt install -y make python3-pip
sudo ln -s /usr/bin/python3 /usr/local/bin/python

# docker
sudo apt -y install apt-transport-https ca-certificates curl gnupg-agent software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo apt-key fingerprint 0EBFCD88 | grep "9DC8 5822 9FC7 DD38 854A  E2D8 8D81 803C 0EBF CD88"
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
sudo apt update
sudo apt -y install docker-ce docker-ce-cli containerd.io
 sudo docker run hello-world

 sudo curl -L "https://github.com/docker/compose/releases/download/1.25.5/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
 sudo chmod 755 /usr/local/bin/docker-compose
 sudo usermod -aG docker $USER

 # User will need to log out and log in if group is added while logged in