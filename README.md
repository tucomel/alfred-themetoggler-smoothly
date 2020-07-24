## Theme Toggler Smoothly Alfred (Workflow) ##
Version 1.0 (2020-07-18)

Theme Toggler Smoothly Alfred is an **[Alfred](http://www.alfredapp.com)** workflow written in Bash/Shell for theme toggle smoothly using preference permission

## Installation ##
Download and double click [theme-toggler-smoothly.alfredworkflow](theme-toggler-smoothly.alfredworkflow). It will be imported into Alfred automatically.

Here is how the workflow nodes look like:
![setup custom](theme-toggler-smoothly.gif)
Full quality video [here](theme-toggler-smoothly.mp4)

## Usage ##
* `theme-setup` **is the unique option available**.
    * **Custom time**: user need to set light and dark times , **must in format HHMM (24h format)**
    * **Night-Shift**: will ask for sudo permission to get nightshift setting from private directory
    `/private/var/root/Library/Preferences/com.apple.CoreBrightness.plist`.
* After setup, it will create a file `.plist` inside `~/Library/LaunchAgents/`, this file will schedule the workflow call based on your setup settings.

* The `.plist` file is set to **RunAtLoad**, then the workflow will do its magic based on your current time and will set theme, it may requires access permission to `System Preferences.app`

* When the workflow got called it will check the current time and fit your system theme based on your configuration.
    * It will open **System Preferences.app** and set theme, if your preferences app was already running, it will change theme and go back to last panel, otherwise it will open preferences app and quit after change the theme.
        * **This is why it change theme smootlhy, it change using System Preferences.app**

## License ##
**Theme Toggler Smoothly** workflow is released to the public domain. (Do whatever you like with it.)
