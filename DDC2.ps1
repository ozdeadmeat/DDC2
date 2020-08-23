<#
DCS Controller Script for Node-Red & Discord Interaction
# Version 1.163a
# Writen by OzDeaDMeaT
# 23-08-2020
####################################################################################################
#CHANGE LOG#########################################################################################
####################################################################################################
- Splitting out Report to multiple Functions
- Added New-Firewall-RDPPort Function to assist in installation when changing RDP Ports from Default
- Added Check-DDC2-PS Function to check variables that are set in DDC2.ps1 File
- Fixed Bug where SRS Server Install does not generate an entry.lua, Version data collection now done via SRS Executable instead.
####################################################################################################
#>

param(
[switch]$Update,
[switch]$Status,
[switch]$Start,
[switch]$Stop,
[switch]$Restart,
[switch]$Reboot,
[switch]$Report,
[switch]$Secure,
[switch]$Access,
[switch]$ClearAll,
[string]$IP,
[string]$USER,
[string]$ID
	)


$BETA 				= $TRUE																						#Set this variable if you wish to use the DCS Open Beta and Beta versions of SRS
####################################################################################################
#ADMIN CONFIGURATION SECTION########################################################################
####################################################################################################
$PS_LogFile			= "G:\GameServer\DDC2\DDC2.log" 															#Log File Location for this script
$DCS_Profile 		= "C:\Users\c0rnerst0ne\Saved Games\DCS.server"			 									#DCS Server Profile Path
$dcsDIR 			= "G:\GameServer\DCS World Server"			 												#DCS Install Location
$srsDIR 			= "G:\GameServer\SRS"						 												#SRS Installation Location
$LotDIR 			= "G:\GameServer\LotAtc" 																	#LotATC Installation Location
$TacvDIR 			= "G:\GameServer\Tacview" 																	#Tacview Installation Location

#The Variabled below should not need configuration but are listed here if you need to configure them.
$dcsBIN				= "$dcsDIR\bin" 																			#DCS Bin Folder
$dcsEXE 			= "$dcsBIN\DCS.exe"																			#DCS Executable 
$DCS_Config 		= "$DCS_Profile\Config\serverSettings.lua"													#DCS Server Settings File
$DCS_AutoE			= "$DCS_Profile\Config\autoexec.cfg"														#DCS Autoexec.cfg
$dcsargs 			= "--server --norender" 																	#DCS Server Arguments
$DCS_Updater 		= "$dcsBIN\dcs_updater.exe" 																#DCS Updater Executable
$DCS_Updater_Args 	= if($BETA) {"update @openbeta"} else {"update @release"}									#DCS Updater Arguments

$TacvEXE 			= "$TacvDIR\Tacview64.exe" 																	#Tacview Executable
$TACv_Entry 		= "$DCS_Profile\Mods\Tech\Tacview\entry.lua"												#Tacview Entry Data
$TACv_Config 		= "$DCS_Profile\Config\options.lua"															#Tacview Configuration File

$Lot_Entry			= "$DCS_Profile\Mods\services\LotAtc\entry.lua"												#LotATC Entry Data
$Lot_Config 		= "$DCS_Profile\Mods\services\LotAtc\config.lua"											#LotATC Config File
$Lot_Updater 		= "$LotDIR\LotAtc_updater.exe"																#LotATC Updater Executable
$Lot_Updater_Args 	= "--silentUpdate"																			#LotATC Updater Arguments

$srsEXE 			= "$srsDIR\SR-Server.exe" 																	#SRS Executable
$SRS_Entry 			= "$DCS_Profile\Mods\services\DCS-SRS\entry.lua"											#SRS DCS Entry Data
$SRS_Config 		= "$srsDIR\server.cfg"																		#SRS DCS Config File
$SRS_AutoConnect	= "$DCS_Profile\Scripts\Hooks\DCS-SRS-AutoConnectGameGUI.lua"								#SRS AutoConnect File
$SRS_Updater 		= "$srsDIR\SRS-AutoUpdater.exe"																#SRS Updater Executable
$SRS_Updater_Args = if($BETA) {"-beta","-server","-path=$srsDIR"} else {"-server","-path=$srsDIR"}				#SRS Updater Arguments 				NOTE: REMOVE '-beta' IF YOU DO NOT WANT BETA SRS UPDATES!!
#################################################################################################################################################################################################################################################################################################################################################################################################################################################################
#__/\\\\\\\\\\\\__________/\\\\\_________________/\\\\\_____/\\\_______/\\\\\_______/\\\\\\\\\\\\\\\____________/\\\\\\\\\\\\\\\__/\\\\\\\\\\\\_____/\\\\\\\\\\\__/\\\\\\\\\\\\\\\____________/\\\\\\\\\\\\\____/\\\\\\\\\\\\\\\__/\\\___________________/\\\\\_______/\\\______________/\\\____________/\\\\\\\\\\\\\\\__/\\\________/\\\__/\\\\\\\\\\\_____/\\\\\\\\\\\______________/\\\______________/\\\\\\\\\\\__/\\\\\_____/\\\__/\\\\\\\\\\\\\\\_        
# _\/\\\////////\\\______/\\\///\\\______________\/\\\\\\___\/\\\_____/\\\///\\\____\///////\\\/////____________\/\\\///////////__\/\\\////////\\\__\/////\\\///__\///////\\\/////____________\/\\\/////////\\\_\/\\\///////////__\/\\\_________________/\\\///\\\____\/\\\_____________\/\\\___________\///////\\\/////__\/\\\_______\/\\\_\/////\\\///____/\\\/////////\\\___________\/\\\_____________\/////\\\///__\/\\\\\\___\/\\\_\/\\\///////////__       
#  _\/\\\______\//\\\___/\\\/__\///\\\____________\/\\\/\\\__\/\\\___/\\\/__\///\\\________\/\\\_________________\/\\\_____________\/\\\______\//\\\_____\/\\\___________\/\\\_________________\/\\\_______\/\\\_\/\\\_____________\/\\\_______________/\\\/__\///\\\__\/\\\_____________\/\\\_________________\/\\\_______\/\\\_______\/\\\_____\/\\\______\//\\\______\///____________\/\\\_________________\/\\\_____\/\\\/\\\__\/\\\_\/\\\_____________      
#   _\/\\\_______\/\\\__/\\\______\//\\\___________\/\\\//\\\_\/\\\__/\\\______\//\\\_______\/\\\_________________\/\\\\\\\\\\\_____\/\\\_______\/\\\_____\/\\\___________\/\\\_________________\/\\\\\\\\\\\\\\__\/\\\\\\\\\\\_____\/\\\______________/\\\______\//\\\_\//\\\____/\\\____/\\\__________________\/\\\_______\/\\\\\\\\\\\\\\\_____\/\\\_______\////\\\___________________\/\\\_________________\/\\\_____\/\\\//\\\_\/\\\_\/\\\\\\\\\\\_____     
#    _\/\\\_______\/\\\_\/\\\_______\/\\\___________\/\\\\//\\\\/\\\_\/\\\_______\/\\\_______\/\\\_________________\/\\\///////______\/\\\_______\/\\\_____\/\\\___________\/\\\_________________\/\\\/////////\\\_\/\\\///////______\/\\\_____________\/\\\_______\/\\\__\//\\\__/\\\\\__/\\\___________________\/\\\_______\/\\\/////////\\\_____\/\\\__________\////\\\________________\/\\\_________________\/\\\_____\/\\\\//\\\\/\\\_\/\\\///////______    
#     _\/\\\_______\/\\\_\//\\\______/\\\____________\/\\\_\//\\\/\\\_\//\\\______/\\\________\/\\\_________________\/\\\_____________\/\\\_______\/\\\_____\/\\\___________\/\\\_________________\/\\\_______\/\\\_\/\\\_____________\/\\\_____________\//\\\______/\\\____\//\\\/\\\/\\\/\\\____________________\/\\\_______\/\\\_______\/\\\_____\/\\\_____________\////\\\_____________\/\\\_________________\/\\\_____\/\\\_\//\\\/\\\_\/\\\_____________   
#      _\/\\\_______/\\\___\///\\\__/\\\______________\/\\\__\//\\\\\\__\///\\\__/\\\__________\/\\\_________________\/\\\_____________\/\\\_______/\\\______\/\\\___________\/\\\_________________\/\\\_______\/\\\_\/\\\_____________\/\\\______________\///\\\__/\\\_______\//\\\\\\//\\\\\_____________________\/\\\_______\/\\\_______\/\\\_____\/\\\______/\\\______\//\\\____________\/\\\_________________\/\\\_____\/\\\__\//\\\\\\_\/\\\_____________  
#       _\/\\\\\\\\\\\\/______\///\\\\\/_______________\/\\\___\//\\\\\____\///\\\\\/___________\/\\\_________________\/\\\\\\\\\\\\\\\_\/\\\\\\\\\\\\/____/\\\\\\\\\\\_______\/\\\_________________\/\\\\\\\\\\\\\/__\/\\\\\\\\\\\\\\\_\/\\\\\\\\\\\\\\\____\///\\\\\/_________\//\\\__\//\\\______________________\/\\\_______\/\\\_______\/\\\__/\\\\\\\\\\\_\///\\\\\\\\\\\/_____________\/\\\\\\\\\\\\\\\__/\\\\\\\\\\\_\/\\\___\//\\\\\_\/\\\\\\\\\\\\\\\_ 
#        _\////////////__________\/////_________________\///_____\/////_______\/////_____________\///__________________\///////////////__\////////////_____\///////////________\///__________________\/////////////____\///////////////__\///////////////_______\/////____________\///____\///_______________________\///________\///________\///__\///////////____\///////////_______________\///////////////__\///////////__\///_____\/////__\///////////////__
#################################################################################################################################################################################################################################################################################################################################################################################################################################################################
#Global Variables for Data Output and Process Selection set
$DCSreturn = $null
$DCSreturnJSON = $null
$selection = 'Name', 'ProcessName', 'PriorityClass', 'ProductVersion', 'Responding', 'StartTime', @{Name='Ticks';Expression={$_.TotalProcessorTime.Ticks}}, @{Name='MemGB';Expression={'{00:N2}' -f ($_.WorkingSet/1GB)}}
####################################################################################################
Function Write-Log {
<# 
.DESCRIPTION 
Write-Log is a simple function that dumps an output to a log file.
 
.EXAMPLE
The line below will create a log file called test.log in the current folder and populate it with 'This data is going into the log'
write-log -LogData "This data is going into the log" -LogFile "test.log" 
#>
 
Param (
$LogData = "",
$LogFile = $PS_LogFile,
[switch]$Silent
)
if ($LogData -ne "") {
	$Time = get-date -Format "yyyy-MMM-dd--HH:mm:ss"
	$TimeStampLog = $Time + "  -  " + $LogData
	if (-Not (test-path $LogFile)) {
		$shh = new-item $LogFile -type File -Force -ErrorAction SilentlyContinue
		if($shh.count -gt 0) {
			$created = $Time + " - LOGFILE CREATED"
			Add-Content $LogFile $created
			Add-Content $LogFile $TimeStampLog
			if(-not ($silent)) {
				write-host "Logfile created"
				write-host $LogData
				}
			}
		else
			{
			if(-not ($silent)) {
				write-host "Logfile does not exist and was not able to be created, please check path provided and try again"
				}
			
			}
		}
	else
		{
		Add-Content $LogFile $TimeStampLog
		if(-not ($silent)) {
			write-host $LogData
			}
		}
	} 
}

