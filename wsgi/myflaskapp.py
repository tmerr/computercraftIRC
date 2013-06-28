from flask import Flask
from flask import request
app = Flask(__name__)

@app.route("/")
def hello():
    return "Hello World!"

@app.route("/status", methods=['GET'])
def status():
    return "Not implemented"

@app.route("/messages", methods=['GET'])
def messages():
    start = request.args.get('start', default=None, type=int)
    end = request.args.get('end', default=None, type=int)
    return "start:" + str(start) + " end:" + str(end)

@app.route("/users", methods=['GET'])
def users():
    return "Users go here"

@app.route("/ops", methods=['GET'])
def ops():
    return "Operators go here"

@app.route("/voiced", methods=['GET'])
def voiced():
    return "Voiced go here"

if __name__ == "__main__":
    app.run()

