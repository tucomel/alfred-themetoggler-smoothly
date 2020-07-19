## Theme Toggler Smoothly Alfred (Workflow) ##
Version 1.0 (2020-07-18)

Theme Toggler Smoothly Alfred is an **[Alfred](http://www.alfredapp.com)** workflow written in Bash/Shell for theme toggle smoothly using preference permission

## Installation ##
Download and double click [theme-toggler-smoothly.alfredworkflow](theme-toggler-smoothly.alfredworkflow). It will be imported into Alfred automatically.

Here is how the workflow nodes look like:
`full quality video at root folder`
![setup custom](theme-toggler-smoothly.gif)

## Usage ##
* `theme-setup` will automatically download gist from github and setup all workflow.
    * Custom time: need to set light and dark times
    * NightShift: will ask for sudo permission to get nightshift setting from private directory

* After setup, it will create a file `.plist` inside `~/Library/LaunchAgents/`, this file will schedule the workflow call based on your setup settings.

* The `.plist` file is set to RunAtLoad, then th workflow will do it magic based on your current time and will set theme, it may requires permission to access System Preferences.app

* When the workflow got called it will check the current time and fit your system theme based on your configuration.
    * It will open preferences app and set theme, if your preferences was running, it will go back to last panel , otherwise it will open preferences and quit after change the theme.

## License ##
**Theme Toggler Smoothly** workflow is released to the public domain. (Do whatever you like with it.)