Function Check-DDC2-PS {
<# 
.DESCRIPTION 
This function checks that all the config files etc have been entered correctly into the DDC2 Powershell script
 
.EXAMPLE
Check-DDC2-PS
#>
write-host "Reloading DDC2.ps1 file into memory"
. .\DDC2.ps1
write-host "Checking DDC2.ps1 admin entered file paths...." -ForegroundColor white
write-log -LogData "Checking DDC2.ps1 admin entered file paths...." -silent
####################################################################################################
write-host '$PS_LogFile	== ' -nonewline -ForegroundColor white
if (test-path $PS_LogFile) {
	write-host "OK" -nonewline -ForegroundColor green
	write-host " - $PS_LogFile" -ForegroundColor yellow
	} else {write-host "Not Found" -ForegroundColor red}
####################################################################################################
write-host " "
write-host "Checking all DCS Variables...." -ForegroundColor white

write-host '$DCS_Profile 	== ' -nonewline -ForegroundColor white
if (test-path $DCS_Profile) {
	write-host "OK" -nonewline -ForegroundColor green
	write-host " - $DCS_Profile" -ForegroundColor yellow
	} else {write-host "Not Found" -ForegroundColor red}

write-host '$DCS_Config 	== ' -nonewline -ForegroundColor white
if (test-path $DCS_Config) {
	write-host "OK" -nonewline -ForegroundColor green
	write-host " - $DCS_Config" -ForegroundColor yellow
	} else {write-host "Not Found" -ForegroundColor red}
	
write-host '$DCS_AutoE	== ' -nonewline -ForegroundColor white
if (test-path $DCS_AutoE) {
	write-host "OK" -nonewline -ForegroundColor green
	write-host " - $DCS_AutoE" -ForegroundColor yellow
	} else {write-host "Not Found" -ForegroundColor red}
	
write-host '$dcsDIR 	== ' -nonewline -ForegroundColor white
if (test-path $dcsDIR) {
	write-host "OK" -nonewline -ForegroundColor green
	write-host " - $dcsDIR" -ForegroundColor yellow
	} else {write-host "Not Found" -ForegroundColor red}

write-host '$dcsBIN		== ' -nonewline -ForegroundColor white
if (test-path $dcsBIN) {
	write-host "OK" -nonewline -ForegroundColor green
	write-host " - $dcsBIN" -ForegroundColor yellow
	} else {write-host "Not Found" -ForegroundColor red}

write-host '$dcsEXE 	== ' -nonewline -ForegroundColor white
if (test-path $dcsEXE) {
	write-host "OK" -nonewline -ForegroundColor green
	write-host " - $dcsEXE" -ForegroundColor yellow
	} else {write-host "Not Found" -ForegroundColor red}

write-host '$DCS_Updater 	== ' -nonewline -ForegroundColor white
if (test-path $DCS_Updater) {
	write-host "OK" -nonewline -ForegroundColor green
	write-host " - $DCS_Updater" -ForegroundColor yellow
	} else {write-host "Not Found" -ForegroundColor red}
#END DCS Variables
####################################################################################################
#Start SRS Variables
write-host " "
write-host "Checking all SRS Variables...." -ForegroundColor white

write-host '$srsDIR 	== ' -nonewline -ForegroundColor white
if (test-path $srsDIR) {
	write-host "OK" -nonewline -ForegroundColor green
	write-host " - $srsDIR" -ForegroundColor yellow
	} else {write-host "Not Found" -ForegroundColor red}

write-host '$srsEXE 	== ' -nonewline -ForegroundColor white
if (test-path $srsEXE) {
	write-host "OK" -nonewline -ForegroundColor green
	write-host " - $srsEXE" -ForegroundColor yellow
	} else {write-host "Not Found" -ForegroundColor red}
	
<#write-host '$SRS_Entry 	== ' -nonewline -ForegroundColor white
if (test-path $SRS_Entry) {
	write-host "OK" -nonewline -ForegroundColor green
	write-host " - $SRS_Entry" -ForegroundColor yellow
	} else {write-host "Not Found" -ForegroundColor red}
#>	
write-host '$SRS_Config 	== ' -nonewline -ForegroundColor white
if (test-path $SRS_Config) {
	write-host "OK" -nonewline -ForegroundColor green
	write-host " - $SRS_Config" -ForegroundColor yellow
	} else {write-host "Not Found" -ForegroundColor red}
	
write-host '$SRS_AutoConnect== ' -nonewline -ForegroundColor white
if (test-path $SRS_AutoConnect) {
	write-host "OK" -nonewline -ForegroundColor green
	write-host " - $SRS_AutoConnect" -ForegroundColor yellow
	} else {write-host "Not Found" -ForegroundColor red}
	
write-host '$SRS_Updater	== ' -nonewline -ForegroundColor white
if (test-path $SRS_Updater) {
	write-host "OK" -nonewline -ForegroundColor green
	write-host " - $SRS_Updater" -ForegroundColor yellow
	} else {write-host "Not Found" -ForegroundColor red}
#END SRS Variables
####################################################################################################
#Start LotATC Variables
write-host " "
write-host "Checking all LotATC Variables...." -ForegroundColor white

write-host '$LotDIR 	== ' -nonewline -ForegroundColor white
if (test-path $LotDIR) {
	write-host "OK" -nonewline -ForegroundColor green
	write-host " - $LotDIR" -ForegroundColor yellow
	} else {write-host "Not Found" -ForegroundColor red}

write-host '$Lot_Entry 	== ' -nonewline -ForegroundColor white
if (test-path $Lot_Entry) {
	write-host "OK" -nonewline -ForegroundColor green
	write-host " - $Lot_Entry" -ForegroundColor yellow
	} else {write-host "Not Found" -ForegroundColor red}
	
write-host '$Lot_Config 	== ' -nonewline -ForegroundColor white
if (test-path $Lot_Config) {
	write-host "OK" -nonewline -ForegroundColor green
	write-host " - $Lot_Config" -ForegroundColor yellow
	} else {write-host "Not Found" -ForegroundColor red}
	
write-host '$Lot_Updater 	== ' -nonewline -ForegroundColor white
if (test-path $Lot_Updater) {
	write-host "OK" -nonewline -ForegroundColor green
	write-host " - $Lot_Updater" -ForegroundColor yellow
	} else {write-host "Not Found" -ForegroundColor red}
	
write-host '$LotDIR 	== ' -nonewline -ForegroundColor white
if (test-path $LotDIR) {
	write-host "OK" -nonewline -ForegroundColor green
	write-host " - $LotDIR" -ForegroundColor yellow
	} else {write-host "Not Found" -ForegroundColor red}
#END LotATC Variables
####################################################################################################
#Start TACView Variables
write-host " "
write-host "Checking all TACView Variables...." -ForegroundColor white

write-host '$TacvDIR 	== ' -nonewline -ForegroundColor white
if (test-path $TacvDIR) {
	write-host "OK" -nonewline -ForegroundColor green
	write-host " - $TacvDIR" -ForegroundColor yellow
	} else {write-host "Not Found" -ForegroundColor red}

write-host '$TacvEXE 	== ' -nonewline -ForegroundColor white
if (test-path $TacvEXE) {
	write-host "OK" -nonewline -ForegroundColor green
	write-host " - $TacvEXE" -ForegroundColor yellow
	} else {write-host "Not Found" -ForegroundColor red}

write-host '$TACv_Entry 	== ' -nonewline -ForegroundColor white
if (test-path $TACv_Entry) {
	write-host "OK" -nonewline -ForegroundColor green
	write-host " - $TACv_Entry" -ForegroundColor yellow
	} else {write-host "Not Found" -ForegroundColor red}
	
write-host '$TACv_Config 	== ' -nonewline -ForegroundColor white
if (test-path $TACv_Config) {
	write-host "OK" -nonewline -ForegroundColor green
	write-host " - $TACv_Config" -ForegroundColor yellow
	} else {write-host "Not Found" -ForegroundColor red}
write-host " "
write-host "Check Complete...." -ForegroundColor white
write-host " "	
}

