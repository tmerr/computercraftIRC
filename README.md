computercraftIRC
================

Run IRC in computercraft through a web server bridging IRC to HTTP.  
Author: Trevor Merrifield (trevorm42@gmail.com)

Quick start
===========

1. Install python 2.7, irclib 8.3, and Flask
2. In irclib, modify buffer.py modify line 80 so that errors = 'replace'.  This way the client won't crash when it faces strange text encodings.
3. Forward port 5000 on your router
4. Run myflaskapp.py (use -h to see the parameters)
