<#
Discord to DCS Command & Control Settings Script
# Version 2.0j
# Writen by OzDeaDMeaT
# 04-05-2021
########################################################################################################################################################################################################
#CHANGE LOG#############################################################################################################################################################################################
########################################################################################################################################################################################################
- v2.0j Added $DesktopLocation
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
#Paths variables are written with "", so for example "C:\Program Files\RealVNC\VNC Server\vncserver.exe" for a DIR leave the file \ out 
$VNC_Path			= "PATH DATA OPTIONAL"										#Path to VNC Server EXE
$DCS_Profile 		= "PATH DATA REQUIRED" 									#DCS Server Profile Path
$dcsDIR 			= "PATH DATA REQUIRED"			 												#DCS Install Location
$srsDIR 			= "PATH DATA OPTIONAL" 												#SRS Installation Location
$srsCONFIGFile		= "SRS CONFIG FILENAME"																			#SRS DCS Config File (File Name and extension Only)
$srsCLIENTSFile		= "SRS CLIENT JSON FILENAME"																			#Clients Data Export for SRS (File Name and extension Only)
$LotDIR 			= "PATH DATA OPTIONAL" 																	#LotATC Installation Location
$Lot_Config 		= "$DCS_Profile\Mods\services\LotAtc\config.custom.lua"										#LotATC Custom Config File
$TacvDIR 			= "PATH DATA OPTIONAL" 																	#Tacview Installation Location
$MOOSE_Path			= "PATH DATA OPTIONAL"															#Path to external mission Moose.lua file

########################################################################################################################################################################################################
#SERVER IDENTITY CONFIGURATION SECTION##################################################################################################################################################################
########################################################################################################################################################################################################
#DDC2 IDENTITY, DOWNTIME & COMMAND PREFIX
$ServerID = "DATA REQUIRED"																			#ServerID for DDC2
$ServerDT = "DATA REQUIRED"															#Downtime Notice Text
$DDC2_CommandPrefix = "!"																		#This will change all commands prefixes, do not use - ' " $ # ` / \

#VNC Enabled
$VNCEnabled = $FALSE
$VNCPort = ""
$VNCType = ""

#HostedBy Information
$HostedByMember = $TRUE 																		#If this is set to TRUE it will display contact info for the person hosting the server rather than just the Name element
$HostedByName = "DATA REQUIRED" 																	#Name of person paying for or providing the hosting
$HostedAT = "DATA REQUIRED" 																#Name of person or Organisation Hosting the server (AWS, Azure, etc etc)
$DiscordID = 'DATA REQUIRED' 															#Use single quotes, DISCORD ID of Host

#Suport Contact Info
$SupportByMember = $TRUE																		#If this is set to TRUE it will display contact info for the person supporting the server rather than just the data element
$SupportContactID = 'DATA REQUIRED' 													#Use single quotes, DISCORD ID of Host
$SupportBy = "DATA REQUIRED" 																		#Name of person supporting the server (if SupportedByMember is set to True
$SupportTimeTXT = "DATA REQUIRED"						#Times when Support channel is being actively manned.
$SupportContactTXT = "DATA REQUIRED" 	#Text for support request when requested in the wrong channel.

#ISP Information
$ISP = "DATA REQUIRED"
$NetSpeed = 'DATA REQUIRED'
$DNSName = "DATA REQUIRED"

########################################################################################################################################################################################################
#SRS TEXT TO SPEECH CONFIGURATION SECTION#################################################################################################################################################################
########################################################################################################################################################################################################
$SRS_FreqLOW = "30"			#Lower frequency limit for supported DDC2 Text to Radio 
$SRS_FreqHIGH = "400"		#Upper frequency limit for supported DDC2 Text to Radio 
$SRS_DefaultMOD = "AM"		#Default modulation transmitted if nothing supplied by user
$SRS_DefaultVOL = 1			#Volume (Item not available in Discord due to possible abuse, peoples hearing matters yo!)
$SRS_DefaultCoal = 0		#Default Coalition recieving the Text to Speech Radio Message 