Function Check-Update { 
write-log -LogData "--------------------------------------------------------" -Silent
write-log -LogData "Check-Update: STARTED" -Silent
$ChkUpd = $null
$ChkUpd = New-Object -TypeName psobject
$DCS_Updater = $null
$DCS_Updater = Get-Process -Name DCS_Updater -ErrorAction SilentlyContinue | Select-Object $selection
$SRS_Updater = $null
$SRS_Updater = Get-Process -Name SRS-AutoUpdater -ErrorAction SilentlyContinue | Select-Object $selection
$LOT_Updater = $null
$LOT_Updater = Get-Process -Name LotAtc_updater -ErrorAction SilentlyContinue | Select-Object $selection

if($DCS_Updater.count -eq 0) {
	$DCS_Updater = New-Object -TypeName psobject 
	$DCS_Updater | Add-Member -MemberType NoteProperty -Name Name -Value "DCS_Updater"
	$DCS_Updater | Add-Member -MemberType NoteProperty -Name IsActive -Value $false
	}
else {
	$DCS_Updater | Add-Member -MemberType NoteProperty -Name RunTime -Value ((get-date) - $DCS_Updater.StartTime)
	$DCS_Updater | Add-Member -MemberType NoteProperty -Name IsActive -Value $true
	$DCS_Updater | add-Member -MemberType NoteProperty -Name Started -Value ((get-date $DCS_Updater.StartTime).DateTime)
	}
####################
if($SRS_Updater.count -eq 0) {
	$SRS_Updater = New-Object -TypeName psobject 
	$SRS_Updater | Add-Member -MemberType NoteProperty -Name Name -Value "SRS-AutoUpdater"
	$SRS_Updater | Add-Member -MemberType NoteProperty -Name IsActive -Value $false
	}
else {
	
	$SRS_Updater | Add-Member -MemberType NoteProperty -Name RunTime -Value ((get-date) - $SRS_Updater.StartTime)
	$SRS_Updater | Add-Member -MemberType NoteProperty -Name IsActive -Value $true
	$SRS_Updater | add-Member -MemberType NoteProperty -Name Started -Value ((get-date $SRS_Updater.StartTime).DateTime)
	}
####################
if($LOT_Updater.count -eq 0) {
	$LOT_Updater = New-Object -TypeName psobject 
	$LOT_Updater | Add-Member -MemberType NoteProperty -Name Name -Value "LotAtc_Updater"
	$LOT_Updater | Add-Member -MemberType NoteProperty -Name IsActive -Value $false
	}
else {
	$LOT_Updater | Add-Member -MemberType NoteProperty -Name RunTime -Value ((get-date) - $LOT_Updater.StartTime)
	$LOT_Updater | Add-Member -MemberType NoteProperty -Name IsActive -Value $true
	$LOT_Updater | add-Member -MemberType NoteProperty -Name Started -Value ((get-date $LOT_Updater.StartTime).DateTime)
	}
$Updating = if (($DCS_Updater.IsActive) -or ($SRS_Updater.IsActive) -or ($LOT_Updater.IsActive)) {$true} else {$false}

$ChkUpd | Add-Member -MemberType NoteProperty -Name Updating -Value $Updating
$ChkUpd | Add-Member -MemberType NoteProperty -Name DCS_updater -Value $DCS_Updater
$ChkUpd | Add-Member -MemberType NoteProperty -Name SRS_Updater -Value $SRS_Updater
$ChkUpd | Add-Member -MemberType NoteProperty -Name LOT_Updater -Value $LOT_Updater
write-log -LogData "Check-Update: ENDED" -Silent
return $ChkUpd
}

