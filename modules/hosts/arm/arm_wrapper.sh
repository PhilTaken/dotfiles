#!/usr/bin/env bash

# TODO: conform to nix paths
# TODO: logger

DEVNAME=$1

#######################################################################################
# YAML Parser to read Config
#
# From: https://stackoverflow.com/questions/5014632/how-can-i-parse-a-yaml-file-from-a-linux-shell-script
#######################################################################################

function parse_yaml {
   local prefix=$2
   local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=$(echo @|tr @ '\034')
   sed -ne "s|^\($s\):|\1|" \
        -e "s|^\($s\)\($w\)$s:$s[\"']\(.*\)[\"']$s\$|\1$fs\2$fs\3|p" \
        -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p"  $1 |
   awk -F$fs '{
      indent = length($1)/2;
      vname[indent] = $2;
      for (i in vname) {if (i > indent) {delete vname[i]}}
      if (length($3) > 0) {
         vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
         printf("%s%s%s=\"%s\"\n", "'$prefix'",vn, $2, $3);
      }
   }'
}

eval $(parse_yaml @configFile@ "CONFIG_")

#######################################################################################
# Log Discovered Type and Start Rip
#######################################################################################

# ID_CDROM_MEDIA_BD = Bluray
# ID_CDROM_MEDIA_CD = CD
# ID_CDROM_MEDIA_DVD = DVD

if [ "$ID_CDROM_MEDIA_DVD" == "1" ]; then
    if [ "$CONFIG_PREVENT_99" != "false" ]; then
        numtracks=$(@lsdvd@ /dev/${DEVNAME} 2> /dev/null | sed 's/,/ /' | cut -d ' ' -f 2 | grep -E '[0-9]+' | sort -r | head -n 1)
        if [ "$numtracks" == "99" ]; then
            echo "[ARM] ${DEVNAME} has 99 Track Protection. Bailing out and ejecting." | logger -t ARM -s
            eject ${DEVNAME}
            exit
        fi
    fi
    echo "[ARM] Starting ARM for DVD on ${DEVNAME}" | logger -t ARM -s

elif [ "$ID_CDROM_MEDIA_BD" == "1" ]; then
    echo "[ARM] Starting ARM for Bluray on ${DEVNAME}" | logger -t ARM -s

elif [ "$ID_CDROM_MEDIA_CD" == "1" ]; then
    echo "[ARM] Starting ARM for CD on ${DEVNAME}" | logger -t ARM -s

elif [ "$ID_FS_TYPE" != "" ]; then
    echo "[ARM] Starting ARM for Data Disk on ${DEVNAME} with File System ${ID_FS_TYPE}" | logger -t ARM -s

else
    echo "[ARM] Not CD, Bluray, DVD or Data. Bailing out on ${DEVNAME}" | logger -t ARM -s
    exit #bail out
fi

export PYTHONPATH="$PYTHONPATH:@pythonpath@"
@python@ @rippermain@ -d ${DEVNAME}

#######################################################################################
# Check to see if the admin page is running, if not, start it
#######################################################################################

# if ! pgrep -f "runui.py" > /dev/null; then
#   echo "[ARM] ARM Webgui not running; starting it " | logger -t ARM -s
#   /bin/su -l -c "/usr/bin/python3 /opt/arm/arm/runui.py  " -s /bin/bash arm
# fi
