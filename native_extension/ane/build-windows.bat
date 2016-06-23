REM Get the path to the script and trim to get the directory.
@echo off
SET SZIP="C:\Program Files\7-Zip\7z.exe"
echo Setting path to current directory to:
SET pathtome=%~dp0
echo %pathtome%

SET projectName=MediaInfoANE

REM Setup the directory.
echo Making directories.

mkdir %pathtome%platforms
mkdir %pathtome%platforms\win
mkdir %pathtome%platforms\win\release
mkdir %pathtome%platforms\win\debug

REM Copy SWC into place.
echo Copying SWC into place.
echo %pathtome%..\bin\%projectName%.swc
copy %pathtome%..\bin\%projectName%.swc %pathtome%

REM contents of SWC.
echo Extracting files form SWC.
echo %pathtome%%projectName%.swc
copy %pathtome%%projectName%.swc %pathtome%%projectName%Extract.swc
ren %pathtome%%projectName%Extract.swc %projectName%Extract.zip

call %SZIP% e %pathtome%%projectName%Extract.zip -o%pathtome%

del %pathtome%%projectName%Extract.zip

REM Copy library.swf to folders.
echo Copying library.swf into place.
copy %pathtome%library.swf %pathtome%platforms\win\release
copy %pathtome%library.swf %pathtome%platforms\win\debug


REM Copy native libraries into place.
echo Copying native libraries into place.

copy %pathtome%..\..\native_library\win\%projectName%\Release\%projectName%.dll %pathtome%platforms\win\release
copy %pathtome%..\..\native_library\win\%projectName%\Release\%projectName%.dll %pathtome%platforms\win\debug

REM Run the build command.
echo Building Release.
call adt.bat -package -target ane %pathtome%%projectName%.ane %pathtome%extension_win.xml -swc %pathtome%%projectName%.swc -platform Windows-x86 -C %pathtome%platforms\win\release %projectName%.dll library.swf
echo Building Debug
call adt.bat -package -target ane %pathtome%%projectName%-debug.ane %pathtome%extension_win.xml -swc %pathtome%%projectName%.swc -platform Windows-x86 -C %pathtome%platforms\win\debug %projectName%.dll library.swf

call %SZIP% x %pathtome%%projectName%-debug.ane -o%pathtome%debug\%projectName%.ane\ -aoa

call %pathtome%clean.bat
