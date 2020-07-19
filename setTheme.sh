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

if [[ -z "$1" || -z "$2" ]]; then
	echo "Need theme1 theme2 variables";
	exit 1;
fi

theme1=$1
theme2=$2
dsHour="${theme1:0:2}"
dsMin="${theme1:2:2}"
nsHour="${theme2:0:2}"
nsMin="${theme2:2:2}"

nowHour=$(date +"%H")
nowMin=$(date +"%M")

shouldBeDark=true;

##same hours
if [ $nowHour -eq $dsHour ]; then
	if [ $nowMin -ge $dsMin ]; then
		shouldBeDark=false;
	else
		shouldBeDark=true;
	fi
elif [ $nowHour -eq $nsHour ]; then
	if [ $nowMin -lt $nsMin ]; then
		shouldBeDark=false;
	else
		shouldBeDark=true;
	fi
##different hours
elif [[ $nowHour -gt $dsHour && $nowHour -lt $nsHour ]]; then
	shouldBeDark=false;
else
	shouldBeDark=true;
fi

osascript "$CURRENT_DIR/themetoggler.applescript" $shouldBeDark