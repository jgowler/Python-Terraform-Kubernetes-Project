# Create Dockerfile, Docker image, Test, upload to Dockerhub

1. After getting all the files together the next step was to set up the creation of the Docker image using a Dockerfile:

```
FROM python:3.12-slim

WORKDIR /app/

COPY requirements.txt .

RUN pip install --upgrade pip
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 5000

CMD ["python", "main.py"]
```

2. Build the Docker image using the following command:

`docker build -t flask-users-app .`

3. Created and ran a test container, exposing it on port 5000:

`docker run -p 5000:5000 flask-users-app`

4. Logged in to DOckerhub ready to upload the image to my repository. First needed to tag it:

`docker tag flask-users-app jgowler/flask-users-app:latest`

5. Pushed the image to the repo:

`docker push flask-users-app jgowler/flask-users-app:latest`

[On to Kubernetes](https://github.com/jgowler/Python-Terraform-Kubernetes-Project/tree/main/Kubernetes-Files)
Now that the image is created, tested, and uploaded the next step would be to run a test deployment using this image in Kubernetes.
