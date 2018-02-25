# cod2install
Script, which can help you install cod2 servers on your VDS much faster.

I put here all steps, which I always do on my servers.


## About:
I recommend you to look this [link](https://killtube.org/showthread.php?2454-Work-in-progress-Setup-CoD2-on-your-ubuntu-14-04-server) first. 
And you will need to do all this points if you want to install cod2 server.

But! With my sh you can do all these (and another) steps much faster!

I measured the time from VDS purchase to full CoD2 installation with this .sh and it's less than 10 minutes (with uploading all cod2 files!).

So, any beginner, even he doesn't know anything about Linux can install CoD2 server on Linux now!


## So, what does this do:
All what you need to start cod2 server(s): 
- Updating and upgrading packets
- Install all libs for cod2
- Install some tools, which you will need (screen git make zip unzip geoip-bin)
- Ask you to install no-ip client (for dynamic dns. you will need this for gametracker.com)
- Creates new user for cod2 (will ask you about name)
- Creates all cod2 folders for all versions (it will use links, so you don't have to have main files for all versions)
- Ask you to upload main files by yourself or download it from my link or download it from torrent!
- Install the latest version of libcod (from VoroN's repo)
- Install cod2_lnxded for all versions
- Install YOUR servers for each version (ask you about your sh name, fs_game, config name, cracked and port)
- Make .sh files to launch your servers (for all CoD2 versions, what you need)


## cod2_lnxded versions:
This is the latest patched versions of CoD2 servers (from [this thread](https://killtube.org/showthread.php?1719-CoD2-Latest-cod2-linux-binaries-(1-0-1-2-1-3))):
- 1.0: cod2_lnxded_1_0a
- 1.2: cod2_lnxded_1_2c_patch_va_loc
- 1.3: cod2_lnxded_1_3_patch_va_loc


## And what do you need to start it:
0. Get VDS with Ubuntu 14.04 and log in as root there.
1. On command line, type in the following commands:
```sh
apt-get update
apt-get install git -y
git clone https://github.com/lonsofore/cod2install
cd cod2install
chmod +x start.sh
./start.sh
``` 
2. Enter your info, when it will ask!


## Support:
Community / Help: [killtube.org](http://killtube.org/forum.php)

Your questions: [killtube thread](https://killtube.org/showthread.php?2873-cod2install-Install-CoD2-on-your-VDS-much-faster!)

And please, tell me if something is wrong. My contacts:
- Steam: [lonsofore](http://steamcommunity.com/id/lonsofore/)
- Skype: wmsys_