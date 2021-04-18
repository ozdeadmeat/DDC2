<#
Discord to DCS Command & Control Settings Script
# Version 2.0b
# Writen by OzDeaDMeaT
# 16-04-2021
########################################################################################################################################################################################################
#CHANGE LOG#############################################################################################################################################################################################
########################################################################################################################################################################################################
- v2.0b Analysing errors in Start and Restart Functions with new version of DCS
- v2.0b Update function re-work
- v2.0b DEVTOOLS Add Sanitize Function for ddc2_config.ps1 for faster releases.

########################################################################################################################################################################################################
#>
########################################################################################################################################################################################################
#SERVER FILE PATH CONFIGURATION SECTION#################################################################################################################################################################
########################################################################################################################################################################################################
#Paths variables are written with "", so for example "C:\Program Files\RealVNC\VNC Server\vncserver.exe" for a DIR leave the file \ out 
$VNC_Path			= "PATH DATA REQUIRED"										#Path to VNC Server EXE
$DCS_Profile 		= "PATH DATA REQUIRED" 									#DCS Server Profile Path
$dcsDIR 			= "PATH DATA REQUIRED"			 												#DCS Install Location
$srsDIR 			= "PATH DATA REQUIRED" 												#SRS Installation Location
$srsClients			= "$srsDIR\clients-list.json"																#Clients Data Export for SRS. User Count and Names used for Server Status messages. if you do not wish to use this feature enter a file that does not exist and it will skip this part of the status report
$LotDIR 			= "PATH DATA REQUIRED" 																	#LotATC Installation Location
$Lot_Config 		= "$DCS_Profile\Mods\services\LotAtc\config.custom.lua"										#LotATC Custom Config File
$TacvDIR 			= "PATH DATA REQUIRED" 																	#Tacview Installation Location

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
$DDC2_HELP			= $TRUE																						#This will enable !help responses from this server (recommended to only have one server respond to !help requests if you have multiple servers monitoring a channel)
$DCSBETA 			= $FALSE																						#Set this variable if you wish to use the DCS Open Beta 
$SRSBETA 			= $FALSE																					#Set this variable if you wish to use the SRS Beta 
$LoTBETA 			= $FALSE																					#Not currently in use
$UPDATE_DCS			= $TRUE																						#Enables and disables the automated update process for DCS
$UPDATE_SRS			= $TRUE																						#Enables and disables the automated update process for SRS
$UPDATE_LoT			= $TRUE																						#Enables and disables the automated update process for LotATC
$AutoStartonUpdate	= $TRUE																						#AutoRestarts the DCS Server after updates are complete. (Default: $TRUE)
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
$SRS_Config 		= "$srsDIR\server.cfg"																		#SRS DCS Config File
$SRS_AutoConnect	= "$DCS_Profile\Scripts\Hooks\DCS-SRS-AutoConnectGameGUI.lua"								#SRS AutoConnect File
$SRS_External		= "$srsDIR\DCS-SR-ExternalAudio.exe"														#SRS External TXT to Speech exe
$SRS_Updater 		= "$srsDIR\SRS-AutoUpdater.exe"																#SRS Updater Executable
$SRS_Updater_Args 	= if($SRSBETA) {"-beta","-server","-path=$srsDIR"} else {"-server","-path=$srsDIR"}			#SRS Updater Arguments 

########################################################################################################################################################################################################
#SERVER IDENTITY CONFIGURATION SECTION##################################################################################################################################################################
########################################################################################################################################################################################################
#DDC2 IDENTITY
$ServerID = "DATA REQUIRED"																			#ServerID for DDC2
$ServerDT = "DATA REQUIRED"															#Downtime Notice Text

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
$DDC2_PSConfig_Version = "v2.0b"
