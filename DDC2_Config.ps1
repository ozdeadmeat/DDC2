<#
Discord to DCS Command & Control Settings Script
# Version 2.2 November
# Writen by OzDeaDMeaT
# 08-09-2023

Copyright (c) 2021 Josh 'OzDeaDMeaT' McDougall, All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
4. Utilization of this software for commercial use is prohibited unless authorized by the software copywrite holder in writing (electronic mail).

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

########################################################################################################################################################################################################
#CHANGE LOG#############################################################################################################################################################################################
########################################################################################################################################################################################################
- v2.2n Switched to Modular DCS Server install (this is now manditory, moving forward this is the only type of DCS Server that will be supported)
- v2.2l Added $SANITIZE_MIZ_SCRPT to sanitize DDC2_MASTER servers /Scripts/MissionScripting.lua files at server start
- v2.2k Added Command Permissions to Config for DDC2 v3 https://trello.com/c/63egyr46/53-ddc2-v3-commands-added-to-powershell
- v2.2j Added LANG_OVERRIDE for Language override from OS language. (NOTE: this is currently only used for date formatting)
- v2.2i Added InfluxDB setting
- v2.2h Added Scheduled Task Configuration Items
- v2.2f Added log file locations
- v2.2A Added Bidirectional Chat Capability (initial) between DDC2 and DCS
- v2.1A Added DDC2 Listening Port for data collection from DCS
- v2.0j Added $DesktopLocation
- v2.0i Added $SERVER_PRIORITY
- v2.0i Added $DCS_SERVERSTART
- v2.0e Added $DDC2_MASTER, $AUTOSTART_DCS_WAIT, $srsCLIENTSFile, $srsCONFIGFile
- v2.0c Added Moose.lua Path and $UPDATE_MOOSE variable for automated Moose.lua updates if your server keeps moose.lua external to your mission files

########################################################################################################################################################################################################
#>
########################################################################################################################################################################################################
#SERVER FILE PATH CONFIGURATION SECTION#################################################################################################################################################################
########################################################################################################################################################################################################
#DDC2 IDENTITY, DOWNTIME & COMMAND PREFIX
$ServerID = "DCS-01"																			#ServerID for DDC2
$ServerDT = "Every Monday, Thursday and Saturday at 0430-0500 AEST"								#Downtime Notice Text
$DDC2_CommandPrefix = "!"																		#This will change all commands prefixes, do not use - ' " $ # ` / \
$DDC2_Port = 6666																				#This is the port DDC2 recieves information from DCS on.
$DCS_Port = 6667																				#This is the port DDC2 recieves information from DCS on.
$LANG_OVERRIDE = ""																				#Set this to use a specific language that isnt the default one installed on the OS. NOTE: This is currently only used for date formatting, Leave as "" if you want to use the OS Default Language, formatting for this variable is 'en-AU'
########################################################################################################################################################################################################
#Paths variables are written with "", so for example "C:\Program Files\RealVNC\VNC Server\vncserver.exe" for a DIR leave the file \ out 
$usrname			= $env:USERNAME																				#Grabs the user that DDC2 is being run by
$VNC_Path			= "C:\Program Files\RealVNC\VNC Server\vncserver.exe"										#Path to VNC Server EXE
$DCS_Profile 		= "C:\Users\$usrname\Saved Games\DCS.server"			 									#DCS Server Profile Path
$dcsDIR 			= "G:\Games\DCS World"			 														#DCS Install Location
$srsDIR 			= "" #"G:\Games\SRS\Server" 																		#SRS Installation Location
$srsCONFIGFile		= "SRS-SERVER.cfg"																			#SRS DCS Config File (File Name and extension Only)
$srsCLIENTSFile		= "SRS-SERVER.json"																			#Clients Data Export for SRS (File Name and extension Only)
$LotDIR 			= "G:\Games\LotAtc" 																	#LotATC Installation Location
$Lot_Config 		= "$DCS_Profile\Mods\services\LotAtc\config.custom.lua"										#LotATC Custom Config File
$TacvDIR 			= "G:\Games\Tacview" 																	#Tacview Installation Location
$MOOSE_Path			= "G:\DDC2\SCRIPTS\MOOSE\Moose.lua"															#Path to external mission Moose.lua file
$MIST_Path			= "G:\DDC2\SCRIPTS\MIST\mist.lua"															#Path to external mission mist.lua file
$DB_File			= "G:\DDC2\database.db"															#Location of SQLite Database File, !!NOTE!! The Folder path MUST exist to generate a new DB file
$DB_Server			= ""																						#PLACEHOLDER VARIABLE

