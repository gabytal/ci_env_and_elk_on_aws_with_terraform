

  <h2 align="left">CI-CD environment on AWS with Terraform</h3>



---

### About The Project

This is a full CI\CD System for Docker containers that hosts API.

all system components managed by Terraform


##  Infrastructure Layer

*  Machines Components:
     * CI Machine (EC2 VM with Docker).   functioning also as a Prod machine for demonstration


*  Logs  Components:
     * AWS managed ELK Cluster


*  Versioning Components:
      * AWS ECR docker repository


*  Network Components:
      * VPC, Subnet, InternetGW,  RouteTable,  Security Group
    


### All components provisioned With

* Terraform  v1.0.5
  *  aws v3.55.0 provider 
    

-----------------------------------------


### Provisioning Process

The first thing will be to create the environment.
1. clone the Terraform GitHub repo (use SSH Key)
  ```sh
  git clone git@github.com:gabytal/flask_api_and_elk_on_aws_with_terraform.git --config core.sshCommand="ssh -i ~.ssh/private_key"
  ```
2. cd to terraform folder
  ```sh
  cd terraform
  ```
3. initialize Terraform
  ```sh
  terraform init
  ```
3. execute Terraform plan
  ```sh
  terraform plan
  ```
4. apply Terraform
  ```sh
  terraform apply
  ```

4. get dynamic variables from Terraform
  ```sh
  terraform output
  ```

#
### Connect to Kibana:
#### In order to connect to Kibana  from outside the VPC, we will need to create a SSH Tunnel to the CI-Machine

1. cd to the ssh_tunnel config file location
    ```sh
    cd ssh_tunnel/
    ```
   
2. change the hostname in the file to the IP of the ci machine
    ```sh
    sed -i 's/CHANGEME/<CI_MACHINE_IP>/g' ssh_tunnel/config
    ```
   
3. start the ssh tunnel using the config file
    ```sh
    ssh -N estunnel -v
    ```
4. access from local browser - 
    ```sh
    http://localhost:9200/_plugin/kibana/app/kibana
    ```       
#

Created by Gaby Tal
