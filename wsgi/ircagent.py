#! /usr/bin/env python
#
# An IRC agent designed for a web api that allows minecraft computers to talk
# over IRC.  It has an interface to let the user get a slice of the last 500 
# messages sent over IRC as well as the users, ops and voiced members.
#
# Trevor Merrifield <trevorm42@gmail.com>

import irc.bot
import irc.client
import sys
import time
import threading

class IRCAgent(irc.bot.SingleServerIRCBot):
    def __init__(self, server, port, channel, nickname):
        irc.bot.SingleServerIRCBot.__init__(self, [(server, port)], nickname,
                nickname, reconnection_interval=30)
        self.target = channel
        self.nickname = nickname
        self.messages = []
        self.messagelimit = 500
        self.lastmessageid = -1
        self.lock = threading.RLock()

    def getMessages(self, start=None, end=None):
        """Get a range of messages, by default selecting everything.
        Exludes messages sent by agent."""
        if start == None:
            start = 0
        if end == None:
            end = self.lastmessageid + 1

        with self.lock:
            if (start < 0 or end < 0):
                return []
            if self.lastmessageid > self.messagelimit:
                start += self.lastmessageid - self.messagelimit
                end += self.lastmessageid - self.messagelimit
            return self.messages[start:end]

    def sendMessage(self, text):
        """Send the text to the channel"""
        if self.connection.is_connected():
            self.connection.privmsg(self.target, text)
            with self.lock:
                self.lastmessageid += 1
                self.messages.append((self.lastmessageid, self.nickname, text))
                if len(self.messages) > self.messagelimit:
                    self.messages.pop(0)
            return True
        else:
            return False

    def getUsers(self):
        channel = self.channels.get(self.target)
        if channel == None:
            return {}
        else:
            return channel.users()

    def getOps(self):
        channel = self.channels.get(self.target)
        if channel == None:
            return {}
        else:
            return channel.opers()

    def getHalfOps(self):
        channel = self.channels.get(self.target)
        if channel == None:
            return {}
        else:
            return channel.halfops()

    def getVoiced(self):
        channel = self.channels.get(self.target)
        if channel == None:
            return {}
        else:
            return channel.voiced()

    def on_welcome(self, connection, event):
        if irc.client.is_channel(self.target):
            connection.join(self.target)

    def on_join(self, connection, event):
        pass

    def on_disconnect(self, connection, event):
        sys.exit(0)

    def on_privmsg(self, connection, event):
        """Treat private messages like public but append pm to the sender
        nick"""
        msgsource = event.source
        
        nick = msgsource.split('!')[0]
        nick = "pm: " + nick
        body = event.arguments[0].split(":", 1)[0]

        with self.lock:
            self.lastmessageid += 1
            self.messages.append((self.lastmessageid, nick, body))
            if len(self.messages) > self.messagelimit:
                self.messages.pop(0)

    def on_pubmsg(self, connection, event):
        msgsource = event.source
        nick = msgsource.split('!')[0]
        body = event.arguments[0].split(":", 1)[0]

        with self.lock:
            self.lastmessageid += 1
            self.messages.append((self.lastmessageid, nick, body))
            if len(self.messages) > self.messagelimit:
                self.messages.pop(0)