########################################################################################################################################################################################################
#DDC2 CONFIGURATION SECTION#############################################################################################################################################################################
########################################################################################################################################################################################################
#DDC2 Master Server Settings
$DDC2_MASTER		= $TRUE																						#This tells this instance of DDC2 that it is the Primary DCS Instance on this Server, This means that all updates for these paths are managed from this instance. All other servers using the same SRS and DCS paths should be set to $FALSE
$AUTOSTART_UPDATE	= $TRUE																						# Will automatically start the update of the server
$AutoStartonUpdate	= $TRUE																						#Auto Restarts the DCS Server after updates are complete. (Default: $TRUE)
$UPDATE_DCS			= $TRUE																						#Enables and disables the automated update process for DCS
$UPDATE_SRS			= $TRUE																						#Enables and disables the automated update process for SRS
$UPDATE_LoT			= $TRUE																						#Enables and disables the automated update process for LotATC
$UPDATE_MOOSE		= $FALSE																						#Enables and disables the automated update process for Moose.lua
$DCSBETA 			= $FALSE																					#Set this variable if you wish to use the DCS Open Beta 
$SRSBETA 			= $FALSE																					#Set this variable if you wish to use the SRS Beta 
$LoTBETA 			= $FALSE																					#Not currently in use
#DDC2 Subordinate Server Settings
$AUTOSTART_DCS_WAIT	= 60																						#This setting is for instances with $DDC2_MASTER set to $FALSE. This number should be different per instance, check how one of your instances takes to completely Autostart and then wait make sure each server has a gap of atleast this amount of time before starting DCS. e.g. if your server takes 60 seconds to initialize, for instance 2 leave it at 60 seconds, but for instance 3 you would set this variable to 120 seconds.
$AUTOSTART_DCS		= $TRUE																						#Tells the instance to Start DCS in the event that AUTOSTART_UPDATE is disabled
$DCS_SERVERSTART	= 60																						#The amount of time the server will wait before attempting to check if DCS is responding (used for Start Command, 3.5Ghz CPU takes approximately 40 seconds running DCS Server 2.7.
$SERVER_PRIORITY	= "AboveNormal"																				#Sets the Server Process Priorities. Valid options are "Idle", "BelowNormal", "Normal", "AboveNormal", "HighPriority", "AboveNormal"

$DesktopLocation	= 1																							#Changes the location the windows are placed when the server (only 0 - 4 are supported, designed for 1920x1080 resolution)

$DDC2_HELP			= $TRUE																						#This will enable !help responses from this server (recommended to only have one server respond to !help requests if you have multiple servers monitoring a channel)

$SHOW_BLUPWD		= $TRUE																						#Set this to false if you do not want passwords published by DDC2 in non Admin Channels
$SHOW_REDPWD		= $TRUE																						#Set this to false if you do not want passwords published by DDC2 in non Admin Channels
$SHOW_SRVPWD		= $TRUE																						#Set this to false if you do not want passwords published by DDC2 in non Admin Channels
$SHOW_LotATC		= $TRUE																					#Will show connection information for LotATC to non-Admins
$SHOW_TACView		= $TRUE																					#Will show connection information for Tacview to non-Admins
$ACCESS_LOOP_DELAY	= 60																						#Sets the amount of time the Access loop will check for a connection. Note: This will also mean you only have this amount of time to connect to the Server. Setting it too short will mean you wont have time to connect to the server.
$UPDATE_LOOP_DELAY	= 30																						#The period of time powershell will loop to check on update status and send a new message to Discord

########################################################################################################################################################################################################
#DDC2 SERVER PASSWORD RANDOMIZER########################################################################################################################################################################
########################################################################################################################################################################################################
$EnableRandomizer	= $FALSE																					#Enables the Password Randomizer, this will execute every time before the server is started / restarted
$ServerPassword		= $FALSE																					#If set to true the server password randomizer will change the DCS Server Password
$SRSPassword		= $FALSE																						#If set to true the AWACS Side password for SRS will be randomized
$SeperateLOT 		= $FALSE																					#If set to true LoT will use a different password to the SRS Side Password for Side specific GCI Access
$SeperateTAC 		= $FALSE																						#If set to true the TACView Telemetry Client access password will be set to the Server Password

########################################################################################################################################################################################################
#DDC2_NOTIFICATIONS
#COMING SOON.... HOPEFULLY

