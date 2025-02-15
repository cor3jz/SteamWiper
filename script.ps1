$Title = "SteamWiper"
$Version = "1.0.0"
$Host.UI.RawUI.WindowTitle= $Title + ' - ' + $Version

# Настройки
$configFile = Join-Path $PSScriptRoot 'config.ini'
$logFile = Join-Path $PSScriptRoot 'debug.log'
$steamInstallPath = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Wow6432Node\Valve\Steam').InstallPath
$global:removedGamesCount = 0
$global:freedSpace = 0
$global:cacheFreedSpace = 0
$global:rootCleanedSpace = 0

if (Test-Path -Path "$logFile" -PathType Leaf) {
    Remove-Item -Path "$logFile"
}

function Write-Log {
    param ([string]$message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "$timestamp - $message"
    Add-Content -Path $logFile -Value $logEntry -Encoding UTF8
    Write-Output $logEntry
}

function Get-ExcludedAppIDs {
    if (Test-Path $configFile) {
        $iniContent = Get-Content $configFile | ForEach-Object { $_.Trim() }
        $gamesSectionStarted = $false
        $excludedAppIDs = @()

        foreach ($line in $iniContent) {
            if ($line -match '^\[Games\]') {
                $gamesSectionStarted = $true
                continue
            }
            if ($gamesSectionStarted -and $line -match '^\d+$') {
                $excludedAppIDs += [int]$line
            }
        }

        return $excludedAppIDs
    } else {
        Write-Log "Файл конфигурации config.ini не найден. Проверьте его наличие и формат."
        return @()
    }
}

function Remove-SteamGame {
    param (
        [string]$gameFolder,
        [string]$manifestFile,
        [int]$appID,
        [string]$gameName
    )
    $folderSize = (Get-ChildItem -Recurse -Force $gameFolder | Measure-Object -Property Length -Sum).Sum
    $folderSizeGB = [math]::Round($folderSize / 1GB, 2)

    Remove-Item -Recurse -Force $gameFolder -ErrorAction SilentlyContinue
    Remove-Item -Force $manifestFile -ErrorAction SilentlyContinue

    Write-Log "Удалено: $gameName ($folderSizeGB GB)"

    $global:removedGamesCount++
    $global:freedSpace += $folderSizeGB
}

function Get-SteamLibraries {
    $steamLibrariesPath = Join-Path $steamInstallPath 'steamapps\libraryfolders.vdf'
    if (Test-Path $steamLibrariesPath) {
        $content = Get-Content $steamLibrariesPath -Raw
        $match = [regex]::Matches($content, '"path"\s+"([^"]+)"')
        return $match | ForEach-Object { $_.Groups[1].Value }
    } else {
        Write-Log "Не удалось найти libraryfolders.vdf. Убедитесь, что Steam установлен."
        return @()
    }
}

function Clear-SteamGames {
    $excludedAppIDs = Get-ExcludedAppIDs
    if ($excludedAppIDs.Count -eq 0) {
        Write-Log "Нет исключений. Удаляем всё."
    }

    foreach ($library in Get-SteamLibraries) {
        $steamAppsPath = Join-Path $library "steamapps"
        if (Test-Path $steamAppsPath) {
            $manifestFiles = Get-ChildItem $steamAppsPath -Filter "appmanifest_*.acf" -ErrorAction SilentlyContinue

            foreach ($manifest in $manifestFiles) {
                $manifestContent = Get-Content $manifest.FullName -Raw
                $appIDMatch = $manifestContent | Select-String -Pattern '"appid"\s+"(\d+)"'
                $nameMatch = $manifestContent | Select-String -Pattern '"name"\s+"([^"]+)"'

                if ($appIDMatch -and $nameMatch) {
                    $appID = [int]$appIDMatch.Matches.Groups[1].Value
                    $gameName = $nameMatch.Matches.Groups[1].Value

                    if ($excludedAppIDs -notcontains $appID) {
                        $installDirMatch = Select-String -InputObject $manifestContent -Pattern '"installdir"\s+"([^"]+)"'
                        if ($installDirMatch) {
                            $installDir = $installDirMatch.Matches.Groups[1].Value
                            $gameFolderPath = Join-Path $steamAppsPath "common\$installDir"
                            if (Test-Path $gameFolderPath) {
                                Remove-SteamGame -gameFolder $gameFolderPath -manifestFile $manifest.FullName -appID $appID -gameName $gameName
                            }
                        } else {
                            Write-Log "Не удалось найти путь для игры $gameName (appID $appID)"
                        }
                    } else {
                        Write-Log "$gameName не удаляем, потому что в исключениях."
                    }
                } else {
                    Write-Log "Не удалось получить информацию об игре из манифеста $($manifest.FullName)"
                }
            }
        }
    }
}

function Clear-SteamCache {
    Write-Log "Очистка кэша загрузок Steam..."
    $cacheFolders = @("workshop", "downloading", "temp", "shadercache", "sourcemods")

    foreach ($library in Get-SteamLibraries) {
        foreach ($folder in $cacheFolders) {
            $path = Join-Path $library "steamapps\$folder"
            if (Test-Path $path) {
                $folderSize = (Get-ChildItem -Recurse -Force $path -File | Measure-Object -Property Length -Sum).Sum
                $folderSizeGB = [math]::Round($folderSize / 1GB, 2)

                try {
                    Get-ChildItem -Path $path -Recurse -Force | ForEach-Object {
                        if (-not $_.PSIsContainer) {
                            Remove-Item -Path $_.FullName -Force -ErrorAction SilentlyContinue
                        }
                    }
                    $global:cacheFreedSpace += $folderSizeGB
                    Write-Log "Очищена папка $path (Освобождено $folderSizeGB GB)"
                } catch {
                    Write-Log "Ошибка при удалении $path : $_"
                }
            } else {
                Write-Log "Папка $path не найдена, пропускаем."
            }
        }
    }
}

function Clear-SteamRootFolders {
    Write-Log "Очистка кэша Steam..."
    $steamRoot = "$steamInstallPath"
    $foldersToClean = @("appcache", "config", "dumps", "logs", "userdata")

    foreach ($folder in $foldersToClean) {
        $path = Join-Path $steamRoot $folder
        if (Test-Path $path) {
            $folderSize = (Get-ChildItem -Recurse -Force $path -File | Measure-Object -Property Length -Sum).Sum
            $folderSizeGB = [math]::Round($folderSize / 1GB, 2)

            try {
                if ($folder -eq "config") {
                    Get-ChildItem -Path $path -Recurse -Force | Where-Object { $_.Name -notmatch "config.vdf" } | Remove-Item -Recurse -Force
                } else {
                    Get-ChildItem -Path $path -Recurse -Force | ForEach-Object {
                        if (-not $_.PSIsContainer) {
                            Remove-Item -Path $_.FullName -Force -ErrorAction SilentlyContinue
                        }
                    }
                }
                $global:rootCleanedSpace += $folderSizeGB
                Write-Log "Очищена папка $path (Освобождено $folderSizeGB GB)"
            } catch {
                Write-Log "Ошибка при очистке $path : $_"
            }
        } else {
            Write-Log "Папка $path не найдена, пропускаем."
        }
    }
}

Write-Log "$Title - $Version"
Write-Log "Запуск очистки библиотек Steam..."

Get-Process -name "steam" -ErrorAction SilentlyContinue | ? { $_.SI -eq (Get-Process -PID $PID).SessionId } | Stop-Process -Force
Stop-Service "Steam Client Service" -Force -ErrorAction SilentlyContinue
Write-Log "Процесс Steam успешно завершён."

Start-Sleep -Seconds 1

Write-Log "Удаляем все что можно удалить..."
Clear-SteamGames
Start-Sleep -Seconds 1
Clear-SteamCache
Start-Sleep -Seconds 1
Clear-SteamRootFolders

$summaryMessage = "Удалено игр: $global:removedGamesCount, Освобождено места: $global:freedSpace GB, Кэш загрузок очищен: $global:cacheFreedSpace GB, Кэш Steam очищен: $global:rootCleanedSpace GB"
Write-Log $summaryMessage
Write-Log "Работа SteamWiper завершена!"

[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
$global:balloon = New-Object System.Windows.Forms.NotifyIcon
$path = (Get-Process -id $pid).Path
$balloon.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($path)
$balloon.BalloonTipIcon = [System.Windows.Forms.ToolTipIcon]::Info
$balloon.BalloonTipText = $summaryMessage
$balloon.BalloonTipTitle = $Title
$balloon.Visible = $true
$balloon.ShowBalloonTip(5000)
Start-Sleep 5
$balloon.Dispose()
