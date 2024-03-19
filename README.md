Purpose
---
The purpose of this repository is to build a Docker image that will be used by by the Infra Utility ImageFactory GitHub repository to make a AWS Custom AMI.  This repository contains the Dockerfile that builds a Docker image that contains both Packer and Ansible.  Packer and Ansible are called in the .drone.yml file of Infra Utility ImageFactory GitHub repository.

![Alt text](images/infra-container-imagebuilder.png?raw=true "Drone CI Build")

How Build Is Run
---
The build of the Docker image is launched via a Pull Request (PR) in GitHub which triggers the build by Drone.  The build trigger is configured in the GitHub 
infra-container-imagebuilder repository -> Repository settings -> Webhooks setting.  Also, the repository has to be enabled in Drone in the Repositories -> infra-container-imagebuilder -> Settings -> General setting (bottom left is a button labelled Disable or Enable)

How to start Drone
---
On your Drone server perform the following from CLI:

1. First determine if Drone or Drone Runner are running

```
docker ps
```

2. If you do not see a container with image of drone/drone and drone/registry-plugin then you should start drone with the following commands:

```
cd /docker/drone
docker-compose pull && docker-compose down --remove-orphans && docker-compose rm && docker-compose up -d
```

How to run Drone CLI commands
---
https://docs.drone.io/cli/configure/

The command line tools interact with the server using REST endpoints. You will need to provide the CLI tools with the server addresses and your personal authorization token. You can find your authorization token in your Drone account settings (click your Avatar in the Drone user interface).

https://drone.sre.example.com/account

Example CLI Usage
---
```
$ export DRONE_SERVER=https://drone.sre.example.com
$ export DRONE_TOKEN=<DRONE_TOKEN>
$ drone info
```

How to look at Drone logs
---
$ docker container logs <Drone container id>

[Show Drone Logs](https://docs.drone.io/server/logging/)

$ docker logs <container name>

How to trigger a Drone build of Repository
---
Merge a Pull Request (PR) of the infra-container-imagebuilder repository.  Depending on how the repository's Branch permissions are configure the git merge may require both the developers and a reviewer's approval.

Monitor Drone build
---
Go to the Drone console (https://drone.sre.example.com/) and select Builds and then click on the desired build.

Update ECR
---
Use the following steps to authenticate and push an image to your repository. For additional registry authentication methods, including the Amazon ECR credential helper, see
[Reference]('https://docs.aws.amazon.com/AmazonECR/latest/userguide/Registries.html#registry_auth')

* 1.- Retrieve an authentication token and authenticate your Docker client to your registry.
Use AWS Tools for PowerShell:
```
$ (Get-ECRLoginCommand).Password | docker login --username AWS --password-stdin 123456789012.dkr.ecr.us-east-1.amazonaws.com
```
* 2.- Build your Docker image using the following command. For information on building a Docker file from scratch see the instructions
[Reference]('https://docs.aws.amazon.com/AmazonECS/latest/developerguide/docker-basics.html') You can skip this step if your image is already built:
```
$ docker build -t sre-team/imagebuilder .
```
* 3.- After the build completes, tag your image so you can push the image to this repository:
```
$ docker tag sre-team/imagebuilder:latest 123456789012.dkr.ecr.us-east-1.amazonaws.com/sre-team/imagebuilder:latest
```
* 4.- Run the following command to push this image to your newly created AWS repository:
```
$ docker push 123456789012.dkr.ecr.us-east-1.amazonaws.com/sre-team/imagebuilder:latest
```

Required Resources
---
The .drone.yml file uses the plugins/ecr plugin to create the Docker and store it in a AWS Elastic Container Registry (ECR) 123456789012.dkr.ecr.us-east-1.amazonaws.com.  ECR is a fully managed Docker container registry.