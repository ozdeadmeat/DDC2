# DDC2
## Discord to DCS Command and Control 2.0c Release##

NOTE: This version is now feature complete.

New Instructions:

Download and Install the new version of powershell

From an Admin Powershell Console execute the command below.
iex "& { $(irm https://aka.ms/install-powershell.ps1) } -UseMSI"

In the Exec Node make sure you add the additionalparameter to point to the DDC2 Folder (Extra Input Parameters)

-DDC2DIR "<YourDDC2InstanceLocation"

All config is now located in ddc2_config.ps1 and that file MUST be co-located with the ddc2.ps1 file.
Node-Red only requires the Exec Node to be updated and should work once correctly updated.

DDC2 2.0+ will not work with the powershell that comes with windows by default, an error message will come up in the log if you attempt to run it with the old version of powershell.

A video will come out closer to the full release and once i have worked out all the big bugs I am yet unaware of.

Any issues please post them here for record keeping.

---------------------------------------------------------------------------------

Thanks for taking the time to try out DDC2. Here are some useful links to keep up to date with all that is happening with DDC2. 

[DDC2 Eagle Dynamics Forum Thread](https://forums.eagle.ru/topic/241221-introduction-to-discord-to-dcs-server-command-control-ddc2/ "DDC2 Eagle Dynamics Forum Thread")

[DDC2 KAMBAN](https://trello.com/b/NerHUp2T/ddc2 "DDC2 KAMBAN")

[DDC2 Support Discord](https://discord.com/invite/AZtE9Ew "DDC2 Support Discord")



## Support Options ##

__If you have found DDC2 useful and you have a few coins laying around, please consider passing a few of them this way to help me continue the development.__

[OzDeaDMeaT's Patreon](https://www.patreon.com/ozdeadmeat "OzDeaDMeaT's Patreon")

[PayPal One Off Donation](https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=4K2HH4RF6RZEU&item_name=Support+OzDeaDMeaT+pwn+n00bs+with+his+friends&currency_code=AUD&source=url "PayPal One Off Donation")



## OzDeaDMeaT Contact Details ##

Discord: OzDeaDMeaT#0240

[OzDeaDMeat's Twitch](https://www.twitch.tv/ozdeadmeat "OzDeaDMeat's Twitch")

[OzDeaDMeaT's YouTube](https://www.youtube.com/ozdeadmeat "OzDeaDMeaT's YouTube")



## Special Thanks - ##

__Wedgie__ for his knowledge of Node-Red and integration expertise.

__Zyfr__ for his wealth of knowledge regarding all things DCS and LUA.

__MrPing__ for his knowledge in all things DCS Dedicated Server.

__Rob__ from HypeMan for showing me DCS UDP Ports and Event Handlers.

__Jeffrey Friedl__ for his work on JSON.lua.
