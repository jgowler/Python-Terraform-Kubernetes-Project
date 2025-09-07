# Deploy the flask app to Kubernetes:

In this step I will be deploying the image to Kubernetes and have it available using nodePort service.

## 1. Create the deployment yaml file:

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: flask-users-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: flask-users-app
  template:
    metadata:
      labels:
        app: flask-users-app
    spec:
      containers:
        - name: flask-users-app
          image: jgowler/flask-users-app:1.0
          ports:
            - containerPort: 5000
---
apiVersion: v1
kind: Service
metadata:
  name: flask-users-service
spec:
  selector:
    app: flask-users-app
  type: NodePort
  ports:
    - protocol: TCP
      port: 5000
      targetPort: 5000
      nodePort: 30080
```

The above deployment will create the app in two containers, and have them accessible using the nodePort service in the second half.


Once the containers were up in Kubernetes I tested by accessing the app via the nodePort service created in the deployment yaml file. At this time I only have one Master node and one Worker node and accessing the app from within the LAN, so i was able to access it using the node IP address:30080.

[With the app working from within Kubernetes the next step is to deploy using Terraform](https://github.com/jgowler/Python-Terraform-Kubernetes-Project/tree/main/Terraform-Files)