########################################################################################################################################################################################################
#DDC2 EXTERNAL CONNECTION VARIABLES#####################################################################################################################################################################
########################################################################################################################################################################################################
#For passing data to InfluxDB for Dashboarding (currently only tested for single instance deployments) 
$ENABLE_INFLUXDB	= $TRUE																						#Enables the InfluxDB connection from DDC2 to InfluxDB (NOTE, you will need to enter creds for your influx server in node-red flow)

########################################################################################################################################################################################################
#SERVER IDENTITY CONFIGURATION SECTION##################################################################################################################################################################
########################################################################################################################################################################################################
#VNC Enabled
$VNCEnabled = $TRUE
$VNCPort = "11116"
$VNCType = "RealVNC"
#HostedBy Information
$HostedByMember = $TRUE 																		#If this is set to TRUE it will display contact info for the person hosting the server rather than just the Name element
$HostedByName = "OzDeaDMeaT" 																	#Name of person paying for or providing the hosting
$HostedAT = "OzDeaDMeaT's House" 																#Name of person or Organisation Hosting the server (AWS, Azure, etc etc)
$DiscordID = '<@183573224565506048>' 															#Use single quotes, DISCORD ID of Host

#Suport Contact Info
$SupportByMember = $TRUE																		#If this is set to TRUE it will display contact info for the person supporting the server rather than just the data element
$SupportContactID = '<@1046358657639649392>' 														#Use single quotes, DISCORD ID of Host
$SupportBy = "OzDeaDMeaT" 																		#Name of person supporting the server (if SupportedByMember is set to True
$SupportTimeTXT = "The channel is checked daily between 6pm and 10pm AEST."						#Times when Support channel is being actively manned.
$SupportContactTXT = "Please post a detailed description of the issue you are experiencing in the #server-support channel and someone will get back to you." 	#Text for support request when requested in the wrong channel.

#ISP Information
$ISP = "Aussie Broadband"
$NetSpeed = '500Mbps / 200Mbps'
$DNSName = "dcs.ozdeadmeat.com"

########################################################################################################################################################################################################
#SRS TEXT TO SPEECH CONFIGURATION SECTION#################################################################################################################################################################
########################################################################################################################################################################################################
$SRS_FreqLOW = "30"			#Lower frequency limit for supported DDC2 Text to Radio 
$SRS_FreqHIGH = "400"		#Upper frequency limit for supported DDC2 Text to Radio 
$SRS_DefaultMOD = "AM"		#Default modulation transmitted if nothing supplied by user
$SRS_DefaultVOL = "1"		#Volume (Item not available in Discord due to possible abuse, peoples hearing matters yo!)
$SRS_DefaultCoal = "0"		#Default Coalition recieving the Text to Speech Radio Message 

########################################################################################################################################################################################################
#DDC2 CONFIGURATION SECTION#############################################################################################################################################################################
########################################################################################################################################################################################################
#DDC2 Master Server Settings
$DDC2_MASTER		= $TRUE																						#This tells this instance of DDC2 that it is the Primary DCS Instance on this Server, This means that all updates for these paths are managed from this instance. All other servers using the same SRS and DCS paths should be set to $FALSE
$AUTOSTART_UPDATE	= $TRUE																						# Will automatically start the update of the server
$AutoStartonUpdate	= $TRUE																						#Auto Restarts the DCS Server after updates are complete. (Default: $TRUE)
$UPDATE_DCS			= $TRUE																						#Enables and disables the automated update process for DCS
$UPDATE_SRS			= $FALSE																						#Enables and disables the automated update process for SRS
$UPDATE_LoT			= $FALSE																						#Enables and disables the automated update process for LotATC
$UPDATE_MOOSE		= $FALSE																						#Enables and disables the automated update process for Moose.lua
$DCSBETA 			= $FALSE																						#Set this variable if you wish to use the DCS Open Beta 
$SRSBETA 			= $FALSE																					#Set this variable if you wish to use the SRS Beta 
$LoTBETA 			= $FALSE																					#Not currently in use
$DCS_SERVERSTART	= 120																						#The MAXIMUM amount of time the server will wait before attempting to check if DCS is responding (used for Start Command, 3.5Ghz CPU takes approximately 70 seconds running DCS Server 2.7. DEFAULT SET TO 120, recommend not setting this any lower as it may impact the servers fix-position and set-priority calls
#DDC2 Subordinate Server Settings
$AUTOSTART_DCS_WAIT	= 60																						#This setting is for instances with $DDC2_MASTER set to $FALSE. This number should be different per instance, check how one of your instances takes to completely Autostart and then wait make sure each server has a gap of atleast this amount of time before starting DCS. e.g. if your server takes 60 seconds to initialize, for instance 2 leave it at 60 seconds, but for instance 3 you would set this variable to 120 seconds.
$AUTOSTART_DCS		= $TRUE																						#Tells the instance to Start DCS in the event that AUTOSTART_UPDATE is disabled
$SERVER_PRIORITY	= "RealTime"																				#Sets the Server Process Priorities. Valid options are "Idle", "BelowNormal", "Normal", "AboveNormal", "HighPriority", "RealTime"
$SANITIZE_MIZ_SCRPT = $True																						#If the server is the $DDC2_MASTER this will replace the /Scripts/MissionScripting.lua file with the one in the DDC2 folder

