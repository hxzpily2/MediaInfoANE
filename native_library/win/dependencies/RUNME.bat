@echo off
SET pathtome=%~dp0
NET SESSION >nul 2>&1
if %ERRORLEVEL% EQU 0 (
	if not defined BOOST_ROOT call boost.bat
	if not defined ZLIB_INCLUDEDIR call zlib.bat
	if not defined MEDIAINFO_LIBRARYDIR call mediainfo.bat
) else (
   echo ##########################################################
   echo This script must be run as administrator to work properly!  
   echo If you're seeing this after clicking on a start menu icon, then right click on the shortcut and select "Run As Administrator".
   echo ##########################################################
)