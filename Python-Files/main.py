from flask import Flask, jsonify
from users import users

app = Flask(__name__)

@app.route("/")
def welcome():
    return "Hello, this is the app"

@app.route("/users", methods=["GET"])
def userList():
    return users

@app.route("/users/<user_id>", methods=["GET"])
def getUser(user_id):
    key = f"user{user_id}"
    if key in users:
        return jsonify(users[key])
    else:
        return jsonify({"error": "User not found"}), 404

if __name__ == "__main__":
    app.run()
