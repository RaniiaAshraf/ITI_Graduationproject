# ***ITI Graduation Project***
## infrastructure used Terraform
- one VPC
- 2 private subnets
- 2 public subnets 
- nat gateway
 internet gateway
 - 2 network loadbalancers
 - Public intsance EC2
 - Private instancer for workernode
 - private route table
 - public route table 
 - EKS Cluster
 
 ## Build jenkins image from docker file contain docker client and kubectl
 ```
 FROM jenkins/jenkins:lts

USER root

# to install docker client
RUN apt-get update -qq \
    && apt-get install -qqy apt-transport-https ca-certificates curl gnupg2 software-properties-common
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -
RUN add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/debian \
   $(lsb_release -cs) \
   stable"
RUN apt-get update  -qq \
    && apt-get -y install docker-ce \
    && usermod -aG docker jenkins
    
# to install kubectl
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
RUN chmod +x ./kubectl
RUN mv ./kubectl /usr/local/bin
 ```
 ## Image 
   <div>
  <img src="https://github.com/RaniiaAshraf/ITI_Graduationproject/blob/main/screenshots/image.png" > 
  </div>
