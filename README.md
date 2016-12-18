# pfUI

An educational project for World of Warcraft (1.12) mostly known as "Vanilla" 
which aimes to be a full replacement for the original Wow interface. The design 
is highly inspired by TukUI and ElvUI (which I never used) as well as several 
other screenshots I found around the web during the last 10 years. 
It is completely written from scratch without any inclusion of 3rd party addons 
or libraries. This is **not** an addon-pack like 
[ShaguUI](http://shaguaddons.ericmauser.de/shaguui/) which means that no 
external Addons will be included. There will be support for external addons like 
MobHealth3 and HealComm, but they will be never shipped within the package.

**Notice**: *pfUI is still in early stages and under heavy development. 
Please report all bugs and errors in the 
[Bugtracker](https://github.com/shagu/pfUI/issues). 
Feature-Requests might not be processed right now.*

## Commands

    /pfui   Open the configuration GUI
    /gm     Open the ticket Dialog
    /rl     Reload the whole UI

## Languages
pfUI will support and contain language specific code for the following languages.
* English (enUS)
* French (frFR)
* German (deDE)
* Chinese (zhCN)
* Russian (ruRU)

## Screenshots
![Screenshot](http://mephis.he-hosting.de/shaguaddons/pfUI/mmobase/screen.jpg)

![Moving Frames](http://mephis.he-hosting.de/shaguaddons/pfUI/mmobase/moveit.jpg)

## Recommended Addons
* [DPSMate](https://github.com/Geigerkind/DPSMate) An advanced combat analyzation tool
* [HealComm](https://github.com/Aviana/HealComm/releases) Visual representation of incoming heals
* [WIM](http://addons.us.to/addon/wim), [WIM (continued)](https://github.com/shirsig/WIM) Give whispers an instant messenger feel
* [MobHealth3](http://addons.us.to/addon/mobhealth) Estimates a mob's health
* [Clean_Up](https://github.com/shirsig/Clean_Up-lib) Automatically stacks and sorts your items.

## Installation (common)
1. Download from Github as Zip, unpack and rename the folder pfUI-master to pfUI.
2. Copy "pfUI" to Wow-Directory\Interface\AddOns
3. Make sure to have the file "*Wow-Directory\Interface\AddOns\pfUI\pfUI.toc*"
4. Restart Wow

## Installation (unix)
	cd ~/Wow-Directory/Interface/AddOns && git clone http://github.com/shagu/pfUI.git

## FAQ
**What does "pfUI" stand for?**  
The term "*pfui!*" is german and simply stands for "*pooh!*", because I'm not a 
big fan of creating configuration UI's especially not via the Wow-API 
(you might have noticed that in ShaguUI). 

**How can I enable mouseover cast?**  
Create a macro with "/pfcast SPELLNAME". 

**How can I checkout the current state?**  
See Installation Section. But be aware that things might not work for you.

**When will it be ready?**  
I have no idea and no timeline yet. I'm working on it whenever I have motivation.

**Why do I get lots of LUA Errors?**  
Please disable all addons beside pfUI and check if you still get error messages. 
If the messages are gone, check one addon after the other and report conflicting 
addons in the [Bugtracker](https://github.com/shagu/pfUI/issues).

**How can I donate?**  
You can't. I'm doing that for fun. Enjoy!

**How can I contribute?**  
Report LUA-Errors and Issues in the [Bugtracker](https://github.com/shagu/pfUI/issues).

**Everything from scratch?! Are you insane?**  
Yes.
