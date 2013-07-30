#!/usr/bin/env python

"""A web server that barbarically bridges IRC to HTTP to allow chat via
computercraft"""

__author__ = "Trevor Merrifield"

from flask import Flask
from flask import request
from flask import jsonify
from ircagent import IRCAgent
import threading
from time import sleep
import sys
import argparse

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

@app.route("/halfops", methods=['GET'])
def halfops():
    halfops = agent.getHalfOps()
    d = {}
    for idx, row in enumerate(halfops):
        d[idx] = row
    return jsonify(d)

@app.route("/voiced", methods=['GET'])
def voiced():
    voiced = agent.getVoiced()
    d = {}
    for idx, row in enumerate(voiced):
        d[idx] = row
    return jsonify(d)

def start(server, port, channel, nick, local, debug):
    global agent
    agent = IRCAgent(server, port, channel, nick)
    t = threading.Thread(target = agent.start)
    t.daemon = True
    t.start()
    if local or debug:
        host = '127.0.0.1'
    else:
        host = '0.0.0.0'
    if debug:
        app.debug = True
    app.run(host=host)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Bridge IRC and HTTP')
    parser.add_argument('server', type=str,
                    help = 'the name of the irc server e.g. irc.freenode.net')
    parser.add_argument('port', type=int, 
                    help = 'the port of the irc server e.g. 6667')
    parser.add_argument('channel', type=str,
                    help = 'the channel of the irc server e.g. #test')
    parser.add_argument('-nick', type=str, nargs='?',
                    default='mcagent',
                    help='the nick of the irc agent (default: mcagent)')
    parser.add_argument('--local', dest='local', action='store_const',
                    const=True, default=False,
                    help='make server only visible to localhost')
    parser.add_argument('--debug', dest='debug', action = 'store_const',
                    const=True, default=False,
                    help='use debug mode (forces --local)')
    args = parser.parse_args()
    start(args.server, args.port, args.channel, args.nick, args.local,
            args.debug)
