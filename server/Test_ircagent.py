#! /usr/bin/env python

"""This is a manual test for the ircagent. The user needs to check that the
values are correct. The bot should join a channel and send 3 messages.  Then
it will pause for 10 seconds after which it will print the messages, users, ops
and voiced users."""

__author__ = "Trevor Merrifield"

from ircagent import IRCAgent
import time
import sys
from threading import Timer

SERVER = 'frogbox.es'
PORT = 6667
CHANNEL = '#buttstorm'
NICK = 'testbot666'

def main():
    agent = IRCAgent(SERVER, PORT, CHANNEL, NICK)
    print "IRCAgent connected"
    Timer(2, sendMessages, args=[agent]).start()
    Timer(10, printInfo, args=[agent]).start()
    print("This will take 10 seconds...")
    agent.start()
    print("It's over")

def sendMessages(agent):
    agent.sendMessage("Quick type things this is a test (please no kick)")
    agent.sendMessage("Bo0p be b0oP Bop")
    agent.sendMessage("Wu-Tang Forever")

def printInfo(agent):
    print "==Information=="
    print("Messages: ", agent.getMessages())
    print("Users: ", agent.getUsers())
    print("Ops: ", agent.getOps())
    print("Voiced: ", agent.getVoiced())
    agent.disconnect()

if __name__ == "__main__":
    main()
