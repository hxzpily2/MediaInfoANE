@echo off
call "C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\vcvarsall.bat"
SET pathtome=%~dp0
SET SZIP="C:\Program Files\7-Zip\7z.exe"
echo Downloading mediainfo...
call cscript scripts\wget.js http://mediaarea.net/download/source/mediainfo/0.7.86/mediainfo_0.7.86_AllInclusive.7z mediainfo.7z
echo Unzipping mediainfo...
call %SZIP% x %pathtome%mediainfo.7z -o%pathtome%
DEL /F /S /Q /A %pathtome%mediainfo.7z

cd mediainfo_AllInclusive\MediaInfo\Project\MSVC2015
msbuild MediaInfo.sln /target:MediaInfoLib\MediaInfoLib /p:Configuration=Release
msbuild MediaInfo.sln /target:MediaInfoLib\MediaInfoLib /p:Configuration=Debug
cd ../../../..

mkdir %pathtome%mediainfo-build\lib
mkdir %pathtome%mediainfo-build\include\ZenLib
mkdir %pathtome%mediainfo-build\include\MediaInfo

cd mediainfo-build\lib

copy %pathtome%mediainfo_AllInclusive\MediaInfo\Project\MSVC2015\Win32\Debug\ZenLib.lib %pathtome%mediaInfo-build\lib
ren ZenLib.lib zenlibd.lib
copy %pathtome%mediainfo_AllInclusive\MediaInfo\Project\MSVC2015\Win32\Release\ZenLib.lib %pathtome%mediainfo-build\lib
ren ZenLib.lib zenlib.lib

copy %pathtome%mediainfo_AllInclusive\MediaInfo\Project\MSVC2015\Win32\Release\MediaInfo-Static.lib %pathtome%mediainfo-build\lib
ren MediaInfo-Static.lib mediainfo.lib
copy %pathtome%mediainfo_AllInclusive\MediaInfo\Project\MSVC2015\Win32\Debug\MediaInfo-Static.lib %pathtome%mediainfo-build\lib
ren MediaInfo-Static.lib mediainfod.lib

cd ../..

copy %pathtome%mediainfo_AllInclusive\ZenLib\Source\ZenLib\Conf.h %pathtome%mediainfo-build\include\ZenLib
copy %pathtome%mediainfo_AllInclusive\MediaInfoLib\Source\MediaInfo\MediaInfo.h %pathtome%mediainfo-build\include\MediaInfo
copy %pathtome%mediainfo_AllInclusive\MediaInfoLib\Source\MediaInfo\MediaInfo_Config.h %pathtome%mediainfo-build\include\MediaInfo
copy %pathtome%mediainfo_AllInclusive\MediaInfoLib\Source\MediaInfo\MediaInfo_Const.h %pathtome%mediainfo-build\include\MediaInfo

rd /S /Q mediainfo_AllInclusive

SETX MEDIAINFO_LIBRARYDIR %pathtome%mediainfo-build\lib /m
SETX MEDIAINFO_INCLUDEDIR %pathtome%mediainfo-build\include /m