@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

set "CONFIG_FILE=config.ini"

:init_config
:: default vars if no config
set "CONF_BROWSER=2"
set "CONF_QUALITY=1080"
set "CONF_PL_ITEMS=1:"

:: color
for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do set "ESC=%%b"
set "C_RESET=%ESC%[0m"
set "C_RED=%ESC%[91m"

:: config
if exist "%CONFIG_FILE%" (
    for /f "usebackq delims=" %%a in ("%CONFIG_FILE%") do set "%%a"
)

:main_menu
cls
echo ————————————— Youtube download ————————————
echo 1. Download MP4 MKV WEBM
echo 2. Download MP3
echo 3. Settings
echo 4. Exit
echo ———————————————————————————————————————————
set "choice="
set /p "choice=Select: "

if "%choice%"=="1" goto download_mp4
if "%choice%"=="2" goto download_mp3
if "%choice%"=="3" goto settings_menu
if "%choice%"=="4" exit
goto main_menu

:settings_menu
cls
echo ————————————————— Settings ————————————————
:: browser
if "%CONF_BROWSER%"=="1" set "b_txt=Waterfox"
if "%CONF_BROWSER%"=="2" set "b_txt=Firefox"
if "%CONF_BROWSER%"=="3" set "b_txt=Chrome"

echo 1. Browser cookies [%b_txt%]
echo 2. Video quality   [%CONF_QUALITY%p]
echo 3. Playlist range  [%CONF_PL_ITEMS%]
echo 4. Back
echo ———————————————————————————————————————————
set "s_choice="
set /p "s_choice=Select: "

if "%s_choice%"=="1" goto set_browser
if "%s_choice%"=="2" goto set_quality
if "%s_choice%"=="3" goto set_playlist
if "%s_choice%"=="4" (
    call :save_config
    goto main_menu
)
goto settings_menu

:set_browser
cls
echo —————— Browser selection for cookies ——————
echo 1. Waterfox
echo 2. Firefox
echo 3. Google Chrome
echo 4. Back
echo ———————————————————————————————————————————
set "b_choice="
set /p "b_choice=Select: "
if "%b_choice%"=="1" set "CONF_BROWSER=1"
if "%b_choice%"=="2" set "CONF_BROWSER=2"
if "%b_choice%"=="3" set "CONF_BROWSER=3"
if "%b_choice%"=="4" goto settings_menu
call :save_config
goto settings_menu

:set_quality
cls
echo ————————— Video quality selection —————————
echo If unavailable, the best lower quality
echo will be chosen.
echo ———————————————————————————————————————————
echo 1. 144p
echo 2. 360p
echo 3. 480p
echo 4. 720p
echo 5. 1080p (HD)
echo 6. 1440p (2K)
echo 7. 2160p (4K)
echo 8. 4320p (8K)
echo 9. Back
echo ———————————————————————————————————————————
set "q_choice="
set /p "q_choice=Select: "
if "%q_choice%"=="1" set "CONF_QUALITY=144"
if "%q_choice%"=="2" set "CONF_QUALITY=360"
if "%q_choice%"=="3" set "CONF_QUALITY=480"
if "%q_choice%"=="4" set "CONF_QUALITY=720"
if "%q_choice%"=="5" set "CONF_QUALITY=1080"
if "%q_choice%"=="6" set "CONF_QUALITY=1440"
if "%q_choice%"=="7" set "CONF_QUALITY=2160"
if "%q_choice%"=="8" set "CONF_QUALITY=4320"
if "%q_choice%"=="9" goto settings_menu
call :save_config
goto settings_menu

:set_playlist
cls
echo ———————————— Playlist settings ————————————
echo %C_RED%Unavailable videos may cause index shifts.%C_RESET%
echo Note: Enter a range in yt-dlp format 
echo   1:    = Whole playlist (All videos)
echo   1-10  = Videos from 1 to 10
echo   1,3,5 = Specific videos only
echo   :5    = First 5 videos
echo   5:    = From video 5 to end
echo   -3:   = Last 3 videos
echo ———————————————————————————————————————————
set "NEW_PL_ITEMS="
set /p "NEW_PL_ITEMS=Index: "

if not "%NEW_PL_ITEMS%"=="" (
    set "CONF_PL_ITEMS=%NEW_PL_ITEMS%"
    call :save_config
)
goto settings_menu

:save_config
(
    echo CONF_BROWSER=%CONF_BROWSER%
    echo CONF_QUALITY=%CONF_QUALITY%
    echo CONF_PL_ITEMS=%CONF_PL_ITEMS%
) > "%CONFIG_FILE%"
exit /b

:get_url
cls
if "%1"=="mp4" echo ——————————————— MP4 MKV WEBM ——————————————
if "%1"=="mp3" echo ——————————————————— MP3 ———————————————————
set "URL="
set /p "URL=Paste video/playlist link: "
if "%URL%"=="" (
    echo Error: Link is empty.
    pause
    goto main_menu
)
:: cookie
if "%CONF_BROWSER%"=="1" set "COOKIE_ARG=--cookies-from-browser firefox:"%APPDATA%\Waterfox\Profiles""
if "%CONF_BROWSER%"=="2" set "COOKIE_ARG=--cookies-from-browser firefox"
if "%CONF_BROWSER%"=="3" set "COOKIE_ARG=--cookies-from-browser chrome"

echo "%URL%" | findstr /i "index=" >nul
if !errorlevel!==0 (
    set "PLAYLIST_ARG=--no-playlist"
) else (
    echo "%URL%" | findstr /i "list=" >nul
    if !errorlevel!==0 (
        set "PLAYLIST_ARG=--playlist-items "%CONF_PL_ITEMS%""
    ) else (
        set "PLAYLIST_ARG=--no-playlist"
    )
)
exit /b

:download_mp4
call :get_url mp4
echo Starting video download...
yt-dlp -f "bv*[height<=%CONF_QUALITY%]+ba/b[height<=%CONF_QUALITY%]" %COOKIE_ARG% %PLAYLIST_ARG% -o "downloads/%%(title)s.%%(ext)s" "%URL%"
echo.
echo Download completed.
pause
goto main_menu

:download_mp3
call :get_url mp3
echo Starting audio download...
yt-dlp -x --audio-format mp3 --embed-thumbnail %COOKIE_ARG% %PLAYLIST_ARG% -o "downloads/%%(title)s.%%(ext)s" "%URL%"
echo.
echo Download completed.
pause
goto main_menu