@echo off
echo Downloading zlib...
call "C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\vcvarsall.bat"
SET pathtome=%~dp0
mkdir %pathtome%SMP\git
git clone https://github.com/ShiftMediaProject/zlib.git SMP\git\zlib
cd SMP\git\zlib\SMP
call MSBuild libzlib.sln /t:Rebuild /p:Configuration=Release
call MSBuild libzlib.sln /t:Rebuild /p:Configuration=Debug
cd ../../../..

SETX ZLIB_INCLUDEDIR %pathtome%SMP\msvc\include /m
SETX ZLIB_LIBRARYDIR %pathtome%SMP\msvc\lib\x86 /m