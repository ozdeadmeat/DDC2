<#
DCS Controller Script for Node-Red & Discord Interaction
# Version 2.0a
# Writen by OzDeaDMeaT
# 10-04-2021
####################################################################################################
#CHANGE LOG#########################################################################################
####################################################################################################
- Seperation of settings from primary ddc2.ps1 file.
- Extraction of configuration data from Node-Red workflow to enable easier and less fiddly upgrades of DDC2 moving forward
- Introduced Radio feature allowing people to send audio messages to SRS frequency via a text message in discord
- Added dependency to Powershell 7.x (Powershell 5.x is no longer supported)
- Update not tested as Release and beta versions are the same atm.
####################################################################################################
#>

param(
[switch]$init,
[switch]$Refresh,
[switch]$Radio,
[switch]$Update,
[switch]$Status,
[switch]$Start,
[switch]$Stop,
[switch]$Restart,
[switch]$Reboot,
[switch]$Report,
[switch]$Secure,
[switch]$Access,
[switch]$VNC,
[switch]$ClearAll,
[switch]$DoUpdate,
[string]$IP,
[string]$USER,
[string]$ID,
[string]$DDC2DIR,
[string]$RadioMSG,
[string]$RadioFrq,
[string]$RadioMod,
[string]$RadioPort,
[string]$RadioSide,
[string]$RadioUser
	)

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
$DCSreturn 			= $null
$DCSreturnJSON 		= $null
$selection 			= 'Name', 'id', 'ProcessName', 'PriorityClass', 'ProductVersion', 'Responding', 'StartTime', @{Name='Ticks';Expression={$_.TotalProcessorTime.Ticks}}, @{Name='MemGB';Expression={'{00:N2}' -f ($_.WS/1GB)}}
$ProcessSelection = 'id', 'PriorityClass', 'ProductVersion', 'Responding', 'StartTime', @{Name='Ticks';Expression={$_.TotalProcessorTime.Ticks}}, @{Name='MemGB';Expression={'{00:N2}' -f ($_.WS/1GB)}}, 'MainWindowTitle', 'Path'
$DDC2_PSCore_Version = "v2.0a"
####################################################################################################
########################################################################################################################################################################################################
##This section Sets the DDC2 Location for execution and sets the correct config and log files to write to.
if(($DDC2DIR).count -gt 0) {
		if (test-path $DDC2DIR) {
			$currentDIR = $DDC2DIR
		} else {
			$currentDIR = (Get-Location).Path
		 }
} else {
	$currentDIR = (Get-Location).Path
	}
$PS_LogFile			= "$currentDIR\DDC2.log" 															#Log File Location for this script
$DDC2_Config 		= "$currentDIR\ddc2_config.ps1"														#DDC2 Configuration and Settings File Location
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
####################################################################################################
# Execute the config file
if (test-path $DDC2_Config) {
	write-log -LogData "DDC2 configuration File Found at $DDC2_Config, loading file now..." -Silent
	. $DDC2_Config
<# 	if (($DDC2).count -eq 0) {
		write-log -LogData "DDC2 variable has no data." -Silent}
	else {
		write-log -LogData "DDC2 variable has data...." -Silent
		write-log -LogData "$DDC2" -Silen
		write-log -LogData "######################## END OF DDC2 Variable" -Silent
		} #>
} else {
	write-log -LogData "DDC2 configuration file does not exist or is incorrect. Please check that $DDC2_Config file exists." -Silent
	$CHECKCONFIG = "ERROR -- DDC2 Config file not found at $DDC2_Config"
	$DCSreturnJSON = $CHECKCONFIG | ConvertTo-Json -Depth 100
	return $DCSreturn
	}
#Check Powershell version
$PSMajorVer = (($PSVersionTable).PSVersion).Major
$PSRequired = 7
if ($PSMajorVer -lt $PSRequired) {
	write-log -LogData "DDC2 requires version $PSRequired of Powershell to operate. Your version '$PSMajorVer' is too low to run DDC2, please upgrade your Powershell" -Silent
	$CHECKVERSION = "Your Powershell version too old to run DDC2, please upgrade your powershell executable."
	$DCSreturnJSON = $CHECKVERSION | ConvertTo-Json -Depth 100
	return $DCSreturn
} else {
	write-log -LogData "Powershell $PSMajorVer version found, Powershell check OK!" -Silent
	}
########################################################################################################################################################################################################

