#!/bin/sh

#Get the path to the script and trim to get the directory.
echo "Setting path to current directory to:"
pathtome=$0
pathtome="${pathtome%/*}"
echo $pathtome

AIR_SDK="/Applications/Adobe Flash Builder 4.7/sdks/4.6.0"
echo $AIR_SDK

PROJECT_NAME=MediaInfoANE

#Setup the directory.
echo "Making directories."

mkdir "$pathtome/platforms"
mkdir "$pathtome/platforms/mac"
mkdir "$pathtome/platforms/mac/release"
mkdir "$pathtome/platforms/mac/debug"

mkdir "$pathtome/platforms/win"
mkdir "$pathtome/platforms/win/release"
mkdir "$pathtome/platforms/win/debug"

#Copy SWC into place.
echo "Copying SWC into place."
cp "$pathtome/../bin/$PROJECT_NAME.swc" "$pathtome/"

#Extract contents of SWC.
echo "Extracting files form SWC."
unzip "$pathtome/$PROJECT_NAME.swc" "library.swf" -d "$pathtome"

#Copy library.swf to folders.
echo "Copying library.swf into place."
cp "$pathtome/library.swf" "$pathtome/platforms/mac/release"
cp "$pathtome/library.swf" "$pathtome/platforms/mac/debug"
cp "$pathtome/library.swf" "$pathtome/platforms/win/release"
cp "$pathtome/library.swf" "$pathtome/platforms/win/debug"

#Copy native libraries into place.
echo "Copying native libraries into place."
cp -R -L "$pathtome/../../native_library/mac/$PROJECT_NAME/Build/Products/Release/$PROJECT_NAME.framework" "$pathtome/platforms/mac/release"
cp -R -L "$pathtome/../../native_library/mac/$PROJECT_NAME/Build/Products/Debug/$PROJECT_NAME.framework" "$pathtome/platforms/mac/debug"
cp -R -L "$pathtome/../../native_library/win/$PROJECT_NAME/Release/$PROJECT_NAME.dll" "$pathtome/platforms/win/release"
cp -R -L "$pathtome/../../native_library/win/$PROJECT_NAME/Release/$PROJECT_NAME.dll" "$pathtome/platforms/win/debug"

#Run the build command.
echo "Building Release."
"$AIR_SDK"/bin/adt -package \
-target ane "$pathtome/$PROJECT_NAME.ane" "$pathtome/extension_multi.xml" \
-swc "$pathtome/$PROJECT_NAME.swc" \
-platform MacOS-x86-64 -C "$pathtome/platforms/mac/release" "$PROJECT_NAME.framework" "library.swf" \
-platform Windows-x86 -C "$pathtome/platforms/win/release" "$PROJECT_NAME.dll" "library.swf"

echo "Building Debug."
"$AIR_SDK"/bin/adt -package \
-target ane "$pathtome/$PROJECT_NAME-debug.ane" "$pathtome/extension_multi.xml" \
-swc "$pathtome/$PROJECT_NAME.swc" \
-platform MacOS-x86-64 -C "$pathtome/platforms/mac/debug" "$PROJECT_NAME.framework" "library.swf" \
-platform Windows-x86 -C "$pathtome/platforms/win/debug" "$PROJECT_NAME.dll" "library.swf"

if [[ -d "$pathtome/debug" ]]
then
rm -r "$pathtome/debug"
fi


mkdir "$pathtome/debug"
unzip "$pathtome/$PROJECT_NAME-debug.ane" -d  "$pathtome/debug/$PROJECT_NAME.ane/"

rm -r "$pathtome/platforms"
rm "$pathtome/$PROJECT_NAME.swc"
rm "$pathtome/library.swf"
rm "$pathtome/$PROJECT_NAME-debug.ane"