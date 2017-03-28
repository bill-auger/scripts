#!/bin/bash


(($1)) && ALSA_CAPTURE_CARD_N=$1
MUTE_MODE=0
CAPTURE_PIN='Capture,0'
CAPTURE_STATE_ON='100% cap'
CAPTURE_STATE_OFF='0% nocap'
LINE_INPUT_PIN='Line'
MIC_INPUT_PIN='Rear Mic'
MIC_BOOST_PIN='Rear Mic Boost,0'
MIC_BOOST_VAL='20.00dB'
LED_STATE_ON='-led'
LED_STATE_OFF='led'
TOGGLE_STATE_ON='1'
TOGGLE_STATE_OFF='0'
CAPTURE_STATE="$CAPTURE_STATE_OFF"
LED_STATE="$LED_STATE_OFF"
TOGGLE_STATE="$TOGGLE_STATE_OFF"
STATE_FILE=~/.config/mic-toggle-state

[ -z $ALSA_CAPTURE_CARD_N ] && ( (speaker-test -t sine -f 1000)& pid=$! ; sleep 0.1s ; kill -9 $pid ; )
[ -z $ALSA_CAPTURE_CARD_N ] && echo "no card # specified" && exit


[ -f "$STATE_FILE" ] && ((`cat $STATE_FILE`)) && is_off=1 || is_off=0
(($MUTE_MODE)) && capture_state_off=$CAPTURE_STATE_OFF || capture_state_off=$CAPTURE_STATE_ON
(($is_off)) && input_pin=$LINE_INPUT_PIN || input_pin=$MIC_INPUT_PIN

if (($is_off))
then CAPTURE_STATE="$capture_state_off" LED_STATE="$LED_STATE_OFF" TOGGLE_STATE="$TOGGLE_STATE_OFF"
else CAPTURE_STATE="$CAPTURE_STATE_ON"  LED_STATE="$LED_STATE_ON"  TOGGLE_STATE="$TOGGLE_STATE_ON"
fi
amixer -c $ALSA_CAPTURE_CARD_N sset $CAPTURE_PIN $CAPTURE_STATE
amixer -c $ALSA_CAPTURE_CARD_N sset 'Input Source' "$input_pin"
amixer -c $ALSA_CAPTURE_CARD_N sset "$MIC_BOOST_PIN" "$MIC_BOOST_VAL"
xset "$LED_STATE" named 'Scroll Lock'
echo "$TOGGLE_STATE" > $STATE_FILE


echo "cat STATE_FILE=`cat $STATE_FILE` CAPTURE_STATE=$CAPTURE_STATE LED_STATE=$LED_STATE TOGGLE_STATE=$TOGGLE_STATE input_pin=$input_pin"
