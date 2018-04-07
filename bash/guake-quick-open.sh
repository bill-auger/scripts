#!/bin/bash

# add to guake prefs:
#     guake-quick-open.sh "%(file_path)s" %(line_number)s

FILE=$1
LINE=$2
ORIG_JUCE_BUILD_DIR=./Builds/LinuxMakefile
NEW_JUCE_BUILD_DIR=./Builds/Linux
MY_JUCE_BUILD_DIR=./Builds/Makefile


[ -f "$ORIG_JUCE_BUILD_DIR/$FILE" ] && FILE="$ORIG_JUCE_BUILD_DIR/$FILE"
[ -f "$NEW_JUCE_BUILD_DIR/$FILE"  ] && FILE="$NEW_JUCE_BUILD_DIR/$FILE"
[ -f "$MY_JUCE_BUILD_DIR/$FILE"   ] && FILE="$MY_JUCE_BUILD_DIR/$FILE"
[ -f "src/$FILE"                  ] && FILE="src/$FILE"
[ -f "plugins/$FILE"              ] && FILE="plugins/$FILE"
[ -f "$FILE"                      ] && kate "$FILE" --line $LINE
