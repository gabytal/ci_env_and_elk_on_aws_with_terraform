

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
    VPC, Subnet, InternetGW,  RouteTable,  Security Group


##  Application Layer
* Docker container
    * Python 3.9 Docker image
      * Python Modules:
        * Flask 1.1.4 - for the API
        * elasticsearch 7.7.0 - for Log shipping to ELK
        * marshmallow 3.13.0 - for request data validations
        

## API Features:
  * supports POST requests
    * supported data type: application/json
    supported keys:
      * "log_type": STR
      + "message": STR
      * "version": INT
    
      
  * Advance API Application Logging
    

  * Logs can be viewed through container logs 


    
  * Application Log shipping ability to ELK cluster



### All components provisioned With

* Terraform  v1.0.5
  *  aws v3.55.0 provider 



-----------------------------------------



### Provisioning Process

The first thing will be to create the environment.
1. clone the Terraform GitHub repo (use SSH Key)
  ```sh
  git git clone git@github.com:gabytal/flask_api_and_elk_on_aws_with_terraform.git --config core.sshCommand="ssh -i ~.ssh/private_key"
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

---

### CI-CD Process 
### Pipeline stages:
 * Clone Git Repo
 * Build new docker image
 * Test the API
 * Push Artifact version at ECR Repo  
 * Deploy the Artifact to the production server

###Usage
#### This process needs to be executed each time a new version of the API is ready.
in a better world, this ci-cd script will be replaced with a Jenkins pipeline.

1. Get CI Machine IP from Terraform
   ```sh
   ci_machine = $(terraform output ci-prod-machine-ip)
   ```
2. SSH to the CI machine 
   ```sh
   ssh ubuntu@$ci_machine -i ~.ssh/private_key
   ```
3. Configure AWS Credentials (needed to Push the Artifact to ECR)
   ```sh
   aws configure
   ```
      
3. Clone the Flask-API GitHub Repo to the CI machine
   ```sh
    git clone https://github.com/gabytal/flask_api.git
    cd flask_api/
   ```
4. Set permissions to the required files
   ```sh
     chmod 555 ci-cd.sh test_api_functionality.sh
   ```
5. Execute the ci-cd.sh script.
    ```sh
    sudo./ci-cd.sh <VERSION> <ELK_HOST> <ECR_REPO>
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
