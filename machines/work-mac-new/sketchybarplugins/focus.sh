#!/bin/sh

status=$(cat ~/Library/DoNotDisturb/DB/Assertions.json | jq .data[0].storeAssertionRecords)

if [ "$status" = "null" ]; then
    sketchybar -m --set $NAME icon=
else
    sketchybar -m --set $NAME icon=
fi
