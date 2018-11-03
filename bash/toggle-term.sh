#!/bin/bash

[[ "$1" == 'hide' ]] && readonly SHOULD_HIDE=1 || readonly SHOULD_HIDE=0
readonly DEBUG=false
readonly TOGGLE_WINDOW_NAME='toggle-term'


cached_window_pid=$(cat /tmp/toggle_window_pid 2> /dev/null)
toggle_window_pid=$(xdotool search --name "^$TOGGLE_WINDOW_NAME$")

if   [[ -z "$toggle_window_pid"                              ]] && ((! $SHOULD_HIDE))
then $DEBUG && echo "window does not exist - launching"
     lxterminal --title="$TOGGLE_WINDOW_NAME"

elif [[ "$toggle_window_pid" != "$cached_window_pid"         ]] && ((! $SHOULD_HIDE))
then $DEBUG && echo "window is not visible - mapping"
     xdotool windowmap      $toggle_window_pid
     xdotool windowactivate $toggle_window_pid 2> /dev/null

elif [[ "$toggle_window_pid" == "$(xdotool getactivewindow)" ]] || ((  $SHOULD_HIDE ))
then $DEBUG && echo "window is visible - unmapping"
     xdotool windowunmap $toggle_window_pid
     toggle_window_pid=''

else $DEBUG && echo "window is visible but blurred - focussing"
     xdotool windowactivate $toggle_window_pid 2> /dev/null
fi
echo $toggle_window_pid > /tmp/toggle_window_pid
