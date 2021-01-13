#!/usr/bin/env zsh

set -euo pipefail nounset

###########################
# config section          #
###########################

## rofi settings
# seperate with a newline 
default_save_dirs="$HOME"

## commands
# when editing these make sure to edit the flags in the functions below accordingly
recorder="wf-recorder"
snapper="grim"
part_select="slurp"
clipboard_manager="wl-copy"
notif_cmd="notify-send"

## text lines
rec_start="Start recording"
rec_stop="Stop recording"
screenshot="Take a screenshot"
record_part="Part of the screen"
record_whole="The whole screen"
prompt_save="Save as >"
prompt_choose="Choose one > "

## recorder config
valid_extensions=$(ffmpeg -muxers 2>/dev/null | tail -n +5 | cut -d " " -f 4 | tr '\n' ' ' | sed 's/ *$//g')

###########################

## rofi methods
queue_options() {
    echo $1 | rofi -dmenu -no-custom -i -fixed-num-lines false -p "${prompt_choose}"
}

queue_save() {
    echo $1 | rofi -dmenu -i -fixed-num-lines false -p "${prompt_save}"
}

notify() {
    notify-send $1 -t 2000
}


## recording
record_screen_part() {
    area=$($part_select)
    notify "Recording to $(realpath '$1')"
    ${recorder} -g "${area}" -f "$1" >/dev/null 2>&1 &
}

record_screen_whole() {
    notify "Recording to $(realpath ${outfile})"
    ${recorder} -f "$1" >/dev/null 2>&1 &
}

stop_recording() {
    pkill -2 ${recorder}
}

## taking screenshots
take_shot_all() {
    ${snapper} - | ${clipboard_manager} -t image/png
    notify "Copied to clipboard"
}

take_shot_part() {
    area=$($part_select)
    ${snapper} -g "${area}" - | ${clipboard_manager} -t image/png
    notify "Copied to clipboard"
}

###########################

# check if a recording is running atm
if [ -z "$(pgrep ${recorder})" ]; then
    option_rec=${rec_start}
else 
    option_rec=${rec_stop}
fi

# prompt what to do
selection=$(queue_options "${screenshot}\n${option_rec}")

# stop the current recording
if [[ ${selection} == ${rec_stop} ]]; then
    stop_recording
    notify "Finished recording"
    exit
fi

# otherwise, ask wether to record/snap the whole screen or just a part
area_choice=$(queue_options "${record_whole}\n${record_part}")

case ${selection} in
    ${rec_start})
        # start recording
        # prompt where to save
        outfile=$(queue_save "${default_save_dirs}")
        echo "${outfile}"

        # if no extension or an invalid one is provided, set it to mp4
        # in case of an existing directory save using the current date/time
        if [ -z "${outfile}" ]; then
            exit
        elif [ -d "${outfile}" ]; then
            cur=$(date "+%Y%m%d_%H%M")
            outfile=${outfile}"/${cur}.mp4"
        elif [ -z "${outfile##*.}" ]; then
            outfile="${outfile}.mp4"
        elif [[ ! ${valid_extensions} =~ (^|[[:space:]])"${outfile##*.}"($|[[:space:]]) ]]; then
            notify "Invalid extension!"
            exit
        fi

        # finally, record it all
        if [[ "${area_choice}" == "${record_whole}" ]]; then
            record_screen_whole "${outfile}"
        else 
            record_screen_part "${outfile}"
        fi
        ;;
    $screenshot)
        if [[ "${area_choice}" == "${record_whole}" ]]; then
            take_shot_all
        else 
            take_shot_part
        fi
        ;;
esac