$DesktopLocation	= 1																							#Changes the location the windows are placed when the server (only 0 - 4 are supported, designed for 1920x1080 resolution)

$DDC2_HELP			= $TRUE																						#This will enable !help responses from this server (recommended to only have one server respond to !help requests if you have multiple servers monitoring a channel)
$DDC2_LINK_MASTER   = $TRUE																						#This will enable this server to do all responses for account link to go through this server. If all instances are connected via the same DB, this option should be enabled on one instance.

$SHOW_BLUPWD		= $TRUE																						#Set this to false if you do not want passwords published by DDC2 in non Admin Channels
$SHOW_REDPWD		= $TRUE																						#Set this to false if you do not want passwords published by DDC2 in non Admin Channels
$SHOW_SRVPWD		= $TRUE																						#Set this to false if you do not want passwords published by DDC2 in non Admin Channels
$SHOW_LotATC		= $FALSE																					#Will show connection information for LotATC to non-Admins
$SHOW_TACView		= $FALSE																					#Will show connection information for Tacview to non-Admins
$ACCESS_LOOP_DELAY	= 60																						#Sets the amount of time the Access loop will check for a connection. Note: This will also mean you only have this amount of time to connect to the Server. Setting it too short will mean you wont have time to connect to the server.
$UPDATE_LOOP_DELAY	= 30																						#The period of time powershell will loop to check on update status and send a new message to Discord

########################################################################################################################################################################################################
#DDC2 SERVER PASSWORD RANDOMIZER########################################################################################################################################################################
########################################################################################################################################################################################################
$EnableRandomizer	= $FALSE																					#Enables the Password Randomizer, this will execute every time before the server is started / restarted
$ServerPassword		= $FALSE																					#If set to true the server password randomizer will change the DCS Server Password
$SRSPassword		= $FALSE																					#If set to true the AWACS Side password for SRS will be randomized
$SeperateLOT 		= $FALSE																					#If set to true LoT will use a different password to the SRS Side Password for Side specific GCI Access
$SeperateTAC 		= $FALSE																					#If set to true the TACView Telemetry Client access password will be set to the Server Password

########################################################################################################################################################################################################
#DDC2_NOTIFICATIONS
$ENABLE_NOTIFY		= $TRUE 																					#Enables Event Notifications for this DDC2 Instance
$RANDOM_WEAPON		= $TRUE																						#When DCS does not correctly register a weapon kill the weapon name will be randomized
$RANDOM_DEATH		= $TRUE																						#When a player dies, DDC2 will produce a randomly generated death message notification
$FRIENDLY_FIRE		= $TRUE 																					#Enables the Event Notification for Friendly Fire events in the DDC2 Discord Notifications Channel
$MISSION_END		= $TRUE 																					#Enables the Event Notification for Mission End events in the DDC2 Discord Notifications Channel
$MISSION_LOAD_END	= $TRUE																						#Enables the Event Notification for when a Mission has loaded in the DDC2 Discord Notifications Channel
$KILL				= $TRUE 																					#Enables the Event Notification for Kill events in the DDC2 Discord Notifications Channel
$SELF_KILL			= $TRUE 																					#Enables the Event Notification for Self Kill events in the DDC2 Discord Notifications Channel
$CHANGE_SLOT		= $TRUE 																					#Enables the Event Notification for Change Slot events in the DDC2 Discord Notifications Channel
$CONNECT			= $TRUE 																					#Enables the Event Notification for Connection events in the DDC2 Discord Notifications Channel
$DISCONNECT			= $TRUE 																					#Enables the Event Notification for Disconnection events in the DDC2 Discord Notifications Channel
$CRASH				= $TRUE 																					#Enables the Event Notification for Crash events in the DDC2 Discord Notifications Channel
$EJECT				= $TRUE 																					#Enables the Event Notification for Eject events in the DDC2 Discord Notifications Channel
$TAKEOFF			= $TRUE 																					#Enables the Event Notification for Take Off events in the DDC2 Discord Notifications Channel
$LANDING			= $TRUE 																					#Enables the Event Notification for Landing events in the DDC2 Discord Notifications Channel
$PILOT_DEATH		= $TRUE 																					#Enables the Event Notification for Pilot Death events in the DDC2 Discord Notifications Channel

