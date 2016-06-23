
REM Get the path to the script and trim to get the directory.
@echo off
SET pathtome=%~dp0
SET projectName=MediaInfoANE
echo cleaning %pathtome%
DEL /F /Q /A %pathtome%%projectName%-debug.ane
DEL /F /Q /A %pathtome%%projectName%.swc
DEL /F /Q /A %pathtome%library.swf
DEL /F /Q /A %pathtome%catalog.xml
rd /S /Q %pathtome%platforms