Function Check-Game {
write-log -LogData "--------------------------------------------------------" -Silent
write-log -LogData "Check-Game: STARTED" -Silent
$ChkGame = $null
$ChkGame = New-Object -TypeName psobject
$network = get-nettcpconnection -ErrorAction SilentlyContinue | Select-Object local*,remote*,state,@{Name="Process";Expression={(Get-Process -Id $_.OwningProcess).ProcessName}}
$DCS = Get-Process -Name DCS -ErrorAction SilentlyContinue | Select-Object $selection 
$SRS = Get-Process -Name SR-Server -ErrorAction SilentlyContinue | Select-Object $selection

if($DCS.count -eq 0) {
	$DCS = New-Object -TypeName psobject 
	$DCS | Add-Member -MemberType NoteProperty -Name Name -Value "DCS"
	$DCS | Add-Member -MemberType NoteProperty -Name IsActive -Value $false
	}
else {
	$DCS | Add-Member -MemberType NoteProperty -Name IsActive -Value $true
	$DCS | Add-Member -MemberType NoteProperty -Name RunTime -Value ((get-date) - $DCS.StartTime)
	$DCS.StartTime = ((get-date $DCS.StartTime).DateTime)	
	$dcsNet = $network | Where-Object{$_.Process -eq $DCS.ProcessName} | Where-Object{$_.State -eq 'Listen'} | sort-Object LocalPort
	$dcsNetTXT = ""
	Foreach($DNitem in $dcsNet)
		{
		$dcsNetTXT = $dcsNetTXT + $DNitem.LocalPort
		if($DNitem -ne $dcsNet[-1]) {$dcsNetTXT = $dcsNetTXT + ", "}
		}
	$DCS | add-Member -MemberType NoteProperty -Name ProcessPorts -Value $dcsNetTXT
	}
if($SRS.count -eq 0) {
	$SRS = New-Object -TypeName psobject 
	$SRS | Add-Member -MemberType NoteProperty -Name Name -Value "SR-Server"
	$SRS | Add-Member -MemberType NoteProperty -Name IsActive -Value $false
	}
else {
	$SRS | Add-Member -MemberType NoteProperty -Name RunTime -Value ((get-date) - $SRS.StartTime)
	$SRS | Add-Member -MemberType NoteProperty -Name IsActive -Value $true
	$SRS.StartTime = ((get-date $SRS.StartTime).DateTime)
	$srsNet = $network | Where-Object{$_.Process -eq $SRS.ProcessName} | Where-Object{$_.State -eq 'Listen'} | sort-Object LocalPort
	$srsNetTXT = ""
	Foreach($SNitem in $srsNet)
		{
		$srsNetTXT = $srsNetTXT + $SNitem.LocalPort
		if($SNitem -ne $srsNet[-1]) {$srsNetTXT = $srsNetTXT + ", "}
		}
	$SRS | add-Member -MemberType NoteProperty -Name ProcessPorts -Value $srsNetTXT
	}

$ChkGame | Add-Member -MemberType NoteProperty -Name DCS -Value $DCS
$ChkGame | Add-Member -MemberType NoteProperty -Name SRS -Value $SRS
write-log -LogData "Check-Game: ENDED" -Silent
return $ChkGame
}
Function Get-ServerInfo {
	##COLLECTION OF SERVER INFO
	$wVER = (Get-Item "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").GetValue('ProductName') + " (Build:" + (Get-Item "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").GetValue('ReleaseId') + "."+(Get-Item "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").GetValue('CurrentBuildNumber')+")"
	$RDP = (Get-Item "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp").GetValue('PortNumber')
	$tzInfo = [System.TimeZoneInfo]::Local
	$utcoffset = (($tzinfo).DisplayName).Split(" ")[0]
	$tzSN = [Regex]::Replace($tzInfo.StandardName, '([A-Z])\w+\s*', '$1')
	$ServerDateTime = (get-date).DateTime
	$LastBoot = (([wmiclass]"").ConvertToDateTime((Get-wmiobject win32_operatingsystem).LastBootUpTime))
	$serverUpTime = (get-date) - $LastBoot
	########################################################################################################################
	#Get CPU Information
	$Processor = Get-WmiObject -ComputerName $env:COMPUTERNAME -Class win32_processor
	#Get Memory Information
	$ComputerMemory = Get-WmiObject -ComputerName $env:COMPUTERNAME -Class win32_operatingsystem -ErrorAction SilentlyContinue
	$TotalMemGB = [math]::Round((($ComputerMemory).TotalVisibleMemorySize / 1048576),0)
	$MemoryLoad = [math]::Round(((($ComputerMemory.TotalVisibleMemorySize - $ComputerMemory.FreePhysicalMemory)*100)/ $ComputerMemory.TotalVisibleMemorySize), 0)
	#Get Network Information
	$ExternalNET = Invoke-RestMethod http://ipinfo.io/json
	#$network = get-nettcpconnection -ErrorAction SilentlyContinue | Select-Object local*,remote*,state,@{Name="Process";Expression={(Get-Process -Id $_.OwningProcess).ProcessName}} 
	##SET SERVER INFO VARIABLE
	$Get_ServerInfo = $null
	$Get_ServerInfo = New-Object -TypeName psobject 
	$Get_ServerInfo | Add-Member -MemberType NoteProperty -Name WinVer -Value $wVER
	$Get_ServerInfo | Add-Member -MemberType NoteProperty -Name RDPport -Value $RDP
	$Get_ServerInfo | Add-Member -MemberType NoteProperty -Name ServerTime -Value $ServerDateTime
	$Get_ServerInfo | Add-Member -MemberType NoteProperty -Name LastBoot -Value $LastBoot.DateTime
	$Get_ServerInfo | Add-Member -MemberType NoteProperty -Name UpTime -Value $serverUpTime
	$Get_ServerInfo | Add-Member -MemberType NoteProperty -Name TZ -Value $tzInfo.StandardName
	$Get_ServerInfo | Add-Member -MemberType NoteProperty -Name TZSN -Value $tzSN
	$Get_ServerInfo | Add-Member -MemberType NoteProperty -Name UTCOffset -Value $utcoffset
	$Get_ServerInfo | Add-Member -MemberType NoteProperty -Name IPAddr -Value $ExternalNET.ip
	$Get_ServerInfo | Add-Member -MemberType NoteProperty -Name HostName -Value $ExternalNET.hostname
	$Get_ServerInfo | Add-Member -MemberType NoteProperty -Name ISP -Value $ExternalNET.org
	$Get_ServerInfo | Add-Member -MemberType NoteProperty -Name CPUType -Value $Processor.Name
	$Get_ServerInfo | Add-Member -MemberType NoteProperty -Name CPULoad -Value $Processor.LoadPercentage
	$Get_ServerInfo | Add-Member -MemberType NoteProperty -Name TotalMem -Value $TotalMemGB
	$Get_ServerInfo | Add-Member -MemberType NoteProperty -Name MEMLoad -Value $MemoryLoad
return $Get_ServerInfo
}

