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

## On Private machine
1- connect to public machine using key 
2- install docker 

## On public machine 
1- Install kubectl and aws cli packages
2- Configure aws 
3- copy .yml files 

## On jenkins create pipeline 
```
pipeline {
    agent any

    stages {
        stage('CI') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
                git 'https://github.com/RaniiaAshraf/Application'
                sh """
                cd ./application
                docker login -u ${USERNAME} -p ${PASSWORD}
                docker build . -f Dockerfile -t raniiaashraff/pythonapplication  --network host
                docker push raniiaashraff/pythonapplication
                """
                }
            }
        }
         stage('CD') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
                git 'https://github.com/RaniiaAshraf/Application'
                sh """
                docker login -u ${USERNAME} -p ${PASSWORD}
                pwd
                kubectl create namespace app
                kubectl apply -f /var/jenkins_home/workspace/pipeline/Deployment/redis-deployment.yaml -n app
                kubectl apply -f /var/jenkins_home/workspace/pipeline/Deployment/redis-service.yaml -n app
                kubectl apply -f /var/jenkins_home/workspace/pipeline/Deployment/configMap.yaml -n app
                kubectl apply -f /var/jenkins_home/workspace/pipeline/Deployment/deployment.yaml -n app
                kubectl apply -f /var/jenkins_home/workspace/pipeline/Deployment/load-balancer-service.yaml -n app
            
                """
                }
            }
        }
    }
}
```


