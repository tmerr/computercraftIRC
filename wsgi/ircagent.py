#! /usr/bin/env python
#
# An IRC agent designed for a web api that allows minecraft computers to talk
# over IRC.  It has an interface to let the user get a slice of the last 500 
# messages sent over IRC as well as the users, ops and voiced members.
#
# For some reason the getUsers, getOps, and getVoices methods use unicode
# charactesr and that's something that should probably be fixed.
#
# Trevor Merrifield <trevorm42@gmail.com>

import irc.bot
import irc.client
import sys
import time
import threading

class IRCAgent(irc.bot.SingleServerIRCBot):
    def __init__(self, server, port, channel, nickname):
        irc.bot.SingleServerIRCBot.__init__(self, [(server, port)], nickname, nickname)
        self.target = channel
        self.messages = []
        self.messagelimit = 500
        self.lastmessageid = -1
        self.lock = threading.RLock()

    def getMessages(self, start=None, end=None):
        """Get a range of messages, by default selecting everything.
        Exludes messages sent by agent."""
        with self.lock:
            if (start != None):
                if (start < 0 or end < 0):
                    return []
                if self.lastmessageid > self.messagelimit:
                    start += self.lastmessageid - self.messagelimit
                    end += self.lastmessageid - self.messagelimit
            return self.messages[start:end]

    def sendMessage(self, text):
        """Send the text to the channel"""
        self.connection.privmsg(self.target, text)

    def getUsers(self):
        return self.channels[self.target].users()

    def getOps(self):
        return self.channels[self.target].opers()

    def getVoiced(self):
        return self.channels[self.target].voiced()

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