########################################################################################################################################################################################################
#The Variabled below should not need configuration but are listed here if you need to configure them.
########################################################################################################################################################################################################
$dcsBIN				= "$dcsDIR\bin" 																			#DCS Bin Folder
$dcsEXE 			= "$dcsBIN\DCS.exe"																			#DCS Executable 
$DCS_Config 		= "$DCS_Profile\Config\serverSettings.lua"													#DCS Server Settings File
$DCS_AutoE			= "$DCS_Profile\Config\autoexec.cfg"														#DCS Autoexec.cfg
$DCS_WindowTitle	= split-path $DCS_Profile -Leaf																#Used to distinguish which instance of DCS should be manipulated by this instance of DDC2 (MULTI-INSTANCE CAPABILITY)
$dcsargs 			= "--server --norender -w $DCS_WindowTitle"													#DCS Server Arguments
$DCS_Updater 		= "$dcsBIN\dcs_updater.exe" 																#DCS Updater Executable
$DCS_Updater_Args 	= if($DCSBETA) {"update @openbeta --quiet"} else {"update @release --quiet"}				#DCS Updater Arguments

$TacvEXE 			= "$TacvDIR\Tacview64.exe" 																	#Tacview Executable
$TACv_Entry 		= "$DCS_Profile\Mods\Tech\Tacview\entry.lua"												#Tacview Entry Data
$TACv_Config 		= "$DCS_Profile\Config\options.lua"															#Tacview Configuration File

$Lot_Entry			= "$DCS_Profile\Mods\services\LotAtc\entry.lua"												#LotATC Entry Data
$Lot_Updater 		= "$LotDIR\LotAtc_updater.exe"																#LotATC Updater Executable
$Lot_Updater_Args 	= "-c up"																					#LotATC Updater Arguments

$srsEXE 			= "$srsDIR\SR-Server.exe" 																	#SRS Executable
$SRS_Entry 			= "$DCS_Profile\Mods\services\DCS-SRS\entry.lua"											#SRS DCS Entry Data
$SRS_Config 		= "$srsDIR\$srsCONFIGFile"																	#SRS DCS Config File & Path
$SRS_Clients		= "$srsDIR\$srsCLIENTSFile"																	#Clients Data Export File & Path
$SRSargs 			= "-cfg=`"$srsCONFIGFile`""																	#DCS Server Arguments
#$SRSargs 			= "-cfg=`"$SRS_Config`""																	#DCS Server Arguments
$SRS_AutoConnect	= "$DCS_Profile\Scripts\Hooks\DCS-SRS-AutoConnectGameGUI.lua"								#SRS AutoConnect File
$SRS_External		= "$srsDIR\DCS-SR-ExternalAudio.exe"														#SRS External TXT to Speech exe
$SRS_Updater 		= "$srsDIR\SRS-AutoUpdater.exe"																#SRS Updater Executable
$SRS_Updater_Args 	= if($SRSBETA) {"-beta","-server","-path=$srsDIR"} else {"-server","-path=$srsDIR"}			#SRS Updater Arguments 
########################################################################################################################################################################################################
#DISCORD CHANNEL.ID CONFIGURATION SECTION###############################################################################################################################################################
########################################################################################################################################################################################################
#DISCORD GROUP ID's (Note, you can have as many groups as you want here)
$BluForGrp = ""; 	#Cave Dwellers       - (Info Only User Group)
$RedForGrp = "";					#Red Group Users Only
$PwrUsrGrp = ""; 	#Server Power Users  - (Server Power User Group)
$AdminGrp = ""; 	#Server Admnins      - (Server Admin User Group)

#DISCORD CHANNEL ID's
$AdminChannel = ""; 	#For Admin Messages ONLY
$BlueChannel = ""; 	#For Blue Force Messages ONLY
$RedChannel = ""; 	#For Red Force Messages ONLY
$LogChannel = ""; 	#For Log Messages ONLY
$SupportChannel = "";	#For support requests ONLY
$ServerStatus = "";	#Displays Notifications for servers

#DISCORD PERMISSIONS PER DDC2 COMMAND

