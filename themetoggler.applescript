(* based on https://gist.github.com/davedelong/850409c512ab2d2a21aa6fa690096d56 *)
on setDarkModeSmothly(shouldBeDark)
	tell application "System Events"
		if dark mode of appearance preferences is shouldBeDark then
			return "no changes"
		end if
	end tell
	
	if shouldBeDark then
		set mode to "dark"
	else
		set mode to "light"
	end if
	set currentPanel to ""
	set preferenceWasOpen to false
	set showAll to false
	
	if application "System Preferences" is running then
		set preferenceWasOpen to true
		tell application "System Preferences"
			if show all is true then
				set showAll to true
			else
				set currentPanel to the id of the current pane
				--quit isnt necessary anymore
			end if
		end tell
	else
		try
			do shell script "killall 'System Preferences'"
		end try
	end if
	
	tell application "System Events"
		repeat until exists of checkbox mode of window "General" of application process "System Preferences"
			tell application "System Preferences" to reveal anchor "Main" of pane id "com.apple.preference.general"
			delay 0.5
		end repeat
		delay 1
		click checkbox mode of window "General" of application process "System Preferences"
		--log mode & " mode set"
	end tell
	delay 2
	if preferenceWasOpen then
		tell application "System Preferences"
			if showAll then
				set show all to true
			else
				reveal (the first pane whose id is currentPanel)
				set current pane to pane currentPanel
			end if
		end tell
	else
		try
			if application "System Preferences" is running then do shell script "killall 'System Preferences'"
		end try
	end if
	
	return mode & " mode set"
end setDarkModeSmothly

on run themeToggler
	set argList to {}
	repeat with arg in themeToggler
		set end of argList to arg
		log argList
	end repeat
	(*set {TID, text item delimiters} to {text item delimiters, space}
	set argList to argList as text
	set text item delimiters to TID*)
	setDarkModeSmothly(argList as boolean)
	--log argList
end run

(*set result to display dialog "Set System Appearance" buttons ["Light Mode", "Dark Mode"]
if button returned of result is "Light Mode" then
	setDarkModeSmothly(false)
else
	setDarkModeSmothly(true)
end if*)

