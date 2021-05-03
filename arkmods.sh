#!/bin/bash

if [ -z "$MODCOLLECTION"]
then
  echo "No mods to install"
  exit 0
fi

MODID=$(echo $MODCOLLECTION | grep SubscribeCollectionItem | cut -d"'" -f2)

echo > modlist

#Strip mod IDs from Collection
for i in $MODID
do
    echo $i | tee >> modlist
done
sed -i '/^$/d' modlist

#Steamcmd install mods from modlist
for m in `cat modlist`;
do
    ./steamcmd.sh +login anonymous +force_install_dir /home/container +workshop_download_item 376030 $m +quit
done

#Set ActiveMods in ./ShooterGame/Saved/Config/LinuxServer/GameUserSettings.ini
MODLISTLINE=$(cat modlist | grep "\S" | tr '\n' ',' | sed 's/.$//')
if grep -qF "ActiveMods=" ShooterGame/Saved/Config/LinuxServer/GameUserSettings.ini;
then
    sed -i "s/ActiveMods=.*/ActiveMods=$MODLISTLINE/g" ShooterGame/Saved/Config/LinuxServer/GameUserSettings.ini
else
    #Insert ActiveMods=
    sed -i "/[ServerSettings]/a ActiveMods=" test.txt
    sed -i "s/ActiveMods=.*/ActiveMods=$MODLISTLINE/g" ShooterGame/Saved/Config/LinuxServer/GameUserSettings.ini
fi