#Commands Executed in NR and not PS
$testPerm 		= @($BluForGrp,$RedForGrp,$PwrUsrGrp,$AdminGrp) 	#Everyone				NA (16)
$versionPerm 	= @($BluForGrp,$RedForGrp,$PwrUsrGrp,$AdminGrp) 	#Everyone				12
$infoPerm 		= @($BluForGrp,$RedForGrp,$PwrUsrGrp,$AdminGrp) 	#Everyone				13
$supportPerm 	= @($BluForGrp,$RedForGrp,$PwrUsrGrp,$AdminGrp) 	#Everyone				14
$helpPerm 		= @($BluForGrp,$RedForGrp,$PwrUsrGrp,$AdminGrp) 	#Everyone				15

#Admin Commands Executed in NR and not PS
$refreshPerm	= @($AdminGrp)										#Admins ONLY			9
$portsPerm		= @($AdminGrp)										#Admins ONLY			10
$configPerm		= @($AdminGrp)										#Admins ONLY			11

#Commands Executed in PS

$radioPerm 		= @($BluForGrp,$RedForGrp,$PwrUsrGrp,$AdminGrp) 	#Everyone				1
$startPerm 		= @($PwrUsrGrp,$AdminGrp)							#Power Users and Admins	2
$stopPerm 		= @($PwrUsrGrp,$AdminGrp)							#Power Users and Admins	3
$restartPerm 	= @($PwrUsrGrp,$AdminGrp)							#Power Users and Admins	4
$statusPerm 	= @($PwrUsrGrp,$AdminGrp)							#Power Users and Admins	5	
$updatePerm		= @($AdminGrp)										#Admins ONLY			6
$accessPerm 	= @($AdminGrp)										#Admins ONLY			7
$rebootPerm		= @($AdminGrp)										#Admins ONLY			8

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
}
#####################################################################################################################################################################################################################
### DONT EDIT BELOW THIS LINE ### DONT EDIT BELOW THIS LINE ### DONT EDIT BELOW THIS LINE ### DONT EDIT BELOW THIS LINE ### DONT EDIT BELOW THIS LINE ### DONT EDIT BELOW THIS LINE ### DONT EDIT BELOW THIS LINE ###
#####################################################################################################################################################################################################################
$Lot_Release = If($LoTBETA) {"Beta"} else {"Stable"}
$SRS_Release = If($SRSBETA) {"Beta"} else {"Stable"}
$DCS_Release = If($DCSBETA) {"Beta"} else {"Stable"}

$Channel = $null
$Channel = New-Object -TypeName psobject
$Channel | Add-Member -MemberType NoteProperty -Name Admin -Value $AdminChannel
$Channel | Add-Member -MemberType NoteProperty -Name Blue -Value $BlueChannel
$Channel | Add-Member -MemberType NoteProperty -Name Red -Value $RedChannel
$Channel | Add-Member -MemberType NoteProperty -Name Log -Value $LogChannel
$Channel | Add-Member -MemberType NoteProperty -Name Support -Value $SupportChannel

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
$CMDPerms | Add-Member -MemberType NoteProperty -Name test -Value $TestPerm
$CMDPerms | Add-Member -MemberType NoteProperty -Name version -Value $versionPerm
$CMDPerms | Add-Member -MemberType NoteProperty -Name info -Value $infoPerm
$CMDPerms | Add-Member -MemberType NoteProperty -Name support -Value $supportPerm
$CMDPerms | Add-Member -MemberType NoteProperty -Name help -Value $helpPerm
$CMDPerms | Add-Member -MemberType NoteProperty -Name refresh -Value $refreshPerm
$CMDPerms | Add-Member -MemberType NoteProperty -Name access -Value $accessPerm
$CMDPerms | Add-Member -MemberType NoteProperty -Name ports -Value $portsPerm
$CMDPerms | Add-Member -MemberType NoteProperty -Name config -Value $configPerm
$CMDPerms | Add-Member -MemberType NoteProperty -Name start -Value $startPerm
$CMDPerms | Add-Member -MemberType NoteProperty -Name restart -Value $restartPerm
$CMDPerms | Add-Member -MemberType NoteProperty -Name stop -Value $stopPerm
$CMDPerms | Add-Member -MemberType NoteProperty -Name update -Value $updatePerm
$CMDPerms | Add-Member -MemberType NoteProperty -Name status -Value $statusPerm
$CMDPerms | Add-Member -MemberType NoteProperty -Name reboot -Value $rebootPerm
$CMDPerms | Add-Member -MemberType NoteProperty -Name radio -Value $radioPerm

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
$DDC2_PSConfig_Version = "v2.0j"