Function StringOutPorts {
Param ($Id)
$Netprocess = get-nettcpconnection -OwningProcess $Id -ErrorAction SilentlyContinue | Where-Object{$_.State -eq 'Listen'} | Select-Object localPort,State | Sort LocalPort
$PortOut = ""
Foreach($item in $Netprocess) {
		$PortOut = $PortOut + $item.LocalPort
		if($item -ne $Netprocess[-1]) {$PortOut = $PortOut + ", "}
	}
return $PortOut
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
write-host '$PS_LogFile			== ' -nonewline -ForegroundColor white
if (test-path $PS_LogFile) {
	write-host "OK" -nonewline -ForegroundColor green
	write-host " - $PS_LogFile" -ForegroundColor yellow
	} else {write-host "Not Found" -ForegroundColor red}
write-host '$VNC_Path			== ' -nonewline -ForegroundColor white
if (test-path $VNC_Path) {
	write-host "OK" -nonewline -ForegroundColor green
	write-host " - $VNC_Path" -ForegroundColor yellow
	} else {write-host "Not Found" -ForegroundColor red}	
####################################################################################################
write-host " "
write-host "Checking all DCS Variables...." -ForegroundColor white

write-host '$DCS_Profile 			== ' -nonewline -ForegroundColor white
if (test-path $DCS_Profile) {
	write-host "OK" -nonewline -ForegroundColor green
	write-host " - $DCS_Profile" -ForegroundColor yellow
	} else {write-host "Not Found" -ForegroundColor red}

write-host '$DCS_Config 			== ' -nonewline -ForegroundColor white
if (test-path $DCS_Config) {
	write-host "OK" -nonewline -ForegroundColor green
	write-host " - $DCS_Config" -ForegroundColor yellow
	} else {write-host "Not Found" -ForegroundColor red}
	
write-host '$DCS_AutoE			== ' -nonewline -ForegroundColor white
if (test-path $DCS_AutoE) {
	write-host "OK" -nonewline -ForegroundColor green
	write-host " - $DCS_AutoE" -ForegroundColor yellow
	} else {write-host "Not Found" -ForegroundColor red}
	
write-host '$dcsDIR 			== ' -nonewline -ForegroundColor white
if (test-path $dcsDIR) {
	write-host "OK" -nonewline -ForegroundColor green
	write-host " - $dcsDIR" -ForegroundColor yellow
	} else {write-host "Not Found" -ForegroundColor red}

write-host '$dcsBIN				== ' -nonewline -ForegroundColor white
if (test-path $dcsBIN) {
	write-host "OK" -nonewline -ForegroundColor green
	write-host " - $dcsBIN" -ForegroundColor yellow
	} else {write-host "Not Found" -ForegroundColor red}

write-host '$dcsEXE 			== ' -nonewline -ForegroundColor white
if (test-path $dcsEXE) {
	write-host "OK" -nonewline -ForegroundColor green
	write-host " - $dcsEXE" -ForegroundColor yellow
	} else {write-host "Not Found" -ForegroundColor red}

write-host '$DCS_Updater 			== ' -nonewline -ForegroundColor white
if (test-path $DCS_Updater) {
	write-host "OK" -nonewline -ForegroundColor green
	write-host " - $DCS_Updater" -ForegroundColor yellow
	} else {write-host "Not Found" -ForegroundColor red}
#END DCS Variables
####################################################################################################
#Start SRS Variables
write-host " "
write-host "Checking all SRS Variables...." -ForegroundColor white

write-host '$srsDIR 			== ' -nonewline -ForegroundColor white
if (test-path $srsDIR) {
	write-host "OK" -nonewline -ForegroundColor green
	write-host " - $srsDIR" -ForegroundColor yellow
	} else {write-host "Not Found" -ForegroundColor red}

write-host '$srsEXE 			== ' -nonewline -ForegroundColor white
if (test-path $srsEXE) {
	write-host "OK" -nonewline -ForegroundColor green
	write-host " - $srsEXE" -ForegroundColor yellow
	} else {write-host "Not Found" -ForegroundColor red}

write-host '$srsTXTaudio			== ' -nonewline -ForegroundColor white
if (test-path $SRS_External) {
	write-host "OK" -nonewline -ForegroundColor green
	write-host " - $SRS_External" -ForegroundColor yellow
	} else {write-host "Not Found" -ForegroundColor red}
#>	
write-host '$SRS_Config 			== ' -nonewline -ForegroundColor white
if (test-path $SRS_Config) {
	write-host "OK" -nonewline -ForegroundColor green
	write-host " - $SRS_Config" -ForegroundColor yellow
	} else {write-host "Not Found" -ForegroundColor red}
	
write-host '$SRS_AutoConnect		== ' -nonewline -ForegroundColor white
if (test-path $SRS_AutoConnect) {
	write-host "OK" -nonewline -ForegroundColor green
	write-host " - $SRS_AutoConnect" -ForegroundColor yellow
	} else {write-host "Not Found" -ForegroundColor red}
	
write-host '$SRS_Updater			== ' -nonewline -ForegroundColor white
if (test-path $SRS_Updater) {
	write-host "OK" -nonewline -ForegroundColor green
	write-host " - $SRS_Updater" -ForegroundColor yellow
	} else {write-host "Not Found" -ForegroundColor red}
#END SRS Variables
####################################################################################################
#Start LotATC Variables
write-host " "
write-host "Checking all LotATC Variables...." -ForegroundColor white

write-host '$LotDIR 			== ' -nonewline -ForegroundColor white
if (test-path $LotDIR) {
	write-host "OK" -nonewline -ForegroundColor green
	write-host " - $LotDIR" -ForegroundColor yellow
	} else {write-host "Not Found" -ForegroundColor red}

write-host '$Lot_Entry 			== ' -nonewline -ForegroundColor white
if (test-path $Lot_Entry) {
	write-host "OK" -nonewline -ForegroundColor green
	write-host " - $Lot_Entry" -ForegroundColor yellow
	} else {write-host "Not Found" -ForegroundColor red}
	
write-host '$Lot_Config 			== ' -nonewline -ForegroundColor white
if (test-path $Lot_Config) {
	write-host "OK" -nonewline -ForegroundColor green
	write-host " - $Lot_Config" -ForegroundColor yellow
	} else {write-host "Not Found" -ForegroundColor red}
	
write-host '$Lot_Updater 			== ' -nonewline -ForegroundColor white
if (test-path $Lot_Updater) {
	write-host "OK" -nonewline -ForegroundColor green
	write-host " - $Lot_Updater" -ForegroundColor yellow
	} else {write-host "Not Found" -ForegroundColor red}
	
write-host '$LotDIR 			== ' -nonewline -ForegroundColor white
if (test-path $LotDIR) {
	write-host "OK" -nonewline -ForegroundColor green
	write-host " - $LotDIR" -ForegroundColor yellow
	} else {write-host "Not Found" -ForegroundColor red}
#END LotATC Variables
####################################################################################################
#Start TACView Variables
write-host " "
write-host "Checking all TACView Variables...." -ForegroundColor white

write-host '$TacvDIR 			== ' -nonewline -ForegroundColor white
if (test-path $TacvDIR) {
	write-host "OK" -nonewline -ForegroundColor green
	write-host " - $TacvDIR" -ForegroundColor yellow
	} else {write-host "Not Found" -ForegroundColor red}

write-host '$TacvEXE 			== ' -nonewline -ForegroundColor white
if (test-path $TacvEXE) {
	write-host "OK" -nonewline -ForegroundColor green
	write-host " - $TacvEXE" -ForegroundColor yellow
	} else {write-host "Not Found" -ForegroundColor red}

write-host '$TACv_Entry 			== ' -nonewline -ForegroundColor white
if (test-path $TACv_Entry) {
	write-host "OK" -nonewline -ForegroundColor green
	write-host " - $TACv_Entry" -ForegroundColor yellow
	} else {write-host "Not Found" -ForegroundColor red}
	
write-host '$TACv_Config 			== ' -nonewline -ForegroundColor white
if (test-path $TACv_Config) {
	write-host "OK" -nonewline -ForegroundColor green
	write-host " - $TACv_Config" -ForegroundColor yellow
	} else {write-host "Not Found" -ForegroundColor red}
write-host " "
write-host "Check Complete...." -ForegroundColor white
write-host " "	
}
Function Setup-Ports {
Param (
[Parameter(Mandatory=$true)][int]$DCSPort
)
<#

#IMPORTANT NOTICE:::: RDP or VNC Set it up manually

This function sets up ports in accordance with a specific pattern listed below
$DCSPort = DCS World Port (8881)
$SRSPort = SRS Server Port + 1 (8882)
$LoTPort = LoTATC Port + 2 (8883)
$TACPort = TACView Client Telemetry Port + 3 (8884)
$WebUIPort = DCS Server WebUI Port + 4 (8885)
$ConsolePort = Console Port + 5 (Not configured by this Function) (8886)
$SRSTransponder = SRS Server Port + 6 (8887)
$TACRCPort = TACView RC Port + 7 (8888)
$LoTJSONPort = LoTATC JSON Server Port + 8 (8889)

DCS	1
SRS 2
LOT 3
TAC 4
WEB 5
CON 6
TRN 7
TRC 8
JSN 9
#>
write-log "Setup-Ports: STARTED" -silent
if(test-path $DCS_Config) {
	Set-Port -Search "[`"port`"]" -Port ($DCSPort+ 0) -File $DCS_Config
} else {
	write-log "$DCS_Config File not Found" -silent
}

if(test-path $SRS_Config) {
	Set-Port -Search "SERVER_PORT" -Port ($DCSPort + 1) -File $SRS_Config
	Set-Port -Search "LOTATC_EXPORT_PORT" -Port ($DCSPort + 6) -File $SRS_Config
} else {
	write-log "$SRS_Config File not Found" -silent
}

if(test-path $Lot_Config) {
	Set-Port -Search " port =" -Port ($DCSPort + 2) -File $Lot_Config
	Set-Port -Search "srs_transponder_port" -Port ($DCSPort + 6) -File $Lot_Config
	Set-Port -Search "jsonserver_port" -Port ($DCSPort + 8) -File $Lot_Config
} else {
	write-log "$Lot_Config File not Found" -silent
}

if(test-path $TACv_Config) {
	Set-Port -Search "[`"tacviewRealTimeTelemetryPort`"]" -Port ($DCSPort + 3) -File $TACv_Config
	Set-Port -Search "[`"tacviewRemoteControlPort`"]" -Port ($DCSPort + 7) -File $TACv_Config
} else {
	write-log "$TACv_Config File not Found" -silent
}

if(test-path $DCS_AutoE) {
	Set-Port -Search "webgui_port" -Port ($DCSPort + 4) -File $DCS_AutoE
} else {
	write-log "$DCS_AutoE File not Found" -silent
}

if(test-path $SRS_AutoConnect) {
	Set-Port -Search "SRSAuto.SERVER_SRS_PORT =" -Port ($DCSPort + 1) -File $SRS_AutoConnect
} else {
	write-log "$SRS_AutoConnect File not Found" -silent
}
write-log "Setup-Ports: ENDED" -silent
}


########################################################################################################################################################################################################
#SERVER & FIREWALL CONTROL##############################################################################################################################################################################
########################################################################################################################################################################################################
Function Reboot-Server {
	write-log -LogData "--------------------------------------------------------" -Silent
	write-log -LogData "REBOOT STARTED..." -Silent
	write-log -LogData "REBOOT: Stop-DCS CALLED..." -Silent
	Stop-DCS
	write-log -LogData "REBOOT: 'Change-Firewall -ClearAll' CALLED..." -Silent
	$shh = Change-Firewall -ClearAll
	write-log -LogData "REBOOTING NOW" -Silent
	Restart-Computer -ComputerName $env:COMPUTERNAME -Force
}
Function Change-Firewall {
<# 
.DESCRIPTION 
Manages all Firewall rules for a specific IP address
 
.EXAMPLE
Mode 1: Unlock
This mode will generate rules for the specific user who requested them.
Change-Firewall -UnLock -IP 192.168.0.55 -USER 'OzDeaDMeaT' -DiscordID '548546875'
Change-Firewall -UnLock -IP 192.168.0.55 -USER 'OzDeaDMeaT' -DiscordID '548546875' -VNC

Mode 2: Lock
This mode will check if there is an active connection for the specific user and if there is not it will remove the rules associated with the user it is checking for.
Change-Firewall -Lock -IP 192.168.0.55 -USER 'OzDeaDMeaT' -DiscordID '548546875'
Mode 3: ClearAll
This mode will remove ALL rules that have been generated. (use this for scheduled task on reboot)
Change-Firewall -ClearAll
System returns a PowerShell Object Variable for all task types.
#>

Param (
[string]$IP = '',
[string]$USER = '',
[string]$DiscordID = '',
[switch]$VNC,
[switch]$Lock,
[switch]$Unlock,
[switch]$ClearAll
)
write-log -LogData "--------------------------------------------------------" -Silent
write-log -LogData "Change-Firewall: STARTED" -Silent
write-log -LogData "Change-Firewall Started for $USER with Discord ID of $DiscordID for IP:$IP" -Silent
$outputVar = $null
$RDPPort = (Get-Item "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp").GetValue('PortNumber')
$RULEPREFIX = 'DDC2 - '
$WILDCARD = "$RULEPREFIX*"
$Time = get-date -Format "yyyy-MMM-dd--HH:mm:ss"
$RULE_NAME_PREFIX = "$RULEPREFIX$DiscordID -"
$RULE_DISPLAYNAME_PREFIX = "$RULEPREFIX$USER -"
$RULE_DESCRIPTION = "AutoGenerated Firewall Rule for $USER with Discord ID $DiscordID on date $Time"
$OutputVar = New-Object -TypeName psobject 
#$OutputVar | Add-Member -MemberType NoteProperty -Name Request -Value "UNKNOWN"
$OutputVar | Add-Member -MemberType NoteProperty -Name Status -Value "UNKNOWN"
$OutputVar | Add-Member -MemberType NoteProperty -Name Name -Value $USER
$OutputVar | Add-Member -MemberType NoteProperty -Name DiscordID -Value $DiscordID
$OutputVar | Add-Member -MemberType NoteProperty -Name IP -Value $IP
$OutputVar | Add-Member -MemberType NoteProperty -Name Connected -Value $false
$OutputVar | Add-Member -MemberType NoteProperty -Name ExitLoop -Value $false
#$OutputVar | Add-Member -MemberType NoteProperty -Name Message -Value ""
#$OutputVar | Add-Member -MemberType NoteProperty -Name ValidIP -Value $false
if($Unlock) {
	#$Octet = '(?:0?0?[0-9]|0?[1-9][0-9]|1[0-9]{2}|2[0-5][0-5]|2[0-4][0-9])'
	#[regex] $IPv4Regex = "^(?:$Octet\.){3}$Octet$"
	#$checkIP = $IP -match $IPv4Regex
	$checkIP = $true
	#$OutputVar.ValidIP = $checkIP
	if($CheckIP) {
		#check if the rules currently exist
		$currentRules = (get-NetFirewallRule -Name "$RULE_NAME_PREFIX *" | Measure-Object).count
		if($currentRules -gt 0) {
			get-NetFirewallRule -Name "$RULE_NAME_PREFIX *" | remove-NetFirewallRule
			write-log -LogData "Old Firewall Rules Found, removing..." -Silent
			Start-sleep 1
			}
		#RDP Rules			
		if ($VNCEnabled) {
			$shhh = New-NetFirewallRule -Name "$RULE_NAME_PREFIX VNC-TCP" -DisplayName "$RULE_DISPLAYNAME_PREFIX TCP" -Description $RULE_DESCRIPTION -Direction Inbound -LocalPort $VNCPort -Protocol TCP -RemoteAddress $IP -Action Allow -Program $VNC_Path -Group 'Remote Desktop'
			$shhh = New-NetFirewallRule -Name "$RULE_NAME_PREFIX VNC-UDP" -DisplayName "$RULE_DISPLAYNAME_PREFIX UDP" -Description $RULE_DESCRIPTION -Direction Inbound -LocalPort $VNCPort -Protocol UDP -RemoteAddress $IP -Action Allow -Program $VNC_Path -Group 'Remote Desktop'
			}
		else {	
			$shhh = New-NetFirewallRule -Name "$RULE_NAME_PREFIX RDP-TCP" -DisplayName "$RULE_DISPLAYNAME_PREFIX TCP" -Description $RULE_DESCRIPTION -Direction Inbound -LocalPort $RDPPort -Protocol TCP -RemoteAddress $IP -Action Allow -Program %SystemRoot%\system32\svchost.exe -Group 'Remote Desktop'
			$shhh = New-NetFirewallRule -Name "$RULE_NAME_PREFIX RDP-UDP" -DisplayName "$RULE_DISPLAYNAME_PREFIX UDP" -Description $RULE_DESCRIPTION -Direction Inbound -LocalPort $RDPPort -Protocol UDP -RemoteAddress $IP -Action Allow -Program %SystemRoot%\system32\svchost.exe -Group 'Remote Desktop'
			$shhh = New-NetFirewallRule -Name "$RULE_NAME_PREFIX Shadow RDP-TCP" -DisplayName "$RULE_DISPLAYNAME_PREFIX Shadow TCP" -Description $RULE_DESCRIPTION -Direction Inbound -Protocol TCP -RemoteAddress $IP -Action Allow -Program %SystemRoot%\system32\RdpSa.exe -Group 'Remote Desktop'
			}
		
		$OutputVar.Status = "Unlock"
		#$OutputVar.Message = "$USER Door is unlocked, come on in..."
		write-log -LogData "Firewall rules generated for $USER with Discord ID of $DiscordID for IP:$IP" -Silent
		}
	else {
		#$OutputVar.Message = "$USER, the IP address $IP appears to be invalid, door remains locked"
		$OutputVar.ExitLoop = $true
		write-log -LogData "IP Address Supplied is invalid" -Silent
		}
	}
#Need VNC Bool Check and new info here
if ($VNCEnabled) {
	write-log -LogData "VNC Selected" -Silent
	$connected = (get-nettcpconnection | Where-Object{$_.RemoteAddress -eq $IP -and $_.LocalPort -eq $VNCPort -and $_.State -eq 'Established'} | Measure-Object).Count
	write-log -LogData "VNC Connections = $connected" -Silent
	}
else {
	write-log -LogData "RDP Selected" -Silent
	$connected = (get-nettcpconnection | Where-Object{$_.RemoteAddress -eq $IP -and $_.LocalPort -eq $RDPPort -and $_.State -eq 'Established'} | Measure-Object).Count
	write-log -LogData "RDP Connections = $connected" -Silent
	}
if($connected -ne 0) {
	$OutputVar.Connected = $true
	}
if($Lock) {
	if($connected -eq 0) {
		$OutputVar.Status = "Lock"
		$OutputVar.ExitLoop = $true
		#$OutputVar.Message = "$USER connection not detected, firewall rules removed..."
		Get-NetFirewallRule -Name "$RULE_NAME_PREFIX*" | remove-NetFirewallRule
		write-log -LogData "$USER RDP Firewall rules removed" -Silent
		}
	else{
		$OutputVar.Connected = $true
		$OutputVar.Status = "Connected"
		#$OutputVar.Message = "$USER has connected..."
		write-log -LogData "$USER still connected" -Silent
		}
	}
If($ClearAll) {
	Get-NetFirewallRule -Name $WILDCARD | remove-NetFirewallRule
	$OutputVar.Status = "ClearAll"
	#$OutputVar.Message = "All AutoGenerated Firewall rules have been deleted."
	write-log -LogData "All AutoGenerated Firewall rules have been deleted." -Silent
	}
write-log -LogData $OutputVar -Silent
write-log -LogData "Change-Firewall: ENDED" -Silent
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
Function PasswordGenerator {
$pwd = $null
$CharVar = (97..122) | Get-Random -count 3 | % {[char]$_}
$NumVar = Get-Random -Minimum 0 -Maximum 9999
$NumVarPad = ([string]$NumVar).PadLeft(4,'0')
$pwd = $CharVar[0] + $CharVar[1] + $CharVar[2] +$NumVarPad
return $pwd
}
Function PwdRandomizer {

$Config = Get-Config
	if($EnableRandomizer) {
		if($ServerPassword) {
			$SrvPwd = PasswordGenerator
			Set-Pwd -File $DCS_Config -Search "password" -Pwd $SrvPwd
		} else {
			$SrvPwd = ($Config.DCS.password)
		}
		if($SeperateTAC) {
			$TacPwd = PasswordGenerator
			Set-Pwd -File $DCS_Config -Search "password" -Pwd $SrvPwd
			Set-Pwd -File $TACv_Config -Search "tacviewClientTelemetryPassword" -Pwd $TacPwd
		} else {
			$TacPwd = $SrvPwd
			Set-Pwd -File $TACv_Config -Search "tacviewClientTelemetryPassword" -Pwd $TacPwd
		}
		if($SRSPassword) {
			$BluPwd = PasswordGenerator	#SRS / Generic Blue Side Pwd
			Set-Pwd -File $SRS_Config -Search "EXTERNAL_AWACS_MODE_BLUE_PASSWORD" -Pwd $BluPwd
			$RedPwd = PasswordGenerator #SRS / Generic Red Side Pwd
			Set-Pwd -File $SRS_Config -Search "EXTERNAL_AWACS_MODE_RED_PASSWORD" -Pwd $RedPwd
		} else {
			$BluPwd = ($Config.srs.EXTERNAL_AWACS_MODE_BLUE_PASSWORD) #SRS / Generic Blue Side Pwd
			$RedPwd = ($Config.srs.EXTERNAL_AWACS_MODE_RED_PASSWORD) #SRS / Generic Red Side Pwd
		}
		if($SeperateLOT){
			$BluLOT	= PasswordGenerator
			Set-Pwd -File $Lot_Config -Search "blue_password" -Pwd $BluLOT
			$RedLOT	= PasswordGenerator
			Set-Pwd -File $Lot_Config -Search "red_password" -Pwd $RedLOT
		} else {
			$BluLOT	= $BluPwd
			Set-Pwd -File $Lot_Config -Search "blue_password" -Pwd $BluLOT
			$RedLOT	= $RedPwd
			Set-Pwd -File $Lot_Config -Search "red_password" -Pwd $RedLOT
		}
	}
}
Function Set-Pwd {
<#
BETA - DONT USE YET, IT AINT READY!
Examples
DCS == 	Set-Pwd -File $DCS_Config -Search "password" -Pwd "Elephant"

SRS == 	Set-Pwd -File $SRS_Config -Search "EXTERNAL_AWACS_MODE_BLUE_PASSWORD" -Pwd "Elephant" ||
		Set-Pwd -File $SRS_Config -Search "EXTERNAL_AWACS_MODE_RED_PASSWORD" -Pwd "Elephant"
		
LOT ==	Set-Pwd -File $Lot_Config -Search "blue_password" -Pwd "Elephant" ||
		Set-Pwd -File $Lot_Config -Search "red_password" -Pwd "Elephant"

TAC == 	Set-Pwd -File $TACv_Config -Search "tacviewHostTelemetryPassword" -Pwd "Elephant" || 
		Set-Pwd -File $TACv_Config -Search "tacviewClientTelemetryPassword" -Pwd "Elephant" || 
		Set-Pwd -File $TACv_Config -Search "tacviewRemoteControlPassword" -Pwd "Elephant"
#>
Param (
[Parameter(Mandatory=$true)]$File,
[Parameter(Mandatory=$true)]$Search,
[Parameter(Mandatory=$true)]$Pwd
)
	write-log "Searching for: $Search" -silent
	$Found = $false
	$LineNumber = 0
	$NewContent = @()
	$FileExtentsion = ((Get-ChildItem $file).Extension)
	if($FileExtentsion -eq ".lua") {$LUA = $true} else {$LUA = $false}
	write-log "File extension is LUA = $LUA" -silent
	$Content = Get-Content $File
	ForEach ($Line in $Content) {
		if($Line -match $Search) {
			$Found = $true
			write-log "Found on Line #$LineNumber - $Line" -silent
			if($LUA) {
				$SplitStr = $Line.Split("=")[0]
				$Line = "$SplitStr= `"$Pwd`","
			} else {
				$SplitStr = $Line.Split("=")[0]
				$Line = "$SplitStr=$Pwd"
			}
			write-log "Line #$LineNumber Set To - $Line" -silent
		}
		$LineNumber = $LineNumber + 1
		$NewContent += $Line
	} 
if ($Found) {
		#Make a backup of the file before attempting to write file
		$backupFile = (split-path $file)+"\Pre-DDC2-"+(split-path $file -leaf)+".bak"
		Copy-Item $DCS_Config -Destination $backupFile -Force
		#Write New Data to file
		$NewContent | Out-File $File
		write-log "$File UPDATED!!" -silent
		$rtn = $true
	} else { 
		write-log "$Search was not found in $File" -silent
		$rtn = $false
	}
