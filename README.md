# PalmGemPlucker
Palm PDB generator for reading Gemini offline with [Plucker](https://palmdb.net/app/plucker) for Palm OS

Wanting to read the new old web ([Gemini](https://gemini.circumlunar.space/docs/faq.gmi)) on your old newly revived Palm OS device?
This tool takes a list of your favorite gemini sites and spits out corresponding Plucker PDB files which you can use to read them offline on your Palm OS device.

## Prerequisites to have installed on your system
- pcre2grep (Ubuntu users can install it with apt-get install pcre2-utils)
- git
- pilot-xfer to transfer the generated PDB files

## Setup

Get the script:
```
wget https://raw.githubusercontent.com/captaintouch/palmGemPlucker/main/palmGemPlucker.sh
chmod +x palmGemPlucker.sh
```
Open up the script and configure your favorite gemsites along with your device info (port used for pilot-xfer and device width)

Once configured, just run ```./palmGemPlucker.sh``` from the path where you installed it

## Thanks

Based on [Kelbots](https://retro.social/@kelbot) original hotsync script, see [gempost](http://portal.mozz.us/gemini/gemini.cyberbot.space/gemlog/2023-05-26-sl10pdascript.gmi)

[GemGet](https://github.com/makew0rld/gemget)

[PyPlucker](https://github.com/lxmx/PyPlucker)
