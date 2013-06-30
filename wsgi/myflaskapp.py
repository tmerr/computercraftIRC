from flask import Flask
from flask import request
from flask import jsonify
from ircagent import IRCAgent
import threading
from time import sleep

app = Flask(__name__)

@app.route("/")
def hello():
    return "You were never here."

@app.route("/status", methods=['GET'])
def status():
    return "Not implemented"

@app.route("/messages", methods=['GET'])
def messages():
    start = request.args.get('start', default=None, type=int)
    end = request.args.get('end', default=None, type=int)
    m = agent.getMessages(start, end)
    d = {}
    for row in m:
        d[row[0]] = {"nick": row[1], "message": row[2]}
    return jsonify(d)

@app.route("/sendmessage", methods=['GET', 'POST'])
def sendmessage():
    if request.method == 'POST':
        ip = request.remote_addr
        try:
            msg = request.data.encode('utf-8')
            print "sending message from " + ip + ": " + msg
            if agent.sendMessage(msg):
                return "success"
            else:
                print "failed message from " + ip + ", bot not connected"
                return "failure"
        except UnicodeDecodeError:
            print "failed message from " + ip
            return "failure"
    return "This page requires a POST request"

@app.route("/users", methods=['GET'])
def users():
    users = agent.getUsers()
    d = {}
    for idx, row in enumerate(users):
        d[idx] = row
    return jsonify(d)

@app.route("/ops", methods=['GET'])
def ops():
    ops = agent.getOps()
    d = {}
    for idx, row in enumerate(ops):
        d[idx] = row
    return jsonify(d)

@app.route("/voiced", methods=['GET'])
def voiced():
    voiced = agent.getVoiced()
    d = {}
    for idx, row in enumerate(voiced):
        d[idx] = row
    return jsonify(d)

if __name__ == "__main__":
    agent = IRCAgent("frogbox.es", 6667, "#coldstorm", "FTB")
    t = threading.Thread(target = agent.start)
    t.daemon = True
    t.start()
    app.run(host='0.0.0.0')
