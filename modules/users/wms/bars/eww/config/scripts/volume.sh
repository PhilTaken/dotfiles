#!/usr/bin/env bash
# vi: ft=sh

# @requires: amixer

percentage () {
  local val=$(echo $1 | tr '%' ' ' | awk '{print $1}')
  local icon1=$2
  local icon2=$3
  local icon3=$4
  local icon4=$5
  if [ "$val" -le 15 ]; then
    echo $icon1
  elif [ "$val" -le 30 ]; then
    echo $icon2
  elif [ "$val" -le 60 ]; then
    echo $icon3
  else
    echo $icon4
  fi
}

is_muted () {
  amixer get Master | tail -2 | grep -q '\[off\]'
}

get_percentage () {
  local muted=$(is_muted)
  if [[ $muted == 'yes' ]]; then
    echo "muted"
  else
    amixer get Master | grep % |awk '{print $5}'| sed -e 's/\[//' -e 's/\]//' | head -n 1
  fi
}

get_icon() {
  local vol=$(get_percentage)
  if [[ $vol == "muted" ]]; then
    echo "婢"
  else
    echo $(percentage "$vol" "" "" "墳" "")
  fi
}

get_class () {
  local vol=$(get_percentage)
  if [[ $vol == "muted" ]]; then
    echo "red"
  else
    echo $(percentage "$vol" "red" "magenta" "yellow" "blue")
  fi
}

get_vol () {
  local percent=$(get_percentage)
  echo $percent | tr -d '%'
}

if [[ $1 == "icon" ]]; then
  get_icon
fi

if [[ $1 == "class" ]]; then
  get_class
fi

if [[ $1 == "percentage" ]]; then
  get_percentage
fi

if [[ $1 == "vol" ]]; then
  get_vol
fi

if [[ $1 == "set" ]]; then
  val=$(echo $2 | tr '.' ' ' | awk '{print $1}')
  if test $val -gt 100; then
    val=100
  fi
  amixer sset 'Master' $val%
fi