Function Get-Config {
#This function checks all the config files etc for version, ports, passwords for each seperate application and outputs it all as a single variable to be used in the Node-Red message output workflow or stored as vairables for the !info message
########################################################################################################################
write-log -LogData "--------------------------------------------------------" -Silent
write-log -LogData "Get-Config: STARTED" -Silent

$SRV_config = $null
$SRV_config = New-Object -TypeName psobject
########################################################################################################################
##DCS
$DCS_Settings = $null
$DCS_Settings = New-Object -TypeName psobject
$DCS_Version = if(test-path $dcsEXE) {(Get-ChildItem $dcsEXE).VersionInfo.ProductVersion} else {"$dcsEXE NOT FOUND"}
$DCS_WebUIport = if(test-path $DCS_AutoE) {((Select-String -Path $DCS_AutoE -Pattern "webgui_port =" | Out-String).Split('=')[-1]).Trim()} else {'8088'}
if(test-path $DCS_Config) {
	$dcsSRVname = (Select-String -Path $DCS_Config -Pattern "name" | Out-String).Split('"')[-2]
	$dcsMaxPlyr = (Select-String -Path $DCS_Config -Pattern "maxPlayers" | Out-String).Split('"')[-2]
	$dcsMaxPing = (Select-String -Path $DCS_Config -Pattern "maxPing" | Out-String).Split('"')[-2]
	$dcsPasswrd = (Select-String -Path $DCS_Config -Pattern "password" | Out-String).Split('"')[-2]
	$dcsSRVport = ((Select-String -Path $DCS_Config -Pattern "port" | Out-String).Split(' ')[-1]).Split(',')[0]
	} else {
	$dcsSRVname = '$DCS_Config PATH NOT FOUND IN DDC2.ps1'
	$dcsMaxPlyr = '$DCS_Config PATH NOT FOUND IN DDC2.ps1'
	$dcsMaxPing = '$DCS_Config PATH NOT FOUND IN DDC2.ps1'
	$dcsPasswrd = '$DCS_Config PATH NOT FOUND IN DDC2.ps1'
	$dcsSRVport = '$DCS_Config PATH NOT FOUND IN DDC2.ps1'
	}
$DCS_Settings | Add-Member -MemberType NoteProperty -Name Version -Value $DCS_Version
$DCS_Settings | Add-Member -MemberType NoteProperty -Name ServerName -Value $dcsSRVname
$DCS_Settings | Add-Member -MemberType NoteProperty -Name MaxPlayers -Value $dcsMaxPlyr
$DCS_Settings | Add-Member -MemberType NoteProperty -Name MaxPing -Value $dcsMaxPing
$DCS_Settings | Add-Member -MemberType NoteProperty -Name Passwrd -Value $dcsPasswrd
$DCS_Settings | Add-Member -MemberType NoteProperty -Name Port -Value $dcsSRVport
$DCS_Settings | Add-Member -MemberType NoteProperty -Name WebUIPort -Value $DCS_WebUIport

$SRV_config | Add-Member -MemberType NoteProperty -Name DCS -Value $DCS_Settings
########################################################################################################################
##LotATC
$LotATC_Settings = $null
$LotATC_Settings = New-Object -TypeName psobject
$LotATC_Version = if(test-path $Lot_Entry) {(Select-String -Path $Lot_Entry -Pattern "version" | Out-String).Split('"')[-2]} else {'NOT INSTALLED'}
if(test-path $Lot_Config) {
	$LotATC_Port 	= ((Select-String -Path $Lot_Config -Pattern " port = " | Out-String).Split(' ')[-1] | Out-String).Split(',')[0]
	$LotATC_BluePW 	= (Select-String -Path $Lot_Config -Pattern "blue_password = " | Out-String).Split('"')[-2]
	$LotATC_RedPW 	= (Select-String -Path $Lot_Config -Pattern "red_password = " | Out-String).Split('"')[-2]
	}
else {
	$LotATC_Port 	= '$Lot_Config PATH NOT FOUND IN DDC2.ps1'
	$LotATC_BluePW 	= '$Lot_Config PATH NOT FOUND IN DDC2.ps1'
	$LotATC_RedPW 	= '$Lot_Config PATH NOT FOUND IN DDC2.ps1'
	}
$LotATC_Settings | Add-Member -MemberType NoteProperty -Name Version -Value $LotATC_Version	
$LotATC_Settings | Add-Member -MemberType NoteProperty -Name Port -Value $LotATC_Port
$LotATC_Settings | Add-Member -MemberType NoteProperty -Name BluPWD -Value $LotATC_BluePW
$LotATC_Settings | Add-Member -MemberType NoteProperty -Name RedPWD -Value $LotATC_RedPW

$SRV_config | Add-Member -MemberType NoteProperty -Name LotATC -Value $LotATC_Settings
########################################################################################################################
##TacView
$TACv_Settings = $null
$TACv_Settings = New-Object -TypeName psobject	
$TACv_Version = if(test-path $TACv_Entry) {(Select-String -Path $TACv_Entry -Pattern "version" | Out-String).Split('"')[-2]} else {'NOT INSTALLED'}
if(test-path $TACv_Config) {
	$TACv_Port 			= (Select-String -Path $TACv_Config -Pattern "tacviewRealTimeTelemetryPort" | Out-String).Split('"')[-2]
	$TACv_RCPort 		= (Select-String -Path $TACv_Config -Pattern "tacviewRemoteControlPort" | Out-String).Split('"')[-2]
	$TACv_Delay			= (Select-String -Path $TACv_Config -Pattern "tacviewPlaybackDelay" | Out-String).replace(',',' ').Split(' ')[-2]
	$TACv_TelemetryPW 	= (Select-String -Path $TACv_Config -Pattern "tacviewHostTelemetryPassword" | Out-String).Split('"')[-2]
	$TACv_ClientPW 		= (Select-String -Path $TACv_Config -Pattern "tacviewClientTelemetryPassword" | Out-String).Split('"')[-2]
	}
else {
	$TACv_Port 			= '$TACv_Config PATH NOT FOUND IN DDC2.ps1'
	$TACv_RCPort 		= '$TACv_Config PATH NOT FOUND IN DDC2.ps1'
	$TACv_Delay 		= '$TACv_Config PATH NOT FOUND IN DDC2.ps1' 
	$TACv_TelemetryPW 	= '$TACv_Config PATH NOT FOUND IN DDC2.ps1'
	$TACv_ClientPW 		= '$TACv_Config PATH NOT FOUND IN DDC2.ps1' 
	}
$TACv_Settings | Add-Member -MemberType NoteProperty -Name Version -Value $TACv_Version
$TACv_Settings | Add-Member -MemberType NoteProperty -Name Port -Value $TACv_Port
$TACv_Settings | Add-Member -MemberType NoteProperty -Name RCPort -Value $TACv_RCPort
$TACv_Settings | Add-Member -MemberType NoteProperty -Name Delay -Value $TACv_Delay
$TACv_Settings | Add-Member -MemberType NoteProperty -Name TlmtryPWD -Value $TACv_TelemetryPW
$TACv_Settings | Add-Member -MemberType NoteProperty -Name ClientPWD -Value $TACv_ClientPW

$SRV_config | Add-Member -MemberType NoteProperty -Name Tacview -Value $TACv_Settings
########################################################################################################################
##SRS
$SRS_Settings = $null
$SRS_Settings = New-Object -TypeName psobject	
$SRS_Version = if(test-path $SRS_Entry) {
	(Select-String -Path $SRS_Entry -Pattern "version" | Out-String).Split('"')[-2]}
else {
	if(test-path $srsEXE) {(Get-ChildItem $srsEXE).VersionInfo.ProductVersion} else {'NOT INSTALLED'}
	}
if(test-path $SRS_Config) {
	$SRS_Port 	= ((Select-String -Path $SRS_Config -Pattern "SERVER_PORT=" | Out-String).Split('=')[1]).Trim()
	$SRS_BluePW = ((Select-String -Path $SRS_Config -Pattern "EXTERNAL_AWACS_MODE_BLUE_PASSWORD=" | Out-String).Split('=')[1]).Trim()
	$SRS_RedPW 	= ((Select-String -Path $SRS_Config -Pattern "EXTERNAL_AWACS_MODE_RED_PASSWORD=" | Out-String).Split('=')[1]).Trim()
	}
else {
	$SRS_Port 	= '$SRS_Config PATH NOT FOUND IN DDC2.ps1'
	$SRS_BluePW = '$SRS_Config PATH NOT FOUND IN DDC2.ps1'
	$SRS_RedPW 	= '$SRS_Config PATH NOT FOUND IN DDC2.ps1'
	}
$SRS_Settings | Add-Member -MemberType NoteProperty -Name Version -Value $SRS_Version	
$SRS_Settings | Add-Member -MemberType NoteProperty -Name Port -Value $SRS_Port
$SRS_Settings | Add-Member -MemberType NoteProperty -Name BluPWD -Value $SRS_BluePW
$SRS_Settings | Add-Member -MemberType NoteProperty -Name RedPWD -Value $SRS_RedPW

$SRV_config | Add-Member -MemberType NoteProperty -Name SRS -Value $SRS_Settings
########################################################################################################################

##SET OUTPUT VARIABLE
$get_config = $null
$get_config = New-Object -TypeName psobject 
$ServerInfo = Get-ServerInfo
$get_config | Add-Member -MemberType NoteProperty -Name Info -Value $ServerInfo
$get_config | Add-Member -MemberType NoteProperty -Name Config -Value $SRV_config
write-log -LogData "Get-Config: ENDED" -Silent
return $get_config
}

