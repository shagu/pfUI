# pfUI

An AddOn for World of Warcraft (1.12.1), mostly known as "Vanilla", which aims to be a full replacement for the original interface. The design is highly inspired by TukUI and ElvUI, bringing modern features and a minimalistic style that's easy to use right from the start. It is entirely written from scratch without any inclusion of third-party addons or libraries.

This is **not** an addon-pack like [ShaguUI](http://shagu.org/shaguui/), however, there will be support for external addons like MobHealth3 and HealComm, but they will never be shipped within the package.

## Screenshots

<img src="http://mephis.he-hosting.de/shaguaddons/pfUI/mmobase/screen.jpg" align="right" width="48.87%">
<img src="http://mephis.he-hosting.de/shaguaddons/pfUI/mmobase/moveit.jpg" width="48.87%">
<img src="http://i.imgur.com/xo060dZ.jpg" align="right" width="48.87%">
<img src="http://i.imgur.com/gGnVtP6.jpg" width="48.87%">

## Installation
1. Download **[Latest Version](https://github.com/shagu/pfUI/archive/master.zip)**
2. Unpack the Zip file
3. Rename the folder "pfUI-master" to "pfUI"
4. Copy "pfUI" into Wow-Directory\Interface\AddOns
5. Restart Wow

## Commands

    /pfui         Open the configuration GUI
    /gm           Open the ticket Dialog
    /rl           Reload the whole UI
    /focus        Creates a Focus-Frame for the current target
    /clearfocus   Clears the Focus-Frame

## Languages
pfUI supports and contains language specific code for the following gameclients.
* English (enUS)
* Korean (koKR)
* French (frFR)
* German (deDE)
* Chinese (zhCN)
* Spanish (esES)
* Russian (ruRU)

## Recommended Addons
* [HealComm](https://github.com/Aviana/HealComm/releases) Visual representation of incoming heals
* [WIM](http://addons.us.to/addon/wim), [WIM (continued)](https://github.com/shirsig/WIM) Give whispers an instant messenger feel
* [MobHealth3](http://addons.us.to/addon/mobhealth) Estimates a mob's health

## Other Addons
* [DPSMate](https://github.com/Geigerkind/DPSMate) An advanced combat analyzation tool
* [DebuffTimers](https://github.com/shagu/DebuffTimers) Timer Overlays for enemy debuffs
* [Clique](https://github.com/shagu/Clique) Simply powerful click-casting interface
* [Clean_Up](https://github.com/shirsig/Clean_Up) Automatically stacks and sorts your items.

## FAQ
**What does "pfUI" stand for?**  
The term "*pfui!*" is german and simply stands for "*pooh!*", because I'm not a
big fan of creating configuration UI's, especially not via the Wow-API
(you might have noticed that in ShaguUI).

**How can I donate?**  
You can't. I'm doing this for fun. Enjoy!

**How do I report a Bug?**  
Please provide as much information as possible in the [Bugtracker](https://github.com/shagu/pfUI/issues).
If there is an error message, provide the full content of it. Just telling that "there is an error" won't help any of us.
Please consider adding additional information such as: since when did you got the error,
does it still happen using a clean configuration, what other addons are loaded and which version you're running.
When playing with a non-english client, the language might be relevant too. If possible, explain how people can reproduce the issue.

**How can I contribute?**  
Report Errors, Issues and Feature Requests in the [Bugtracker](https://github.com/shagu/pfUI/issues).
Please make sure to have the latest version installed and check for conflicting addons beforehand.

**Can I use Clique with pfUI?**  
A pfUI compatible version of Clique can be found [Here](https://github.com/shagu/Clique/releases). If you want to keep your current version of Clique, you'll have to apply this [Patch](https://github.com/shagu/Clique/commit/a5ee56c3f803afbdda07bae9cd330e0d4a75d75a).

**How do I show the Damage- and Threatmeter Dock?**  
If you enabled the "dock"-feature for your external (third-party) meters such as DPSMate or KTM, then you'll be able to toggle between them and the Right Chat by clicking on the ">" symbol on the bottom-right panel.

**How can I enable mouseover cast?**  
Create a macro with "/pfcast SPELLNAME". If you also want to see the cooldown, You might want to add "/run if nil then CastSpellByName("SPELLNAME") end" on top of the macro.

**Everything from scratch?! Are you insane?**  
Most probably, yes.
