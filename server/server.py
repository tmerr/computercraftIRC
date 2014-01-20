#!/usr/bin/env python2.7

"""A web server that barbarically bridges IRC to HTTP to allow chat via
computercraft"""

__author__ = "Original by Trevor Merrifield, modified by Koaps"

import sys
import time
import json
import argparse
import threading
import cyclone.web
import cyclone.escape
from twisted.python import log
from twisted.internet import reactor

from ircagent import IRCAgent

class Application(cyclone.web.Application):
    def __init__(self):

        handlers = [
            (r"/", MainHandler),
            (r"/status", StatusHandler),
            (r"/messages", MessagesHandler),
            (r"/sendmessage", SendMessageHandler),
            (r"/users", UsersHandler),
            (r"/ops", OpsHandler),
            (r"/halfops", HalfopsHandler),
            (r"/voiced", VoicedHandler),
        ]
        settings = dict(
            debug=debugmode,
        )
        cyclone.web.Application.__init__(self, handlers, **settings)


class BaseHandler(cyclone.web.RequestHandler):
    def initialize(self):
        self


class MainHandler(BaseHandler):
    def get(self):
        self.write('You were never here.')


class StatusHandler(BaseHandler):
    def get(self):
        self.write('Not implemented')


class MessagesHandler(BaseHandler):
    def get(self):
        start = self.get_argument("start", default=None)
        start = start if start else None
        end = self.get_argument("end", default=None)
        end = end if end else None
        print "Start: %s , End: %s" % (start,end)
        m = agent.getMessages(start, end)
        d = {}
        for row in m:
            d[row[0]] = {"nick": row[1], "message": row[2]}
        self.write(json.dumps(d))


class SendMessageHandler(BaseHandler):
    def get(self):
        self.write("This page requires a POST request")

    def post(self):
        agent.sendMessage(self.get_argument("msg"))


class UsersHandler(BaseHandler):
    def get(self):
        users = agent.getUsers()
        d = {}
        for idx, row in enumerate(users):
            d[idx] = row
        self.write(json.dumps(d))


class OpsHandler(BaseHandler):
    def get(self):
        ops = agent.getOps()
        d = {}
        for idx, row in enumerate(ops):
            d[idx] = row
        self.write(json.dumps(d))


class HalfopsHandler(BaseHandler):
    def get(self):
        halfops = agent.getHalfOps()
        d = {}
        for idx, row in enumerate(halfops):
            d[idx] = row
        self.write(json.dumps(d))


class VoicedHandler(BaseHandler):
    def get(self):
        voiced = agent.getVoiced()
        d = {}
        for idx, row in enumerate(voiced):
            d[idx] = row
        self.write(json.dumps(d))


def start(server, port, channel, nick, local, debug):
    global agent, debugmode
    debugmode = False
    agent = IRCAgent(server, port, channel, nick)
    t = threading.Thread(target = agent.start)
    t.daemon = True
    t.start()
    if local or debug:
        host = '127.0.0.1'
    else:
        host = '0.0.0.0'
    if debug:
        debugmode = True
    reactor.listenTCP(5000, Application())
    reactor.run()


if __name__ == "__main__":
    log.startLogging(sys.stdout)
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
