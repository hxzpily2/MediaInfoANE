# MeiaInfoANE

Adobe Air Native Extension written in ActionScript 3 and C++ based on the MediaInfo libraries.

Sample included

![alt tag](https://raw.githubusercontent.com/tuarua/MediaInfoANE/master/screenshots/screenshot.png)

### Version
- 0.0.1 Win 32 and OSX version

### Tech

MediaInfoANE uses the following libraries:

* [http://mediaarea.net/en/MediaInfo] - MediaInfo Lib
* [https://github.com/ShiftMediaProject/zlib] - ShiftMediaProject Zlib
* [http://www.boost.org] - C++ portable libraries

### Prerequisites

You will need
 
 - Flash Builder 4.7
 - AIR 22 SDK
 - Homebrew if you wish to modify the ANE code on OSX
 - XCode if you wish to modify the ANE code on OSX
 - MS Visual Studio 2015 if you wish to modify the ANE code on Windows

### OSX Preconfiguration to modify the ANE code:
 - Install Homebrew
 - from the Terminal run: brew install media-info

### Win Preconfiguration to modify the ANE code:
 - Install Visual Studio 2015
 - Install 7Zip [http://7-zip.org]
 - Run native_library/win/dependencies/RUNME.bat from cmd as Administrator.
This will download and build the remaining dependencies needed (zlib,mediainfo)

### Todos
 - add menu in default returned
 - retrieve any field item
 - Add ASDocs