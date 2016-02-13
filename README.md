### Why we need a script to install mongo db as a service?
Mongo db is a great tool, but after you install it is not installed as a service. That means you need to run it every time you need or install as a service once following this [tutorial](https://docs.mongodb.org/manual/tutorial/install-mongodb-on-windows/).
It is not a complicate procedure, but it need some time to understand commands and run them. This script allow you to perform an installation just with one click.

### How to install mongo db as a service
Double click on "InstallAsService.ps1" and follow wizard. That's all, folks ;-)
During wizard will be asked for settings, each of them comes with a default value so you just need to press "next" "next" "next" if you dont'mind to customize installation.


### PowerShell says “execution of scripts is disabled on this system.”
Dont worry it is normal. Powershell doesn' allow you to run script by "double click" by deafult. What you can do:
Open a powershell shell, then navigate to folder and launch script using following command:

    PowerShell.exe -ExecutionPolicy Bypass -File .\InstallAsService.ps1

### Authors and Contributors
This script is bundled by @zeppaman  and inspired from a stack overflow thread. 

### Support or Contact
Having trouble with Script?  [contact me](https://github.com/contact) and we’ll be happy to help you. Feedback like suggestion or error reporting are very appreciated.
