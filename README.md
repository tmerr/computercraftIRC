ComputercraftIRC
================
Author: Trevor Merrifield (trevorm42@gmail.com)

####What it does
This lets a computercraft computer run an IRC client. The client can connect to an IRC channel, show
it on screen and send messages to it.

####Screenshots
http://i.imgur.com/IBxLMax.png  
http://i.imgur.com/M3vxuOX.png

####How?
The tricky part is that computercraft computers can't talk directly over IRC. We get around that by
bridging the IRC connection to HTTP with a program that runs on your real computer. So there are two
parts to get this running.
* The server (that runs on the real computer) and  
* The client (that runs on the computercraft computer).

Quick start
===========

####Server

1. Install python 2.7, irclib 8.3, and Flask
2. In irclib, modify buffer.py modify line 80 so that errors = 'replace'.  This way the client won't crash when it faces strange text encodings.
3. Forward port 5000 on your router (if you want to use this on remote computercraft servers)
4. Run myflaskapp.py (use -h to see the parameters)

####Client

You will need an advanced computer next to a large advanced monitor. At the terminal enter:

    pastebin get cT6943Sp client
    edit client
    
At the top of client make sure you set MONITORSIDE, REMOTE and REMOTEDOMAIN. Now run

    client
    
And it should start up.

License
=======

All code is licensed under the MIT License with the exception of lua/JSON.lua which is copyright Jeffrey Friedl (http://regex.info/blog/lua/json).
    
    The MIT License (MIT)
    
    Copyright (c) 2013 Trevor Merrifield
    
    Permission is hereby granted, free of charge, to any person obtaining a copy of
    this software and associated documentation files (the "Software"), to deal in
    the Software without restriction, including without limitation the rights to
    use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
    the Software, and to permit persons to whom the Software is furnished to do so,
    subject to the following conditions:
    
    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.
    
    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
    FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
    COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
    IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
    CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
