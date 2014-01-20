ComputercraftIRC
================


This is an IRC client for computercraft that works much like any other you would run
on a real desktop. Everything you need to get started is in the most recent release.
It contains a lua script and a web server that provides a means for said script to talk to IRC.  
Screenshots: [[1]](http://i.imgur.com/M3vxuOX.png)[[2]](http://i.imgur.com/IBxLMax.png)


###Running from source
1. Install python 2.7 and setuptools
2. pip install irc and cyclone
3. Modify site-packages/irc/buffer.py line 80 so that `errors = 'replace'`.  This way the client won't crash when it faces strange text encodings.
4. Unzip ComputerCraft zip, cd into ComputerCraft dir
5. Copy computercraftIRC/lua/claent.lua to assets/computercraft/lua/rom/programs/irc
6. Copy computercraftIRC/lua/JSON.lua to assets/computercraft/lua/rom/JSON
7. create zip, zip -r ComputerCraft *
8. Move ComputerCraft.zip into minecraft mod dir.
3. Forward port 5000 on your router (if you want to use this on remote computercraft servers)
4. Run server.py (use -h to see the parameters)