Function Change-Firewall-RDP {
<# 
.DESCRIPTION 
Manages all RDP Firewall rules for a specific IP address
 
.EXAMPLE
Mode 1: Unlock
This mode will generate rules for the specific user who requested them.
Change-Firewall-RDP -UnLock -IP 192.168.0.55 -USER 'OzDeaDMeaT' -DiscordID '548546875'
Mode 2: Lock
This mode will check if there is an active connection for the specific user and if there is not it will remove the rules associated with the user it is checking for.
Change-Firewall-RDP -Lock -IP 192.168.0.55 -USER 'OzDeaDMeaT' -DiscordID '548546875'
Mode 3: ClearAll
This mode will remove ALL RDP rules that have been generated. (use this for scheduled task on reboot)
Change-Firewall-RDP -ClearAll
System returns a PowerShell Object Variable for all task types.
#>

Param (
[string]$IP = '',
[string]$USER = '',
[string]$DiscordID = '',
[switch]$Lock,
[switch]$Unlock,
[switch]$ClearAll
)
write-log -LogData "--------------------------------------------------------" -Silent
write-log -LogData "Change-Firewall-RDP: STARTED" -Silent
write-log -LogData "Change-Firewall-RDP Started for $USER with Discord ID of $DiscordID for IP:$IP" -Silent
$outputVar = $null
$RDPPort = (Get-Item "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp").GetValue('PortNumber')
$RULEPREFIX = 'DDC2 - '
$WILDCARD = "$RULEPREFIX*"
$Time = get-date -Format "yyyy-MMM-dd--HH:mm:ss"
$RULE_NAME_PREFIX = "$RULEPREFIX$DiscordID -"
$RULE_DISPLAYNAME_PREFIX = "$RULEPREFIX$USER -"
$RULE_DESCRIPTION = "AutoGenerated Firewall Rule for $USER with Discord ID $DiscordID on date $Time"
$OutputVar = New-Object -TypeName psobject 
$OutputVar | Add-Member -MemberType NoteProperty -Name Request -Value "UNKNOWN"
$OutputVar | Add-Member -MemberType NoteProperty -Name Name -Value $USER
$OutputVar | Add-Member -MemberType NoteProperty -Name DiscordID -Value $DiscordID
$OutputVar | Add-Member -MemberType NoteProperty -Name IP -Value $IP
$OutputVar | Add-Member -MemberType NoteProperty -Name Connected -Value $false
$OutputVar | Add-Member -MemberType NoteProperty -Name ExitLoop -Value $false
$OutputVar | Add-Member -MemberType NoteProperty -Name Message -Value ""
$OutputVar | Add-Member -MemberType NoteProperty -Name ValidIP -Value $false
if($Unlock) {
	$Octet = '(?:0?0?[0-9]|0?[1-9][0-9]|1[0-9]{2}|2[0-5][0-5]|2[0-4][0-9])'
	[regex] $IPv4Regex = "^(?:$Octet\.){3}$Octet$"
	$checkIP = $IP -match $IPv4Regex
	$OutputVar.ValidIP = $checkIP
	if($CheckIP) {
		#check if the rules currently exist
		$currentRules = (get-NetFirewallRule -Name "$RULE_NAME_PREFIX *" | Measure-Object).count
		if($currentRules -gt 0) {
			get-NetFirewallRule -Name "$RULE_NAME_PREFIX *" | remove-NetFirewallRule
			write-log -LogData "Old Firewall Rules Found, removing..." -Silent
			Start-sleep 1
			}		
		$shhh = New-NetFirewallRule -Name "$RULE_NAME_PREFIX TCP" -DisplayName "$RULE_DISPLAYNAME_PREFIX TCP" -Description $RULE_DESCRIPTION -Direction Inbound -LocalPort $RDPPort -Protocol TCP -RemoteAddress $IP -Action Allow -Program %SystemRoot%\system32\svchost.exe -Group 'Remote Desktop'
		$shhh = New-NetFirewallRule -Name "$RULE_NAME_PREFIX UDP" -DisplayName "$RULE_DISPLAYNAME_PREFIX UDP" -Description $RULE_DESCRIPTION -Direction Inbound -LocalPort $RDPPort -Protocol UDP -RemoteAddress $IP -Action Allow -Program %SystemRoot%\system32\svchost.exe -Group 'Remote Desktop'
		$shhh = New-NetFirewallRule -Name "$RULE_NAME_PREFIX Shadow TCP" -DisplayName "$RULE_DISPLAYNAME_PREFIX Shadow TCP" -Description $RULE_DESCRIPTION -Direction Inbound -Protocol TCP -RemoteAddress $IP -Action Allow -Program %SystemRoot%\system32\RdpSa.exe -Group 'Remote Desktop'
		$OutputVar.Request = "Unlock"
		$OutputVar.Message = "$USER Door is unlocked, come on in..."
		write-log -LogData "Firewall rules generated for $USER with Discord ID of $DiscordID for IP:$IP" -Silent
		}
	else {
		$OutputVar.Message = "$USER, the IP address $IP appears to be invalid, door remains locked"
		$OutputVar.ExitLoop = $true
		write-log -LogData "IP Address Supplied is invalid" -Silent
		}
	}

$connected = (get-nettcpconnection | Where-Object{$_.RemoteAddress -eq $IP -and $_.LocalPort -eq $RDPPort -and $_.State -eq 'Established'} | Measure-Object).Count
if($connected -ne 0) {
	$OutputVar.Connected = $true
	}
if($Lock) {
	if($connected -eq 0) {
		$OutputVar.Request = "Lock"
		$OutputVar.ExitLoop = $true
		$OutputVar.Message = "$USER connection not detected, firewall rules removed..."
		Get-NetFirewallRule -Name "$RULE_NAME_PREFIX*" | remove-NetFirewallRule
		write-log -LogData "$USER RDP Firewall rules removed" -Silent
		}
	else{
		$OutputVar.Connected = $true
		$OutputVar.Request = "Lock"
		$OutputVar.Message = "$USER has connected..."
		write-log -LogData "$USER still connected" -Silent
		}
	}
If($ClearAll) {
	Get-NetFirewallRule -Name $WILDCARD | remove-NetFirewallRule
	$OutputVar.Request = "ClearAll"
	$OutputVar.Message = "All AutoGenerated Firewall rules have been deleted."
	write-log -LogData "All AutoGenerated Firewall rules have been deleted." -Silent
	}
write-log -LogData $OutputVar -Silent
write-log -LogData "Change-Firewall-RDP: ENDED" -Silent
return $OutputVar
}
Function New-Firewall-RDPPort {
Param (
[string]$IP = ''
)
write-log -LogData "New-Firewall-RDPPort Started"
$RDPPort = (Get-Item "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp").GetValue('PortNumber')
$RULE_NAME_PREFIX = "RDP Port - $RDPPort --" 
$Octet = '(?:0?0?[0-9]|0?[1-9][0-9]|1[0-9]{2}|2[0-5][0-5]|2[0-4][0-9])'
[regex] $IPv4Regex = "^(?:$Octet\.){3}$Octet$"
$checkIP = $IP -match $IPv4Regex
if($CheckIP) {
	#check if the rules currently exist
	$currentRules = (get-NetFirewallRule -Name "$RULE_NAME_PREFIX *" | Measure-Object).count
	if($currentRules -gt 0) {
		get-NetFirewallRule -Name "$RULE_NAME_PREFIX *" | remove-NetFirewallRule
		write-log -LogData "Old Firewall Rules Found, removing..." -Silent
		Start-sleep 1
		}		
	$shhh = New-NetFirewallRule -Name "$RULE_NAME_PREFIX TCP" -DisplayName "$RULE_NAME_PREFIX TCP" -Description $RULE_DESCRIPTION -Direction Inbound -LocalPort $RDPPort -Protocol TCP -RemoteAddress $IP -Action Allow -Program %SystemRoot%\system32\svchost.exe -Group 'Remote Desktop'
	$shhh = New-NetFirewallRule -Name "$RULE_NAME_PREFIX UDP" -DisplayName "$RULE_NAME_PREFIX UDP" -Description $RULE_DESCRIPTION -Direction Inbound -LocalPort $RDPPort -Protocol UDP -RemoteAddress $IP -Action Allow -Program %SystemRoot%\system32\svchost.exe -Group 'Remote Desktop'
	$shhh = New-NetFirewallRule -Name "$RULE_NAME_PREFIX Shadow TCP" -DisplayName "$RULE_NAME_PREFIX Shadow TCP" -Description $RULE_DESCRIPTION -Direction Inbound -Protocol TCP -RemoteAddress $IP -Action Allow -Program %SystemRoot%\system32\RdpSa.exe -Group 'Remote Desktop'
	}
write-log -LogData "New-Firewall-RDPPort Finished"
}



