# Deploy the app to Kubernetes using Terraform

## 1. Create the deployment script.

This looks very similar to the Kubernetes deployment YAML as it will use all the same information, only in a slightly different format.
To connect to the cluster from Terraform the Providers need to be specified in the main.tf file:

```
terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.20.0"
    }
  }
}
```

To access the cluster from my local machine i needed to include connection information, suchb as the API server IP and the certs:

```
provider "kubernetes" {
  host                   = var.k8s_server
  cluster_ca_certificate = base64decode(var.k8s_ca)
  client_certificate     = base64decode(var.k8s_client_cert)
  client_key             = base64decode(var.k8s_client_key)
}
```
### 1.a. Getting the info for the connection

To get the information needed to inpput into the variables for the connection I jumped onto the MAster node and viewed the contents of the admin.conf file:

`cat /etc/kubernetes/admin.conf`

From here, just copy and paste the information required.

<span style="color:red">NOTE: The values in the above are defined in the variables.tf file, but are overwritten by the terraform.tfvars file at the planning and deployment phase.</span>

## 2. Plan and Deploy

The nest step is to ensure Terraform can plan the deployment. This can be done using the following:

`terraform plan -var-file="terraform.tfvars"`

Once the plan has gone through OK it's time to deploy. On the master node I wanted to keep track of what was happening so ran the following to watch in real time:

`kubectl get pods -w` (-w = "watch")

from here, the pods began to appear!

## 3. Testing from local machine

Access to the pods was available from my local machine using `http://<node-ip>:30080/`. This returned the welcome page.
Access to the users: `http://<node-ip>:30080/users`.
Access to a specific user: `http://<node_ip>:30080/users/<user_id>`.

## 4. Destroy the deployment

Now that this has been tested and is working now is the time to tear it down again. This can be done by simply running `terraform destroy`. Terraform will check the state of the deployment and remove any resources it had created previously.

# Conclusion

This was a very simple project but was very helpful in allowing me to rasp all the steps required to making this work from start to finish. In working on this project I became more confident in the following areas:

1. Create a Python Flask application that responds to GET requests.
2. Deploy Kubernetes using Containerd and Calico.
3. Write Dockerfiles and create Docker images from them, to then be uploaded to Dockerhub.
4. Writing Kubernetes deployment files and deploying pods and services.
5. Designing Terraform deployment scripts that can be altered to access different clusters based on the information provided in the terraform.tfvars file.

If I were to improve on this I would write in more functionality to the Python app, and potentially work with a load balancer to allow a single IP address to be used externally to reach the app no matter the node it was hosted on.

All in all, I am very happy with how this turned out. I was expecting this to take much longer than it did as it was my first project but once I got going it all started to fall into place, especially translating the Kubernetes deployments to Terraform.

### If you have made it this far I would like to say thank you and I hope that it could help you with your own projects.