#return $rtn
}
Function Set-Port {
<#
I have a love hate relationship with REGEX
#>
Param (
[Parameter(Mandatory=$true)]$File,
[Parameter(Mandatory=$true)]$Search,
[Parameter(Mandatory=$true)]$Port
)


	#write-log "Searching for: $Search" -silent
	$Found = $false
	$LineNumber = 0
	$NewContent = @()
	$FileExtentsion = ((Get-ChildItem $file).Extension)
	if($FileExtentsion -eq ".lua") {$LUA = $true} else {$LUA = $false}
	#write-log "File extension is LUA = $LUA" -silent
	$Content = Get-Content $File
	ForEach ($Line in $Content) {
		if($Line -match [regex]::Escape("$Search")) {
			$Found = $true
			#write-log "Found on Line #$LineNumber - $Line" -silent
			if($LUA) {
				$SplitStr = $Line.Split("=")[0]
				if(($Search -match [regex]::Escape('tacview')) -or ($Search -match [regex]::Escape('SRSAuto.SERVER_SRS_PORT'))) {
					$Line = "$SplitStr= `"$Port`","
				} else {
					$Line = "$SplitStr= $Port,"	
				}
			} else {
				$SplitStr = $Line.Split("=")[0]
				$Line = "$SplitStr=$Port"
			}
			write-log "Line #$LineNumber Set To - $Line" -silent
		}
		$LineNumber = $LineNumber + 1
		$NewContent += $Line
	} 
if ($Found) {
		#Make a backup of the file before attempting to write file
		$backupFile = (split-path $file)+"\Pre-DDC2-"+(split-path $file -leaf)+".bak"
		Copy-Item $file -Destination $backupFile -Force
		#Write New Data to file
		$NewContent | Out-File $File
		write-log "$File UPDATED!!" -silent
		$rtn = $true
	} else { 
		write-log "$Search was not found in $File" -silent
		$rtn = $false
	}
#return $rtn
}


########################################################################################################################################################################################################
#SERVER DATA COLLECTION#################################################################################################################################################################################
########################################################################################################################################################################################################
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
write-host '$VNC_Path	== ' -nonewline -ForegroundColor white
if (test-path $VNC_Path) {
	write-host "OK" -nonewline -ForegroundColor green
	write-host " - $VNC_Path" -ForegroundColor yellow
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
Function Get-ServerInfo {
	##COLLECTION OF SERVER INFO
	$system = Get-CimInstance -Class Win32_OperatingSystem
	$LastBoot = $system.LastBootUpTime
	$serverUpTime = (get-date) - $LastBoot
	$wVER = (Get-Item "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").GetValue('ProductName') + " (Build:" + (Get-Item "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").GetValue('ReleaseId') + "."+(Get-Item "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").GetValue('CurrentBuildNumber')+")"
	if ($VNCEnabled) {
		$ConsoleType = $VNCType
		$ConsolePort = $VNCPort
	} else {
		$ConsoleType = "Remote Desktop"
		$ConsolePort = (Get-Item "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp").GetValue('PortNumber')
		}
	$tzInfo = [System.TimeZoneInfo]::Local
	$utcoffset = (($tzinfo).DisplayName).Split(" ")[0]
	$tzSN = [Regex]::Replace($tzInfo.StandardName, '([A-Z])\w+\s*', '$1')
	$ServerDateTime = (get-date).DateTime
	########################################################################################################################
	#Get CPU Information
	$Processor = Get-CimInstance -ClassName Win32_Processor
	#Get Memory Information
	$TotalMemGB = [math]::Round((($system).TotalVisibleMemorySize / 1048576),0)
	#Get Network Information
	$ExternalNET = Invoke-RestMethod http://ipinfo.io/json
	#$network = get-nettcpconnection -ErrorAction SilentlyContinue | Select-Object local*,remote*,state,@{Name="Process";Expression={(Get-Process -Id $_.OwningProcess).ProcessName}} 
	##SET SERVER INFO VARIABLE
	$PwdRandomizer = $null
	$PwdRandomizer = New-Object -TypeName psobject 	
	$PwdRandomizer | Add-Member -MemberType NoteProperty -Name EnableRandomizer -Value $EnableRandomizer	#Item Pulled from ddc2_config.ps1
	$PwdRandomizer | Add-Member -MemberType NoteProperty -Name ServerPassword -Value $ServerPassword		#Item Pulled from ddc2_config.ps1
	$PwdRandomizer | Add-Member -MemberType NoteProperty -Name SRSPassword -Value $SRSPassword				#Item Pulled from ddc2_config.ps1
	$PwdRandomizer | Add-Member -MemberType NoteProperty -Name SeperateLOT -Value $SeperateLOT				#Item Pulled from ddc2_config.ps1
	$PwdRandomizer | Add-Member -MemberType NoteProperty -Name SeperateTAC -Value $SeperateTAC				#Item Pulled from ddc2_config.ps1
	
	$ConnectStr = if($DNSName -ne "") {$DNSName} else {$ExternalNET.ip} #Checks item from ddc2_config.ps1 
	$Get_ServerInfo = $null
	$Get_ServerInfo = New-Object -TypeName psobject 
	$Get_ServerInfo | Add-Member -MemberType NoteProperty -Name WinVer -Value $wVER
	$Get_ServerInfo | Add-Member -MemberType NoteProperty -Name ComputerName -Value $env:COMPUTERNAME
	$Get_ServerInfo | Add-Member -MemberType NoteProperty -Name VNCEnabled -Value $VNCEnabled
	$Get_ServerInfo | Add-Member -MemberType NoteProperty -Name ConsoleType -Value $ConsoleType
	$Get_ServerInfo | Add-Member -MemberType NoteProperty -Name ConsolePort -Value $ConsolePort
	$Get_ServerInfo | Add-Member -MemberType NoteProperty -Name ServerTime -Value $ServerDateTime
	$Get_ServerInfo | Add-Member -MemberType NoteProperty -Name LastBoot -Value $LastBoot.DateTime
	$Get_ServerInfo | Add-Member -MemberType NoteProperty -Name UpTime -Value $serverUpTime
	$Get_ServerInfo | Add-Member -MemberType NoteProperty -Name TZ -Value $tzInfo.StandardName
	$Get_ServerInfo | Add-Member -MemberType NoteProperty -Name TZSN -Value $tzSN
	$Get_ServerInfo | Add-Member -MemberType NoteProperty -Name UTCOffset -Value $utcoffset
	$Get_ServerInfo | Add-Member -MemberType NoteProperty -Name ConnectionAdrr -Value $ConnectStr
	$Get_ServerInfo | Add-Member -MemberType NoteProperty -Name IPAddr -Value $ExternalNET.ip
	$Get_ServerInfo | Add-Member -MemberType NoteProperty -Name HostName -Value $ExternalNET.hostname
	$Get_ServerInfo | Add-Member -MemberType NoteProperty -Name ISP -Value $ExternalNET.org
	$Get_ServerInfo | Add-Member -MemberType NoteProperty -Name CPUType -Value $Processor.Name
	$Get_ServerInfo | Add-Member -MemberType NoteProperty -Name CPUCores -Value $Processor.NumberOfLogicalProcessors
	$Get_ServerInfo | Add-Member -MemberType NoteProperty -Name TotalMem -Value $TotalMemGB
	$Get_ServerInfo | Add-Member -MemberType NoteProperty -Name ServerID -Value $ServerID					#Item Pulled from ddc2_config.ps1
	$Get_ServerInfo | Add-Member -MemberType NoteProperty -Name DDC2_PSCore -Value $DDC2_PSCore_Version		#Item Pulled from ddc2.ps1
	$Get_ServerInfo | Add-Member -MemberType NoteProperty -Name DDC2_PSConfig -Value $DDC2_PSConfig_Version	#Item Pulled from ddc2_config.ps1
	$Get_ServerInfo | Add-Member -MemberType NoteProperty -Name DDC2_Path -Value $DDC2DIR					#Item Pulled from ddc2.ps1 during command execution (ddc2 script argument)
	$Get_ServerInfo | Add-Member -MemberType NoteProperty -Name ENABLE_HELP -Value $DDC2_HELP				#Item Pulled from ddc2_config.ps1
	$Get_ServerInfo | Add-Member -MemberType NoteProperty -Name ServerDT -Value $ServerDT					#Item Pulled from ddc2_config.ps1
	$Get_ServerInfo | Add-Member -MemberType NoteProperty -Name HostedBy -Value $HostedBy					#Item Pulled from ddc2_config.ps1
	$Get_ServerInfo | Add-Member -MemberType NoteProperty -Name Support -Value $Support						#Item Pulled from ddc2_config.ps1
	$Get_ServerInfo | Add-Member -MemberType NoteProperty -Name ShowBluPWD -Value $SHOW_BLUPWD				#Item Pulled from ddc2_config.ps1
	$Get_ServerInfo | Add-Member -MemberType NoteProperty -Name ShowRedPWD -Value $SHOW_REDPWD				#Item Pulled from ddc2_config.ps1
	$Get_ServerInfo | Add-Member -MemberType NoteProperty -Name ShowSrvPWD -Value $SHOW_SRVPWD				#Item Pulled from ddc2_config.ps1
	$Get_ServerInfo | Add-Member -MemberType NoteProperty -Name ShowLotATC -Value $SHOW_LotATC				#Item Pulled from ddc2_config.ps1
	$Get_ServerInfo | Add-Member -MemberType NoteProperty -Name ShowTACView -Value $SHOW_TACView			#Item Pulled from ddc2_config.ps1
	$Get_ServerInfo | Add-Member -MemberType NoteProperty -Name AccessLoop -Value $ACCESS_LOOP_DELAY		#Item Pulled from ddc2_config.ps1
	$Get_ServerInfo | Add-Member -MemberType NoteProperty -Name UpdateLoop -Value $UPDATE_LOOP_DELAY		#Item Pulled from ddc2_config.ps1	
	$Get_ServerInfo | Add-Member -MemberType NoteProperty -Name PwdRandomizer -Value $PwdRandomizer			#Item Pulled from ddc2_config.ps1	

return $Get_ServerInfo
}
Function Get-Config {
#This function checks all the config files etc for version, ports, passwords for each seperate application and outputs it all as a single variable to be used in the Node-Red message output workflow or stored as vairables for the !info message
########################################################################################################################
write-log -LogData "Get-Config: STARTED" -Silent
$SRV_config = $null
$SRV_config = New-Object -TypeName psobject
########################################################################################################################
##DCS
$DCS_Settings = $null
$DCS_Settings = New-Object -TypeName psobject

if(test-path $dcsEXE) {
	$DCS_Version = (Get-ChildItem $dcsEXE).VersionInfo.ProductVersion
	$DCS_INSTALLED = $true
} else {
	$DCS_Version = 'NOT INSTALLED'
	$DCS_INSTALLED = $false
	}

if(test-path $DCS_AutoE) {
	$DCS_webgui_port = ((Select-String -Path $DCS_AutoE -Pattern "webgui_port " | Out-String).Split('=')[-1]).Trim()
	$DCS_use_upnp = ((Select-String -Path $DCS_AutoE -Pattern "net.use_upnp " | Out-String).Split('=')[-1]).Trim()
	if ($DCS_use_upnp -eq "") {$DCS_use_upnp = 'true'}
} else {
	$DCS_webgui_port = '8088'
	$DCS_use_upnp = 'true'
	}

if(test-path $DCS_Config) {
	$DCS_require_pure_textures 	= ((Select-String -Path $DCS_Config -Pattern "require_pure_textures" | Out-String).Split(' ')[-1]).Split(',')[0]
	$DCS_allow_change_tailno 	= ((Select-String -Path $DCS_Config -Pattern "allow_change_tailno" | Out-String).Split(' ')[-1]).Split(',')[0]
	$DCS_disable_events 		= ((Select-String -Path $DCS_Config -Pattern "disable_events" | Out-String).Split(' ')[-1]).Split(',')[0]
	$DCS_allow_ownship_export 	= ((Select-String -Path $DCS_Config -Pattern "allow_ownship_export" | Out-String).Split(' ')[-1]).Split(',')[0]
	$DCS_allow_object_export 	= ((Select-String -Path $DCS_Config -Pattern "allow_object_export" | Out-String).Split(' ')[-1]).Split(',')[0]
	$DCS_pause_on_load 			= ((Select-String -Path $DCS_Config -Pattern "pause_on_load" | Out-String).Split(' ')[-1]).Split(',')[0]
	$DCS_allow_sensor_export 	= ((Select-String -Path $DCS_Config -Pattern "allow_sensor_export" | Out-String).Split(' ')[-1]).Split(',')[0]
	$DCS_event_Takeoff 			= ((Select-String -Path $DCS_Config -Pattern "event_Takeoff" | Out-String).Split(' ')[-1]).Split(',')[0]
	$DCS_pause_without_clients 	= ((Select-String -Path $DCS_Config -Pattern "pause_without_clients" | Out-String).Split(' ')[-1]).Split(',')[0]
	$DCS_client_outbound_limit	= ((Select-String -Path $DCS_Config -Pattern "client_outbound_limit" | Out-String).Split(' ')[-1]).Split(',')[0]
	$DCS_client_inbound_limit 	= ((Select-String -Path $DCS_Config -Pattern "client_inbound_limit" | Out-String).Split(' ')[-1]).Split(',')[0]
	$DCS_server_can_screenshot 	= ((Select-String -Path $DCS_Config -Pattern "server_can_screenshot" | Out-String).Split(' ')[-1]).Split(',')[0]
	$DCS_voice_chat_server 		= ((Select-String -Path $DCS_Config -Pattern "voice_chat_server" | Out-String).Split(' ')[-1]).Split(',')[0]
	$DCS_allow_change_skin 		= ((Select-String -Path $DCS_Config -Pattern "allow_change_skin" | Out-String).Split(' ')[-1]).Split(',')[0]
	$DCS_event_Connect 			= ((Select-String -Path $DCS_Config -Pattern "event_Connect" | Out-String).Split(' ')[-1]).Split(',')[0]
	$DCS_event_Ejecting			= ((Select-String -Path $DCS_Config -Pattern "event_Ejecting" | Out-String).Split(' ')[-1]).Split(',')[0]
	$DCS_event_Kill 			= ((Select-String -Path $DCS_Config -Pattern "event_Kill" | Out-String).Split(' ')[-1]).Split(',')[0]
	$DCS_event_Crash 			= ((Select-String -Path $DCS_Config -Pattern "event_Crash" | Out-String).Split(' ')[-1]).Split(',')[0]
	$DCS_resume_mode 			= ((Select-String -Path $DCS_Config -Pattern "resume_mode" | Out-String).Split(' ')[-1]).Split(',')[0]
	$DCS_event_Role 			= ((Select-String -Path $DCS_Config -Pattern "event_Role" | Out-String).Split(' ')[-1]).Split(',')[0]
	$DCS_maxPing 				= (Select-String -Path $DCS_Config -Pattern "maxPing" | Out-String).Split('"')[-2]
	$DCS_port					= ((Select-String -Path $DCS_Config -Pattern "port" | Out-String).Split(' ')[-1]).Split(',')[0]
	$DCS_mode					= ((Select-String -Path $DCS_Config -Pattern "mode" | Out-String).Split(' ')[-1]).Split(',')[0]
	$DCS_bind_address 			= (Select-String -Path $DCS_Config -Pattern "bind_address" | Out-String).Split('"')[-2]
	$DCS_isPublic				= ((Select-String -Path $DCS_Config -Pattern "isPublic" | Out-String).Split(' ')[-1]).Split(',')[0]
	$DCS_password 				= (Select-String -Path $DCS_Config -Pattern "password" | Out-String).Split('"')[-2]
	$DCS_uri 					= (Select-String -Path $DCS_Config -Pattern "uri" | Out-String).Split('"')[-2]
	$DCS_name 					= (Select-String -Path $DCS_Config -Pattern "name" | Out-String).Split('"')[-2]
	$DCS_listShuffle			= ((Select-String -Path $DCS_Config -Pattern "listShuffle" | Out-String).Split(' ')[-1]).Split(',')[0]
	$DCS_listLoop				= ((Select-String -Path $DCS_Config -Pattern "listLoop" | Out-String).Split(' ')[-1]).Split(',')[0]
	$DCS_require_pure_clients	= ((Select-String -Path $DCS_Config -Pattern "require_pure_clients" | Out-String).Split(' ')[-1]).Split(',')[0]
	$DCS_require_pure_models	= ((Select-String -Path $DCS_Config -Pattern "require_pure_models" | Out-String).Split(' ')[-1]).Split(',')[0]
	$DCS_maxPlayers				= (Select-String -Path $DCS_Config -Pattern "maxPlayers" | Out-String).Split('"')[-2]
} else {
	$DCS_require_pure_textures 	= '$DCS_Config PATH NOT FOUND IN DDC2_CONFIG.ps1'
	$DCS_allow_change_tailno 	= '$DCS_Config PATH NOT FOUND IN DDC2_CONFIG.ps1'
	$DCS_disable_events 		= '$DCS_Config PATH NOT FOUND IN DDC2_CONFIG.ps1'
	$DCS_allow_ownship_export 	= '$DCS_Config PATH NOT FOUND IN DDC2_CONFIG.ps1'
	$DCS_allow_object_export 	= '$DCS_Config PATH NOT FOUND IN DDC2_CONFIG.ps1'
	$DCS_pause_on_load 			= '$DCS_Config PATH NOT FOUND IN DDC2_CONFIG.ps1'
	$DCS_allow_sensor_export 	= '$DCS_Config PATH NOT FOUND IN DDC2_CONFIG.ps1'
	$DCS_event_Takeoff 			= '$DCS_Config PATH NOT FOUND IN DDC2_CONFIG.ps1'
	$DCS_pause_without_clients 	= '$DCS_Config PATH NOT FOUND IN DDC2_CONFIG.ps1'
	$DCS_client_outbound_limit	= '$DCS_Config PATH NOT FOUND IN DDC2_CONFIG.ps1'
	$DCS_client_inbound_limit 	= '$DCS_Config PATH NOT FOUND IN DDC2_CONFIG.ps1'
	$DCS_server_can_screenshot 	= '$DCS_Config PATH NOT FOUND IN DDC2_CONFIG.ps1'
	$DCS_voice_chat_server 		= '$DCS_Config PATH NOT FOUND IN DDC2_CONFIG.ps1'
	$DCS_allow_change_skin 		= '$DCS_Config PATH NOT FOUND IN DDC2_CONFIG.ps1'
	$DCS_event_Connect 			= '$DCS_Config PATH NOT FOUND IN DDC2_CONFIG.ps1'
	$DCS_event_Ejecting			= '$DCS_Config PATH NOT FOUND IN DDC2_CONFIG.ps1'
	$DCS_event_Kill 			= '$DCS_Config PATH NOT FOUND IN DDC2_CONFIG.ps1'
	$DCS_event_Crash 			= '$DCS_Config PATH NOT FOUND IN DDC2_CONFIG.ps1'
	$DCS_resume_mode 			= '$DCS_Config PATH NOT FOUND IN DDC2_CONFIG.ps1'
	$DCS_event_Role 			= '$DCS_Config PATH NOT FOUND IN DDC2_CONFIG.ps1'
	$DCS_maxPing 				= '$DCS_Config PATH NOT FOUND IN DDC2_CONFIG.ps1'
	$DCS_port					= '$DCS_Config PATH NOT FOUND IN DDC2_CONFIG.ps1'
	$DCS_mode					= '$DCS_Config PATH NOT FOUND IN DDC2_CONFIG.ps1'
	$DCS_bind_address 			= '$DCS_Config PATH NOT FOUND IN DDC2_CONFIG.ps1'
	$DCS_isPublic				= '$DCS_Config PATH NOT FOUND IN DDC2_CONFIG.ps1'
	$DCS_password 				= '$DCS_Config PATH NOT FOUND IN DDC2_CONFIG.ps1'
	$DCS_uri 					= '$DCS_Config PATH NOT FOUND IN DDC2_CONFIG.ps1'
	$DCS_name 					= '$DCS_Config PATH NOT FOUND IN DDC2_CONFIG.ps1'
	$DCS_listShuffle			= '$DCS_Config PATH NOT FOUND IN DDC2_CONFIG.ps1'
	$DCS_listLoop				= '$DCS_Config PATH NOT FOUND IN DDC2_CONFIG.ps1'
	$DCS_require_pure_clients	= '$DCS_Config PATH NOT FOUND IN DDC2_CONFIG.ps1'
	$DCS_require_pure_models	= '$DCS_Config PATH NOT FOUND IN DDC2_CONFIG.ps1'
	$DCS_maxPlayers				= '$DCS_Config PATH NOT FOUND IN DDC2_CONFIG.ps1'
	}
$DCS_Settings | Add-Member -MemberType NoteProperty -Name Installed -Value $DCS_INSTALLED
$DCS_Settings | Add-Member -MemberType NoteProperty -Name Version -Value $DCS_Version
$DCS_Settings | Add-Member -MemberType NoteProperty -Name EXE -Value $dcsEXE
$DCS_Settings | Add-Member -MemberType NoteProperty -Name InstallDIR -Value $dcsDIR
$DCS_Settings | Add-Member -MemberType NoteProperty -Name ProfileDIR -Value $DCS_Profile
$DCS_Settings | Add-Member -MemberType NoteProperty -Name Config -Value $DCS_Config
$DCS_Settings | Add-Member -MemberType NoteProperty -Name require_pure_textures -Value $DCS_require_pure_textures 	
$DCS_Settings | Add-Member -MemberType NoteProperty -Name allow_change_tailno -Value $DCS_allow_change_tailno 	
$DCS_Settings | Add-Member -MemberType NoteProperty -Name disable_events -Value $DCS_disable_events
$DCS_Settings | Add-Member -MemberType NoteProperty -Name ownship_export -Value $DCS_allow_ownship_export
$DCS_Settings | Add-Member -MemberType NoteProperty -Name object_export -Value $DCS_allow_object_export
$DCS_Settings | Add-Member -MemberType NoteProperty -Name pause_on_load -Value $DCS_pause_on_load
$DCS_Settings | Add-Member -MemberType NoteProperty -Name allow_sensor_export -Value $DCS_allow_sensor_export
$DCS_Settings | Add-Member -MemberType NoteProperty -Name event_Takeoff -Value $DCS_event_Takeoff
$DCS_Settings | Add-Member -MemberType NoteProperty -Name pause_without_clients -Value $DCS_pause_without_clients
$DCS_Settings | Add-Member -MemberType NoteProperty -Name client_outbound_limit -Value $DCS_client_outbound_limit
$DCS_Settings | Add-Member -MemberType NoteProperty -Name client_inbound_limit -Value $DCS_client_inbound_limit
$DCS_Settings | Add-Member -MemberType NoteProperty -Name server_can_screenshot -Value $DCS_server_can_screenshot
$DCS_Settings | Add-Member -MemberType NoteProperty -Name voice_chat_server -Value $DCS_voice_chat_server
$DCS_Settings | Add-Member -MemberType NoteProperty -Name allow_change_skin -Value $DCS_allow_change_skin
$DCS_Settings | Add-Member -MemberType NoteProperty -Name event_Connect -Value $DCS_event_Connect
$DCS_Settings | Add-Member -MemberType NoteProperty -Name event_Ejecting -Value $DCS_event_Ejecting
$DCS_Settings | Add-Member -MemberType NoteProperty -Name event_Kill -Value $DCS_event_Kill
$DCS_Settings | Add-Member -MemberType NoteProperty -Name event_Crash -Value $DCS_event_Crash
$DCS_Settings | Add-Member -MemberType NoteProperty -Name resume_mode -Value $DCS_resume_mode
$DCS_Settings | Add-Member -MemberType NoteProperty -Name event_Role -Value $DCS_event_Role
$DCS_Settings | Add-Member -MemberType NoteProperty -Name maxPing -Value $DCS_maxPing
$DCS_Settings | Add-Member -MemberType NoteProperty -Name Port -Value $DCS_port
$DCS_Settings | Add-Member -MemberType NoteProperty -Name webui_port -Value $DCS_webgui_port
$DCS_Settings | Add-Member -MemberType NoteProperty -Name use_upnp -Value $DCS_use_upnp
$DCS_Settings | Add-Member -MemberType NoteProperty -Name mode -Value $DCS_mode
$DCS_Settings | Add-Member -MemberType NoteProperty -Name bind_address -Value $DCS_bind_address
$DCS_Settings | Add-Member -MemberType NoteProperty -Name isPublic -Value $DCS_isPublic
$DCS_Settings | Add-Member -MemberType NoteProperty -Name password -Value $DCS_password
$DCS_Settings | Add-Member -MemberType NoteProperty -Name uri -Value $DCS_uri
$DCS_Settings | Add-Member -MemberType NoteProperty -Name name -Value $DCS_name
$DCS_Settings | Add-Member -MemberType NoteProperty -Name listShuffle -Value $DCS_listShuffle
$DCS_Settings | Add-Member -MemberType NoteProperty -Name listLoop -Value $DCS_listLoop
$DCS_Settings | Add-Member -MemberType NoteProperty -Name require_pure_clients -Value $DCS_require_pure_clients
$DCS_Settings | Add-Member -MemberType NoteProperty -Name require_pure_models -Value $DCS_require_pure_models
$DCS_Settings | Add-Member -MemberType NoteProperty -Name maxPlayers -Value $DCS_maxPlayers

$SRV_config | Add-Member -MemberType NoteProperty -Name DCS -Value $DCS_Settings
########################################################################################################################
##LotATC
$LotATC_Settings = $null
$LotATC_Settings = New-Object -TypeName psobject

if(test-path $Lot_Entry) {
	$LotATC_Version = (Select-String -Path $Lot_Entry -Pattern "version" | Out-String).Split('"')[-2]
	$LotATC_INSTALLED = $true
} else {
	$LotATC_Version = 'NOT INSTALLED'
	$LotATC_INSTALLED = $false
	}
if(test-path $Lot_Config) {
	$LotATC_port 					= ((Select-String -Path $Lot_Config -Pattern " port =" | Out-String).Split(' ')[-1] | Out-String).Split(',')[0]
	$LotATC_blue_password		 	= (Select-String -Path $Lot_Config -Pattern "blue_password = " | Out-String).Split('"')[-2]
	$LotATC_red_password 			= (Select-String -Path $Lot_Config -Pattern "red_password = " | Out-String).Split('"')[-2]
	$LotATC_virtual_awacs_name 		= (Select-String -Path $Lot_Config -Pattern "virtual_awacs_name = " | Out-String).Split('"')[-2]
	$LotATC_ignore_radar_name 		= (Select-String -Path $Lot_Config -Pattern "ignore_radar_name = " | Out-String).Split('"')[-2]
	$LotATC_dedicated_mode 			= ((Select-String -Path $Lot_Config -Pattern " dedicated_mode =" | Out-String).Split(' ')[-1] | Out-String).Split(',')[0]
	$LotATC_srs_transponder_port 	= ((Select-String -Path $Lot_Config -Pattern " srs_transponder_port =" | Out-String).Split(' ')[-1] | Out-String).Split(',')[0]
	$LotATC_jsonserver_port 		= ((Select-String -Path $Lot_Config -Pattern " jsonserver_port =" | Out-String).Split(' ')[-1] | Out-String).Split(',')[0]
	$LotATC_update_time 			= ((Select-String -Path $Lot_Config -Pattern " update_time =" | Out-String).Split(' ')[-1] | Out-String).Split(',')[0]
	$LotATC_update_search_for_new 	= ((Select-String -Path $Lot_Config -Pattern " update_search_for_new =" | Out-String).Split(' ')[-1] | Out-String).Split(',')[0]
	$LotATC_minimum_frame_update 	= ((Select-String -Path $Lot_Config -Pattern " minimum_frame_update =" | Out-String).Split(' ')[-1] | Out-String).Split(',')[0]
} else {
	$LotATC_port 					= '$Lot_Config PATH NOT FOUND IN DDC2_CONFIG.ps1'
	$LotATC_blue_password		 	= '$Lot_Config PATH NOT FOUND IN DDC2_CONFIG.ps1'
	$LotATC_red_password 			= '$Lot_Config PATH NOT FOUND IN DDC2_CONFIG.ps1'
	$LotATC_virtual_awacs_name 		= '$Lot_Config PATH NOT FOUND IN DDC2_CONFIG.ps1'
	$LotATC_ignore_radar_name 		= '$Lot_Config PATH NOT FOUND IN DDC2_CONFIG.ps1'
	$LotATC_dedicated_mode 			= '$Lot_Config PATH NOT FOUND IN DDC2_CONFIG.ps1'
	$LotATC_srs_transponder_port 	= '$Lot_Config PATH NOT FOUND IN DDC2_CONFIG.ps1'
	$LotATC_jsonserver_port 		= '$Lot_Config PATH NOT FOUND IN DDC2_CONFIG.ps1'
	$LotATC_update_time 			= '$Lot_Config PATH NOT FOUND IN DDC2_CONFIG.ps1'
	$LotATC_update_search_for_new 	= '$Lot_Config PATH NOT FOUND IN DDC2_CONFIG.ps1'
	$LotATC_minimum_frame_update 	= '$Lot_Config PATH NOT FOUND IN DDC2_CONFIG.ps1'
	}
	
$LotATC_Settings | Add-Member -MemberType NoteProperty -Name Installed -Value $LotATC_INSTALLED
$LotATC_Settings | Add-Member -MemberType NoteProperty -Name Version -Value $LotATC_Version
$LotATC_Settings | Add-Member -MemberType NoteProperty -Name Config -Value $Lot_Config
$LotATC_Settings | Add-Member -MemberType NoteProperty -Name InstallDIR -Value $LotDIR
$LotATC_Settings | Add-Member -MemberType NoteProperty -Name Port -Value $LotATC_port
$LotATC_Settings | Add-Member -MemberType NoteProperty -Name blue_password -Value $LotATC_blue_password
$LotATC_Settings | Add-Member -MemberType NoteProperty -Name red_password -Value $LotATC_red_password
$LotATC_Settings | Add-Member -MemberType NoteProperty -Name virtual_awacs_name -Value $LotATC_virtual_awacs_name
$LotATC_Settings | Add-Member -MemberType NoteProperty -Name ignore_radar_name -Value $LotATC_ignore_radar_name
$LotATC_Settings | Add-Member -MemberType NoteProperty -Name dedicated_mode -Value $LotATC_dedicated_mode
$LotATC_Settings | Add-Member -MemberType NoteProperty -Name srs_transponder_port -Value $LotATC_srs_transponder_port
$LotATC_Settings | Add-Member -MemberType NoteProperty -Name jsonserver_port -Value $LotATC_jsonserver_port
$LotATC_Settings | Add-Member -MemberType NoteProperty -Name update_time -Value $LotATC_update_time
$LotATC_Settings | Add-Member -MemberType NoteProperty -Name update_search_for_new -Value $LotATC_update_search_for_new
$LotATC_Settings | Add-Member -MemberType NoteProperty -Name minimum_frame_update -Value $LotATC_minimum_frame_update

$SRV_config | Add-Member -MemberType NoteProperty -Name LotATC -Value $LotATC_Settings
########################################################################################################################
##TacView
$TACv_Settings = $null
$TACv_Settings = New-Object -TypeName psobject	

if(test-path $TacvEXE) {
	$TACv_Version = (Get-ChildItem $TacvEXE).VersionInfo.ProductVersion
	$TACv_INSTALLED = $true
} else {
	$TACv_Version = 'NOT INSTALLED'
	$TACv_INSTALLED = $false
	}

if(test-path $TACv_Config) {
	$TACv_tacviewClientTelemetryPassword 		= (Select-String -Path $TACv_Config -Pattern "tacviewClientTelemetryPassword" | Out-String).Split('"')[-2]
	$TACv_tacviewCompressionLevel				= (Select-String -Path $TACv_Config -Pattern "tacviewCompressionLevel" | Out-String).replace(',',' ').Split(' ')[-2]
	$TACv_tacviewDataRecordingEnabled			= (Select-String -Path $TACv_Config -Pattern "tacviewDataRecordingEnabled" | Out-String).replace(',',' ').Split(' ')[-2]
	$TACv_tacviewDebugModeEnabled				= (Select-String -Path $TACv_Config -Pattern "tacviewDebugModeEnabled" | Out-String).replace(',',' ').Split(' ')[-2]
	$TACv_tacviewHostTelemetryPassword 			= (Select-String -Path $TACv_Config -Pattern "tacviewHostTelemetryPassword" | Out-String).Split('"')[-2]
	$TACv_tacviewPlaybackDelay					= (Select-String -Path $TACv_Config -Pattern "tacviewPlaybackDelay" | Out-String).replace(',',' ').Split(' ')[-2]
	$TACv_tacviewProfilingPeriod				= (Select-String -Path $TACv_Config -Pattern "tacviewProfilingPeriod" | Out-String).replace(',',' ').Split(' ')[-2]
	$TACv_tacviewRealTimeTelemetryPort 			= (Select-String -Path $TACv_Config -Pattern "tacviewRealTimeTelemetryPort" | Out-String).Split('"')[-2]
	$TACv_tacviewRecordClientsSessionsEnabled	= (Select-String -Path $TACv_Config -Pattern "tacviewRecordClientsSessionsEnabled" | Out-String).replace(',',' ').Split(' ')[-2]
	$TACv_tacviewRemoteControlPassword 			= (Select-String -Path $TACv_Config -Pattern "tacviewRemoteControlPassword" | Out-String).Split('"')[-2]
	$TACv_tacviewRemoteControlPort 				= (Select-String -Path $TACv_Config -Pattern "tacviewRemoteControlPort" | Out-String).Split('"')[-2]
	$TACv_tacviewTerrainExport					= (Select-String -Path $TACv_Config -Pattern "tacviewTerrainExport" | Out-String).replace(',',' ').Split(' ')[-2]
} else {
	$TACv_tacviewClientTelemetryPassword 		= '$TACv_Config PATH NOT FOUND IN DDC2_CONFIG.ps1'
	$TACv_tacviewCompressionLevel				= '$TACv_Config PATH NOT FOUND IN DDC2_CONFIG.ps1'
	$TACv_tacviewDataRecordingEnabled			= '$TACv_Config PATH NOT FOUND IN DDC2_CONFIG.ps1'
	$TACv_tacviewDebugModeEnabled				= '$TACv_Config PATH NOT FOUND IN DDC2_CONFIG.ps1'
	$TACv_tacviewHostTelemetryPassword 			= '$TACv_Config PATH NOT FOUND IN DDC2_CONFIG.ps1'
	$TACv_tacviewPlaybackDelay					= '$TACv_Config PATH NOT FOUND IN DDC2_CONFIG.ps1'
	$TACv_tacviewProfilingPeriod				= '$TACv_Config PATH NOT FOUND IN DDC2_CONFIG.ps1'
	$TACv_tacviewRealTimeTelemetryPort 			= '$TACv_Config PATH NOT FOUND IN DDC2_CONFIG.ps1'
	$TACv_tacviewRecordClientsSessionsEnabled	= '$TACv_Config PATH NOT FOUND IN DDC2_CONFIG.ps1'
	$TACv_tacviewRemoteControlPassword 			= '$TACv_Config PATH NOT FOUND IN DDC2_CONFIG.ps1'
	$TACv_tacviewRemoteControlPort 				= '$TACv_Config PATH NOT FOUND IN DDC2_CONFIG.ps1'
	$TACv_tacviewTerrainExport					= '$TACv_Config PATH NOT FOUND IN DDC2_CONFIG.ps1'
	}
$TACv_Settings | Add-Member -MemberType NoteProperty -Name Installed -Value $TACv_INSTALLED
$TACv_Settings | Add-Member -MemberType NoteProperty -Name Version -Value $TACv_Version
$TACv_Settings | Add-Member -MemberType NoteProperty -Name EXE -Value $TacvEXE
$TACv_Settings | Add-Member -MemberType NoteProperty -Name InstallDIR -Value $TacvDIR
$TACv_Settings | Add-Member -MemberType NoteProperty -Name ConfigFile -Value $TACv_Config
$TACv_Settings | Add-Member -MemberType NoteProperty -Name tacviewClientTelemetryPassword -Value $TACv_tacviewClientTelemetryPassword
$TACv_Settings | Add-Member -MemberType NoteProperty -Name tacviewCompressionLevel -Value $TACv_tacviewCompressionLevel
$TACv_Settings | Add-Member -MemberType NoteProperty -Name tacviewDataRecordingEnabled -Value $TACv_tacviewDataRecordingEnabled
$TACv_Settings | Add-Member -MemberType NoteProperty -Name tacviewDebugModeEnabled -Value $TACv_tacviewDebugModeEnabled
$TACv_Settings | Add-Member -MemberType NoteProperty -Name tacviewHostTelemetryPassword -Value $TACv_tacviewHostTelemetryPassword
$TACv_Settings | Add-Member -MemberType NoteProperty -Name tacviewPlaybackDelay -Value $TACv_tacviewPlaybackDelay
$TACv_Settings | Add-Member -MemberType NoteProperty -Name tacviewProfilingPeriod -Value $TACv_tacviewProfilingPeriod
$TACv_Settings | Add-Member -MemberType NoteProperty -Name tacviewRealTimeTelemetryPort -Value $TACv_tacviewRealTimeTelemetryPort
$TACv_Settings | Add-Member -MemberType NoteProperty -Name tacviewRecordClientsSessionsEnabled -Value $TACv_tacviewRecordClientsSessionsEnabled
$TACv_Settings | Add-Member -MemberType NoteProperty -Name tacviewRemoteControlPassword -Value $TACv_tacviewRemoteControlPassword
$TACv_Settings | Add-Member -MemberType NoteProperty -Name tacviewRemoteControlPort -Value $TACv_tacviewRemoteControlPort
$TACv_Settings | Add-Member -MemberType NoteProperty -Name tacviewTerrainExport -Value $TACv_tacviewTerrainExport

$SRV_config | Add-Member -MemberType NoteProperty -Name Tacview -Value $TACv_Settings
########################################################################################################################
##SRS
$SRS_Settings = $null
$SRS_Settings = New-Object -TypeName psobject	
if(test-path $srsEXE) {
	$SRS_Version = (Get-ChildItem $srsEXE).VersionInfo.ProductVersion
	$SRS_INSTALLED = $true
} else {
	$SRS_Version = 'NOT INSTALLED'
	$SRS_INSTALLED = $false
	}

if(test-path $SRS_AutoConnect) {
	$SRS_SERVER_SRS_HOST_AUTO 		= ((Select-String -Path $SRS_AutoConnect -Pattern "SRSAuto.SERVER_SRS_HOST_AUTO =" | Out-String).Split(' '))[3]
	$SRS_SERVER_SRS_PORT 			= (Select-String -Path $SRS_AutoConnect -Pattern "SRSAuto.SERVER_SRS_PORT =" | Out-String).Split('"')[-2]
	$SRS_SERVER_SRS_HOST	 		= (Select-String -Path $SRS_AutoConnect -Pattern "SRSAuto.SERVER_SRS_HOST =" | Out-String).Split('"')[-2]
	$SRS_SERVER_SEND_AUTO_CONNECT	= ((Select-String -Path $SRS_AutoConnect -Pattern "SRSAuto.SERVER_SEND_AUTO_CONNECT =" | Out-String).Split(' '))[3]
	$SRS_CHAT_COMMANDS_ENABLED 		= ((Select-String -Path $SRS_AutoConnect -Pattern "SRSAuto.CHAT_COMMANDS_ENABLED =" | Out-String).Split(' '))[3]
	$SRS_SRS_NUDGE_ENABLED 			= ((Select-String -Path $SRS_AutoConnect -Pattern "SRSAuto.SRS_NUDGE_ENABLED =" | Out-String).Split(' '))[3]
	$SRS_SRS_NUDGE_TIME 			= ((Select-String -Path $SRS_AutoConnect -Pattern "SRSAuto.SRS_NUDGE_TIME =" | Out-String).Split(' '))[3]
	$SRS_SRS_MESSAGE_TIME 			= ((Select-String -Path $SRS_AutoConnect -Pattern "SRSAuto.SRS_MESSAGE_TIME =" | Out-String).Split(' '))[3]
	$SRS_SRS_NUDGE_PATH 			= (Select-String -Path $SRS_AutoConnect -Pattern "SRSAuto.SRS_NUDGE_PATH =" | Out-String).Split('"')[-2]
} else {
	$SRS_SERVER_SRS_HOST_AUTO 		= '$SRS_Config PATH NOT FOUND IN DDC2_CONFIG.ps1'
	$SRS_SERVER_SRS_PORT	 		= '$SRS_Config PATH NOT FOUND IN DDC2_CONFIG.ps1'
	$SRS_SERVER_SRS_HOST	 		= '$SRS_Config PATH NOT FOUND IN DDC2_CONFIG.ps1'
	$SRS_SERVER_SEND_AUTO_CONNECT	= '$SRS_Config PATH NOT FOUND IN DDC2_CONFIG.ps1'
	$SRS_CHAT_COMMANDS_ENABLED 		= '$SRS_Config PATH NOT FOUND IN DDC2_CONFIG.ps1'
	$SRS_SRS_NUDGE_ENABLED 			= '$SRS_Config PATH NOT FOUND IN DDC2_CONFIG.ps1'
	$SRS_SRS_NUDGE_TIME 			= '$SRS_Config PATH NOT FOUND IN DDC2_CONFIG.ps1'
	$SRS_SRS_MESSAGE_TIME 			= '$SRS_Config PATH NOT FOUND IN DDC2_CONFIG.ps1'
	$SRS_SRS_NUDGE_PATH 			= '$SRS_Config PATH NOT FOUND IN DDC2_CONFIG.ps1'
	}

if(test-path $SRS_Config) {
	$SRS_CLIENT_EXPORT_ENABLED 				= ((Select-String -Path $SRS_Config -Pattern "CLIENT_EXPORT_ENABLED" | Out-String).Split('=')[1]).Trim()
	$SRS_LOTATC_EXPORT_ENABLED 				= ((Select-String -Path $SRS_Config -Pattern "LOTATC_EXPORT_ENABLED" | Out-String).Split('=')[1]).Trim()
	$SRS_TEST_FREQUENCIES 					= ((Select-String -Path $SRS_Config -Pattern "TEST_FREQUENCIES" | Out-String).Split('=')[1]).Trim()
	$SRS_GLOBAL_LOBBY_FREQUENCIES			= ((Select-String -Path $SRS_Config -Pattern "GLOBAL_LOBBY_FREQUENCIES" | Out-String).Split('=')[1]).Trim()
	$SRS_EXTERNAL_AWACS_MODE 				= (((Select-String -Path $SRS_Config -Pattern "EXTERNAL_AWACS_MODE")[0] | Out-String).Split('=')[1]).Trim()
	$SRS_COALITION_AUDIO_SECURITY			= ((Select-String -Path $SRS_Config -Pattern "COALITION_AUDIO_SECURITY" | Out-String).Split('=')[1]).Trim()
	$SRS_SPECTATORS_AUDIO_DISABLED			= ((Select-String -Path $SRS_Config -Pattern "SPECTATORS_AUDIO_DISABLED" | Out-String).Split('=')[1]).Trim()
	$SRS_LOS_ENABLED						= ((Select-String -Path $SRS_Config -Pattern "LOS_ENABLED" | Out-String).Split('=')[1]).Trim()
	$SRS_DISTANCE_ENABLED					= ((Select-String -Path $SRS_Config -Pattern "DISTANCE_ENABLED" | Out-String).Split('=')[1]).Trim()
	$SRS_IRL_RADIO_TX						= ((Select-String -Path $SRS_Config -Pattern "IRL_RADIO_TX" | Out-String).Split('=')[1]).Trim()
	$SRS_IRL_RADIO_RX_INTERFERENCE			= ((Select-String -Path $SRS_Config -Pattern "IRL_RADIO_RX_INTERFERENCE" | Out-String).Split('=')[1]).Trim()
	$SRS_RADIO_EXPANSION					= ((Select-String -Path $SRS_Config -Pattern "RADIO_EXPANSION" | Out-String).Split('=')[1]).Trim()
	$SRS_ALLOW_RADIO_ENCRYPTION				= ((Select-String -Path $SRS_Config -Pattern "ALLOW_RADIO_ENCRYPTION" | Out-String).Split('=')[1]).Trim()
	$SRS_SHOW_TUNED_COUNT					= ((Select-String -Path $SRS_Config -Pattern "SHOW_TUNED_COUNT" | Out-String).Split('=')[1]).Trim()
	$SRS_SHOW_TRANSMITTER_NAME				= ((Select-String -Path $SRS_Config -Pattern "SHOW_TRANSMITTER_NAME" | Out-String).Split('=')[1]).Trim()
	$SRS_RETRANSMISSION_NODE_LIMIT			= ((Select-String -Path $SRS_Config -Pattern "RETRANSMISSION_NODE_LIMIT" | Out-String).Split('=')[1]).Trim()
	$SRS_LOTATC_EXPORT_IP					= ((Select-String -Path $SRS_Config -Pattern "LOTATC_EXPORT_IP" | Out-String).Split('=')[1]).Trim()
	$SRS_LOTATC_EXPORT_PORT					= ((Select-String -Path $SRS_Config -Pattern "LOTATC_EXPORT_PORT" | Out-String).Split('=')[1]).Trim()
	$SRS_CLIENT_EXPORT_FILE_PATH 			= ((Select-String -Path $SRS_Config -Pattern "CLIENT_EXPORT_FILE_PATH" | Out-String).Split('=')[1]).Trim()
	$SRS_SERVER_PORT 						= ((Select-String -Path $SRS_Config -Pattern "SERVER_PORT" | Out-String).Split('=')[1]).Trim()
	$SRS_UPNP_ENABLED 						= ((Select-String -Path $SRS_Config -Pattern "UPNP_ENABLED" | Out-String).Split('=')[1]).Trim()
	$SRS_CHECK_FOR_BETA_UPDATES				= ((Select-String -Path $SRS_Config -Pattern "CHECK_FOR_BETA_UPDATES" | Out-String).Split('=')[1]).Trim()
	$SRS_EXTERNAL_AWACS_MODE_BLUE_PASSWORD 	= ((Select-String -Path $SRS_Config -Pattern "EXTERNAL_AWACS_MODE_BLUE_PASSWORD" | Out-String).Split('=')[1]).Trim()
	$SRS_EXTERNAL_AWACS_MODE_RED_PASSWORD 	= ((Select-String -Path $SRS_Config -Pattern "EXTERNAL_AWACS_MODE_RED_PASSWORD" | Out-String).Split('=')[1]).Trim()
} else {
	$SRS_CLIENT_EXPORT_ENABLED 				= '$SRS_Config PATH NOT FOUND IN DDC2_CONFIG.ps1'
	$SRS_LOTATC_EXPORT_ENABLED 				= '$SRS_Config PATH NOT FOUND IN DDC2_CONFIG.ps1'
	$SRS_TEST_FREQUENCIES					= '$SRS_Config PATH NOT FOUND IN DDC2_CONFIG.ps1'
	$SRS_GLOBAL_LOBBY_FREQUENCIES			= '$SRS_Config PATH NOT FOUND IN DDC2_CONFIG.ps1'
	$SRS_EXTERNAL_AWACS_MODE 				= '$SRS_Config PATH NOT FOUND IN DDC2_CONFIG.ps1'
	$SRS_COALITION_AUDIO_SECURITY			= '$SRS_Config PATH NOT FOUND IN DDC2_CONFIG.ps1'
	$SRS_SPECTATORS_AUDIO_DISABLED			= '$SRS_Config PATH NOT FOUND IN DDC2_CONFIG.ps1'
	$SRS_LOS_ENABLED						= '$SRS_Config PATH NOT FOUND IN DDC2_CONFIG.ps1'
	$SRS_DISTANCE_ENABLED					= '$SRS_Config PATH NOT FOUND IN DDC2_CONFIG.ps1'
	$SRS_IRL_RADIO_TX						= '$SRS_Config PATH NOT FOUND IN DDC2_CONFIG.ps1'
	$SRS_IRL_RADIO_RX_INTERFERENCE			= '$SRS_Config PATH NOT FOUND IN DDC2_CONFIG.ps1'
	$SRS_RADIO_EXPANSION					= '$SRS_Config PATH NOT FOUND IN DDC2_CONFIG.ps1'
	$SRS_ALLOW_RADIO_ENCRYPTION				= '$SRS_Config PATH NOT FOUND IN DDC2_CONFIG.ps1'
	$SRS_SHOW_TUNED_COUNT					= '$SRS_Config PATH NOT FOUND IN DDC2_CONFIG.ps1'
	$SRS_SHOW_TRANSMITTER_NAME				= '$SRS_Config PATH NOT FOUND IN DDC2_CONFIG.ps1'
	$SRS_RETRANSMISSION_NODE_LIMIT			= '$SRS_Config PATH NOT FOUND IN DDC2_CONFIG.ps1'
	$SRS_LOTATC_EXPORT_IP					= '$SRS_Config PATH NOT FOUND IN DDC2_CONFIG.ps1'
	$SRS_LOTATC_EXPORT_PORT					= '$SRS_Config PATH NOT FOUND IN DDC2_CONFIG.ps1'
	$SRS_CLIENT_EXPORT_FILE_PATH 			= '$SRS_Config PATH NOT FOUND IN DDC2_CONFIG.ps1'
	$SRS_SERVER_PORT 						= '$SRS_Config PATH NOT FOUND IN DDC2_CONFIG.ps1'
	$SRS_UPNP_ENABLED 						= '$SRS_Config PATH NOT FOUND IN DDC2_CONFIG.ps1'
	$SRS_CHECK_FOR_BETA_UPDATES				= '$SRS_Config PATH NOT FOUND IN DDC2_CONFIG.ps1'
	$SRS_EXTERNAL_AWACS_MODE_BLUE_PASSWORD	= '$SRS_Config PATH NOT FOUND IN DDC2_CONFIG.ps1'
	$SRS_EXTERNAL_AWACS_MODE_RED_PASSWORD 	= '$SRS_Config PATH NOT FOUND IN DDC2_CONFIG.ps1'
	}
	
$SRS_Settings | Add-Member -MemberType NoteProperty -Name Installed -Value $SRS_INSTALLED
$SRS_Settings | Add-Member -MemberType NoteProperty -Name Version -Value $SRS_Version
$SRS_Settings | Add-Member -MemberType NoteProperty -Name EXE -Value $srsEXE
$SRS_Settings | Add-Member -MemberType NoteProperty -Name InstallDIR -Value $srsDIR
$SRS_Settings | Add-Member -MemberType NoteProperty -Name Config -Value $SRS_Config
$SRS_Settings | Add-Member -MemberType NoteProperty -Name Port -Value $SRS_SERVER_PORT
$SRS_Settings | Add-Member -MemberType NoteProperty -Name CLIENT_EXPORT_ENABLED -Value $SRS_CLIENT_EXPORT_ENABLED
$SRS_Settings | Add-Member -MemberType NoteProperty -Name LOTATC_EXPORT_ENABLED -Value $SRS_LOTATC_EXPORT_ENABLED
$SRS_Settings | Add-Member -MemberType NoteProperty -Name TEST_FREQUENCIES -Value $SRS_TEST_FREQUENCIES
$SRS_Settings | Add-Member -MemberType NoteProperty -Name GLOBAL_LOBBY_FREQUENCIES -Value $SRS_GLOBAL_LOBBY_FREQUENCIES
$SRS_Settings | Add-Member -MemberType NoteProperty -Name EXTERNAL_AWACS_MODE -Value $SRS_EXTERNAL_AWACS_MODE
$SRS_Settings | Add-Member -MemberType NoteProperty -Name COALITION_AUDIO_SECURITY -Value $SRS_COALITION_AUDIO_SECURITY
$SRS_Settings | Add-Member -MemberType NoteProperty -Name SPECTATORS_AUDIO_DISABLED -Value $SRS_SPECTATORS_AUDIO_DISABLED
$SRS_Settings | Add-Member -MemberType NoteProperty -Name LOS_ENABLED -Value $SRS_LOS_ENABLED
$SRS_Settings | Add-Member -MemberType NoteProperty -Name DISTANCE_ENABLED -Value $SRS_DISTANCE_ENABLED
$SRS_Settings | Add-Member -MemberType NoteProperty -Name IRL_RADIO_TX -Value $SRS_IRL_RADIO_TX
$SRS_Settings | Add-Member -MemberType NoteProperty -Name IRL_RADIO_RX_INTERFERENCE -Value $SRS_IRL_RADIO_RX_INTERFERENCE
$SRS_Settings | Add-Member -MemberType NoteProperty -Name RADIO_EXPANSION -Value $SRS_RADIO_EXPANSION
$SRS_Settings | Add-Member -MemberType NoteProperty -Name ALLOW_RADIO_ENCRYPTION -Value $SRS_ALLOW_RADIO_ENCRYPTION
$SRS_Settings | Add-Member -MemberType NoteProperty -Name SHOW_TUNED_COUNT -Value $SRS_SHOW_TUNED_COUNT
$SRS_Settings | Add-Member -MemberType NoteProperty -Name SHOW_TRANSMITTER_NAME -Value $SRS_SHOW_TRANSMITTER_NAME
$SRS_Settings | Add-Member -MemberType NoteProperty -Name RETRANSMISSION_NODE_LIMIT -Value $SRS_RETRANSMISSION_NODE_LIMIT
$SRS_Settings | Add-Member -MemberType NoteProperty -Name LOTATC_EXPORT_IP -Value $SRS_LOTATC_EXPORT_IP
$SRS_Settings | Add-Member -MemberType NoteProperty -Name LOTATC_EXPORT_PORT -Value $SRS_LOTATC_EXPORT_PORT
$SRS_Settings | Add-Member -MemberType NoteProperty -Name CLIENT_EXPORT_FILE_PATH -Value $SRS_CLIENT_EXPORT_FILE_PATH
$SRS_Settings | Add-Member -MemberType NoteProperty -Name SERVER_PORT -Value $SRS_SERVER_PORT
$SRS_Settings | Add-Member -MemberType NoteProperty -Name UPNP_ENABLED -Value $SRS_UPNP_ENABLED
$SRS_Settings | Add-Member -MemberType NoteProperty -Name CHECK_FOR_BETA_UPDATES -Value $SRS_CHECK_FOR_BETA_UPDATES
$SRS_Settings | Add-Member -MemberType NoteProperty -Name EXTERNAL_AWACS_MODE_BLUE_PASSWORD -Value $SRS_EXTERNAL_AWACS_MODE_BLUE_PASSWORD
$SRS_Settings | Add-Member -MemberType NoteProperty -Name EXTERNAL_AWACS_MODE_RED_PASSWORD -Value $SRS_EXTERNAL_AWACS_MODE_RED_PASSWORD
$SRS_Settings | Add-Member -MemberType NoteProperty -Name SERVER_SRS_HOST_AUTO -Value $SRS_SERVER_SRS_HOST_AUTO
$SRS_Settings | Add-Member -MemberType NoteProperty -Name SERVER_SRS_PORT -Value $SRS_SERVER_SRS_PORT
$SRS_Settings | Add-Member -MemberType NoteProperty -Name SERVER_SRS_HOST -Value $SRS_SERVER_SRS_HOST
$SRS_Settings | Add-Member -MemberType NoteProperty -Name SERVER_SEND_AUTO_CONNECT -Value $SRS_SERVER_SEND_AUTO_CONNECT
$SRS_Settings | Add-Member -MemberType NoteProperty -Name CHAT_COMMANDS_ENABLED -Value $SRS_CHAT_COMMANDS_ENABLED
$SRS_Settings | Add-Member -MemberType NoteProperty -Name SRS_NUDGE_ENABLED -Value $SRS_SRS_NUDGE_ENABLED
$SRS_Settings | Add-Member -MemberType NoteProperty -Name SRS_NUDGE_TIME -Value $SRS_SRS_NUDGE_TIME
$SRS_Settings | Add-Member -MemberType NoteProperty -Name SRS_MESSAGE_TIME -Value $SRS_SRS_MESSAGE_TIME
$SRS_Settings | Add-Member -MemberType NoteProperty -Name SRS_NUDGE_PATH -Value $SRS_SRS_NUDGE_PATH
$SRS_Settings | Add-Member -MemberType NoteProperty -Name DDC2_FREQ -Value $SRS_GLOBAL_LOBBY_FREQUENCIES
$SRS_Settings | Add-Member -MemberType NoteProperty -Name DDC2_HIGH -Value $SRS_FreqHIGH
$SRS_Settings | Add-Member -MemberType NoteProperty -Name DDC2_LOW -Value $SRS_FreqLOW
$SRS_Settings | Add-Member -MemberType NoteProperty -Name DDC2_MOD -Value $SRS_DefaultMOD
$SRS_Settings | Add-Member -MemberType NoteProperty -Name DDC2_COAL -Value $SRS_DefaultCoal
$SRS_Settings | Add-Member -MemberType NoteProperty -Name DDC2_VOL -Value $SRS_DefaultVOL

$SRV_config | Add-Member -MemberType NoteProperty -Name SRS -Value $SRS_Settings
########################################################################################################################

##SET OUTPUT VARIABLE
$get_config = $null
$get_config = New-Object -TypeName psobject 
#$ServerInfo = Get-ServerInfo
#$get_config | Add-Member -MemberType NoteProperty -Name Info -Value $ServerInfo
#$get_config | Add-Member -MemberType NoteProperty -Name Config -Value $SRV_config
write-log -LogData "Get-Config: ENDED" -Silent
#return $get_config
return $SRV_config
}
Function Get-Processes {
$get_processes = $null
$get_processes = New-Object -TypeName psobject
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
<#

#>
write-log -LogData "Get-Status: STARTED" -Silent
#Prepare Variable Output
$properties=@(
    @{Name="Name"; Expression = {$_.Name}},
	@{Name="ProcessID"; Expression = {$_.IDProcess}},
    @{Name="CPU"; Expression = {$_.PercentProcessorTime / ($Processor.NumberOfLogicalProcessors)}},    
    @{Name="Memory (GB)"; Expression = {[Math]::Round(($_.PrivateBytes / 1gb),2)}},
	@{Name="Threads"; Expression = {$_.ThreadCount}},
	@{Name="Handles"; Expression = {$_.HandleCount}}
)
$Updating = $false

#START SYSTEM DATA COLLECTION
$system = Get-CimInstance -Class Win32_OperatingSystem
$Processor = Get-CimInstance -ClassName Win32_Processor
#Get Memory Information
$TotalMemGB = [math]::Round((($system).TotalVisibleMemorySize / 1048576),0)
$FreeMemGB = [math]::Round((($system).FreePhysicalMemory / 1048576),2)
$UsedMemGB = [math]::Round(($TotalMemGB - $FreeMemGB),2)
$UsedMemPC = [math]::Round((($UsedMemGB / $TotalMemGB)*100),2)
$serverUpTime = (get-date) - $system.LastBootUpTime
$ServerStatus = $null
$ServerStatus = New-Object -TypeName psobject 
$ServerStatus | Add-Member -MemberType NoteProperty -Name ProcessorLoad -Value ($Processor.LoadPercentage)
$ServerStatus | Add-Member -MemberType NoteProperty -Name TotalMemGB -Value $TotalMemGB
$ServerStatus | Add-Member -MemberType NoteProperty -Name FreeMemGB -Value $FreeMemGB
$ServerStatus | Add-Member -MemberType NoteProperty -Name UsedMemGB -Value $UsedMemGB
$ServerStatus | Add-Member -MemberType NoteProperty -Name UsedMemPC -Value $UsedMemPC
$ServerStatus | Add-Member -MemberType NoteProperty -Name UpTime -Value $serverUpTime
$ServerStatus | Add-Member -MemberType NoteProperty -Name LastBootUpTime -Value ($system.LastBootUpTime)
$ServerStatus | Add-Member -MemberType NoteProperty -Name LastBootUpString -Value (($system.LastBootUpTime).GetDateTimeFormats()[6])

#START DCS
$DCS = Get-Process -ErrorAction SilentlyContinue | where {$_.MainWindowTitle -eq $DCS_WindowTitle -and $_.Path -eq $dcsEXE} | select $ProcessSelection
if($DCS.count -eq 0) {
	$DCS = New-Object -TypeName psobject 
	$DCS | Add-Member -MemberType NoteProperty -Name Name -Value "DCS"
	$DCS | Add-Member -MemberType NoteProperty -Name IsActive -Value $false
	$DCS | Add-Member -MemberType NoteProperty -Name Offline -Value $true
} else {
	$DCS_Additional = Get-CimInstance -ClassName Win32_PerfFormattedData_PerfProc_Process | where {$_.IDProcess -eq ($DCS.Id)} | Select-Object $properties
	$DCS | Add-Member -MemberType NoteProperty -Name Name -Value "DCS"
	$DCS | Add-Member -MemberType NoteProperty -Name IsActive -Value $true
	$DCS | Add-Member -MemberType NoteProperty -Name Offline -Value $false
	if($DCS.Responding) {
		$DCS | Add-Member -MemberType NoteProperty -Name Status -Value "OK"
	} else {
		$DCS | Add-Member -MemberType NoteProperty -Name Status -Value "Not Responding"
	}
	$DCS | add-Member -MemberType NoteProperty -Name Ports -Value (StringOutPorts -Id $DCS.id)
	$DCS | Add-Member -MemberType NoteProperty -Name RunTime -Value ((get-date) - $DCS.StartTime)
	$DCS | Add-Member -MemberType NoteProperty -Name CPULoad -Value ($DCS_Additional.CPU)
	$DCS | Add-Member -MemberType NoteProperty -Name Threads -Value ($DCS_Additional.Threads)
	$DCS | Add-Member -MemberType NoteProperty -Name Handles -Value ($DCS_Additional.Handles)
	$DCS.StartTime = ((get-date $DCS.StartTime).DateTime)
	}
#START SRS	
$SRS = Get-Process -Name SR-Server -ErrorAction SilentlyContinue | where {$_.Path -eq $srsEXE}| Select-Object $ProcessSelection
if($SRS.count -eq 0) {
	$SRS = New-Object -TypeName psobject 
	$SRS | Add-Member -MemberType NoteProperty -Name Name -Value "SRS"
	$SRS | Add-Member -MemberType NoteProperty -Name IsActive -Value $false
	$SRS | Add-Member -MemberType NoteProperty -Name Offline -Value $true
	$SRS | Add-Member -MemberType NoteProperty -Name ClientsEnabled -Value $false
	}
else {
	$SRS_Additional = Get-CimInstance -ClassName Win32_PerfFormattedData_PerfProc_Process | where {$_.IDProcess -eq ($SRS.Id)} | Select-Object $properties
	$SRS | Add-Member -MemberType NoteProperty -Name Name -Value "SRS"
	$SRS | Add-Member -MemberType NoteProperty -Name IsActive -Value $true
	$SRS | Add-Member -MemberType NoteProperty -Name Offline -Value $false
	if($SRS.Responding) {
		$SRS | Add-Member -MemberType NoteProperty -Name Status -Value "OK"
	} else {
		$SRS | Add-Member -MemberType NoteProperty -Name Status -Value "Not Responding"
	}
	$SRS | add-Member -MemberType NoteProperty -Name Ports -Value (StringOutPorts -Id $SRS.id)
	$SRS | Add-Member -MemberType NoteProperty -Name RunTime -Value ((get-date) - $SRS.StartTime)
	$SRS | Add-Member -MemberType NoteProperty -Name CPULoad -Value ($SRS_Additional.CPU)
	$SRS | Add-Member -MemberType NoteProperty -Name Threads -Value ($SRS_Additional.Threads)
	$SRS | Add-Member -MemberType NoteProperty -Name Handles -Value ($SRS_Additional.Handles)
	$SRS.StartTime = ((get-date $SRS.StartTime).DateTime)
	$SRS | Add-Member -MemberType NoteProperty -Name ClientsEnabled -Value $false
	if(test-path $srsClients) {
		$SRS.ClientsEnabled = $true
		$ClientTable = ((gc $srsClients) | ConvertFrom-Json -Depth 100).Clients
		if ($ClientTable.Count -ne 0) {
			$SRS | Add-Member -MemberType NoteProperty -Name ClientTable -Value $ClientTable
			$SRS | Add-Member -MemberType NoteProperty -Name ClientsPresent -Value $true
		} else {
			$SRS | Add-Member -MemberType NoteProperty -Name ClientsPresent -Value $false
		}
		$SRS | Add-Member -MemberType NoteProperty -Name ClientCount -Value ($ClientTable.Count)
		}
	}
#START DCS UPDATE	
$DCS_Upd = Get-Process -Name SR-Server -ErrorAction SilentlyContinue | where {$_.Path -eq $DCS_Updater}| Select-Object $ProcessSelection
if($DCS_Upd.count -eq 0) {
	$DCS_Upd = New-Object -TypeName psobject 
	$DCS_Upd | Add-Member -MemberType NoteProperty -Name Name -Value "DCS Updater"
	$DCS_Upd | Add-Member -MemberType NoteProperty -Name IsActive -Value $false
	$DCS_Upd | Add-Member -MemberType NoteProperty -Name Offline -Value $true
	}
else {
	$Updating = $true
	$DCS_Upd_Additional = Get-CimInstance -ClassName Win32_PerfFormattedData_PerfProc_Process | where {$_.IDProcess -eq ($DCS_Upd.Id)} | Select-Object $properties
	$DCS_Upd | Add-Member -MemberType NoteProperty -Name Name -Value "DCS Updater"
	$DCS_Upd | Add-Member -MemberType NoteProperty -Name IsActive -Value $true
	$DCS_Upd | Add-Member -MemberType NoteProperty -Name Offline -Value $false
	if($DCS_Upd.Responding) {
		$DCS_Upd | Add-Member -MemberType NoteProperty -Name Status -Value "OK"
	} else {
		$DCS_Upd | Add-Member -MemberType NoteProperty -Name Status -Value "Not Responding"
	}
	$DCS_Upd | add-Member -MemberType NoteProperty -Name Ports -Value (StringOutPorts -Id $DCS_Upd.id)
	$DCS_Upd | Add-Member -MemberType NoteProperty -Name RunTime -Value ((get-date) - $DCS_Upd.StartTime)
	$DCS_Upd | Add-Member -MemberType NoteProperty -Name CPULoad -Value ($DCS_Upd_Additional.CPU)
	$DCS_Upd | Add-Member -MemberType NoteProperty -Name Threads -Value ($DCS_Upd_Additional.Threads)
	$DCS_Upd | Add-Member -MemberType NoteProperty -Name Handles -Value ($DCS_Upd_Additional.Handles)
	$DCS_Upd.StartTime = ((get-date $DCS_Upd.StartTime).DateTime)
	}
#START SRS UPDATE
$SRS_Upd = Get-Process -Name SR-Server -ErrorAction SilentlyContinue | where {$_.Path -eq $SRS_Updater}| Select-Object $ProcessSelection
if($SRS_Upd.count -eq 0) {
	$SRS_Upd = New-Object -TypeName psobject 
	$SRS_Upd | Add-Member -MemberType NoteProperty -Name Name -Value "SRS Updater"
	$SRS_Upd | Add-Member -MemberType NoteProperty -Name IsActive -Value $false
	$SRS_Upd | Add-Member -MemberType NoteProperty -Name Offline -Value $true
	}
else {
	$Updating = $true
	$SRS_Upd_Additional = Get-CimInstance -ClassName Win32_PerfFormattedData_PerfProc_Process | where {$_.IDProcess -eq ($SRS_Upd.Id)} | Select-Object $properties
	$SRS_Upd | Add-Member -MemberType NoteProperty -Name Name -Value "SRS Updater"
	$SRS_Upd | Add-Member -MemberType NoteProperty -Name IsActive -Value $true
	$SRS_Upd | Add-Member -MemberType NoteProperty -Name Offline -Value $false
	if($SRS_Upd.Responding) {
		$SRS_Upd | Add-Member -MemberType NoteProperty -Name Status -Value "OK"
	} else {
		$SRS_Upd | Add-Member -MemberType NoteProperty -Name Status -Value "Not Responding"
	}
	$SRS_Upd | add-Member -MemberType NoteProperty -Name Ports -Value (StringOutPorts -Id $SRS_Upd.id)
	$SRS_Upd | Add-Member -MemberType NoteProperty -Name RunTime -Value ((get-date) - $SRS_Upd.StartTime)
	$SRS_Upd | Add-Member -MemberType NoteProperty -Name CPULoad -Value ($SRS_Upd_Additional.CPU)
	$SRS_Upd | Add-Member -MemberType NoteProperty -Name Threads -Value ($SRS_Upd_Additional.Threads)
	$SRS_Upd | Add-Member -MemberType NoteProperty -Name Handles -Value ($SRS_Upd_Additional.Handles)
	$SRS_Upd.StartTime = ((get-date $SRS_Upd.StartTime).DateTime)
	}
#START LOTATC UPDATE
$LoT_Upd = Get-Process -Name SR-Server -ErrorAction SilentlyContinue | where {$_.Path -eq $LoT_Updater}| Select-Object $ProcessSelection
if($LoT_Upd.count -eq 0) {
	$LoT_Upd = New-Object -TypeName psobject 
	$LoT_Upd | Add-Member -MemberType NoteProperty -Name Name -Value "LotATC Updater"
	$LoT_Upd | Add-Member -MemberType NoteProperty -Name IsActive -Value $false
	$LoT_Upd | Add-Member -MemberType NoteProperty -Name Offline -Value $true
	}
else {
	$Updating = $true
	$LoT_Upd_Additional = Get-CimInstance -ClassName Win32_PerfFormattedData_PerfProc_Process | where {$_.IDProcess -eq ($LoT_Upd.Id)} | Select-Object $properties
	$LoT_Upd | Add-Member -MemberType NoteProperty -Name Name -Value "LotATC Updater"
	$LoT_Upd | Add-Member -MemberType NoteProperty -Name IsActive -Value $true
	$LoT_Upd | Add-Member -MemberType NoteProperty -Name Offline -Value $false
	if($LoT_Upd.Responding) {
		$LoT_Upd | Add-Member -MemberType NoteProperty -Name Status -Value "OK"
	} else {
		$LoT_Upd | Add-Member -MemberType NoteProperty -Name Status -Value "Not Responding"
	}
	$LoT_Upd | add-Member -MemberType NoteProperty -Name Ports -Value (StringOutPorts -Id $LoT_Upd.id)
	$LoT_Upd | Add-Member -MemberType NoteProperty -Name RunTime -Value ((get-date) - $LoT_Upd.StartTime)
	$LoT_Upd | Add-Member -MemberType NoteProperty -Name CPULoad -Value ($LoT_Upd_Additional.CPU)
	$LoT_Upd | Add-Member -MemberType NoteProperty -Name Threads -Value ($LoT_Upd_Additional.Threads)
	$LoT_Upd | Add-Member -MemberType NoteProperty -Name Handles -Value ($LoT_Upd_Additional.Handles)
	$LoT_Upd.StartTime = ((get-date $LoT_Upd.StartTime).DateTime)
	}

$Status = $null
$Status = New-Object -TypeName psobject 
$Status | Add-Member -MemberType NoteProperty -Name Server -Value $ServerStatus
$Status | Add-Member -MemberType NoteProperty -Name DCS -Value $DCS
$Status | Add-Member -MemberType NoteProperty -Name SRS -Value $SRS
$Status | Add-Member -MemberType NoteProperty -Name DCS_Updater -Value $DCS_Upd
$Status | Add-Member -MemberType NoteProperty -Name SRS_Updater -Value $SRS_Upd
$Status | Add-Member -MemberType NoteProperty -Name LOT_Updater -Value $LoT_Upd
$Status | Add-Member -MemberType NoteProperty -Name Updating -Value $Updating
write-log -LogData "Get-Status: ENDED" -Silent
return $Status
}

Function Check-Update { 
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
write-log -LogData "Check-Game: STARTED" -Silent
$ChkGame = $null
$ChkGame = New-Object -TypeName psobject
$network = get-nettcpconnection -ErrorAction SilentlyContinue | Select-Object local*,remote*,state,@{Name="Process";Expression={(Get-Process -Id $_.OwningProcess).ProcessName}}
$DCS = Get-Process -Name DCS -ErrorAction SilentlyContinue | where {$_.MainWindowTitle -eq $DCS_WindowTitle -and $_.Path -eq $dcsEXE} | Select-Object $selection 
$SRS = Get-Process -Name SR-Server -ErrorAction SilentlyContinue | where {$_.Path -eq $srsEXE}| Select-Object $selection

$processor = Get-CimInstance -ClassName Win32_Processor
$system = Get-CimInstance -Class Win32_OperatingSystem
$MemoryLoad = [math]::Round(((($system.TotalVisibleMemorySize - $system.FreePhysicalMemory)*100)/ $system.TotalVisibleMemorySize), 0)

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
	if(test-path $srsClients) {
		$SRS | Add-Member -MemberType NoteProperty -Name ClientsEnabled -Value $true
		$SRS | Add-Member -MemberType NoteProperty -Name ClientTable -Value ((gc $srsClients) | ConvertFrom-Json -Depth 100)
		$SRS | Add-Member -MemberType NoteProperty -Name ClientCount -Value ($SRS.ClientTable.Clients.Count)
	} else {
		$SRS | Add-Member -MemberType NoteProperty -Name ClientsEnabled -Value $false
		}
	
	$srsNet = $network | Where-Object{$_.Process -eq $SRS.ProcessName} | Where-Object{$_.State -eq 'Listen'} | sort-Object LocalPort
	$srsNetTXT = ""
	Foreach($SNitem in $srsNet)
		{
		$srsNetTXT = $srsNetTXT + $SNitem.LocalPort
		if($SNitem -ne $srsNet[-1]) {$srsNetTXT = $srsNetTXT + ", "}
		}
	$SRS | add-Member -MemberType NoteProperty -Name ProcessPorts -Value $srsNetTXT
	}

$systemload = $null
$systemload = New-Object -TypeName psobject
$systemload | Add-Member -MemberType NoteProperty -Name CPULoad -Value $Processor.LoadPercentage
$systemload | Add-Member -MemberType NoteProperty -Name MEMLoad -Value $MemoryLoad


$ChkGame | Add-Member -MemberType NoteProperty -Name DCS -Value $DCS
$ChkGame | Add-Member -MemberType NoteProperty -Name SRS -Value $SRS
write-log -LogData "Check-Game: ENDED" -Silent
return $ChkGame
}

Function InitializeDDC2 {
	$info = Get-ServerInfo
	$config = Get-Config
	$status = Get-Status
	$DDC2 = $null
	$DDC2 = New-Object -TypeName psobject
	$DDC2 | Add-Member -MemberType NoteProperty -Name ServerInfo -Value $info
	$DDC2 | Add-Member -MemberType NoteProperty -Name AppConfig -Value $config
	$DDC2 | Add-Member -MemberType NoteProperty -Name Permissions -Value $CMDPerms	#Item Pulled from ddc2_config.ps1
	$DDC2 | Add-Member -MemberType NoteProperty -Name Channel -Value $Channel		#Item Pulled from ddc2_config.ps1
	$DDC2 | Add-Member -MemberType NoteProperty -Name Status -Value $Status
	!status ddc2-dev
return $DDC2
}

########################################################################################################################################################################################################
#UPDATE#SECTION#########################################################################################################################################################################################
########################################################################################################################################################################################################
Function Update-LotATC {
	write-log -LogData "Starting LotATC Update Process" -Silent
	Start-Process -FilePath $Lot_Updater -ArgumentList $Lot_Updater_Args -wait
	write-log -LogData "LotATC Update Process - JOB DONE!" -Silent
}
Function Update-SRS {
	write-log -LogData "Starting SRS Update Process..." -Silent
	Start-Process -FilePath $SRS_Updater -ArgumentList $SRS_Updater_Args -wait
	write-log -LogData "SRS Update Process - JOB DONE!" -Silent
}
Function Update-DCS {
	write-log -LogData "Starting DCS Update Process..." -Silent
	$Pwrshell = New-Object -ComObject wscript.shell;
	start-process $DCS_Updater -ArgumentList $DCS_Updater_Args -WorkingDirectory $dcsBIN -wait
	#write-host "Waiting 15 Seconds for Check Update Window to complete check"
	#write-log -LogData "Sleeping 15 seconds" -Silent
	Start-sleep 5;
	#write-log -LogData 'DCS Update process SET to  $Process_UpdateDCS' -Silent
	$Process_UpdateDCS = Get-Process -Name DCS_updater -ErrorAction SilentlyContinue
	#write-host "Looking for DCS Updater Window: " -nonewline
	#write-log -LogData "Selecting Window 'DCS Updater'" -Silent
	#$shh = $Pwrshell.AppActivate('DCS Updater')
	#write-log -LogData '$contLoop set to $true' -Silent
	$contLoop = $true
	#write-log -LogData '$checkLoop set to 0' -Silent
	$checkLoop = 0
	#write-log -LogData '$working set to 0' -Silent
	$working = 0
	#write-log -LogData '$ticks set to 0' -Silent
	$ticks = 0
	#Possible Rogue TRUE Statement
	write-log -LogData 'Starting DCS Updater While Loop' -Silent
	$shh = while ($contLoop) {
		#This grabs the current tick count for the busy process
		write-log -LogData 'DCS Updating in progress... checking again in 2 second.' -Silent
		Start-sleep 2;
		$Process_UpdateDCS = Get-Process -Name DCS_updater -ErrorAction SilentlyContinue | where {$_.Path -eq $DCS_updater}
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
				#write-log -LogData "'Enter' pressed on 'DCS Updater' window incase it has a message" -Silent
				#$Pwrshell.SendKeys('~')
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
	#write-log -LogData "Sleeping 1 second" -Silent
	#Start-sleep 1;
	#write-log -LogData "Selecting Window 'DCS Updater'" -Silent
	#$shh = $Pwrshell.AppActivate('DCS Updater')
	#$Pwrshell.SendKeys('~')
	#write-log -LogData "'Enter' pressed on 'DCS Updater' window" -Silent
	write-log -LogData "DCS Update Process - JOB DONE!" -Silent
}

Function Update-Server {
$DoUpdate = $true
$ServerStatus = $null

$DCS = Get-Process -ErrorAction SilentlyContinue | where {$_.MainWindowTitle -eq $DCS_WindowTitle -and $_.Path -eq $dcsEXE} | select $ProcessSelection
	if($DCS.count -ne 0) {
	$DoUpdate = $false
	}
$SRS = Get-Process -Name SR-Server -ErrorAction SilentlyContinue | where {$_.Path -eq $srsEXE}| Select-Object $ProcessSelection
	if($SRS.count -ne 0) {
	$DoUpdate = $false
	}
$DCS_Upd = Get-Process -Name SR-Server -ErrorAction SilentlyContinue | where {$_.Path -eq $DCS_Updater}| Select-Object $ProcessSelection
	if($DCS_Upd.count -ne 0) {
	$DoUpdate = $false
	}
$SRS_Upd = Get-Process -Name SR-Server -ErrorAction SilentlyContinue | where {$_.Path -eq $SRS_Updater}| Select-Object $ProcessSelection
	if($SRS_Upd.count -ne 0) {
	$DoUpdate = $false
	}
$LoT_Upd = Get-Process -Name SR-Server -ErrorAction SilentlyContinue | where {$_.Path -eq $LoT_Updater}| Select-Object $ProcessSelection
	if($LoT_Upd.count -ne 0) {
	$DoUpdate = $false
	}
	if($DoUpdate) {
	$PowerShellEXE = "C:\Program Files\PowerShell\7\pwsh.exe"
	$UpdateARGS = "-WindowStyle Minimized -ExecutionPolicy Bypass -Command `"& $DDC2DIR\DDC2.ps1 -DoUpdate -DDC2DIR $DDC2DIR`""
	write-log "COMMAND BEING EXECUTED BY Update-Server: start-process $PowerShellEXE -ArgumentList $UpdateARGS -WorkingDirectory $DDC2DIR" -silent
	start-process $PowerShellEXE -ArgumentList $UpdateARGS -WorkingDirectory $DDC2DIR
	}
start-sleep 3;
$ServerStatus = Get-Status
return $ServerStatus
}


Function Do-Update {
	write-log -LogData "UPDATE DCS: STARTED" -Silent
	#STOP DCS
	write-log -LogData "UPDATE DCS: Call Stop-DCS" -Silent
	Stop-DCS
	Start-sleep 1;
	if ($UPDATE_LoT) {
		write-log -LogData "UPDATE DCS: Call Update LotATC" -Silent
		Update-LotATC
		Start-sleep 1;
		}
	else {
		write-log -LogData "UPDATE DCS: LotATC autoupdate skipped due to UPDATE_LoT variable being set to false." -Silent
		}
	
	if ($UPDATE_SRS) {
		write-log -LogData "UPDATE DCS: Call Update SRS Update" -Silent
		Update-SRS
		Start-sleep 1;
		}
	else {
		write-log -LogData "UPDATE DCS: SRS autoupdate skipped due to UPDATE_SRS variable being set to false." -Silent
		}
	if ($UPDATE_DCS) {	
		write-log -LogData "UPDATE DCS: Call Update DCS" -Silent
		Update-DCS
		Start-sleep 1;
		}
	else {
		write-log -LogData "UPDATE DCS: DCS autoupdate skipped due to UPDATE_DCS variable being set to false." -Silent
		}
	
	if ($AutoStartonUpdate) {
		write-log -LogData "UPDATE DCS: Call Restart-DCS" -Silent
		Restart-DCS
		}
	else {
		write-log -LogData "UPDATE DCS: Restart-DCS Disabled in ddc2_config.ps1, DCS not restarted" -Silent
		}
		
	write-log -LogData "UPDATE DCS: JOB DONE!" -Silent
}

########################################################################################################################################################################################################
#DCS CONTROL############################################################################################################################################################################################
########################################################################################################################################################################################################
Function Restart-DCS {
write-log -LogData "Restart-DCS: STARTED" -Silent
write-log -LogData "Restart-DCS: Calling Stop-DCS" -Silent
	Stop-DCS
write-log -LogData "Restart-DCS: Calling Start-DCS" -Silent	
	Start-DCS
write-log -LogData "Restart-DCS: ENDED" -Silent
}
Function Start-DCS {
$Running = $false	
$Updating = $false	
$DCS = Get-Process -ErrorAction SilentlyContinue | where {$_.MainWindowTitle -eq $DCS_WindowTitle -and $_.Path -eq $dcsEXE} | select $ProcessSelection
	if($DCS.count -ne 0) {
		$Running = $true
	}
$SRS = Get-Process -Name SR-Server -ErrorAction SilentlyContinue | where {$_.Path -eq $srsEXE}| Select-Object $ProcessSelection
	if($SRS.count -ne 0) {
		$Running = $true
	}
$DCS_Upd = Get-Process -Name SR-Server -ErrorAction SilentlyContinue | where {$_.Path -eq $DCS_Updater}| Select-Object $ProcessSelection
	if($DCS_Upd.count -ne 0) {
		$Updating = $true
	}
$SRS_Upd = Get-Process -Name SR-Server -ErrorAction SilentlyContinue | where {$_.Path -eq $SRS_Updater}| Select-Object $ProcessSelection
	if($SRS_Upd.count -ne 0) {
		$Updating = $true
	}
$LoT_Upd = Get-Process -Name SR-Server -ErrorAction SilentlyContinue | where {$_.Path -eq $LoT_Updater}| Select-Object $ProcessSelection
	if($LoT_Upd.count -ne 0) {
		$Updating = $true
	}
	if(-not $Updating -and -not $Running) {
		$PriorityArray = @{Priority        = [Int32](256)}
		if($EnableRandomizer) {PwdRandomizer}
		write-log -LogData "Start-DCS: STARTED" -Silent
		write-log -LogData "Starting DCS" -Silent
		start-process $dcsexe -ArgumentList $dcsargs -WorkingDirectory $dcsdir
		#write-log -LogData "Sleeping 3 second" -Silent
		Start-sleep 3
		write-log -LogData "Setting Priority for DCS" -Silent
		$shh = Get-CimInstance -ClassName win32_process -Filter 'name = "DCS.exe"' | Invoke-CimMethod -MethodName SetPriority -Arguments $PriorityArray
		write-log -LogData "Starting SRS" -Silent
		start-process $srsexe -WorkingDirectory $srsdir
		#write-log -LogData "Sleeping 2 second" -Silent
		Start-sleep 2
		write-log -LogData "Setting Priority for SRS" -Silent
		$shh = Get-CimInstance -ClassName win32_process -Filter 'name = "SR-Server.exe"' | Invoke-CimMethod -MethodName SetPriority -Arguments $PriorityArray
		#write-log -LogData "Sleeping 15 second" -Silent
		Start-sleep 10
		$ContinueSleep = $false
		$sleepTime = 0
		while (-not $ContinueSleep) {
		Start-sleep 1
		$DCS = Get-Process -ErrorAction SilentlyContinue | where {$_.MainWindowTitle -eq $DCS_WindowTitle -and $_.Path -eq $dcsEXE} | select $ProcessSelection
		$sleepTime = $sleepTime + 1
		$ContinueSleep = $DCS.Responding
		}
		write-log -LogData "DCS Process not responding initiation time was $sleepTime seconds" -Silent
		#write-log -LogData "Shaping and Moving DCS Window" -Silent
		Set-Window -ProcessName DCS -X 150 -y 25 -Width 160 -Height 120
		#write-log -LogData "Moving SRS Window" -Silent
		Set-Window -ProcessName SR-Server -x 305 -y 25
		write-log -LogData "Start-DCS: ENDED" -Silent
		###Add DCS Firewall Rules here
	}
}
Function Stop-DCS {
	write-log -LogData "Stop-DCS: STARTED" -Silent
	$DCS = Get-Process -ErrorAction SilentlyContinue | where {$_.MainWindowTitle -eq $DCS_WindowTitle -and $_.Path -eq $dcsEXE} | select $ProcessSelection
	$SRS = Get-Process -Name SR-Server -ErrorAction SilentlyContinue | where {$_.Path -eq $srsEXE}| Select-Object $ProcessSelection
	$DCS_Upd = Get-Process -Name SR-Server -ErrorAction SilentlyContinue | where {$_.Path -eq $DCS_Updater}| Select-Object $ProcessSelection
	$SRS_Upd = Get-Process -Name SR-Server -ErrorAction SilentlyContinue | where {$_.Path -eq $SRS_Updater}| Select-Object $ProcessSelection
	$LoT_Upd = Get-Process -Name SR-Server -ErrorAction SilentlyContinue | where {$_.Path -eq $LoT_Updater}| Select-Object $ProcessSelection
	write-log -LogData 'FORCE Stopping DCS...' -Silent
	$DCS | stop-process -Force
	write-log -LogData 'FORCE Stopping SRS...' -Silent
	$SRS | stop-process -Force
	write-log -LogData 'FORCE Stopping DCS Updater...' -Silent
	$DCS_Upd | stop-process -Force
	write-log -LogData 'FORCE Stopping SRS Updater...' -Silent
	$SRS_Upd | stop-process -Force
	write-log -LogData 'FORCE Stopping LotATC Updater...' -Silent
	$LoT_Upd | stop-process -Force
	write-log -LogData "Stop-DCS: ENDED" -Silent
}



########################################################################################################################################################################################################
#RADIO CONTROL##########################################################################################################################################################################################
########################################################################################################################################################################################################
Function Radio {
Param (
$Freq = ((Select-String -Path $SRS_Config -Pattern "GLOBAL_LOBBY_FREQUENCIES" | Out-String).Split('=')[1]).Trim(),
$MOD = $SRS_DefaultMOD,
$VOL = $SRS_DefaultVOL,
$TxTMSG = "THIS IS A DDC2 TEST MESSAGE",
$RadioUser = "DDC2 TEST USER",
$Coal = 0
)
write-log "Radio Started with the following settings" -silent
write-log "Radio Frequency = $Freq" -silent
write-log "Radio Coalition = $Coal" -silent
write-log "Radio Message   = $TxTMSG" -silent

$SRS_PORT = ((Select-String -Path $SRS_Config -Pattern "SERVER_PORT" | Out-String).Split('=')[1]).Trim()
$DDC2_RadioUser = "DDC2: $RadioUser"

$currentLOC = get-location
$WorkingDirectory = Split-path $SRS_External
if(test-path $SRS_External) {
	#write-log "SRS External Found" -silent
	set-location $WorkingDirectory
	.$SRS_External --text $TxTMSG --freqs $Freq --modulations $MOD --coalition $Coal --port $SRS_PORT --name $DDC2_RadioUser --volume $VOL  #NEW METHOD OF CALLING RADIO
	#	$silent = .$SRS_External $TxTMSG $Freq $MOD $Coal $SRS_PORT $DDC2_RadioUser $VOL    #OLD METHOD OF CALLING RADIO
	set-location $currentLOC
	}
else {
	write-log "SRS External NOT Found" -silent
}
$RadioData = $null
$RadioData = New-Object -TypeName psobject
$RadioData | Add-Member -MemberType NoteProperty -Name Frequency -Value $Freq
$RadioData | Add-Member -MemberType NoteProperty -Name Modulation -Value $MOD
$RadioData | Add-Member -MemberType NoteProperty -Name RadioMSG -Value $TxTMSG
$RadioData | Add-Member -MemberType NoteProperty -Name Port -Value $SRS_PORT
$RadioData | Add-Member -MemberType NoteProperty -Name Volume -Value $VOL
$RadioData | Add-Member -MemberType NoteProperty -Name Side -Value $Coal
return $RadioData
}



########################################################################################################################################################################################################
#EXECUTION SECTION######################################################################################################################################################################################
########################################################################################################################################################################################################
#Server & DCS Control Commands
if ($Start) {
	Start-DCS
	$DCSreturn = InitializeDDC2
	}
if ($Restart) {
	Restart-DCS
	$DCSreturn = InitializeDDC2
	}
if ($Stop) {
	Stop-DCS
	$DCSreturn = get-status
	}
if ($Update) {
	$DCSreturn = Update-Server
	#$DCSreturn = get-status
	}
if ($DoUpdate) {
	Do-Update
	}
If ($Status) {
	$DCSreturn = get-status
	}
if ($Reboot) {
	Reboot-Server
	$DCSreturn = get-status
	}
if ($Refresh) {$DCSreturn = InitializeDDC2}
#Firewall / Access Commands################################################################################
if ($Secure -and (-not $VNC)) {$DCSreturn = Change-Firewall -Lock -IP $IP -USER $USER -DiscordID $ID}
if ($Access -and (-not $VNC)) {$DCSreturn = Change-Firewall -Unlock -IP $IP -USER $USER -DiscordID $ID}
if ($Secure -and $VNC) {$DCSreturn = Change-Firewall -Lock -IP $IP -USER $USER -DiscordID $ID -VNC}
if ($Access -and $VNC) {$DCSreturn = Change-Firewall -Unlock -IP $IP -USER $USER -DiscordID $ID -VNC}
if ($ClearAll) {$DCSreturn = Change-Firewall -ClearAll}
###########################################################################################################
if ($Radio) {
	$DCSreturn = radio -Freq $RadioFrq -RadioUser $RadioUser -Coal $RadioSide -TxTMSG $RadioMSG
	}
if ($init) {$DCSreturn = InitializeDDC2}
$DCSreturnJSON = $DCSreturn | ConvertTo-Json -Depth 100
write-log -LogData "##JOB-DONE#####################################JOB-DONE##" -Silent
return $DCSreturnJSON