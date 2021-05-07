<#
DCS Controller Script for Node-Red & Discord Interaction
# Version 2.0j
# Writen by OzDeaDMeaT
# 03-05-2021

Copyright (c) 2021 Josh 'OzDeaDMeaT' McDougall, All rights reserved.
Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
4. Utilization of this software for commercial use is prohibited unless authorized by the software copyright holder in writing (electronic mail).

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

####################################################################################################
#CHANGE LOG#########################################################################################
####################################################################################################
- v2.0j Added DDC2-AutoStart
- v2.0j Added Add-Position
- v2.0j Added Set-Position
- v2.0j Updated Set-Window
- v2.0j Updated UPDATE-MOOSE
- v2.0i Changed PwdRandomizer to distinguish between SRS and DCS so PwdRandomizer could be called directly from application specific Start Command (start-dcs, start-srs)
- v2.0i Added Start-Server
- v2.0i Added Set-Priority
- v2.0i Added Wait-For-Response
- v2.0f Fixed Stop-SRS from closing all instances of SRS
- v2.0f Re-purposed Start-DCS
- v2.0f Added Start-SRS
####################################################################################################
#>
param(
[switch]$init,
[switch]$AutoStart,
[switch]$Refresh,
[switch]$Radio,
[switch]$Update,
[switch]$Status,
[switch]$Start,
[switch]$Stop,
[switch]$StopAll,
[switch]$StopGame,
[switch]$StopDCS,
[switch]$StopSRS,
[switch]$StopUpdate,
[switch]$Restart,
[switch]$Reboot,
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
$DDC2_PSCore_Version = "v2.0j"
####################################################################################################
########################################################################################################################################################################################################
##This section Sets the DDC2 Location for execution and sets the correct config and log files to write to.
if(($DDC2DIR).count -gt 0) {
		if (test-path $DDC2DIR) {
			$currentDIR = $DDC2DIR
		} else {
			$currentDIR = (Get-Location).Path
			$DDC2DIR = $currentDIR
		 }
} else {
	$currentDIR = (Get-Location).Path
	}
$DDC2_LogFile			= "$currentDIR\DDC2.log" 															#Log File Location for this script
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
$LogFile = $DDC2_LogFile,
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
$PosArray = [PSCustomObject]@{}
#$PosArray = New-Object -TypeName PSObject
#$PosArray = @()
Function Add-Position {
param(
[Parameter(Mandatory=$true)]$POSid,
[Parameter(Mandatory=$true)]$SRS_X,
[Parameter(Mandatory=$true)]$SRS_Y,
[Parameter(Mandatory=$true)]$DCS_X,
[Parameter(Mandatory=$true)]$DCS_Y,
[Parameter(Mandatory=$true)]$DCS_SizeX,
[Parameter(Mandatory=$true)]$DCS_SizeY
)
$NewItem = @(
	[pscustomobject]@{`
		 POSid = $POSid;`
		 SRS_X = $SRS_X;`
		 SRS_Y = $SRS_Y;`
		 DCS_X = $DCS_X;`
		 DCS_Y = $DCS_Y;`
		 DCS_SizeX = $DCS_SizeX;`
		 DCS_SizeY = $DCS_SizeY}
)
return $PosArray + $NewItem
}
Function Set-Position {
param(
[Parameter(Mandatory=$true)]$Id,
[switch]$DCS,
[switch]$SRS
)
	If($DesktopLocation -lt $PosArray.Count) {
		If($SRS) {
			$locationArray = $PosArray[$DesktopLocation]
			Set-Window -Id $Id -x $locationArray.SRS_X -y $locationArray.SRS_Y
			write-log -LogData "SRS Window with ProcessID: $Id has been moved to Desktop Position #$DesktopLocation" -Silent
		}
		If($DCS) {
			$locationArray = $PosArray[$DesktopLocation]
			Set-Window -Id $Id -x $locationArray.DCS_X -y $locationArray.DCS_Y -Width $locationArray.DCS_SizeX -Height $locationArray.DCS_SizeY
			write-log -LogData "DCS Window with ProcessID: $Id has been moved to Desktop Position #$DesktopLocation" -Silent
		}
	} else {write-log -LogData 'Invalid configurtation for $DesktopLocation, the LocationID given is greater than the array of locations available' -Silent}
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
#DDC2 SETUP FUNCTIONS###################################################################################################################################################################################
########################################################################################################################################################################################################
Function Check-DDC2 {
<# 
.DESCRIPTION 
This function checks that all the config files etc have been entered correctly into the DDC2 Powershell script
 
.EXAMPLE
Check-DDC2
#>
write-host "Reloading DDC2.ps1 file into memory"
. .\DDC2.ps1
####################################################################################################
write-host '$DDC2_LogFile	(ddc2.ps1)	== ' -nonewline -ForegroundColor white
if (test-path $DDC2_LogFile) {
	write-host "OK" -nonewline -ForegroundColor green
	write-host " - $DDC2_LogFile" -ForegroundColor yellow
	} else {write-host "Not Found" -ForegroundColor red}
####################################################################################################
write-host " "
write-host "Checking Variables from ddc2_config.ps1 ...." -ForegroundColor white

write-host '$VNC_Path			== ' -nonewline -ForegroundColor white
if (test-path $VNC_Path) {
	write-host "OK" -nonewline -ForegroundColor green
	write-host " - $VNC_Path" -ForegroundColor yellow
	} else {write-host "Not Found" -ForegroundColor red}	
	
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
write-host "DDC2 Settings...." -ForegroundColor white

write-host '$ServerID		 	== ' -nonewline -ForegroundColor white
write-host $ServerID -ForegroundColor green

write-host '$ServerDT		 	== ' -nonewline -ForegroundColor white
write-host $ServerDT -ForegroundColor green

write-host '$DDC2_CommandPrefix		== ' -nonewline -ForegroundColor white
write-host $DDC2_CommandPrefix -ForegroundColor green

write-host '$VNCEnabled			== ' -nonewline -ForegroundColor white
if($VNCEnabled) {write-host "Enabled" -ForegroundColor green} else {write-host "Disabled" -ForegroundColor yellow}

write-host '$VNCPort			== ' -nonewline -ForegroundColor white
write-host $VNCPort -ForegroundColor green

write-host '$VNCType			== ' -nonewline -ForegroundColor white
write-host $VNCType -ForegroundColor green

write-host '$HostedByMember			== ' -nonewline -ForegroundColor white
if($HostedByMember) {write-host "Enabled" -ForegroundColor green} else {write-host "Disabled" -ForegroundColor yellow}

write-host '$HostedByName			== ' -nonewline -ForegroundColor white
write-host $HostedByName -ForegroundColor green

write-host '$HostedAT			== ' -nonewline -ForegroundColor white
write-host $HostedAT -ForegroundColor green

write-host '$DiscordID			== ' -nonewline -ForegroundColor white
write-host $DiscordID -ForegroundColor green

write-host '$SupportByMember		== ' -nonewline -ForegroundColor white
if($SupportByMember) {write-host "Enabled" -ForegroundColor green} else {write-host "Disabled" -ForegroundColor yellow}

write-host '$SupportContactID		== ' -nonewline -ForegroundColor white
write-host $SupportContactID -ForegroundColor green

write-host '$SupportBy			== ' -nonewline -ForegroundColor white
write-host $SupportBy -ForegroundColor green

write-host '$SupportTimeTXT			== ' -nonewline -ForegroundColor white
write-host $SupportTimeTXT -ForegroundColor green

write-host '$SupportContactTXT		== ' -nonewline -ForegroundColor white
write-host $SupportContactTXT -ForegroundColor green

write-host '$ISP				== ' -nonewline -ForegroundColor white
write-host $ISP -ForegroundColor green

write-host '$NetSpeed			== ' -nonewline -ForegroundColor white
write-host $NetSpeed -ForegroundColor green

write-host '$DNSName			== ' -nonewline -ForegroundColor white
write-host $DNSName -ForegroundColor green

write-host '$SRS_FreqLOW			== ' -nonewline -ForegroundColor white
write-host $SRS_FreqLOW -ForegroundColor green

write-host '$SRS_FreqHIGH			== ' -nonewline -ForegroundColor white
write-host $SRS_FreqHIGH -ForegroundColor green

write-host '$SRS_DefaultMOD			== ' -nonewline -ForegroundColor white
write-host $SRS_DefaultMOD -ForegroundColor green

write-host '$SRS_DefaultVOL			== ' -nonewline -ForegroundColor white
write-host $SRS_DefaultVOL -ForegroundColor green

write-host '$SRS_DefaultCoal		== ' -nonewline -ForegroundColor white
write-host $SRS_DefaultCoal -ForegroundColor green

write-host '$DDC2_HELP			== ' -nonewline -ForegroundColor white
if($DDC2_HELP) {write-host "Enabled" -ForegroundColor green} else {write-host "Disabled" -ForegroundColor yellow}

write-host '$DCSBETA			== ' -nonewline -ForegroundColor white
if($DCSBETA) {write-host "Enabled" -ForegroundColor green} else {write-host "Disabled" -ForegroundColor yellow}

write-host '$SRSBETA			== ' -nonewline -ForegroundColor white
if($SRSBETA) {write-host "Enabled" -ForegroundColor green} else {write-host "Disabled" -ForegroundColor yellow}

write-host '$LoTBETA			== ' -nonewline -ForegroundColor white
if($LoTBETA) {write-host "Enabled" -ForegroundColor green} else {write-host "Disabled" -ForegroundColor yellow}

write-host '$UPDATE_DCS			== ' -nonewline -ForegroundColor white
if($UPDATE_DCS) {write-host "Enabled" -ForegroundColor green} else {write-host "Disabled" -ForegroundColor yellow}

write-host '$UPDATE_SRS			== ' -nonewline -ForegroundColor white
if($UPDATE_SRS) {write-host "Enabled" -ForegroundColor green} else {write-host "Disabled" -ForegroundColor yellow}

write-host '$UPDATE_LoT			== ' -nonewline -ForegroundColor white
if($UPDATE_LoT) {write-host "Enabled" -ForegroundColor green} else {write-host "Disabled" -ForegroundColor yellow}

write-host '$UPDATE_MOOSE			== ' -nonewline -ForegroundColor white
if($UPDATE_MOOSE) {write-host "Enabled" -ForegroundColor green} else {write-host "Disabled" -ForegroundColor yellow}

write-host '$AutoStartonUpdate		== ' -nonewline -ForegroundColor white
if($AutoStartonUpdate) {write-host "Enabled" -ForegroundColor green} else {write-host "Disabled" -ForegroundColor yellow}

write-host '$UPDATE_MOOSE			== ' -nonewline -ForegroundColor white
if($UPDATE_MOOSE) {write-host "Enabled" -ForegroundColor green} else {write-host "Disabled" -ForegroundColor yellow}

write-host '$SHOW_BLUPWD			== ' -nonewline -ForegroundColor white
if($SHOW_BLUPWD) {write-host "Enabled" -ForegroundColor green} else {write-host "Disabled" -ForegroundColor yellow}

write-host '$SHOW_REDPWD			== ' -nonewline -ForegroundColor white
if($SHOW_REDPWD) {write-host "Enabled" -ForegroundColor green} else {write-host "Disabled" -ForegroundColor yellow}

write-host '$SHOW_SRVPWD			== ' -nonewline -ForegroundColor white
if($SHOW_SRVPWD) {write-host "Enabled" -ForegroundColor green} else {write-host "Disabled" -ForegroundColor yellow}

write-host '$SHOW_LotATC			== ' -nonewline -ForegroundColor white
if($SHOW_LotATC) {write-host "Enabled" -ForegroundColor green} else {write-host "Disabled" -ForegroundColor yellow}

write-host '$SHOW_TACView			== ' -nonewline -ForegroundColor white
if($SHOW_TACView) {write-host "Enabled" -ForegroundColor green} else {write-host "Disabled" -ForegroundColor yellow}

write-host '$ACCESS_LOOP_DELAY		== ' -nonewline -ForegroundColor white
write-host $ACCESS_LOOP_DELAY -ForegroundColor green

write-host '$UPDATE_LOOP_DELAY		== ' -nonewline -ForegroundColor white
write-host $UPDATE_LOOP_DELAY -ForegroundColor green

write-host '$EnableRandomizer		== ' -nonewline -ForegroundColor white
if($EnableRandomizer) {write-host "Enabled" -ForegroundColor green} else {write-host "Disabled" -ForegroundColor yellow}

write-host '$ServerPassword			== ' -nonewline -ForegroundColor white
if($ServerPassword) {write-host "Enabled" -ForegroundColor green} else {write-host "Disabled" -ForegroundColor yellow}

write-host '$SRSPassword			== ' -nonewline -ForegroundColor white
if($SRSPassword) {write-host "Enabled" -ForegroundColor green} else {write-host "Disabled" -ForegroundColor yellow}

write-host '$SeperateLOT			== ' -nonewline -ForegroundColor white
if($SeperateLOT) {write-host "Enabled" -ForegroundColor green} else {write-host "Disabled" -ForegroundColor yellow}

write-host '$SeperateTAC			== ' -nonewline -ForegroundColor white
if($SeperateTAC) {write-host "Enabled" -ForegroundColor green} else {write-host "Disabled" -ForegroundColor yellow}

write-host '$AdminChannel			== ' -nonewline -ForegroundColor white
write-host $AdminChannel -ForegroundColor green

write-host '$BlueChannel			== ' -nonewline -ForegroundColor white
write-host $BlueChannel -ForegroundColor green

write-host '$RedChannel			== ' -nonewline -ForegroundColor white
write-host $RedChannel -ForegroundColor green

write-host '$LogChannel			== ' -nonewline -ForegroundColor white
write-host $LogChannel -ForegroundColor green

write-host '$SupportChannel			== ' -nonewline -ForegroundColor white
write-host $SupportChannel -ForegroundColor green

write-host '$ServerStatus			== ' -nonewline -ForegroundColor white
write-host $ServerStatus -ForegroundColor green

write-host '$testPerm			== ' -nonewline -ForegroundColor white
write-host $testPerm -ForegroundColor green

write-host '$versionPerm			== ' -nonewline -ForegroundColor white
write-host $versionPerm -ForegroundColor green

write-host '$infoPerm			== ' -nonewline -ForegroundColor white
write-host $infoPerm -ForegroundColor green

write-host '$supportPerm			== ' -nonewline -ForegroundColor white
write-host $supportPerm -ForegroundColor green

write-host '$helpPerm			== ' -nonewline -ForegroundColor white
write-host $helpPerm -ForegroundColor green

write-host '$refreshPerm			== ' -nonewline -ForegroundColor white
write-host $refreshPerm -ForegroundColor green

write-host '$configPerm			== ' -nonewline -ForegroundColor white
write-host $configPerm -ForegroundColor green

write-host '$radioPerm			== ' -nonewline -ForegroundColor white
write-host $radioPerm -ForegroundColor green

write-host '$startPerm			== ' -nonewline -ForegroundColor white
write-host $startPerm -ForegroundColor green

write-host '$stopPerm			== ' -nonewline -ForegroundColor white
write-host $stopPerm -ForegroundColor green

write-host '$restartPerm			== ' -nonewline -ForegroundColor white
write-host $restartPerm -ForegroundColor green

write-host '$statusPerm			== ' -nonewline -ForegroundColor white
write-host $statusPerm -ForegroundColor green

write-host '$updatePerm			== ' -nonewline -ForegroundColor white
write-host $updatePerm -ForegroundColor green

write-host '$accessPerm			== ' -nonewline -ForegroundColor white
write-host $accessPerm -ForegroundColor green

write-host '$rebootPerm			== ' -nonewline -ForegroundColor white
write-host $rebootPerm -ForegroundColor green

write-host " "	
write-host "Check Complete...." -ForegroundColor white
write-host " "	
}
Function Check-Ports {
<# 
.DESCRIPTION 
This function checks all the config files defined in ddc2_config.ps1 for port information and displays the ports in an easy to read manner.
 
.EXAMPLE
Check-Ports
#>
write-host " "
write-host "Checking ports for DDC2-ID: $ServerID, installed in $currentDIR" -ForegroundColor white
write-host " "
if(test-path $DCS_Config) {
	write-host "Port Configuration from - " -ForegroundColor white -nonewline
	write-host "$DCS_Config" -ForegroundColor green
	$DCS_PORT = ((Select-String -Path $DCS_Config -Pattern "port" | Out-String).Split(' ')[-1]).Split(',')[0]
	write-host "	: port 				= "  -nonewline
	write-host "$DCS_PORT" -ForegroundColor green
} else {
	write-host 'Port Configuration from - ' -ForegroundColor white -nonewline
	write-host '$DCS_Config file path not found (check ddc2_config.ps1)' -ForegroundColor yellow
}
write-host " "
if(test-path $SRS_AutoConnect) {
	write-host "Port Configuration from - " -ForegroundColor white -nonewline
	write-host "$SRS_AutoConnect" -ForegroundColor green
	$SRS_SERVER_SRS_PORT = (Select-String -Path $SRS_AutoConnect -Pattern "SRSAuto.SERVER_SRS_PORT =" | Out-String).Split('"')[-2]
	write-host "	: SRSAuto.SERVER_SRS_PORT	= "  -nonewline
	write-host "$SRS_SERVER_SRS_PORT" -ForegroundColor green
} else {
	write-host 'Port Configuration from - ' -ForegroundColor white -nonewline
	write-host '$SRS_AutoConnect file path not found (check ddc2_config.ps1)' -ForegroundColor yellow
}
write-host " "	
if(test-path $SRS_Config) {
	write-host "Port Configuration from - " -ForegroundColor white -nonewline
	write-host "$SRS_Config" -ForegroundColor green
	$SRS_SERVER_PORT = ((Select-String -Path $SRS_Config -Pattern "SERVER_PORT" | Out-String).Split('=')[1]).Trim()
	write-host "	: SERVER_PORT			= "  -nonewline
	write-host "$SRS_SERVER_PORT" -ForegroundColor green
	$SRS_LOTATC_EXPORT_PORT = ((Select-String -Path $SRS_Config -Pattern "LOTATC_EXPORT_PORT" | Out-String).Split('=')[1]).Trim()
	write-host "	: LOTATC_EXPORT_PORT		= "  -nonewline
	write-host "$SRS_LOTATC_EXPORT_PORT" -ForegroundColor green
} else {
	write-host 'Port Configuration from - ' -ForegroundColor white -nonewline
	write-host '$SRS_Config file path not found (check ddc2_config.ps1)' -ForegroundColor yellow
}
write-host " "	
if(test-path $DCS_AutoE) {
	write-host "Port Configuration from - " -ForegroundColor white -nonewline
	write-host "$DCS_AutoE" -ForegroundColor green
	$DCS_webgui_port = ((Select-String -Path $DCS_AutoE -Pattern "webgui_port " | Out-String).Split('=')[-1]).Trim()
	write-host "	: webgui_port 			= "  -nonewline
	write-host "$DCS_webgui_port" -ForegroundColor green
} else {
	write-host 'Port Configuration from - ' -ForegroundColor white -nonewline
	write-host '$DCS_AutoE file path not found (check ddc2_config.ps1)' -ForegroundColor yellow
	write-host "	: webgui_port 			= "  -nonewline
	write-host "8088 (DEFAULT)" -ForegroundColor yellow
	}
write-host " "
if(test-path $Lot_Config) {
	write-host "Port Configuration from - " -ForegroundColor white -nonewline
	write-host "$Lot_Config" -ForegroundColor green
	$LotATC_port = ((Select-String -Path $Lot_Config -Pattern " port =" | Out-String).Split(' ')[-1] | Out-String).Split(',')[0]
	write-host "	: port 				= "  -nonewline
	write-host "$LotATC_port" -ForegroundColor green
	$LotATC_srs_transponder_port = ((Select-String -Path $Lot_Config -Pattern " srs_transponder_port =" | Out-String).Split(' ')[-1] | Out-String).Split(',')[0]
	write-host "	: srs_transponder_port 		= " -nonewline
	write-host "$LotATC_srs_transponder_port" -ForegroundColor green
	$LotATC_jsonserver_port = ((Select-String -Path $Lot_Config -Pattern " jsonserver_port =" | Out-String).Split(' ')[-1] | Out-String).Split(',')[0]
	write-host "	: jsonserver_port 		= " -nonewline
	write-host "$LotATC_jsonserver_port" -ForegroundColor green
} else {
	write-host 'Port Configuration from - ' -ForegroundColor white -nonewline
	write-host '$Lot_Config file path not found (check ddc2_config.ps1)' -ForegroundColor yellow
}
write-host " "
if(test-path $TACv_Config) {
	write-host "Port Configuration from - " -ForegroundColor white -nonewline
	write-host "$TACv_Config" -ForegroundColor green
	$TACv_tacviewRealTimeTelemetryPort = (Select-String -Path $TACv_Config -Pattern "tacviewRealTimeTelemetryPort" | Out-String).Split('"')[-2]
	write-host "	: tacviewRealTimeTelemetryPort	= "  -nonewline
	write-host "$TACv_tacviewRealTimeTelemetryPort" -ForegroundColor green
	$TACv_tacviewRemoteControlPort = (Select-String -Path $TACv_Config -Pattern "tacviewRemoteControlPort" | Out-String).Split('"')[-2]
	write-host "	: tacviewRemoteControlPort 	= "  -nonewline
	write-host "$TACv_tacviewRemoteControlPort" -ForegroundColor green
} else {
	write-host 'Port Configuration from - ' -ForegroundColor white -nonewline
	write-host '$TACv_Config file path not found (check ddc2_config.ps1)' -ForegroundColor yellow
}
}
Function Setup-Ports {
Param (
[Parameter(Mandatory=$true)][int]$DCSPort
)
<#

#IMPORTANT NOTICE:::: RDP or VNC Set it up manually

Usage Process:
1. Stop DCS, SRS and any updates happening on your server
2. To get this function available in your Powershell browse to your DDC2 installation folder and execute: . .\ddc2.ps1
3. Make sure your ddc2_config.ps1 file has all the correct folders mapped for this specific instance of DCS and supporting Applications
#If not, fix the issues and then re execute: . .\ddc2.ps1
4. Follow example below.
5. Execute the !refresh command from inside discord and then !start your server or reboot your server

Example: Setup-Ports -DCSPort 8881

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
	write-log "$DCS_Config File not Found"
}

if(test-path $SRS_Config) {
	Set-Port -Search "SERVER_PORT" -Port ($DCSPort + 1) -File $SRS_Config
	Set-Port -Search "LOTATC_EXPORT_PORT" -Port ($DCSPort + 6) -File $SRS_Config
} else {
	write-log "$SRS_Config File not Found"
}

if(test-path $Lot_Config) {
	Set-Port -Search " port =" -Port ($DCSPort + 2) -File $Lot_Config
	Set-Port -Search "srs_transponder_port" -Port ($DCSPort + 6) -File $Lot_Config
	Set-Port -Search "jsonserver_port" -Port ($DCSPort + 8) -File $Lot_Config
} else {
	write-log "$Lot_Config File not Found"
}

if(test-path $TACv_Config) {
	Set-Port -Search "[`"tacviewRealTimeTelemetryPort`"]" -Port ($DCSPort + 3) -File $TACv_Config
	Set-Port -Search "[`"tacviewRemoteControlPort`"]" -Port ($DCSPort + 7) -File $TACv_Config
} else {
	write-log "$TACv_Config File not Found"
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
Function Tail-DDC2 {
gc $DDC2_LogFile -tail 10 -wait
}
########################################################################################################################################################################################################
#SERVER & FIREWALL CONTROL##############################################################################################################################################################################
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
Retrieve/Set the window size and coordinates of a process window.

.DESCRIPTION
Retrieve/Set the size (height,width) and coordinates (x,y) 
of a process window.

.PARAMETER ProcessName
Name of the process to determine the window characteristics. 
(All processes if omitted).

.PARAMETER Id
Id of the process to determine the window characteristics. 

.PARAMETER X
Set the position of the window in pixels from the left.

.PARAMETER Y
Set the position of the window in pixels from the top.

.PARAMETER Width
Set the width of the window.

.PARAMETER Height
Set the height of the window.

.PARAMETER Passthru
Returns the output object of the window.

.NOTES
Name:   Set-Window
Author: Boe Prox
Version History:
    1.0//Boe Prox - 11/24/2015 - Initial build
    1.1//JosefZ   - 19.05.2018 - Treats more process instances 
                                 of supplied process name properly
    1.2//JosefZ   - 21.02.2019 - Parameter Id

.OUTPUTS
None
System.Management.Automation.PSCustomObject
System.Object

.EXAMPLE
Get-Process powershell | Set-Window -X 20 -Y 40 -Passthru -Verbose
VERBOSE: powershell (Id=11140, Handle=132410)

Id          : 11140
ProcessName : powershell
Size        : 1134,781
TopLeft     : 20,40
BottomRight : 1154,821

Description: Set the coordinates on the window for the process PowerShell.exe

.EXAMPLE
$windowArray = Set-Window -Passthru
WARNING: cmd (1096) is minimized! Coordinates will not be accurate.

    PS C:\>$windowArray | Format-Table -AutoSize

  Id ProcessName    Size     TopLeft       BottomRight  
  -- -----------    ----     -------       -----------  
1096 cmd            199,34   -32000,-32000 -31801,-31966
4088 explorer       1280,50  0,974         1280,1024    
6880 powershell     1280,974 0,0           1280,974     

Description: Get the coordinates of all visible windows and save them into the
             $windowArray variable. Then, display them in a table view.

.EXAMPLE
Set-Window -Id $PID -Passthru | Format-Table
​‌‍
  Id ProcessName Size     TopLeft BottomRight
  -- ----------- ----     ------- -----------
7840 pwsh        1024,638 0,0     1024,638

Description: Display the coordinates of the window for the current 
             PowerShell session in a table view.
             

     
#>
[cmdletbinding(DefaultParameterSetName='Name')]
Param (
    [parameter(Mandatory=$False,
        ValueFromPipelineByPropertyName=$True, ParameterSetName='Name')]
    [string]$ProcessName='*',
    [parameter(Mandatory=$True,
        ValueFromPipeline=$False,              ParameterSetName='Id')]
    [int]$Id,
    [int]$X,
    [int]$Y,
    [int]$Width,
    [int]$Height,
    [switch]$Passthru
)
Begin {
    Try { 
        [void][Window]
    } Catch {
    Add-Type @"
        using System;
        using System.Runtime.InteropServices;
        public class Window {
        [DllImport("user32.dll")]
        [return: MarshalAs(UnmanagedType.Bool)]
        public static extern bool GetWindowRect(
            IntPtr hWnd, out RECT lpRect);

        [DllImport("user32.dll")]
        [return: MarshalAs(UnmanagedType.Bool)]
        public extern static bool MoveWindow(  
            IntPtr handle, int x, int y, int width, int height, bool redraw);
              
        [DllImport("user32.dll")] 
        [return: MarshalAs(UnmanagedType.Bool)]
        public static extern bool ShowWindow(
            IntPtr handle, int state);
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
    If ( $PSBoundParameters.ContainsKey('Id') ) {
        $Processes = Get-Process -Id $Id -ErrorAction SilentlyContinue
    } else {
        $Processes = Get-Process -Name "$ProcessName" -ErrorAction SilentlyContinue
    }
    if ( $null -eq $Processes ) {
        If ( $PSBoundParameters['Passthru'] ) { 
            Write-Warning 'No process match criteria specified'
        }
    } else {
        $Processes | ForEach-Object {
            $Handle = $_.MainWindowHandle
            Write-Verbose "$($_.ProcessName) `(Id=$($_.Id), Handle=$Handle`)"
            if ( $Handle -eq [System.IntPtr]::Zero ) { return }
            $Return = [Window]::GetWindowRect($Handle,[ref]$Rectangle)
            If (-NOT $PSBoundParameters.ContainsKey('X')) {
                $X = $Rectangle.Left            
            }
            If (-NOT $PSBoundParameters.ContainsKey('Y')) {
                $Y = $Rectangle.Top
            }
            If (-NOT $PSBoundParameters.ContainsKey('Width')) {
                $Width = $Rectangle.Right - $Rectangle.Left
            }
            If (-NOT $PSBoundParameters.ContainsKey('Height')) {
                $Height = $Rectangle.Bottom - $Rectangle.Top
            }
            If ( $Return ) {
                $Return = [Window]::MoveWindow($Handle, $x, $y, $Width, $Height,$True)
            }
            If ( $PSBoundParameters['Passthru'] ) {
                $Rectangle = New-Object RECT
                $Return = [Window]::GetWindowRect($Handle,[ref]$Rectangle)
                If ( $Return ) {
                    $Height      = $Rectangle.Bottom - $Rectangle.Top
                    $Width       = $Rectangle.Right  - $Rectangle.Left
                    $Size        = New-Object System.Management.Automation.Host.Size        -ArgumentList $Width, $Height
                    $TopLeft     = New-Object System.Management.Automation.Host.Coordinates -ArgumentList $Rectangle.Left , $Rectangle.Top
                    $BottomRight = New-Object System.Management.Automation.Host.Coordinates -ArgumentList $Rectangle.Right, $Rectangle.Bottom
                    If ($Rectangle.Top    -lt 0 -AND 
                        $Rectangle.Bottom -lt 0 -AND
                        $Rectangle.Left   -lt 0 -AND
                        $Rectangle.Right  -lt 0) {
                        Write-Warning "$($_.ProcessName) `($($_.Id)`) is minimized! Coordinates will not be accurate."
                    }
                    $Object = [PSCustomObject]@{
                        Id          = $_.Id
                        ProcessName = $_.ProcessName
                        Size        = $Size
                        TopLeft     = $TopLeft
                        BottomRight = $BottomRight
                    }
                    $Object
                }
            }
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
Param (
[switch]$SRS,
[switch]$DCS
)
$Config = Get-Config
	if($EnableRandomizer) {
		if($DCS) {
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
		if($SRS) {
			if($SRSPassword) {
				$BluPwd = PasswordGenerator	#SRS / Generic Blue Side Pwd
				Set-Pwd -File $SRS_Config -Search "EXTERNAL_AWACS_MODE_BLUE_PASSWORD" -Pwd $BluPwd
				$RedPwd = PasswordGenerator #SRS / Generic Red Side Pwd
				Set-Pwd -File $SRS_Config -Search "EXTERNAL_AWACS_MODE_RED_PASSWORD" -Pwd $RedPwd
			} else {
				$BluPwd = ($Config.srs.EXTERNAL_AWACS_MODE_BLUE_PASSWORD) #SRS / Generic Blue Side Pwd
				$RedPwd = ($Config.srs.EXTERNAL_AWACS_MODE_RED_PASSWORD) #SRS / Generic Red Side Pwd
			}
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
			write-log "Line #$LineNumber Set To - $Line"
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
		write-log "$Search was not found in $File"
		$rtn = $false
	}
#return $rtn
}
Function Set-Priority {
[CmdletBinding()]
param (
[Parameter(Mandatory=$true)][string]$ProcessID,
[ValidateSet("Idle", "BelowNormal", "Normal", "AboveNormal", "HighPriority", "RealTime")]
[Parameter(Mandatory=$true)][string]$Priority
)

switch ($Priority){
"Idle"         {[uint32]$priorityin =    64; break}
"BelowNormal"  {[uint32]$priorityin = 16384; break}
"Normal"       {[uint32]$priorityin =    32; break}
"AboveNormal"  {[uint32]$priorityin = 32768; break}
"HighPriority" {[uint32]$priorityin =   128; break}
"RealTime"     {[uint32]$priorityin =   256; break}
}
#write-host "Get-CimInstance -ClassName Win32_Process -Filter `"ProcessID = $ProcessID`" | Invoke-CimMethod -MethodName SetPriority -Arguments @{Priority = $priorityin}"
$shh = Get-CimInstance -ClassName Win32_Process -Filter "ProcessID = $ProcessID" | Invoke-CimMethod -MethodName SetPriority -Arguments @{Priority = $priorityin}
}
Function Wait-For-Response {
param(
[Parameter(Mandatory=$true)]$Id,
[Parameter(Mandatory=$true)]$LoopString,
[Parameter(Mandatory=$true)]$MaxWait,
[Parameter(Mandatory=$true)]$SleepingTime,
[Parameter(Mandatory=$true)]$Checks
)
<# 
Example: 

Wait-For-Response -Id 1234 -LoopString "START-DCS: DCS Server" -MaxWait 300 -SleepingTime 1 -Checks 5
This will monitor Process with ID 1234, each log write will have $LoopString variable at the start, The timeout for this command is 300 seconds, each loop takes 1 second, and it is looking for 5 consecutive 

#>
$WaitReturn = $false
$Responding = 0
$sleepTime = 0
$contLoop = $true
	while ($contLoop) {
		start-sleep $SleepingTime
		$sleepTime = $sleepTime + $SleepingTime
		$_func_ProcessCheck = Get-Process -Id $Id
		if($_func_ProcessCheck.Responding) {
			$Responding = $Responding + 1
		} else {
			if($Responding -ne 0) {
				write-log -LogData "$LoopString Process stopped Responding, resetting Check to 0" -Silent
				$Responding = 0
			}
		}
		if($Responding -ge $Checks) {
			write-log -LogData "$LoopString, Process Responded $Responding / $Checks consecutive checks" -Silent
			$WaitReturn = $true
			$contLoop = $false
		} else {
			if($Responding -ne 0) {write-log -LogData "$LoopString Process Responding, $Responding / $Checks consecutive checks" -Silent}
		}
		if($sleepTime -ge $MaxWait) {$contLoop = $false}
	}
return $WaitReturn
}
########################################################################################################################################################################################################
#SERVER DATA COLLECTION#################################################################################################################################################################################
########################################################################################################################################################################################################

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
	$Get_ServerInfo | Add-Member -MemberType NoteProperty -Name CommandPrefix -Value $DDC2_CommandPrefix	#Item Pulled from ddc2_config.ps1
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
	$Get_ServerInfo | Add-Member -MemberType NoteProperty -Name AutoStartonUpdate -Value $AutoStartonUpdate	#Item Pulled from ddc2_config.ps1
	$Get_ServerInfo | Add-Member -MemberType NoteProperty -Name AUTOSTART_WAIT -Value $AUTOSTART_DCS_WAIT	#Item Pulled from ddc2_config.ps1
	$Get_ServerInfo | Add-Member -MemberType NoteProperty -Name AutoUpdateDCS -Value $UPDATE_DCS			#Item Pulled from ddc2_config.ps1
	$Get_ServerInfo | Add-Member -MemberType NoteProperty -Name AutoUpdateSRS -Value $UPDATE_SRS			#Item Pulled from ddc2_config.ps1
	$Get_ServerInfo | Add-Member -MemberType NoteProperty -Name AutoUpdateLoT -Value $UPDATE_LoT			#Item Pulled from ddc2_config.ps1
	$Get_ServerInfo | Add-Member -MemberType NoteProperty -Name AutoUpdateMoose -Value $UPDATE_MOOSE		#Item Pulled from ddc2_config.ps1
	$Get_ServerInfo | Add-Member -MemberType NoteProperty -Name DesktopPosition -Value $DesktopLocation		#Item Pulled from ddc2_config.ps1
	$Get_ServerInfo | Add-Member -MemberType NoteProperty -Name DCS_STARTDELAY -Value $DCS_SERVERSTART		#Item Pulled from ddc2_config.ps1
	$Get_ServerInfo | Add-Member -MemberType NoteProperty -Name DDC2_MASTER -Value $DDC2_MASTER				#Item Pulled from ddc2_config.ps1
	$Get_ServerInfo | Add-Member -MemberType NoteProperty -Name LoTBETA -Value $LoTBETA						#Item Pulled from ddc2_config.ps1
	$Get_ServerInfo | Add-Member -MemberType NoteProperty -Name LotBuild -Value $Lot_Release				#Item Pulled from ddc2_config.ps1
	$Get_ServerInfo | Add-Member -MemberType NoteProperty -Name SRSBETA -Value $SRSBETA						#Item Pulled from ddc2_config.ps1	
	$Get_ServerInfo | Add-Member -MemberType NoteProperty -Name SRSBuild -Value $SRS_Release				#Item Pulled from ddc2_config.ps1
	$Get_ServerInfo | Add-Member -MemberType NoteProperty -Name DCSBETA -Value $DCSBETA						#Item Pulled from ddc2_config.ps1	
	$Get_ServerInfo | Add-Member -MemberType NoteProperty -Name DCSBuild -Value $DCS_Release				#Item Pulled from ddc2_config.ps1	

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
$check = 0
$contLoop = $true
$DCS = $null
while ($contLoop) {
	$DCS = Get-Process -ErrorAction SilentlyContinue | where {$_.MainWindowTitle -eq $DCS_WindowTitle -and $_.Path -eq $dcsEXE} | select $ProcessSelection
	#$DCS = Get-Process -ErrorAction SilentlyContinue | where {$_.CommandLine -match "-w $DCS_WindowTitle" -and $_.Path -eq $dcsEXE} | select $ProcessSelection
	if($DCS.count -gt 0) {
		if($DCS.Responding) {
			#write-log -LogData "DCS is Responding" -Silent
			$contLoop = $false
		} else {
			$check = $check + 1
			write-log -LogData "DCS Failed to respond $check / 10 times" -Silent
		}
	} else {
		#write-log -LogData "DCS isn't Running" -Silent
		$contLoop = $false
	}
if ($check -ge 10) {
	write-log -LogData "DCS is going to show as Not Responding" -Silent
	$contLoop = $false}
Start-sleep 2;
}
if(test-path $dcsEXE) {
	$DCS_Version = (Get-ChildItem $dcsEXE).VersionInfo.ProductVersion
	$DCS_INSTALLED = $true
} else {
	$DCS_Version = 'NOT INSTALLED'
	$DCS_INSTALLED = $false
}
if(test-path $Lot_Entry) {
	$LotATC_Version = (Select-String -Path $Lot_Entry -Pattern "version" | Out-String).Split('"')[-2]
	$LotATC_INSTALLED = $true
} else {
	$LotATC_Version = 'NOT INSTALLED'
	$LotATC_INSTALLED = $false
	}
if($DCS.count -eq 0) {
	$DCS = New-Object -TypeName psobject 
	$DCS | Add-Member -MemberType NoteProperty -Name Name -Value "DCS"
	$DCS | Add-Member -MemberType NoteProperty -Name Version -Value $DCS_Version
	$DCS | Add-Member -MemberType NoteProperty -Name Installed -Value $DCS_INSTALLED
	$DCS | Add-Member -MemberType NoteProperty -Name Lot_Version -Value $LotATC_Version
	$DCS | Add-Member -MemberType NoteProperty -Name Lot_Installed -Value $LotATC_INSTALLED
	$DCS | Add-Member -MemberType NoteProperty -Name IsActive -Value $false
	$DCS | Add-Member -MemberType NoteProperty -Name Offline -Value $true
} else {
	$DCS_Additional = Get-CimInstance -ClassName Win32_PerfFormattedData_PerfProc_Process | where {$_.IDProcess -eq ($DCS.Id)} | Select-Object $properties
	$DCS | Add-Member -MemberType NoteProperty -Name Name -Value "DCS"
	$DCS | Add-Member -MemberType NoteProperty -Name Version -Value $DCS_Version
	$DCS | Add-Member -MemberType NoteProperty -Name Installed -Value $DCS_INSTALLED
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
$SRS = $null
$SRS = Get-Process -ErrorAction SilentlyContinue | where {$_.CommandLine -match "-cfg=`"$srsCONFIGFile`"" -and $_.Path -eq $srsEXE} | select $ProcessSelection
$SRS | Add-Member -MemberType NoteProperty -Name Version -Value $LotATC_Version
$SRS | Add-Member -MemberType NoteProperty -Name Installed -Value $LotATC_INSTALLED
if(test-path $srsEXE) {
	$SRS_Version = (Get-ChildItem $srsEXE).VersionInfo.ProductVersion
	$SRS_INSTALLED = $true
} else {
	$SRS_Version = 'NOT INSTALLED'
	$SRS_INSTALLED = $false
	}
if($SRS.count -eq 0) {
	$SRS = New-Object -TypeName psobject 
	$SRS | Add-Member -MemberType NoteProperty -Name Name -Value "SRS"
	$SRS | Add-Member -MemberType NoteProperty -Name Version -Value $SRS_Version -Force
	$SRS | Add-Member -MemberType NoteProperty -Name Installed -Value $SRS_INSTALLED -Force	
	$SRS | Add-Member -MemberType NoteProperty -Name IsActive -Value $false
	$SRS | Add-Member -MemberType NoteProperty -Name Offline -Value $true
	$SRS | Add-Member -MemberType NoteProperty -Name ClientsEnabled -Value $false
	}
else {
	$SRS_Additional = Get-CimInstance -ClassName Win32_PerfFormattedData_PerfProc_Process | where {$_.IDProcess -eq ($SRS.Id)} | Select-Object $properties
	$SRS | Add-Member -MemberType NoteProperty -Name Name -Value "SRS"
	$SRS | Add-Member -MemberType NoteProperty -Name Version -Value $SRS_Version -Force
	$SRS | Add-Member -MemberType NoteProperty -Name Installed -Value $SRS_INSTALLED -Force		
	$SRS | Add-Member -MemberType NoteProperty -Name IsActive -Value $true
	$SRS | Add-Member -MemberType NoteProperty -Name Offline -Value $false
	if($SRS.Responding) {
		$SRS | Add-Member -MemberType NoteProperty -Name Status -Value "OK"
	} else {
		$SRS | Add-Member -MemberType NoteProperty -Name Status -Value "Not Responding"
	}
	$SRS | add-Member -MemberType NoteProperty -Name Ports -Value (StringOutPorts -Id $SRS.id)
	$SRS_RT = ((get-date) - (get-date $SRS.StartTime))
	$SRS | Add-Member -MemberType NoteProperty -Name RunTime -Value $SRS_RT
	$SRS | Add-Member -MemberType NoteProperty -Name CPULoad -Value ($SRS_Additional.CPU)
	$SRS | Add-Member -MemberType NoteProperty -Name Threads -Value ($SRS_Additional.Threads)
	$SRS | Add-Member -MemberType NoteProperty -Name Handles -Value ($SRS_Additional.Handles)
	$SRS.StartTime = ((get-date $SRS.StartTime).DateTime)
	if(test-path $SRS_Clients) {
		$SRS | Add-Member -MemberType NoteProperty -Name ClientsEnabled -Value $true
		$ClientTable = ((gc $SRS_Clients) | ConvertFrom-Json -Depth 100).Clients
		if ($ClientTable.Count -ne 0) {
			$SRS | Add-Member -MemberType NoteProperty -Name ClientTable -Value $ClientTable
			$SRS | Add-Member -MemberType NoteProperty -Name ClientsPresent -Value $true
		} else {
			$SRS | Add-Member -MemberType NoteProperty -Name ClientsPresent -Value $false
		}
		$SRS | Add-Member -MemberType NoteProperty -Name ClientCount -Value ($ClientTable.Count)
		} else {
			$SRS | Add-Member -MemberType NoteProperty -Name ClientsEnabled -Value $false
		}
	}
#START DCS UPDATE
$DCS_Upd = Get-Process -ErrorAction SilentlyContinue | where {$_.Path -eq $DCS_Updater}| Select-Object $ProcessSelection
if($DCS_Upd.count -eq 0) {
	$DCS_Upd = New-Object -TypeName psobject 
	$DCS_Upd | Add-Member -MemberType NoteProperty -Name Name -Value "DCS Updater"
	$DCS_Upd | Add-Member -MemberType NoteProperty -Name IsActive -Value $false
	$DCS_Upd | Add-Member -MemberType NoteProperty -Name Offline -Value $true
	}
else {
	$DCS_Upd = ($DCS_Upd | Sort-Object -Property Ticks -Descending)[0]
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
$SRS_Upd = Get-Process -ErrorAction SilentlyContinue | where {$_.Path -eq $SRS_Updater}| Select-Object $ProcessSelection
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
$LoT_Upd = Get-Process -ErrorAction SilentlyContinue | where {$_.Path -eq $LoT_Updater}| Select-Object $ProcessSelection
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
$SRS = Get-Process -ErrorAction SilentlyContinue | where {$_.CommandLine -match "-cfg=`"$srsCONFIGFile`"" -and $_.Path -eq $srsEXE} | select $ProcessSelection

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
	if(test-path $SRS_Clients) {
		$SRS | Add-Member -MemberType NoteProperty -Name ClientsEnabled -Value $true
		$SRS | Add-Member -MemberType NoteProperty -Name ClientTable -Value ((gc $SRS_Clients) | ConvertFrom-Json -Depth 100)
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
	$Process_UpdateDCS = Get-Process -Name DCS_updater -ErrorAction SilentlyContinue | where {$_.Path -eq $DCS_updater}
	$contLoop = $true
	$checkLoop = 0
	$working = 0
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
Function Find-Link {
<#
This function will get a websites data and output a single link for download

e.g. Find-Link -URI "https://github.com/FlightControl-Master/MOOSE/releases/latest" -Search '/moose_.lua'

Will return the first value it finds only
#>
Param (
[Parameter(Mandatory=$true)]$URI,
[Parameter(Mandatory=$true)]$Search
)
$webpage = Invoke-WebRequest -Uri $URI
$URISplit = $URI.Split('/')
$rootDomain = $URISplit[0]+'//'+$URISplit[2]  #Gets Website root for any HREF
#$LinkPath = (($webpage.Links.href) -match '/Moose_.lua')[0]
$LinkPath = (($webpage.Links.href) -match $Search)[0]
if($LinkPath.Count -ne 0) {$rtn = $rootDomain + $LinkPath} else {$rtn = $false}
return $rtn
}
Function Update-MOOSE {
write-log -LogData "Starting MOOSE Update Process..." -Silent
	if(test-path $MOOSE_Path) {
	$Go4MOOSEUpdate = $false
	$WebClient = New-Object System.Net.WebClient
	$DLFile = "new_moose.lua"
	$DLPath = "$DDC2DIR\Downloads\MOOSE.LUA"
	$MOOSE_ArchiveROOT = "$DDC2DIR\Archive\MOOSE.LUA"
	$MOOSE_Leaf = (split-path $MOOSE_Path -leaf)
	#$DwnLd = Find-Link -URI "https://github.com/FlightControl-Master/MOOSE_INCLUDE/tree/master/Moose_Include_Static" -Search '/moose_.lua'
	#$DwnLd = Find-Link -URI "https://github.com/FlightControl-Master/MOOSE/releases/latest" -Search '/moose_.lua'
	$DwnLd = "https://github.com/FlightControl-Master/MOOSE_INCLUDE/raw/master/Moose_Include_Static/Moose_.lua"
	write-log -LogData "Preparing to download $DwnLd" -silent
		if(test-path $DLPath) {
			write-log -LogData "Downloading..." -silent
			$shhh = $WebClient.DownloadFile("$DwnLd","$DLPath\$DLFile")
		} else {
			write-log -LogData "$DLPath does not exist, creating folder" -silent
			$shhh = New-Item -Type Directory -Path $DLPath -Force
			if(test-path $DLPath) {
				write-log -LogData "Directory Created" -silent
				write-log -LogData "Downloading..." -silent
				$shhh = $WebClient.DownloadFile("$DwnLd","$DLPath\$DLFile")
			} else {
				write-log -LogData "ERROR!!! - Directory was not created check paths in ddc2_config.ps1 and file permissions" -silent
			}
		}
		if(test-path "$DLPath\$DLFile") {
			write-log -LogData "Download Complete" -silent
			$NewFileHASH = (Get-FileHash "$DLPath\$DLFile").Hash
			$CurrentFileHASH = (Get-FileHash "$MOOSE_Path").Hash
			if($NewFileHASH -eq $CurrentFileHASH) {
				write-log -LogData "Moose.lua is already the latest version, no update required..." -silent
				$Go4MOOSEUpdate = $false
			} else {
				$Go4MOOSEUpdate = $true
			}
		} else {
			$Go4MOOSEUpdate = $false
			write-log -LogData "Update-MOOSE: Download Failed, please check internet connection and DNS" -silent
		}
		if (-not (test-path $MOOSE_ArchiveROOT)) {
			write-log -LogData "$MOOSE_ArchiveROOT does not exist, creating folder" -silent			
			$shhh = New-Item -Type Directory -Path $MOOSE_ArchiveROOT -Force
			if(test-path $MOOSE_ArchiveROOT) {
				write-log -LogData "Directory Created" -silent
			} else {
				$Go4MOOSEUpdate = $false
				write-log -LogData "ERROR!!! - Can't create directory: was not created check MOOSE_path in ddc2_config.ps1 and file permissions for $MOOSE_ArchiveROOT" -silent
			}
		}
		if($Go4MOOSEUpdate) {
			write-log -LogData "Moose.lua is out of date, updating..." -silent
			[string]$TimeStr = get-date -Format "yyyy-MM-dd--HHmmss"
			$ArchiveFilePath = $MOOSE_ArchiveROOT+"\"+$TimeStr+"_"+$MOOSE_Leaf
			$shhh = Copy-Item "$MOOSE_Path" $ArchiveFilePath -Force
			if(test-path $ArchiveFilePath) {
				$ArchivedFileHASH = (Get-FileHash $ArchiveFilePath).Hash
				if($ArchivedFileHASH -eq $CurrentFileHASH) {
					write-log -LogData "Archiving Complete: $ArchiveFilePath" -silent
					$shhh = Copy-Item "$DLPath\$DLFile" "$MOOSE_Path" -Force
					$CurrentFileHASH = (Get-FileHash "$MOOSE_Path").Hash
						if($NewFileHASH -eq $CurrentFileHASH) {
							write-log -LogData "Update-MOOSE: MOOSE Update Complete" -silent
						} else {
							write-log -LogData "Update-MOOSE: New File hasg mismatch compared to downloaded file, update aborted..." -silent
						}
				} else {
					write-log -LogData "Archiving Failed due to file hash mismatch, update aborted..." -silent
				}			
			} else {
				write-log -LogData "Update-MOOSE: was unable to backup a copy of your current Moose.lua, update aborted..." -silent
			}
		}
	} else {
		write-log -LogData "Update-MOOSE: $MOOSE_Path not found, update aborted..." -silent
	}
}
Function Update-Server {
$DoUpdate = $true
$ServerStatus = $null
write-log -LogData "Update-Server: STARTED" -Silent
$DCS = Get-Process -ErrorAction SilentlyContinue | where {$_.MainWindowTitle -eq $DCS_WindowTitle -and $_.Path -eq $dcsEXE} | select $ProcessSelection
#$DCS = Get-Process -ErrorAction SilentlyContinue | where {$_.CommandLine -match "-w $DCS_WindowTitle" -and $_.Path -eq $dcsEXE} | select $ProcessSelection
	if($DCS.count -ne 0) {
	$DoUpdate = $false
	write-log -LogData "Update-Server: DCS is running, Update Aborted!" -Silent
	}
$SRS = Get-Process -ErrorAction SilentlyContinue | where {$_.Path -eq $srsEXE}| Select-Object $ProcessSelection
	if($SRS.count -ne 0) {
	$DoUpdate = $false
	write-log -LogData "Update-Server: SRS is running, Update Aborted!" -Silent
	}
$DCS_Upd = Get-Process -ErrorAction SilentlyContinue | where {$_.Path -eq $DCS_Updater}| Select-Object $ProcessSelection
	if($DCS_Upd.count -ne 0) {
	$DoUpdate = $false
	write-log -LogData "Update-Server: DCS Updater is already running, Update Aborted!" -Silent
	}
$SRS_Upd = Get-Process -ErrorAction SilentlyContinue | where {$_.Path -eq $SRS_Updater}| Select-Object $ProcessSelection
	if($SRS_Upd.count -ne 0) {
	$DoUpdate = $false
	write-log -LogData "Update-Server: SRS Updater is already running, Update Aborted!" -Silent
	}
$LoT_Upd = Get-Process -ErrorAction SilentlyContinue | where {$_.Path -eq $LoT_Updater}| Select-Object $ProcessSelection
	if($LoT_Upd.count -ne 0) {
	$DoUpdate = $false
	write-log -LogData "Update-Server: LotATC Updater is already running, Update Aborted!" -Silent
	}
	if($DoUpdate) {
	$PowerShellEXE = "C:\Program Files\PowerShell\7\pwsh.exe"
	$UpdateARGS = "-WindowStyle Minimized -ExecutionPolicy Bypass -Command `"& $DDC2DIR\DDC2.ps1 -DoUpdate -DDC2DIR $DDC2DIR`""
	write-log "COMMAND BEING EXECUTED BY Update-Server: start-process $PowerShellEXE -ArgumentList $UpdateARGS -WorkingDirectory $DDC2DIR" -silent
	start-process $PowerShellEXE -ArgumentList $UpdateARGS -WorkingDirectory $DDC2DIR
	}
write-log -LogData "Update-Server: ENDED" -Silent
}
Function Do-Update {
	write-log -LogData "UPDATE DCS: STARTED" -Silent
	#STOP DCS
	write-log -LogData "UPDATE DCS: Call Stop-DCS" -Silent
	Stop-DCS
	if ($UPDATE_MOOSE) {
		write-log -LogData "UPDATE DCS: Call Update MOOSE" -Silent
		Update-MOOSE
		}
	else {
		write-log -LogData "UPDATE DCS: MOOSE autoupdate skipped due to UPDATE_MOOSE variable being set to false." -Silent
		}
	if ($UPDATE_LoT) {
		write-log -LogData "UPDATE DCS: Call Update LotATC" -Silent
		Update-LotATC
		}
	else {
		write-log -LogData "UPDATE DCS: LotATC autoupdate skipped due to UPDATE_LoT variable being set to false." -Silent
		}
	
	if ($UPDATE_SRS) {
		write-log -LogData "UPDATE DCS: Call Update SRS Update" -Silent
		Update-SRS
		}
	else {
		write-log -LogData "UPDATE DCS: SRS autoupdate skipped due to UPDATE_SRS variable being set to false." -Silent
		}
	if ($UPDATE_DCS) {	
		write-log -LogData "UPDATE DCS: Call Update DCS" -Silent
		Update-DCS
		}
	else {
		write-log -LogData "UPDATE DCS: DCS autoupdate skipped due to UPDATE_DCS variable being set to false." -Silent
		}
	
	if ($AutoStartonUpdate) {
		write-log -LogData "UPDATE DCS: Call Restart-DCS" -Silent
		Start-Server -SRS -DCS
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
	Stop -Game
write-log -LogData "Restart-DCS: Calling Start-Server" -Silent	
	Start-Server -SRS -DCS
write-log -LogData "Restart-DCS: ENDED" -Silent
}
Function DDC2-AutoStart {
<#
Designed as a global start command that then calls other start functions

Checks if this instance of the server is the MASTER for this server and then acts accordingly depending on the startup variables set in ddc2_config.ps1

Variables required

$DDC2_MASTER	- This boolean variable says if the update functions are to be run or skipped on this instance
$AUTOSTART_DCS_WAIT 	- This is how long this particular instance will wait until it attempts an initialization after the server starts (note, if you have more than 2 instances running on a server, DDC2 will start at the same time unless this number is changed.
e.g.
Instance1 - $DDC2_MASTER = $True #this means the Instance wait is ignored as this is the master server

Instance2 - $DDC2_MASTER = $False #This defines this instance as a subordinate server
Instance2 - $AUTOSTART_DCS_WAIT = 60 #This tells Instance2 to autostart DCS 1 minute after no update processes have been detected 

Instance3 - $DDC2_MASTER = $False #This defines this instance as a subordinate server
Instance3 - $AUTOSTART_DCS_WAIT = 120 #This tells Instance3 to autostart DCS 2 minute after no update processes have been detected 

If ! $DDC2_MASTER then {Server will check if there are updates currently taking place and wait. Wait time will be 30 seconds then another check will take place. no update process has been detected, d

#>
write-log -LogData "DDC2-AutoStart: STARTED" -Silent
	if($DDC2_MASTER) {
		write-log -LogData "DDC2-AutoStart: $ServerID is the Master Server Instance" -Silent
		if($AUTOSTART_UPDATE) {
			write-log -LogData "DDC2-AutoStart: $ServerID Initiating Update-Server" -Silent
			Update-Server
		} else {
			if($AUTOSTART_DCS) {
				write-log -LogData "DDC2-AutoStart: $ServerID Initiating Start-Server" -Silent
				Start-Server -SRS -DCS
			}
		}
	} else {
		$contLoop = $true
		$AutoStartLoopCount = 0
		$Updating = $false
		write-log -LogData "DDC2-AutoStart: $ServerID is a Subordinate Server Instance" -Silent
		write-log -LogData "DDC2-AutoStart: $ServerID Initiating wait for Master Server" -Silent
		while ($contLoop) {
			start-sleep $AUTOSTART_DCS_WAIT
			$DCS_Upd = Get-Process -ErrorAction SilentlyContinue | where {$_.Path -eq $DCS_Updater}| Select-Object $ProcessSelection
			$SRS_Upd = Get-Process -ErrorAction SilentlyContinue | where {$_.Path -eq $SRS_Updater}| Select-Object $ProcessSelection
			$LoT_Upd = Get-Process -ErrorAction SilentlyContinue | where {$_.Path -eq $LoT_Updater}| Select-Object $ProcessSelection
			if(($DCS_Upd.count -ne 0) -or ($SRS_Upd.count -ne 0) -or ($LoT_Upd.count -ne 0)) {$Updating = $true}
			if(-not $Updating) {$contLoop = $FALSE}
			$AutoStartLoopCount = $AutoStartLoopCount + 1
			write-log -LogData "DDC2-AutoStart: $ServerID still waiting for Master Server updating to complete, Loop# $AutoStartLoopCount" -Silent
		}
		write-log -LogData "DDC2-AutoStart: $ServerID has detected the Master Server has completed all updates." -Silent
		if($AUTOSTART_DCS) {
			write-log -LogData "DDC2-AutoStart: $ServerID Initiating Start-Server" -Silent
			Start-Server -SRS -DCS
		}
	}
write-log -LogData "DDC2-AutoStart: ENDED" -Silent
}
Function Start-SRS {
write-log -LogData "Start-SRS: STARTED" -Silent
$_func_SRS_Upd = Get-Process -ErrorAction SilentlyContinue | where {$_.Path -eq $SRS_Updater}| Select-Object $ProcessSelection
	if ($_func_SRS_Upd.count -eq 0) {
		if($EnableRandomizer) {PwdRandomizer -SRS}
		write-log -LogData "Start-SRS: Starting SRS" -Silent
		$shh = start-process $srsexe -ArgumentList $SRSargs -WorkingDirectory $srsdir
		start-sleep 0.5
		$_func_StartSRS = Get-Process -ErrorAction SilentlyContinue | where {$_.CommandLine -match "-cfg=`"$srsCONFIGFile`"" -and $_.Path -eq $srsEXE} | select $ProcessSelection
		start-sleep 0.5
		if($_func_StartSRS.count -ne 0) {
			$_func_Check = Wait-For-Response -id $_func_StartSRS.ID -LoopString "START-SRS: SRS Server" -MaxWait 10 -SleepingTime 0.5 -Checks 3
			if($_func_Check) {
				write-log -LogData "Start-SRS: SRS has been Started" -Silent
				write-log -LogData "Start-SRS: Setting Priority" -Silent
				Set-Priority -ProcessID $_func_StartSRS.ID -Priority $SERVER_PRIORITY
				Set-Position -Id $_func_StartSRS.ID -SRS
			} else {write-log -LogData "Start-SRS: ERROR!! SRS did not start, please check the SRS log file for more information" -Silent}
		} else {write-log -LogData "Start-SRS: ERROR!! SRS did not start, please check the SRS log file for more information" -Silent}
	} else {write-log -LogData "Start-SRS: SRS Update process detected, Start-SRS Aborted!!" -Silent}
write-log -LogData "Start-SRS: ENDED" -Silent
}
Function Start-DCS {
write-log -LogData "Start-DCS: STARTED" -Silent
$_func_DCS_Upd = Get-Process -ErrorAction SilentlyContinue | where {$_.Path -eq $DCS_Updater}| Select-Object $ProcessSelection
$_func_LoT_Upd = Get-Process -ErrorAction SilentlyContinue | where {$_.Path -eq $LoT_Updater}| Select-Object $ProcessSelection
if(($_func_DCS_Upd.count -eq 0) -and ($_func_LoT_Upd.count -eq 0)) {
	if($EnableRandomizer) {PwdRandomizer -DCS}
	write-log -LogData "Start-DCS: Starting DCS" -Silent
	$shh = start-process $dcsexe -ArgumentList $dcsargs -WorkingDirectory $dcsdir
	start-sleep 5
	$_func_StartDCS = Get-Process -ErrorAction SilentlyContinue | where {$_.MainWindowTitle -eq $DCS_WindowTitle -and $_.Path -eq $dcsEXE} | select $ProcessSelection
	$_func_IDCount = 0
	while(($_func_StartDCS.count -eq 0) -or ($_func_IDCount -ge $DCS_SERVERSTART))  {
	start-sleep 1
	$_func_IDCount = $_func_IDCount + 1
	$_func_StartDCS = Get-Process -ErrorAction SilentlyContinue | where {$_.MainWindowTitle -eq $DCS_WindowTitle -and $_.Path -eq $dcsEXE} | select $ProcessSelection
	}
	write-log -LogData "Start-DCS: Finally got a ProcessID after $_func_IDCount seconds" -Silent
	if($_func_StartDCS.count -ne 0) {
			$_func_Check = Wait-For-Response -id $_func_StartDCS.ID -LoopString "START-DCS: DCS Server" -MaxWait $DCS_SERVERSTART -SleepingTime 1 -Checks 5
			if($_func_Check) {
				write-log -LogData "Start-DCS: DCS has been Started" -Silent
				write-log -LogData "Start-DCS: Setting Priority" -Silent
				Set-Priority -ProcessID $_func_StartDCS.ID -Priority $SERVER_PRIORITY
				Set-Position -Id $_func_StartDCS.ID -DCS
			} else {write-log -LogData "Start-DCS: ERROR!! DCS did not start, please check the DCS log file for more information" -Silent}
		} else {write-log -LogData "Start-DCS: ERROR!! DCS did not start, please check the DCS log file for more information" -Silent}
	} else {write-log -LogData "Start-DCS: DCS Update process detected, Start-DCS Aborted!!" -Silent}
write-log -LogData "Start-DCS: ENDED" -Silent
}
Function Start-Server {
Param (
[switch]$SRS,
[switch]$DCS
)
write-log -LogData "Start-Server: STARTED" -Silent
if($SRS) {
		$_func_SRS = Get-Process -ErrorAction SilentlyContinue | where {$_.CommandLine -match "-cfg=`"$srsCONFIGFile`"" -and $_.Path -eq $srsEXE} | select $ProcessSelection
		if($_func_SRS.count -eq 0) {
			write-log -LogData "Start-Server: CALLING Start-SRS" -Silent
			Start-SRS			
		} else {write-log -LogData "Start-Server: SRS already running, Start-SRS Aborted" -Silent}
} else {write-log -LogData "Start-Server: DCS Startup Not Requested, Start-DCS Aborted" -Silent}
################################################################################################
if($DCS) {
		$_func_DCS = Get-Process -ErrorAction SilentlyContinue | where {$_.MainWindowTitle -eq $DCS_WindowTitle -and $_.Path -eq $dcsEXE} | select $ProcessSelection
		if($_func_DCS.count -eq 0) {
			write-log -LogData "Start-Server: CALLING Start-DCS" -Silent
			Start-DCS			
		} else {write-log -LogData "Start-Server: DCS already running, Start-DCS Aborted" -Silent}
} else {write-log -LogData "Start-Server: DCS Startup Not Requested, Start-DCS Aborted" -Silent}
write-log -LogData "Start-Server: ENDED" -Silent
}
Function Stop {
param(
	[switch]$All,
	[switch]$DCS,
	[switch]$SRS,
	[switch]$Game,
	[switch]$Update
)
	if($all -or $DCS -or $Game) {Stop-DCS}
	if($all -or $SRS -or $Game) {Stop-SRS}
	if($all -or $Update) {Stop-Update}
}
Function Stop-DCS {
	write-log -LogData "Stop-DCS: STARTED" -Silent
	$DCS = Get-Process -ErrorAction SilentlyContinue | where {$_.MainWindowTitle -eq $DCS_WindowTitle -and $_.Path -eq $dcsEXE} | select $ProcessSelection
	#$DCS = Get-Process -ErrorAction SilentlyContinue | where {$_.CommandLine -match "-w $DCS_WindowTitle" -and $_.Path -eq $dcsEXE} | select $ProcessSelection
	write-log -LogData 'FORCE Stopping DCS...' -Silent
	$DCS | stop-process -Force
	write-log -LogData "Stop-DCS: ENDED" -Silent
}
Function Stop-SRS {
	write-log -LogData "Stop-SRS: STARTED" -Silent
	$SRS = Get-Process -ErrorAction SilentlyContinue | where {$_.CommandLine -match "-cfg=`"$srsCONFIGFile`"" -and $_.Path -eq $srsEXE} | select $ProcessSelection
	write-log -LogData 'FORCE Stopping SRS...' -Silent
	$SRS | stop-process -Force
	write-log -LogData "Stop-SRS: ENDED" -Silent
}
Function Stop-Update {
	write-log -LogData "Stop-Update: STARTED" -Silent
	$DCS_Upd = Get-Process -ErrorAction SilentlyContinue | where {$_.Path -eq $DCS_Updater}| Select-Object $ProcessSelection
	$SRS_Upd = Get-Process -ErrorAction SilentlyContinue | where {$_.Path -eq $SRS_Updater}| Select-Object $ProcessSelection
	$LoT_Upd = Get-Process -ErrorAction SilentlyContinue | where {$_.Path -eq $LoT_Updater}| Select-Object $ProcessSelection
	write-log -LogData 'FORCE Stopping DCS Updater...' -Silent
	$DCS_Upd | stop-process -Force
	write-log -LogData 'FORCE Stopping SRS Updater...' -Silent
	$SRS_Upd | stop-process -Force
	write-log -LogData 'FORCE Stopping LotATC Updater...' -Silent
	$LoT_Upd | stop-process -Force
	write-log -LogData "Stop-Update: ENDED" -Silent
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
if ($AutoStart) {
	DDC2-AutoStart
	$DCSreturn = get-status
	}
if ($Start) {
	Start-Server -SRS -DCS
	$DCSreturn = get-status
	}
if ($Restart) {
	Restart-DCS
	$DCSreturn = get-status
	}
if ($Stop) {
	#This is where the different stop commands are run depending on the switches recieved from Node-Red, Default action is set in the Node-Red Stop Function Pre-Processing Node.
	if($StopAll) {stop -All}
	if($StopGame) {stop -Game} #Default
	if($StopDCS) {stop -DCS}
	if($StopSRS) {stop -SRS}
	if($StopUpdate) {stop -Update}
	$DCSreturn = get-status
	}
if ($Update) {
	Update-Server
	$DCSreturn = get-status
	}
if ($DoUpdate) {
	$DCS = Get-Process -ErrorAction SilentlyContinue | where {$_.Path -eq $dcsEXE} | select $ProcessSelection
	if($DCS.Count -eq 0) {Do-Update}
	$DCSreturn = get-status
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
if ($DCSreturnJSON -ne "null") {return $DCSreturnJSON}
