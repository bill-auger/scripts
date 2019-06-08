#!/bin/bash

# NOTE: this script is intended to be the target of keybindings
#         to alternatively show/hide a running xWindow
#       'hide' corresponds to desktop switching keybinding (always hide)
#         otherwise assume "toggle" keybinding (toggle visibility)
[[ "$1" == 'hide' ]] && readonly SHOULD_HIDE=1 || readonly SHOULD_HIDE=0
readonly DEBUG=false
readonly DEBUGVB=false
readonly TOGGLE_WINDOW_NAME='toggle-term'
readonly TOGGLE_WINDOW_PID_FILE=/tmp/toggle_window_pid


DBG_LOG()   { ${DEBUG}   && echo -n "[TOGGLE_TERM]: $*" ; } ;
DBGVB_LOG() { ${DEBUGVB} && echo -n "[TOGGLE_TERM]: $*" ; } ;


cached_window_pid=$(cat ${TOGGLE_WINDOW_PID_FILE} 2> /dev/null     )
toggle_window_pid=$(xdotool search --name "^${TOGGLE_WINDOW_NAME}$")
active_window_pid=$(xdotool getactivewindow                        )


DBGVB_LOG "cached_window_pid=${cached_window_pid} "
DBGVB_LOG "toggle_window_pid=${toggle_window_pid} "
DBGVB_LOG "active_window_pid=${active_window_pid}\n"


if   [[ -z "${toggle_window_pid}"                         ]] && ((! ${SHOULD_HIDE}))
then DBG_LOG "window does not exist - launching\n"
     lxterminal --title="${TOGGLE_WINDOW_NAME}"
     which alltray 2> /dev/null && sleep 5 && /code/scripts/bash/alltray-auto

elif [[ "${toggle_window_pid}" != "$cached_window_pid"    ]] && ((! ${SHOULD_HIDE}))
then DBG_LOG "window is not visible - mapping\n"
     xdotool windowmap      ${toggle_window_pid}
     xdotool windowactivate ${toggle_window_pid} 2> /dev/null

elif [[ "${toggle_window_pid}" == "${active_window_pid}"  ]] || ((  ${SHOULD_HIDE} ))
then DBG_LOG "window is visible - unmapping\n"
     xdotool windowunmap ${toggle_window_pid}
     toggle_window_pid=''

else DBG_LOG "window is visible but blurred - focussing\n"
     xdotool windowactivate ${toggle_window_pid} 2> /dev/null
fi

echo ${toggle_window_pid} > ${TOGGLE_WINDOW_PID_FILE}
