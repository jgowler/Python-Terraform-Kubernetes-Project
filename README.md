# Project: Create a Python Flask app hosted in K3s deployed using Terraform

---

## Objectives:
1. To set up a Master and Worker node on VM's - Complete, one Master node and one Worker node
2. Create a Python Flask application to return some information in response to a GET command (build upon this to include other requests)
3. Create a Dockerfile and use this to create the Docker image to deploy to cluster.
4. Write the Terraform script to deploy the above image to be run from the Worker node.
5. Create a Python app that uses Requests (or httpx) to send GET requests to the app hosted in Kubernetes.

---

## How I set up the K3s nodes:
1. Created 2 Linux Server VM's (Ubuntu Server 24.04.3).
2. Ran the following script on the Master node:
```bash
#!/bin/bash

# Update the system
sudo apt-get update && sudo apt-get upgrade -y

# Install Docker
echo "Installing Docker..."
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update && sudo apt-get install -y docker-ce

# Install k3s with specified permissions for kubeconfig
echo "Installing k3s..."
sudo curl -sfL https://get.k3s.io | sh -s - --write-kubeconfig-mode 644

# Verify k3s installation
sudo k3s kubectl get nodes

# Add a taint to the controller node to prevent pods from being scheduled on it
sudo k3s kubectl taint nodes $(hostname) dedicated=controller:NoSchedule

echo "Controller node installation complete."

# Add current user to Docker group
sudo usermod -aG docker $USER
```
3. Set up the Worker node using the following. The IP address and token from the Master node will need to provided before running:
```bash
#!/bin/bash

# Update the system
sudo apt-get update && sudo apt-get upgrade -y

# Install Docker
echo "Installing Docker..."
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update && sudo apt-get install -y docker-ce

# Replace <controller-ip> with the IP address of your controller node
# Replace <token> with the token from your controller node
CONTROLLER_IP=<controller-ip>
TOKEN=<token>

# Install k3s agent and join the cluster
echo "Installing k3s agent..."
sudo curl -sfL https://get.k3s.io | K3S_URL=https://${CONTROLLER_IP}:6443 K3S_TOKEN=${TOKEN} sh -

# Verify the worker node is connected
sudo k3s kubectl get nodes

# Ensure firewall rules allow traffic to NodePort services
# (Adjust the port range as needed)
sudo ufw allow 30000:32767/tcp

echo "Worker node installation complete."
```
4. Set up SSH keys to each VM:
`(Local to Master node) ssh-keygen -t ed25519 -C PC-to-K8sMaster -f pc-to-master`
`(Local to Master node) ssh-copy-id -i pc-to-master.pub <user>@<nodeipaddress>`
The same was done for the Worker node, changing relevent information.
5. Checked that the Worker node could be seen from the Master node by running `kubectl get nodes` and seeing it listed there.

---

## What is next?

With the nodes set up the next objective will be to create the first iteration of the Flask application. This will be tested using Docker locally once the Dockerfile is created and a Docker image is ready.