########################################################################################################################################################################################################
#SERVER REBOOT SCHEDULED TASK###########################################################################################################################################################################
########################################################################################################################################################################################################
$SCHED_TASK_REBOOT	= $TRUE																						#Enables / Disables the weekly Automated reboot function of this DDC2 instance (Note: This that DDC2_MASTER is required for this to work)
$MONDAY				= $TRUE																						#If set to True Server will reboot on this day every week
$TUESDAY			= $TRUE																						#If set to True Server will reboot on this day every week
$WEDNESDAY			= $TRUE																						#If set to True Server will reboot on this day every week
$THURSDAY			= $TRUE																						#If set to True Server will reboot on this day every week
$FRIDAY				= $TRUE																						#If set to True Server will reboot on this day every week
$SATURDAY			= $TRUE																						#If set to True Server will reboot on this day every week
$SUNDAY				= $TRUE																						#If set to True Server will reboot on this day every week
$RESTART_TIME		= "7:30"																					#Time server is to be restarted. NOTE: Notifications of Maintainence period will commence 90 minutes prior server restart

########################################################################################################################################################################################################
#The Variabled below should not need configuration but are listed here if you need to configure them.
########################################################################################################################################################################################################
$DDC2_Hooks 		= "$DCS_Profile\Scripts\Hooks\DDC2_Hooks.lua"												#DDC2 DCS Hooks File
$DDC2_Hooks_Log		= "$DCS_Profile\Logs\DDC2.log"																#DDC2 DCS Hooks Log File

$dcsBIN				= "$dcsDIR\bin" 																			#DCS Bin Folder
$dcsEXE 			= "$dcsBIN\DCS_server.exe"																	#DCS Executable 
$DCS_Log			= "$DCS_Profile\Logs\DCS.log"																#DCS Log File
$DCS_Config 		= "$DCS_Profile\Config\serverSettings.lua"													#DCS Server Settings File
$DCS_AutoE			= "$DCS_Profile\Config\autoexec.cfg"														#DCS Autoexec.cfg
$DCS_WindowTitle	= split-path $DCS_Profile -Leaf																#Used to distinguish which instance of DCS should be manipulated by this instance of DDC2 (MULTI-INSTANCE CAPABILITY)
$dcsargs 			= "-w $DCS_WindowTitle"																		#DCS Server Arguments
$DCS_Updater 		= "$dcsBIN\dcs_updater.exe" 																#DCS Updater Executable
#$DCS_Updater_Args 	= if($DCSBETA) {"update @dcs_server.openbeta --quiet"} else {"update @dcs_server.release --quiet"} #DCS Updater Arguments
$DCS_Updater_Args 	="update @dcs_server.release --quiet"														#DCS Updater Arguments

$nodeEXE			= "C:\Program Files\nodejs\node.exe"														#node.js installation location
$OlympusJSON		= "olympus.json"																			#Olympus.json search param

$TacvEXE 			= "$TacvDIR\Tacview64.exe" 																	#Tacview Executable
$TACv_Entry 		= "$DCS_Profile\Mods\Tech\Tacview\entry.lua"												#Tacview Entry Data
$TACv_Config 		= "$DCS_Profile\Config\options.lua"															#Tacview Configuration File

$Lot_Entry			= "$DCS_Profile\Mods\services\LotAtc\entry.lua"												#LotATC Entry Data
$Lot_Updater 		= "$LotDIR\LotAtc_updater.exe"																#LotATC Updater Executable
$Lot_Updater_Args 	= "-c up"																					#LotATC Updater Arguments

