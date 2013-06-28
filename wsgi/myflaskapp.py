from flask import Flask
from flask import request
app = Flask(__name__)

@app.route("/")
def hello():
    return "Hello World!"

@app.route("/messages", methods=['GET'])
def messages():
    start = request.args.get('start', default=None, type=int)
    end = request.args.get('end', default=None, type=int)
    return "start:" + start + " end:" + end

if __name__ == "__main__":
    app.run()

