# cod2install
Scripts, which can help you install cod2 servers on your VDS much faster.
I put here all steps, which I always do on my servers.

###About:
I recommend you to look this link first:
https://killtube.org/showthread.php?2454-Work-in-progress-Setup-CoD2-on-your-ubuntu-14-04-server
And you will need to do all this points if you want to install cod2 server.
But! With my sh you can do all this steps much faster!

###So, what does this do:
- Updating and upgrading packets
- Install all libs for cod2
- Install some tools, which you will need (screen git make zip unzip geoip-bin vim)
- Ask you to install no-ip client (for dynamic dns. you will need this for gametracker.com)
- Ask you to install web-server (lighttpd - small web-server - much smaller than apache)
- Ask you to install phpmyadmin (only if you installed web-server)
- Creates new user for cod2 (will ask you about name)
- Creates all cod2 folders for all versions (it will use links, so you don't have to have main files for all versions)
- Ask you to upload main files by yourself or download it from my link (from my link you can download it with more than 20 MB/s)
- Install the latest version of libcod (from VoroN's repo)
- Install cod2_lnxded for all versions
- Install YOUR servers for each version (ask you about your fs_game, config name and port)
- Make .sh files to launch your servers (for each cod2 version)
- Reboot your machine finally

###And what do you need to start it:
1. Get VDS with Ubuntu 14.04
2. Log in as root
3. Type: 
`apt-get install git -y`
`cd cod2install`
`chmod +x cod2.sh`
`./cod2.sh`
4. Enter your info, when it will ask!

Community / Help: http://killtube.org/forum.php