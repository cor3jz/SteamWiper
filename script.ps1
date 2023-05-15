$Version = 'beta'
$Host.UI.RawUI.MaxPhysicalWindowSize.Width=550
$Host.UI.RawUI.MaxPhysicalWindowSize.Height=300
$Host.UI.RawUI.WindowTitle="SteamWiper" + ' - ' + $Version
$Host.UI.Write('Выполняется очистка Steam...')

#Log Config
$LogFile = $env:windir+'\'+'steamwiper.log'
if (Test-Path -Path "$env:windir\steamwiper.log" -PathType Leaf) {
    Remove-Item -Path "$env:windir\steamwiper.log"
}
function WriteLog
{
	Param ([string]$LogString)
	$Timestamp = (Get-Date).toString("[dd/MM/yyyy HH:mm:ss]")
	$LogMessage = "$Timestamp $LogString"
	Add-Content $LogFile -value $LogMessage
}

WriteLog "SteamWiper started"

Get-Process -name "steam" -ErrorAction SilentlyContinue | ? { $_.SI -eq (Get-Process -PID $PID).SessionId } | Stop-Process -Force | Add-Content $Logfile
Stop-Service "Steam Client Service" -Force -ErrorAction SilentlyContinue
WriteLog "Steam has been successfully stopped"
Start-Sleep -Seconds 1

#Steam Cleanup Folders
$InstallPath = '' #Папка установки Steam
$LibraryFolders = @() #Папки библиотек Steam
$SteamFolders = @(
	"appcache",
	"config",
	"dumps",
	"logs",
	"userdata"
) #Системные папки Steam
$LibrarySubFolders = @(
	"downloading",
	"shadercache",
	"sourcemods",
	"temp",
	"workshop"
) #Подкаталоги библиотек Steam

if ((Test-Path 'HKLM:\SOFTWARE\Wow6432Node\Valve\Steam') -eq $true) {
    $InstallPath = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Wow6432Node\Valve\Steam').InstallPath
} else {
	WriteLog "Не удалось найти Steam на этом компьютере"
}

#Очистка системных папок Steam
foreach ($SteamFolder in $SteamFolders) {
	$SteamCleanupFolder = "$InstallPath/$SteamFolder"

	if ((Test-Path "$SteamCleanupFolder") -eq '') {
        WriteLog "Каталог $SteamCleanupFolder не существует"
        continue
    }

	Get-ChildItem -Path $SteamCleanupFolder | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue | Add-Content $LogFile
	WriteLog "$SteamCleanupFolder очищен"
}
WriteLog "Очистка системных папок Steam завершена"

#Очистка папок библиотеки Steam
if (Test-Path "$InstallPath\SteamApps\libraryfolders.vdf")
{
	$filedata = Get-Content "$InstallPath\SteamApps\libraryfolders.vdf"
	
	foreach ($line in $filedata)
	{
		if ($line -match '"path".*"(.*)"')
		{
			$LibraryFolders += "$($Matches[1])\SteamApps" -replace '\\\\', '\'
		}
	}
}

function Get-SteamGame
{
	param ($Id, $Name)
	
	foreach ($lib in $LibraryFolders)
	{
		$manifests = Get-ChildItem -Path $lib -File -Filter '*.acf'
		
		foreach ($man in $manifests)
		{
			$filedata = Get-Content $man.FullName
			
			$obj = [pscustomobject] @{
				ID		   = $null
				InstallDir = $null
			}
			
			foreach ($line in $filedata)
			{
				if ($line -match '"appId".*"([0-9]{1,20})"')
				{
					$obj.ID = $Matches[1]
				}
				
				if ($line -match '"installdir".*"(.*)"')
				{
					$obj.InstallDir = "$lib\common\$($Matches[1])"
				}
			}
			if ($Id -ne $null) { if ($Id -ne $obj.ID) { continue } }
			$obj
		}
	}
}

#CS:GO Workshop
if(Get-SteamGame 730) {
	$CSGOPath = (Get-SteamGame 730).InstallDir
	if ((Test-Path -Path "$CSGOPath\csgo\maps\workshop") -eq $true)
	{
		Get-ChildItem -Path "$CSGOPath\csgo\maps\workshop" | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue | Add-Content $Logfile
		WriteLog "Воркшоп CS:GO удален"
	}
} else {
	WriteLog "Не удалось обнаружить CS:GO на этом ПК"
}

foreach ($LibrarySubFolder in $LibrarySubFolders)
{
	foreach ($LibraryFolder in $LibraryFolders)
	{
		$LibraryCleanupPath = "$LibraryFolder\$LibrarySubFolder"

		if ((Test-Path -Path "$LibraryCleanupPath") -eq '')
		{
			WriteLog "Каталог [$LibraryCleanupPath] не существует"
        	continue
		}

		Get-ChildItem -Path $LibraryCleanupPath | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue | Add-Content $LogFile
		WriteLog "$LibraryCleanupPath очищен"
	}	
}
WriteLog "Очистка воркшопа и временных файлов игр завершена!"

#Очистка кэша браузера Steam
if ((Test-Path -Path "$env:localappdata\Steam") -eq $true)
{
	Get-ChildItem -Path "$env:localappdata\Steam" | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue | Add-Content $Logfile
}
WriteLog "Кэш браузера Steam очищен!"

WriteLog "SteamWiper завершил работу"

Add-Type -AssemblyName System.Windows.Forms
$global:balmsg = New-Object System.Windows.Forms.NotifyIcon
$path = (Get-Process -id $pid).Path
$balmsg.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($path)
$balmsg.BalloonTipIcon = [System.Windows.Forms.ToolTipIcon]::Info
$balmsg.BalloonTipText = "Очистка Steam успешно завершена!"
$balmsg.BalloonTipTitle = "SteamWiper"
$balmsg.Visible = $true
$balmsg.ShowBalloonTip(5000)

exit