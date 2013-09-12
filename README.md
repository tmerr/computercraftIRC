ComputercraftIRC
================


This is an IRC client for computercraft that works much like any other you would run
on a real desktop. Everything you need to get started is in the most recent release.
It contains a lua script and a web server that provides a means for said script to talk to IRC.  
Screenshots: [[1]](http://i.imgur.com/M3vxuOX.png)[[2]](http://i.imgur.com/IBxLMax.png)


###Running from source
1. Install python 2.7, irclib 8.3, and Flask
2. In irclib, modify buffer.py line 80 so that `errors = 'replace'`.  This way the client won't crash when it faces strange text encodings.
3. Forward port 5000 on your router (if you want to use this on remote computercraft servers)
4. Run server.py (use -h to see the parameters)