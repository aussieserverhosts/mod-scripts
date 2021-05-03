#!/bin/bash


if [ "${MODCOLLECTION}" == "" ]
then
  echo "No mods to install"
  exit 0
fi

MODID=$(curl ${MODCOLLECTION} | grep SubscribeCollectionItem | cut -d"'" -f2)

echo > modlist

#Mod IDs
echo "Mod IDs"
echo $MODID

#Strip mod IDs from Collection
for i in $MODID
do
    echo $i | tee >> modlist
done
sed -i '/^$/d' modlist

#Steamcmd install mods from modlist
for m in `cat modlist`;
do
    /home/container/steamcmd/steamcmd.sh +login anonymous +force_install_dir /home/container/ +workshop_download_item 346110 $m +quit
done

#If GameUserSettings doesn't exist, probably first run, exit
if [ ! -f "/home/container/ShooterGame/Saved/Config/LinuxServer/GameUserSettings.ini" ];
then
  echo "First run, won't attempt to insert modlist until server rebooted"
  exit 0
fi

#Set ActiveMods in ./ShooterGame/Saved/Config/LinuxServer/GameUserSettings.ini
MODLISTLINE=$(cat modlist | grep "\S" | tr '\n' ',' | sed 's/.$//')
if grep -qF "ActiveMods=" /home/container/ShooterGame/Saved/Config/LinuxServer/GameUserSettings.ini;
then
    sed -i "s/ActiveMods=.*/ActiveMods=$MODLISTLINE/g" /home/container/ShooterGame/Saved/Config/LinuxServer/GameUserSettings.ini
else
    #Insert ActiveMods=
    sed -i "/[ServerSettings]/a ActiveMods=" /home/container/ShooterGame/Saved/Config/LinuxServer/GameUserSettings.ini
    sed -i "s/ActiveMods=.*/ActiveMods=$MODLISTLINE/g" /home/container/ShooterGame/Saved/Config/LinuxServer/GameUserSettings.ini
fi