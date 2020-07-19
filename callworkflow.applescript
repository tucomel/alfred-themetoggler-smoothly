set h to (hours of (current date)) as text
set m to (minutes of (current date)) as text
set minLength to the length of m
if (m < 10) then
	if (minLength < 2) then
		set m to (0 & m)
	end if
end if

tell application id "com.runningwithcrayons.Alfred" to run trigger "toggle" in workflow "com.tucomel.themetoggler" with argument h & m as text
