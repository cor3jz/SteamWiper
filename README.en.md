<div align="center">

<img width="128" height="128" src="https://raw.githubusercontent.com/cor3jz/SteamWiper/refs/heads/main/icon.png">

# SteamWiper

**SteamWiper is a utility for deleting games and cleaning Steam**

![downloads-badge](https://img.shields.io/github/downloads/cor3jz/SteamWiper/total?color=blue)
![release-badge](https://img.shields.io/github/v/release/cor3jz/SteamWiper?color=green&display_name=release)
![static-badge](https://img.shields.io/badge/PowerShell-blue)


[![ru](https://img.shields.io/badge/lang-ru-blue)](./README.md)
[![en](https://img.shields.io/badge/lang-en-red)](./README.en.md)

![stars-badge](https://img.shields.io/github/stars/cor3jz/SteamWiper)

</div>

> [!NOTE]  
> This utility is provided for informational purposes only! The developer is not responsible for files deleted from your computers and incorrect operation of programs with which this script works! All the best :heart:

## What is it?

SteamWiper is designed to automatically delete Steam games from your PC, except for those that you add to the exceptions, to clear the download and game cache, as well as the user cache.

## How to use?

> [!CAUTION] 
> Before launching SteamWiper for the first time, read the instructions for use and configure the configuration file.

1. Download the latest version of SteamWiper [here](https://github.com/cor3jz/SteamWiper/releases "Download SteamWiper").
2. Extract the archive to any convenient location.
3. Go to SteamWiper folder and open `config.ini` file in any text editor.
4. In `[Games]` section, specify the AppID of the Steam games that you want to keep. They will NOT be deleted during the cleaning process.
5. For convenience, the AppIDs of the most popular games are already listed in the `config.ini` file (see the list below).
6. You can find the AppID of the required games on SteamDB.
7. After making the changes, save the file `config.ini`.
8. Run `SteamWiper.exe ` as administrator. After completion, a notification about the completion of cleaning will appear. The results of the execution will also be in the `debug.log` file.

## Configuration

The folder already has a pre-configured `config.ini` file. It contains the AppID of the main games that are available in almost every PC club. You can delete unnecessary AppIDs and add your own ones.

```ini
[Games]
10              # CS 1.6
70              # Half-Life (leave it for CS 1.6)
550             # Left 4 Dead 2
570             # Dota 2
730             # Counter-Strike 2
221100          # DayZ
228980          # Steamworks Common Redistributables (Do not delete!)
252490          # Rust
271590          # Grand Theft Auto V
381210          # Dead by Daylight
578080          # PUBG
1097150         # Fall Guys
1172470         # Apex Legends
1422450         # Deadlock
1938090         # Call of Duty
```

## Tips for use
1. SteamWiper is suitable for use in PC clubs on a disk system.
2. It is not recommended to add SteamWiper to the startup!