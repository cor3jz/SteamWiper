<div align="center">

<img width="128" height="128" src="https://raw.githubusercontent.com/cor3jz/SteamWiper/refs/heads/main/icon.png">

# SteamWiper

**SteamWiper - Утилита для удаления игр и очистки Steam**

![downloads-badge](https://img.shields.io/github/downloads/cor3jz/SteamWiper/total?color=blue)
![release-badge](https://img.shields.io/github/v/release/cor3jz/SteamWiper?color=green&display_name=release)
![static-badge](https://img.shields.io/badge/PowerShell-blue)


[![ru](https://img.shields.io/badge/lang-ru-blue)](./README.md)
[![en](https://img.shields.io/badge/lang-en-red)](./README.en.md)

![stars-badge](https://img.shields.io/github/stars/cor3jz/SteamWiper)

</div>

> [!NOTE]  
> Данная утилита представлена исключительно для ознакомления! Разработчик не несет ответственности за удаленные с ваших компьютеров файлы и некорректную работу программ с которыми работает данный скрипт! Всем добра :heart:

## Для чего?

SteamWiper предназначен для автоматического удаления игр Steam с ПК кроме тех, которые вы добавите в исключения, очистки кэша загрузок и игр, а также кэша пользователей.

## Как использовать?

> [!CAUTION] 
> Перед первым запуском SteamWiper, ознакомьтесь с инструкцией по использованию и настройте файл конфигурации.

1. Скачать последнюю версию SteamWiper [здесь](https://github.com/cor3jz/SteamWiper/releases "Скачать SteamWiper").
2. Извлечь архив в любое удобное место.
3. Перейти в папку SteamWiper и открыть файл `config.ini` в любом текстовом редакторе.
4. В блоке `[Games]` указать AppID игр из Steam которые вы хотите оставить. В процессе очистки они НЕ будут удалены.
5. Для удобства, в файле `config.ini` уже прописаны AppID самых популярных игр (список ниже).
6. Найти AppID нужных игр можно на SteamDB.
7. После внесения изменений, сохранить файл `config.ini`.
8. Запустить `SteamWiper.exe` от имени администратора. После выполнения появится уведомление о завершении очистки. Также результаты выполнения будут в файле `debug.log`.

## Конфигурация

В папке уже есть преднастроенный файл `config.ini`. Он содержит AppID основных игр, которые есть практически в каждом клубе. Вы можете удалить не нужные AppID и добавить собственные.

```ini
[Games]
10              # CS 1.6
70              # Half-Life (оставить для CS 1.6)
550             # Left 4 Dead 2
570             # Dota 2
730             # Counter-Strike 2
221100          # DayZ
228980          # Steamworks Common Redistributables (библиотеки Steam, не удалять)
252490          # Rust
271590          # Grand Theft Auto V
381210          # Dead by Daylight
578080          # PUBG
1097150         # Fall Guys
1172470         # Apex Legends
1422450         # Deadlock
1938090         # Call of Duty
```

## Советы по использованию
1. SteamWiper подходит для использования в компьютерных клубах на дисковой системе.
2. Не рекомендуется добавлять SteamWiper в автозагрузку!