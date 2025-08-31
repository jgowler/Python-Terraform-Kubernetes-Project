# Create Flask app:

1. Created a simple Flask app to respond to GET requests. It will present a simple homepage, but when navigating to "/users" it will return all 50 of the current entries. There is also another function to return a specific user by user id using "/users/<user_id>" (such as "/users/15").

2. Ran the app locally to confirm. Once this was working as intended added the following to the end to make sure it can listen on all interfaces when testing with Docker:

`app.run(host="0.0.0.0", port=5000, debug=True)`

3. Ran pip freeze from my UV venv to ensure the necessary packages were included:
`uv pip freeze > requirements.txt`

[With this all tested and ready it is now on to the Docker testing part](https://github.com/jgowler/Python-Terraform-Kubernetes-Project/tree/main/Docker-Files)
