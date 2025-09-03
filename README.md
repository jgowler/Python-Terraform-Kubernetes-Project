# Project: Create a Python Flask app hosted in Kubernetes deployed using Terraform

---

## Objectives:
1. To set up a Master and Worker node on VM's - Complete, one Master node and one Worker node
2. Create a Python Flask application to return some information in response to a GET command (build upon this to include other requests)
3. Create a Dockerfile and use this to create the Docker image to deploy to cluster.
4. Write the Kubernetes files to deploy the above image to be run from the Worker node.
5. Create the Terraform deployment to deploy the app remotely using variables defined.

---

## How I set up the K8s nodes:
1. Created 2 Linux Server VM's (Ubuntu Server 24.04.3).
2. Ran the following script on the Master node:
```bash
#!/bin/bash

### Set up containerd:
sudo apt update
sudo apt-get install -y containerd

# create /etc/containerd directory for containerd configuration
sudo mkdir -p /etc/containerd

# Generate the default containerd configuration
containerd config default \
| sed 's/SystemdCgroup = false/SystemdCgroup = true/' \
| sed 's|sandbox_image = ".*"|sandbox_image = "registry.k8s.io/pause:3.10"|' \
| sudo tee /etc/containerd/config.toml > /dev/null

# Restart containerd to apply the configuration changes
sudo systemctl restart containerd

# disable swap
sudo swapoff -a

### Kubeadm, kubelet, and kubectl:
sudo apt update

# install apt-transport-https ca-certificates curl and gpg packages using 
sudo apt-get install -y apt-transport-https ca-certificates curl gpg

# create a secure directory for storing GPG keyring files 
sudo mkdir -p -m 755 /etc/apt/keyrings

# download the k8s release gpg key FOR 1.33
sudo curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.33/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg


# Download and convert the Kubernetes APT repository's GPG public key into
# a binary format (`.gpg`) that APT can use to verify the integrity
# and authenticity of Kubernetes packages during installation. 
# This overwrites any existing configuration in 
# /etc/apt/sources.list.d/kubernetes.list FOR 1.33 
# (`tee` without `-a` (append) will **replace** the contents of the file)
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.33/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

# update packages in apt 
sudo apt-get update

apt-cache madison kubelet
apt-cache madison kubectl
apt-cache madison kubeadm

# After running the above select the version of each and assign to the below environment variable:
KUBE_VERSION="1.33.2-1.1"

# install kubelet, kubeadm, and kubectl at version 1.33.2-1.1
sudo apt-get install -y kubelet=$KUBE_VERSION kubeadm=$KUBE_VERSION kubectl=$KUBE_VERSION

# hold these packages at version if you wish
sudo apt-mark hold kubelet kubeadm kubectl

### Enable IP forwarding:
# enable IP packet forwarding on the node, which allows the Linux kernel 
# to route network traffic between interfaces. 
# This is essential in Kubernetes for pod-to-pod communication 
# across nodes and for routing traffic through the control plane
# or CNI-managed networks
sudo sysctl -w net.ipv4.ip_forward=1

# uncomment the line in /etc/sysctl.conf enabling IP forwarding after reboot
sudo sed -i '/^#net\.ipv4\.ip_forward=1/s/^#//' /etc/sysctl.conf

# Apply the changes to sysctl.conf
# Any changes made to sysctl configuration files take immediate effect without requiring a reboot
sudo sysctl -p

########################################
# ⚠️ WARNING ONLY ON THE CONTROL PLANE #
#######################################
# Initialize the cluster specifying containerd as the container runtime, ensuring that the --cri-socket argument includes the unix:// prefix
# containerd.sock is a Unix domain socket used by containerd
# The Unix socket mechanism is a method for inter-process communication (IPC) on the same host.
sudo kubeadm init --pod-network-cidr=192.168.0.0/16 --cri-socket=unix:///run/containerd/containerd.sock

## After this step the join command will be shown on screen along with the below information:

# ONLY ON CONTROL PLANE (also in the output of 'kubeadm init' command)
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

########################################
# HOW TO RESET IF NEEDED
# sudo kubeadm reset --cri-socket=unix:///run/containerd/containerd.sock
# sudo rm -rf /etc/kubernetes /var/lib/etcd
########################################

# Node will show as NotReady, set up either Flannel or Calico to resolve this:

# Flannel:
# ONLY FOR FLANNEL: Load `br_netfilter` and enable bridge networking
# ONLY FOR FLANNEL: echo "br_netfilter" | sudo tee /etc/modules-load.d/br_netfilter.conf
# install flannel
kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml


# Calico:
# install calico
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.0/manifests/calico.yaml



# Install the Tigera Calico CNI operator and custom resource definitions
# kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.28.0/manifests/tigera-operator.yaml

# Install Calico CNI by creating the necessary custom resource
# kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.28.0/manifests/custom-resources.yaml


```
4. Set up SSH keys to each VM:

`(Local to Master node) ssh-keygen -t ed25519 -C PC-to-K8sMaster -f pc-to-master`
`(Local to Master node) ssh-copy-id -i pc-to-master.pub <user>@<nodeipaddress>`
The same was done for the Worker node, changing relevent information.

6. Checked that the Worker node could be seen from the Master node by running `kubectl get nodes` and seeing it listed there.

---

## What is next?

[Create the Python Flask application](https://github.com/jgowler/Python-Terraform-Kubernetes-Project/tree/main/Python-Files)

With the nodes set up the next objective will be to create the first iteration of the Flask application. This will be tested using Docker locally once the Dockerfile is created and a Docker image is ready.