$srsEXE 			= "$srsDIR\SR-Server.exe" 																	#SRS Executable
$SRS_Log 			= "$srsDIR\serverlog.txt"																	#SRS Log File
$SRS_Config 		= "$srsDIR\$srsCONFIGFile"																	#SRS DCS Config File & Path
$SRS_Clients		= "$srsDIR\$srsCLIENTSFile"																	#Clients Data Export File & Path
$SRSargs 			= "-cfg=`"$srsCONFIGFile`""																	#DCS Server Arguments
$SRS_AutoConnect	= "$DCS_Profile\Scripts\Hooks\DCS-SRS-AutoConnectGameGUI.lua"								#SRS AutoConnect File
$SRS_External		= "$srsDIR\DCS-SR-ExternalAudio.exe"														#SRS External TXT to Speech exe
$SRS_Updater 		= "$srsDIR\SRS-AutoUpdater.exe"																#SRS Updater Executable
$SRS_Updater_Args 	= if($SRSBETA) {"-beta","-server","-path=$srsDIR"} else {"-server","-path=$srsDIR"}			#SRS Updater Arguments 
########################################################################################################################################################################################################
#DISCORD CHANNEL.ID CONFIGURATION SECTION###############################################################################################################################################################
########################################################################################################################################################################################################
#DISCORD GUIDE ID
$GuildID = "1045621898584805416"

#DISCORD GROUP ID's (Note, you can have as many groups as you want here)
$BluForGrp = "1045625922436464650"; 			#BlueForce       - (Info Only User Group)
$RedForGrp = "1045625922436464650";				#RedForce		 - (Info Only User Group)
$PwrUsrGrp = "1046358950683103242"; 			#Server Power Users  - (Server Power User Group)
$AdminGrp = "1046358657639649392"; 				#Server Admnins      - (Server Admin User Group)

#DISCORD CHANNEL ID's
$AdminChannel = "1047076082551115816"; 			#For Admin Messages ONLY
$BlueChannel = "00000000000000000000"; 			#For Blue Force Messages ONLY
$RedChannel = "00000000000000000000"; 			#For Red Force Messages ONLY
$LogChannel = "1046404887438696568"; 			#For Log Messages ONLY
$SupportChannel = "00000000000000000000";		#For support requests ONLY
$ServerStatusMessage = "1047089267756761118";	#This is the message ID that will be updated with the servers current status
$ServerStatusChannel = "1045624163039186966";	#Displays Notifications for servers (NOTIFICATIONS CHANNEL)
$ServerNotifications = "1045624414399627305";	#This channel will keep a running log of what is going on in your server. Take off, connected etc events.
$ServerChatChannel = "1143810998826958933";		#This channel will allow people to chat via text message between the discord and DCS.

########################################################################################################################################################################################################
#DISCORD PERMISSIONS PER DDC2 COMMAND###################################################################################################################################################################
########################################################################################################################################################################################################
$radioPerm 		= @($BluForGrp,$RedForGrp,$PwrUsrGrp,$AdminGrp) 	#Everyone
$acclinkPerm	= @($BluForGrp,$RedForGrp,$PwrUsrGrp,$AdminGrp) 	#Everyone				
$testPerm 		= @($BluForGrp,$RedForGrp,$PwrUsrGrp,$AdminGrp) 	#Everyone				
$versionPerm 	= @($BluForGrp,$RedForGrp,$PwrUsrGrp,$AdminGrp) 	#Everyone				
$infoPerm 		= @($BluForGrp,$RedForGrp,$PwrUsrGrp,$AdminGrp) 	#Everyone				
$supportPerm 	= @($BluForGrp,$RedForGrp,$PwrUsrGrp,$AdminGrp) 	#Everyone				
$helpPerm 		= @($BluForGrp,$RedForGrp,$PwrUsrGrp,$AdminGrp) 	#Everyone				
$punishPerm 	= @($BluForGrp,$RedForGrp,$PwrUsrGrp,$AdminGrp) 	#Everyone
$startPerm 		= @($PwrUsrGrp,$AdminGrp)							#Power Users and Admins	
$stopPerm 		= @($PwrUsrGrp,$AdminGrp)							#Power Users and Admins	
$restartPerm 	= @($PwrUsrGrp,$AdminGrp)							#Power Users and Admins	
$statusPerm 	= @($PwrUsrGrp,$AdminGrp)							#Power Users and Admins	
$kickPerms		= @($PwrUsrGrp,$AdminGrp)							#Power Users and Admins	
$kickslotPerms	= @($PwrUsrGrp,$AdminGrp)							#Power Users and Admins
$softbanPerms	= @($PwrUsrGrp,$AdminGrp)							#Power Users and Admins	
$banlistPerms	= @($PwrUsrGrp,$AdminGrp)							#Power Users and Admins
$msnrestartPerms= @($PwrUsrGrp,$AdminGrp)							#Power Users and Admins	
$msnnextPerms 	= @($PwrUsrGrp,$AdminGrp)							#Power Users and Admins	
$msnlistPerms 	= @($PwrUsrGrp,$AdminGrp)							#Power Users and Admins	
$msnloadPerms 	= @($PwrUsrGrp,$AdminGrp)							#Power Users and Admins	
$maintmPerms 	= @($PwrUsrGrp,$AdminGrp)							#Power Users and Admins	
$reservePerms 	= @($PwrUsrGrp,$AdminGrp)							#Power Users and Admins	
$spawnPerms 	= @($PwrUsrGrp,$AdminGrp)							#Power Users and Admins	
$updatePerm		= @($AdminGrp)										#Admins ONLY			
$accessPerm 	= @($AdminGrp)										#Admins ONLY			
$rebootPerm		= @($AdminGrp)										#Admins ONLY			
$refreshPerm	= @($AdminGrp)										#Admins ONLY			
$portsPerm		= @($AdminGrp)										#Admins ONLY			
$configPerm		= @($AdminGrp)										#Admins ONLY
$banPerms		= @($AdminGrp)										#Admins ONLY
$unbanPerms		= @($AdminGrp)										#Admins ONLY
$runPerms		= @($AdminGrp)										#Admins ONLY


#The line below disables reboot and update permissions if server is not Master Instance
if(-not $DDC2_MASTER) {
	$rebootPerm		= @()
	$updatePerm		= @()
	$AUTOSTART_UPDATE = $FALSE
	$AutoStartonUpdate = $FALSE
	$UPDATE_DCS = $FALSE
	$UPDATE_SRS	= $FALSE
	$UPDATE_LoT	= $FALSE
	$UPDATE_MOOSE = $FALSE
	$SCHEDULED_REBOOT = $FALSE
}
#####################################################################################################################################################################################################################
### DONT EDIT BELOW THIS LINE ### DONT EDIT BELOW THIS LINE ### DONT EDIT BELOW THIS LINE ### DONT EDIT BELOW THIS LINE ### DONT EDIT BELOW THIS LINE ### DONT EDIT BELOW THIS LINE ### DONT EDIT BELOW THIS LINE ###
#####################################################################################################################################################################################################################
if($LANG_OVERRIDE -eq "") {$LANG_OVERRIDE = (Get-WinSystemLocale).Name}

$Lot_Release = If($LoTBETA) {"Beta"} else {"Stable"}
$SRS_Release = If($SRSBETA) {"Beta"} else {"Stable"}
$DCS_Release = If($DCSBETA) {"Beta"} else {"Stable"}

$NOTIFICATIONS = $null
$NOTIFICATIONS = New-Object -TypeName psobject
$NOTIFICATIONS | Add-Member -MemberType NoteProperty -Name enabled -Value $ENABLE_NOTIFY
$NOTIFICATIONS | Add-Member -MemberType NoteProperty -Name RandomWeapon -Value $RANDOM_WEAPON
$NOTIFICATIONS | Add-Member -MemberType NoteProperty -Name RandomDeath -Value $RANDOM_DEATH
$NOTIFICATIONS | Add-Member -MemberType NoteProperty -Name friendly_fire -Value $FRIENDLY_FIRE
$NOTIFICATIONS | Add-Member -MemberType NoteProperty -Name mission_end -Value $MISSION_END
$NOTIFICATIONS | Add-Member -MemberType NoteProperty -Name mission_load_end -Value $MISSION_LOAD_END
$NOTIFICATIONS | Add-Member -MemberType NoteProperty -Name kill -Value $KILL
$NOTIFICATIONS | Add-Member -MemberType NoteProperty -Name self_kill -Value $SELF_KILL
$NOTIFICATIONS | Add-Member -MemberType NoteProperty -Name change_slot -Value $CHANGE_SLOT
$NOTIFICATIONS | Add-Member -MemberType NoteProperty -Name connect -Value $CONNECT
$NOTIFICATIONS | Add-Member -MemberType NoteProperty -Name disconnect -Value $DISCONNECT
$NOTIFICATIONS | Add-Member -MemberType NoteProperty -Name crash -Value $CRASH
$NOTIFICATIONS | Add-Member -MemberType NoteProperty -Name eject -Value $EJECT
$NOTIFICATIONS | Add-Member -MemberType NoteProperty -Name takeoff -Value $TAKEOFF
$NOTIFICATIONS | Add-Member -MemberType NoteProperty -Name landing -Value $LANDING
$NOTIFICATIONS | Add-Member -MemberType NoteProperty -Name pilot_death -Value $PILOT_DEATH


$Channel = $null
$Channel = New-Object -TypeName psobject
$Channel | Add-Member -MemberType NoteProperty -Name GuildID -Value $GuildID
$Channel | Add-Member -MemberType NoteProperty -Name Admin -Value $AdminChannel
$Channel | Add-Member -MemberType NoteProperty -Name Blue -Value $BlueChannel
$Channel | Add-Member -MemberType NoteProperty -Name Red -Value $RedChannel
$Channel | Add-Member -MemberType NoteProperty -Name Log -Value $LogChannel
$Channel | Add-Member -MemberType NoteProperty -Name Support -Value $SupportChannel
$Channel | Add-Member -MemberType NoteProperty -Name ServerStatus -Value $ServerStatusChannel
$Channel | Add-Member -MemberType NoteProperty -Name ServerStatusMessage -Value $ServerStatusMessage
$Channel | Add-Member -MemberType NoteProperty -Name ServerNotifications -Value $ServerNotifications
$Channel | Add-Member -MemberType NoteProperty -Name ServerChatChannel -Value $ServerChatChannel

$HostedBy = $null
$HostedBy = New-Object -TypeName psobject
$HostedBy | Add-Member -MemberType NoteProperty -Name HostedByMember -Value $HostedByMember
$HostedBy | Add-Member -MemberType NoteProperty -Name HostedBy -Value $HostedByName
$HostedBy | Add-Member -MemberType NoteProperty -Name HostedAT -Value $HostedAT
$HostedBy | Add-Member -MemberType NoteProperty -Name DiscordID -Value $DiscordID
$HostedBy | Add-Member -MemberType NoteProperty -Name ISP -Value $ISP
$HostedBy | Add-Member -MemberType NoteProperty -Name NetSpeed -Value $NetSpeed
$HostedBy | Add-Member -MemberType NoteProperty -Name DNSName -Value $DNSName

$Support = $null
$Support = New-Object -TypeName psobject
$Support | Add-Member -MemberType NoteProperty -Name SupportByMember -Value $SupportByMember
$Support | Add-Member -MemberType NoteProperty -Name SupportBy -Value $SupportBy
$Support | Add-Member -MemberType NoteProperty -Name SupportContactTXT -Value $SupportContactTXT
$Support | Add-Member -MemberType NoteProperty -Name SupportTimeTXT -Value $SupportTimeTXT
$Support | Add-Member -MemberType NoteProperty -Name SupportContactID -Value $SupportContactID

####
$CMDPerms = $null
$CMDPerms = New-Object -TypeName psobject
$CMDPerms | Add-Member -MemberType NoteProperty -Name radio -Value $radioPerm
$CMDPerms | Add-Member -MemberType NoteProperty -Name acclink  -Value $acclinkPerm
$CMDPerms | Add-Member -MemberType NoteProperty -Name test -Value $TestPerm
$CMDPerms | Add-Member -MemberType NoteProperty -Name version -Value $versionPerm
$CMDPerms | Add-Member -MemberType NoteProperty -Name info -Value $infoPerm
$CMDPerms | Add-Member -MemberType NoteProperty -Name support -Value $supportPerm
$CMDPerms | Add-Member -MemberType NoteProperty -Name help -Value $helpPerm
$CMDPerms | Add-Member -MemberType NoteProperty -Name punish -Value $punishPerm
$CMDPerms | Add-Member -MemberType NoteProperty -Name start -Value $startPerm
$CMDPerms | Add-Member -MemberType NoteProperty -Name stop -Value $stopPerm
$CMDPerms | Add-Member -MemberType NoteProperty -Name restart -Value $restartPerm
$CMDPerms | Add-Member -MemberType NoteProperty -Name status -Value $statusPerm
$CMDPerms | Add-Member -MemberType NoteProperty -Name kick -Value $kickPerms
$CMDPerms | Add-Member -MemberType NoteProperty -Name kickslot -Value $kickslotPerms
$CMDPerms | Add-Member -MemberType NoteProperty -Name softban -Value $softbanPerms
$CMDPerms | Add-Member -MemberType NoteProperty -Name banlist -Value $banlistPerms
$CMDPerms | Add-Member -MemberType NoteProperty -Name msnrestart -Value $msnrestartPerms
$CMDPerms | Add-Member -MemberType NoteProperty -Name msnnext -Value $msnnextPerms
$CMDPerms | Add-Member -MemberType NoteProperty -Name msnlist -Value $msnlistPerms
$CMDPerms | Add-Member -MemberType NoteProperty -Name msnload -Value $msnloadPerms
$CMDPerms | Add-Member -MemberType NoteProperty -Name maintm -Value $maintmPerms
$CMDPerms | Add-Member -MemberType NoteProperty -Name reserve -Value $reservePerms
$CMDPerms | Add-Member -MemberType NoteProperty -Name spawn -Value $spawnPerms
$CMDPerms | Add-Member -MemberType NoteProperty -Name update -Value $updatePerm
$CMDPerms | Add-Member -MemberType NoteProperty -Name access -Value $accessPerm
$CMDPerms | Add-Member -MemberType NoteProperty -Name reboot -Value $rebootPerm
$CMDPerms | Add-Member -MemberType NoteProperty -Name refresh -Value $refreshPerm
$CMDPerms | Add-Member -MemberType NoteProperty -Name ports -Value $portsPerm
$CMDPerms | Add-Member -MemberType NoteProperty -Name config -Value $configPerm
$CMDPerms | Add-Member -MemberType NoteProperty -Name ban -Value $banPerms
$CMDPerms | Add-Member -MemberType NoteProperty -Name unban -Value $unbanPerms
$CMDPerms | Add-Member -MemberType NoteProperty -Name run -Value $runPerms


$SCHEDULEDRESTART = $null
$SCHEDULEDRESTART = New-Object -TypeName psobject
$SCHEDULEDRESTART | Add-Member -MemberType NoteProperty -Name TASK_REBOOT -Value $SCHED_TASK_REBOOT
if($DDC2_MASTER) {
	$SCHEDULEDRESTART | Add-Member -MemberType NoteProperty -Name DDC2_MASTER -Value $ServerID
} else {
	$SCHEDULEDRESTART | Add-Member -MemberType NoteProperty -Name DDC2_MASTER -Value "I ($ServerID)AM NOT THE DDC2 MASTER"
}
$SCHEDULEDRESTART | Add-Member -MemberType NoteProperty -Name Monday -Value $MONDAY
$SCHEDULEDRESTART | Add-Member -MemberType NoteProperty -Name Tuesday -Value $TUESDAY
$SCHEDULEDRESTART | Add-Member -MemberType NoteProperty -Name Wednesday -Value $WEDNESDAY
$SCHEDULEDRESTART | Add-Member -MemberType NoteProperty -Name Thursday -Value $THURSDAY
$SCHEDULEDRESTART | Add-Member -MemberType NoteProperty -Name Friday -Value $FRIDAY
$SCHEDULEDRESTART | Add-Member -MemberType NoteProperty -Name Saturday -Value $SATURDAY
$SCHEDULEDRESTART | Add-Member -MemberType NoteProperty -Name Sunday -Value $SUNDAY
$SCHEDULEDRESTART | Add-Member -MemberType NoteProperty -Name Restart_Time -Value $RESTART_TIME


########################################################################################################################################################################################################
#Instance Window Positions
#Does the Initial Position to setup the Array
$PosArray = @(
[pscustomobject]@{`
POSid = 0;`
SRS_X = 4;`
SRS_Y = 170;`
DCS_X = 4;`
DCS_Y = 10;`
DCS_SizeX = 336;`
DCS_SizeY = 160}
)
$PosArray = Add-Position -POSid 1 -SRS_X 340 -SRS_Y 170 -DCS_X 340 -DCS_Y 10 -DCS_SizeX 336 -DCS_SizeY 160
$PosArray = Add-Position -POSid 2 -SRS_X 676 -SRS_Y 170 -DCS_X 676 -DCS_Y 10 -DCS_SizeX 336 -DCS_SizeY 160
$PosArray = Add-Position -POSid 3 -SRS_X 1012 -SRS_Y 170 -DCS_X 1012 -DCS_Y 10 -DCS_SizeX 336 -DCS_SizeY 160
$PosArray = Add-Position -POSid 4 -SRS_X 1348 -SRS_Y 170 -DCS_X 1348 -DCS_Y 10 -DCS_SizeX 336 -DCS_SizeY 160
########################################################################################################################################################################################################
$DDC2_PSConfig_Version = "v2.2 November"