Function Reboot-Server {
	write-log -LogData "--------------------------------------------------------" -Silent
	write-log -LogData "REBOOT STARTED..." -Silent
	write-log -LogData "REBOOT: Stop-DCS CALLED..." -Silent
	Stop-DCS
	write-log -LogData "REBOOT: 'Change-Firewall-RDP -ClearAll' CALLED..." -Silent
	$shh = Change-Firewall-RDP -ClearAll
	write-log -LogData "REBOOTING NOW" -Silent
	Restart-Computer -ComputerName $env:COMPUTERNAME -Force
}
Function Get-Processes {
$get_processes = $null
$get_processes = New-Object -TypeName psobject
write-log -LogData "--------------------------------------------------------" -Silent
write-log -LogData "Get-Processes: STARTED" -Silent
write-log -LogData "Get-Processes: Calling Check-Game" -Silent
$GameStatus = Check-Game
write-log -LogData "Get-Processes: Calling Check-Update" -Silent
$UpdtStatus = Check-Update
$get_processes | Add-Member -MemberType NoteProperty -Name Game -Value $GameStatus
$get_processes | Add-Member -MemberType NoteProperty -Name Update -Value $UpdtStatus
write-log -LogData "Get-Processes: ENDED" -Silent
return $get_processes
}
Function Get-Status {
$get_status = $null
$get_status_Status = $null
$get_status_Details = $null
$get_status_ServerInfo = $null

$get_status_Status = Get-Processes
$get_status_ServerInfo = Get-ServerInfo

$get_status_Details = New-Object -TypeName psobject
$get_status_Details | Add-Member -MemberType NoteProperty -Name Info -Value $get_status_ServerInfo

$get_status = New-Object -TypeName psobject
$get_status | Add-Member -MemberType NoteProperty -Name Status -Value $get_status_Status
$get_status | Add-Member -MemberType NoteProperty -Name Details -Value $get_status_Details
write-log -LogData "Status Report: ENDED" -Silent
return $get_status
}
Function Restart-DCS {
write-log -LogData "--------------------------------------------------------" -Silent
write-log -LogData "Restart-DCS: STARTED" -Silent
write-log -LogData "Restart-DCS: Calling Stop-DCS" -Silent
	Stop-DCS
write-log -LogData "Restart-DCS: Calling Start-DCS" -Silent	
	Start-DCS
write-log -LogData "Restart-DCS: ENDED" -Silent
}
Function Start-DCS {
	write-log -LogData "--------------------------------------------------------" -Silent
	#Need to add check to see if task is already running
	write-log -LogData "Start-DCS: STARTED" -Silent
	write-log -LogData "Starting DCS" -Silent
	start-process $dcsexe -ArgumentList $dcsargs -WorkingDirectory $dcsdir
	write-log -LogData "Sleeping 5 second" -Silent
	Start-sleep 5
	write-log -LogData "Setting Priority for DCS" -Silent
	$shh = Get-WmiObject Win32_process -filter 'name = "DCS.exe"' -ErrorAction SilentlyContinue | foreach-object { $_.SetPriority(128) }
	write-log -LogData "Starting SRS" -Silent
	start-process $srsexe -WorkingDirectory $srsdir
	write-log -LogData "Sleeping 5 second" -Silent
	Start-sleep 5
	write-log -LogData "Setting Priority for SRS" -Silent
	$shh = Get-WmiObject Win32_process -filter 'name = "SR-Server.exe"' -ErrorAction SilentlyContinue | foreach-object { $_.SetPriority(128) } | Output-
	write-log -LogData "Sleeping 60 second" -Silent
	Start-sleep 90
	write-log -LogData "Shaping and Moving DCS Window" -Silent
	Set-Window -ProcessName DCS -X 150 -y 25 -Width 160 -Height 120
	write-log -LogData "Moving SRS Window" -Silent
	Set-Window -ProcessName SR-Server -x 305 -y 25
	write-log -LogData "Start-DCS: ENDED" -Silent
	###Add DCS Firewall Rules here
}
Function Stop-DCS {
	write-log -LogData "--------------------------------------------------------" -Silent
	write-log -LogData "Stop-DCS: STARTED" -Silent
	$dcs = Get-Process -Name DCS -ErrorAction SilentlyContinue | Select-Object $selection 
	write-log -LogData 'DCS process SET to $dcs' -Silent
	$srs = Get-Process -Name SR-Server -ErrorAction SilentlyContinue | Select-Object $selection
	write-log -LogData 'SRS process SET to  $srs' -Silent
	$dcsUpd = Get-Process -Name dcs_updater -ErrorAction SilentlyContinue | Select-Object $selection
	write-log -LogData 'DCS Update process SET to $dcsUpd' -Silent
	write-log -LogData 'Stopping Process $dcs' -Silent
	$dcs | stop-process -Force
	write-log -LogData '$dcs stopped' -Silent
	write-log -LogData 'Stopping Process $srs' -Silent
	$srs | stop-process -Force
	write-log -LogData '$srs stopped' -Silent
	write-log -LogData 'Stopping Process $dcsUpd' -Silent
	$dcsUpd | stop-process -Force
	write-log -LogData '$dcsUpd stopped' -Silent
	write-log -LogData "Sleeping 1 second" -Silent
	Start-sleep 1
	write-log -LogData "Stop-DCS: ENDED" -Silent
	###Remove DCS Firewall Rules here
}
####################################################################################################
#UPDATE#SECTION#####################################################################################
####################################################################################################
Function Update-LotATC {
	write-log -LogData "--------------------------------------------------------" -Silent
	write-log -LogData "Starting LotATC Update Process" -Silent
	Start-Process -FilePath $Lot_Updater -ArgumentList $Lot_Updater_Args -wait
	write-log -LogData "LotATC Update Process - JOB DONE!" -Silent
}
Function Update-SRS {
	write-log -LogData "--------------------------------------------------------" -Silent
	write-log -LogData "Starting SRS Update Process..." -Silent
	Start-Process -FilePath $SRS_Updater -ArgumentList $SRS_Updater_Args -wait
	write-log -LogData "SRS Update Process - JOB DONE!" -Silent
}
Function Update-DCS {
	write-log -LogData "--------------------------------------------------------" -Silent
	write-log -LogData "Starting DCS Update Process..." -Silent
	$Pwrshell = New-Object -ComObject wscript.shell;
	start-process $DCS_Updater -ArgumentList $DCS_Updater_Args -WorkingDirectory $dcsBIN
	#write-host "Waiting 15 Seconds for Check Update Window to complete check"
	write-log -LogData "Sleeping 15 seconds" -Silent
	Start-sleep 15;
	write-log -LogData 'DCS Update process SET to  $Process_UpdateDCS' -Silent
	$Process_UpdateDCS = Get-Process -Name DCS_updater -ErrorAction SilentlyContinue
	#write-host "Looking for DCS Updater Window: " -nonewline
	write-log -LogData "Selecting Window 'DCS Updater'" -Silent
	$shh = $Pwrshell.AppActivate('DCS Updater')
	write-log -LogData '$contLoop set to $true' -Silent
	$contLoop = $true
	write-log -LogData '$checkLoop set to 0' -Silent
	$checkLoop = 0
	write-log -LogData '$working set to 0' -Silent
	$working = 0
	write-log -LogData '$ticks set to 0' -Silent
	$ticks = 0
	#Possible Rogue TRUE Statement
	write-log -LogData 'Starting DCS Updater While Loop' -Silent
	$shh = while ($contLoop) {
		#This grabs the current tick count for the busy process
		write-log -LogData 'DCS Updating in progress... checking again in 1 second.' -Silent
		Start-sleep 1;
		$Process_UpdateDCS = Get-Process -Name DCS_updater -ErrorAction SilentlyContinue 
		if($Process_UpdateDCS.count -gt 0) {
			$ticks = ($Process_UpdateDCS | Sort-Object -Descending TotalProcessorTime)[0].TotalProcessorTime.ticks
		}
		if ($ticks -gt $working) {
			write-log -LogData "DCS UpdatetTicks: $ticks" -Silent
			$working = $ticks
		}
		else {
			$checkLoop = $checkLoop + 1
			
			if ($checkLoop -eq 1) {
				write-log -LogData "'Enter' pressed on 'DCS Updater' window incase it has a message" -Silent
				$Pwrshell.SendKeys('~')
			}
			if($checkLoop -ge 3) {
				write-log -LogData "CheckLoop triggered $checkLoop / 3" -Silent
				write-log -LogData "Exit DCS Updater While Loop" -Silent
				$contLoop = $false
			}
			else {
				write-log -LogData "CheckLoop triggered $checkLoop / 3" -Silent
			}
		}
	}
	write-log -LogData "Job Done, total completed ticks: $ticks" -Silent
	write-log -LogData "Sleeping 1 second" -Silent
	Start-sleep 1;
	write-log -LogData "Selecting Window 'DCS Updater'" -Silent
	$shh = $Pwrshell.AppActivate('DCS Updater')
	$Pwrshell.SendKeys('~')
	write-log -LogData "'Enter' pressed on 'DCS Updater' window" -Silent
	write-log -LogData "DCS Update Process - JOB DONE!" -Silent
}
Function Update-Server {
	write-log -LogData "--------------------------------------------------------" -Silent
	write-log -LogData "UPDATE DCS: STARTED" -Silent
	#STOP DCS
	write-log -LogData "UPDATE DCS: Call Stop-DCS" -Silent
	Stop-DCS
	Start-sleep 1;
	
	write-log -LogData "UPDATE DCS: Call Update LotATC" -Silent
	Update-LotATC
	Start-sleep 1;
	
	write-log -LogData "UPDATE DCS: Call Update SRS Update" -Silent
	Update-SRS
	Start-sleep 1;
	
	write-log -LogData "UPDATE DCS: Call Update DCS" -Silent
	Update-DCS
	Start-sleep 1;
	write-log -LogData "UPDATE DCS: Call Restart-DCS" -Silent
	Restart-DCS
	write-log -LogData "UPDATE DCS: JOB DONE!" -Silent
}
Function Get-Report {
$get_report = $null
$get_report = New-Object -TypeName psobject
write-log -LogData "--------------------------------------------------------" -Silent
write-log -LogData "Detailed Report: STARTED" -Silent
$details = $null
$details = get-config
$status = get-processes

$get_report | Add-Member -MemberType NoteProperty -Name Details -Value $details
$get_report | Add-Member -MemberType NoteProperty -Name Status -Value $status
write-log -LogData "Detailed Report: ENDED" -Silent
return $get_report
}
Function Set-Window {
    <#
        .SYNOPSIS
            Sets the window size (height,width) and coordinates (x,y) of
            a process window.
        .DESCRIPTION
            Sets the window size (height,width) and coordinates (x,y) of
            a process window.
        .PARAMETER ProcessName
            Name of the process to determine the window characteristics
        .PARAMETER X
            Set the position of the window in pixels from the top.
        .PARAMETER Y
            Set the position of the window in pixels from the left.
        .PARAMETER Width
            Set the width of the window.
        .PARAMETER Height
            Set the height of the window.
        .PARAMETER Passthru
            Display the output object of the window.
        .NOTES
            Name: Set-Window
            Author: Boe Prox
            Version History
                1.0//Boe Prox - 11/24/2015
                    - Initial build
        .OUTPUT
            System.Automation.WindowInfo
        .EXAMPLE
            Get-Process powershell | Set-Window -X 2040 -Y 142 -Passthru
            ProcessName Size     TopLeft  BottomRight
            ----------- ----     -------  -----------
            powershell  1262,642 2040,142 3302,784   
            Description
            -----------
            Set the coordinates on the window for the process PowerShell.exe
        
    #>
    [OutputType('System.Automation.WindowInfo')]
    [cmdletbinding()]
    Param (
        [parameter(ValueFromPipelineByPropertyName=$True)]
        $ProcessName,
        [int]$X,
        [int]$Y,
        [int]$Width,
        [int]$Height,
        [switch]$Passthru
    )
    Begin {
        Try{
            [void][Window]
        } Catch {
        Add-Type @"
              using System;
              using System.Runtime.InteropServices;
              public class Window {
                [DllImport("user32.dll")]
                [return: MarshalAs(UnmanagedType.Bool)]
                public static extern bool GetWindowRect(IntPtr hWnd, out RECT lpRect);
                [DllImport("User32.dll")]
                public extern static bool MoveWindow(IntPtr handle, int x, int y, int width, int height, bool redraw);
              }
              public struct RECT
              {
                public int Left;        // x position of upper-left corner
                public int Top;         // y position of upper-left corner
                public int Right;       // x position of lower-right corner
                public int Bottom;      // y position of lower-right corner
              }
"@
        }
    }
    Process {
        $Rectangle = New-Object RECT
        $Handle = (Get-Process -Name $ProcessName).MainWindowHandle
        $Return = [Window]::GetWindowRect($Handle,[ref]$Rectangle)
        If (-NOT $PSBoundParameters.ContainsKey('Width')) {            
            $Width = $Rectangle.Right - $Rectangle.Left            
        }
        If (-NOT $PSBoundParameters.ContainsKey('Height')) {
            $Height = $Rectangle.Bottom - $Rectangle.Top
        }
        If ($Return) {
            $Return = [Window]::MoveWindow($Handle, $x, $y, $Width, $Height,$True)
        }
        If ($PSBoundParameters.ContainsKey('Passthru')) {
            $Rectangle = New-Object RECT
            $Return = [Window]::GetWindowRect($Handle,[ref]$Rectangle)
            If ($Return) {
                $Height = $Rectangle.Bottom - $Rectangle.Top
                $Width = $Rectangle.Right - $Rectangle.Left
                $Size = New-Object System.Management.Automation.Host.Size -ArgumentList $Width, $Height
                $TopLeft = New-Object System.Management.Automation.Host.Coordinates -ArgumentList $Rectangle.Left, $Rectangle.Top
                $BottomRight = New-Object System.Management.Automation.Host.Coordinates -ArgumentList $Rectangle.Right, $Rectangle.Bottom
                If ($Rectangle.Top -lt 0 -AND $Rectangle.LEft -lt 0) {
                    Write-Warning "Window is minimized! Coordinates will not be accurate."
                }
                $Object = [pscustomobject]@{
                    ProcessName = $ProcessName
                    Size = $Size
                    TopLeft = $TopLeft
                    BottomRight = $BottomRight
                }
                $Object.PSTypeNames.insert(0,'System.Automation.WindowInfo')
                $Object            
            }
        }
    }
}
##This section actually executes the desired effect
$DCSreturn = $null
$DCSreturnJSON = $null
if ($Reboot) {Reboot-Server}
if ($Restart) {Restart-DCS}
if ($Stop) {Stop-DCS}
if ($Update) {Update-Server}
if ($Start) {Start-DCS}
if ($Secure) {$DCSreturn = Change-Firewall-RDP -Lock -IP $IP -USER $USER -DiscordID $ID}
if ($ClearAll) {$DCSreturn = Change-Firewall-RDP -ClearAll}
if ($Access) {$DCSreturn = Change-Firewall-RDP -Unlock -IP $IP -USER $USER -DiscordID $ID}
if ($Report) {$DCSreturn = Get-Report}
if ($Start) {$DCSreturn = Get-Report}
If ($Stop) {$DCSreturn = Get-Status}
if ($Restart) {$DCSreturn = Get-Report}
if ($Update) {$DCSreturn = Get-Report}
If ($Status) {$DCSreturn = Get-Status}

$DCSreturnJSON = $DCSreturn | ConvertTo-Json -Depth 100
write-log -LogData "DCSreturnJSON:" -silent
write-log -LogData $DCSreturnJSON -silent
write-log -LogData "---------------------------------------------------------" -Silent
write-log -LogData "--JOB-DONE-JOB-DONE-JOB-DONE-JOB-DONE-JOB-DONE-JOB-DONE--" -Silent
write-log -LogData "---------------------------------------------------------" -Silent
return $DCSreturnJSON
