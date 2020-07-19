#!/bin/zsh
# Author: Arthur Melo (github.com/tucomel)

# -------------------------------------
# IMPORTS
# -------------------------------------
CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# create if does not exist
touch ~/.bash_profile
source ~/.bash_profile
source "$CURRENT_DIR"/shelper.sh

cd $CURRENT_DIR
# -------------------------------------
# VARIABLES
# -------------------------------------
type="$1"
customTimeLight=$2
customTimeDark=$3
launchAgentFile="com.tucomel.themetoggler.plist"
applescript="themetoggler.applescript"
PLISTBUDDY="/usr/libexec/PlistBuddy"
# -------------------------------------
# VALIDATIONS
# -------------------------------------
if [ -z "$1" ]; then
    echo "You must need to set type of theme changing (custom time or night-shift)"
    exit 1
fi
jq_installed=$(program_exists "jq")
if ! [ $jq_installed ]; then
    echo "Failed! Please install jq for json parse (brew install jq)."
    exit 1
fi

if [ "$type" == "custom" ]; then
    if  ! $(isInteger $customTimeLight) || ! $(isInteger $customTimeDark) ; then
        echo "Some parameter is invalid, you must need to set time in format HHMM (sh setup.sh \"custom\" 0500 1700)"
        exit 1
    else
        if [ ${#customTimeLight} != 4 ] || [ ${#customTimeDark} != 4 ] ; then
            echo "Some parameter is invalid, you must need to set time in format HHMM (sh setup.sh \"custom\" 0500 1700)"
            exit 1;
        fi
    fi
fi

# -------------------------------------
# SCRIPT START HERE
# -------------------------------------
if [ -f ~/Library/LaunchAgents/$launchAgentFile ]; then
    #launchctl stop ~/Library/LaunchAgents/$launchAgentFile > /dev/null 2>&1
    #launchctl unload ~/Library/LaunchAgents/$launchAgentFile > /dev/null 2>&1
    rm ~/Library/LaunchAgents/$launchAgentFile > /dev/null 2>&1
fi
rm $launchAgentFile > /dev/null 2>&1
#echo $"($PLISTBUDDY 'add :LowPriorityIO bool true' $launchAgentFile)"
$PLISTBUDDY -c 'add :LowPriorityIO bool true' $launchAgentFile > /dev/null 2>&1
$PLISTBUDDY -c 'add :KeepAlive bool false' $launchAgentFile
$PLISTBUDDY -c 'add :EnvironmentVariables dict' $launchAgentFile
$PLISTBUDDY -c 'add :EnvironmentVariables:PATH string '/bin:/usr/bin:/usr/local/bin'' $launchAgentFile
$PLISTBUDDY -c 'add :RunAtLoad bool true' $launchAgentFile
$PLISTBUDDY -c 'add :Label string "com.tucomel.themetoggler"' $launchAgentFile
$PLISTBUDDY -c 'add :ProgramArguments array' $launchAgentFile
$PLISTBUDDY -c 'add :ProgramArguments: string "/usr/bin/osascript"' $launchAgentFile
$PLISTBUDDY -c 'add :ProgramArguments: string "-e"' $launchAgentFile
$PLISTBUDDY -c 'add :ProgramArguments: string "to-be-replaced"' $launchAgentFile
#$PLISTBUDDY -c 'add :ProgramArguments: string "'$CURRENT_DIR'/callworkflow.applescript"' $launchAgentFile
$PLISTBUDDY -c 'add :StartCalendarInterval array' $launchAgentFile
$PLISTBUDDY -c 'add :StartCalendarInterval:0 dict' $launchAgentFile
$PLISTBUDDY -c 'add :StartCalendarInterval:0:Minute integer 00' $launchAgentFile
$PLISTBUDDY -c 'add :StartCalendarInterval:0:Hour integer 06' $launchAgentFile
$PLISTBUDDY -c 'add :StartCalendarInterval:1 dict' $launchAgentFile
$PLISTBUDDY -c 'add :StartCalendarInterval:1:Minute integer 00' $launchAgentFile
$PLISTBUDDY -c 'add :StartCalendarInterval:1:Hour integer 17' $launchAgentFile

if [ "$type" == "nightshift" ]; then
    nightShiftFile="nightshift.plist"
    if ! [ -f $nightShiftFile ]; then
        #echo "Nightshift files not found, needs elevation to copy from system"
        #this file is private only accessible using root to check nightshift custom time
        # Get the GeneratedUID for the current user
        currentUserUID=$(dscl . -read /Users/$(whoami)/ GeneratedUID)
        # Remove the "GeneratedUID: " part
        currentUserUID=$(echo $currentUserUID | cut -d' ' -f2)
        # Append the prefix
        currentUserUID="CBUser-"$currentUserUID
        hasFile=$(osascript -e 'do shell script "'"sudo $PLISTBUDDY -x -c 'print :$currentUserUID:CBBlueReductionStatus:' '/private/var/root/Library/Preferences/com.apple.CoreBrightness.plist' > '$nightShiftFile' && chmod ug=r '$nightShiftFile' && echo true"'" with administrator privileges')
    else
        hasFile=true;
    fi

    #blueReductionMode = 0 - off, 1 - sunset sunrise - 2 custom time
    blueReductionMode=0
    if [ "$hasFile" == true ]; then
        blueReductionMode=$($PLISTBUDDY -c "print :BlueReductionMode" $nightShiftFile)
        if [ "$blueReductionMode" -eq 0 ]; then
            rm $nightShiftFile
            echo "You must set night-shift options at preferences > displays > night shift"
            exit 1
        fi
    else
        echo "Night Shift setting needs elevation to copy '/private/var/root/Library/Preferences/com.apple.CoreBrightness.plist' from system"
        exit 1
    fi

    if ! [ "$blueReductionMode" -eq 0 ]; then
        nightShiftEnabled=$($PLISTBUDDY -c "print :BlueReductionEnabled" $nightShiftFile)
        #echo "nightShiftEnabled : $nightShiftEnabled"
        dsHour=$($PLISTBUDDY -c "print :BlueLightReductionSchedule:DayStartHour" $nightShiftFile)
        #echo "DayStartHour : "$dsHour
        dsMin=$($PLISTBUDDY -c "print :BlueLightReductionSchedule:DayStartMinute" $nightShiftFile)
        #echo "DayStartMinute : "$dsMin
        nsHour=$($PLISTBUDDY -c "print :BlueLightReductionSchedule:NightStartHour" $nightShiftFile)
        #echo "NightStartHour : "$nsHour
        nsMin=$($PLISTBUDDY -c "print :BlueLightReductionSchedule:NightStartMinute" $nightShiftFile)
        #echo "NightStartMinute : "$nsMin
    else
        echo "You must set night-shift options at preferences > displays > night shift"
        exit 1
    fi
else
    #custom time set
    dsHour="${customTimeLight:0:2}"
    dsMin="${customTimeLight:2:2}"
    nsHour="${customTimeDark:0:2}"
    nsMin="${customTimeDark:2:2}"
fi

if [ -f $launchAgentFile ]; then
$PLISTBUDDY -c 'set :ProgramArguments:2 "tell application id \"com.runningwithcrayons.Alfred\" to run trigger \"toggle\" in workflow \"com.tucomel.themetoggler\" with argument \"'$dsHour$dsMin","$nsHour$nsMin'\""' $launchAgentFile
    $PLISTBUDDY -c 'set :StartCalendarInterval:0:Hour '$dsHour'' $launchAgentFile
    $PLISTBUDDY -c 'set :StartCalendarInterval:0:Minute '$dsMin'' $launchAgentFile
    $PLISTBUDDY -c 'set :StartCalendarInterval:1:Hour '$nsHour'' $launchAgentFile
    $PLISTBUDDY -c 'set :StartCalendarInterval:1:Minute '$nsMin'' $launchAgentFile
    ln -f $launchAgentFile ~/Library/LaunchAgents/$launchAgentFile
    launchctl unload ~/Library/LaunchAgents/$launchAgentFile
    launchctl stop ~/Library/LaunchAgents/$launchAgentFile
else
    echo "Failed to create file " $launchAgentFile
    exit 1
fi

json=$(curl -s -k "https://api.github.com/gists/2fd454ffabbdb11300a03e20e99b367b"\
 -H 'Accept: application/vnd.github.v3+json'\
 -H 'Authorization: token 264d1eb51d0e9272d3ce00ae20f4a5e3a8997918'\
 | jq -r --tab '.files[]')
#populate $filename
#filename="$(jq -r '.filename' <<< $json)"
#get .content token and write on $filename file
jq -r '.content' <<< $json > $applescript
#return true if $applescript exists, otherwise return error
#echo "$CURRENT_DIR/$launchAgentFile"
if [[ -f $applescript && -f ~/Library/LaunchAgents/$launchAgentFile ]]; then
    chmod 644 ~/Library/LaunchAgents/$launchAgentFile
    launchctl load ~/Library/LaunchAgents/$launchAgentFile
    echo "workflow set!"
else
    if ! [ -f ~/Library/LaunchAgents/$launchAgentFile ]; then
        echo "AgentFileError!"
    else
        echo "AppleScriptError!"
    fi
fi
