@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

set "CONFIG_FILE=config.ini"

:init_config
:: default vars if no config
set "CONF_BROWSER=2"
set "CONF_QUALITY=1080"
set "CONF_PL_ACTIVE=0"
set "CONF_PL_ITEMS=1-10"

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

:: playlist
if "%CONF_PL_ACTIVE%"=="1" (set "pl_txt=Enabled][%CONF_PL_ITEMS%") else (set "pl_txt=Disabled")

echo 1. Browser cookies [%b_txt%]
echo 2. Video quality   [%CONF_QUALITY%p]
echo 3. Playlist        [%pl_txt%]
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
echo 8. Back
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
if "%q_choice%"=="8" goto settings_menu
call :save_config
goto settings_menu

:set_playlist
cls
echo ———————————— Playlist settings ————————————
echo Unavailable videos may cause index shifts.
echo ———————————————————————————————————————————
if "%CONF_PL_ACTIVE%"=="1" (set "status_txt=[Enabled]") else (set "status_txt=[Disabled]")

echo 1. Change state       %status_txt%
echo 2. Change index range [%CONF_PL_ITEMS%]
echo 3. Back
echo ———————————————————————————————————————————
set "p_choice="
set /p "p_choice=Select: "

if "%p_choice%"=="3" goto settings_menu

if "%p_choice%"=="1" (
    if "%CONF_PL_ACTIVE%"=="1" (set "CONF_PL_ACTIVE=0") else (set "CONF_PL_ACTIVE=1")
    call :save_config
    goto set_playlist
)

if "%p_choice%"=="2" (
    echo Enter a range in yt-dlp format (e.g., 1-10, 1,3,5, or :5)
    set /p "CONF_PL_ITEMS=Index: "
    call :save_config
    goto set_playlist
)

goto set_playlist

:save_config
(
    echo CONF_BROWSER=%CONF_BROWSER%
    echo CONF_QUALITY=%CONF_QUALITY%
    echo CONF_PL_ACTIVE=%CONF_PL_ACTIVE%
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

:: playlist
if "%CONF_PL_ACTIVE%"=="1" (
    set "PLAYLIST_ARG=--playlist-items "%CONF_PL_ITEMS%""
) else (
    set "PLAYLIST_ARG=--no-playlist"
)
exit /b

:download_mp4
call :get_url mp4
echo Starting video download...
yt-dlp -f "bv*[height<=%CONF_QUALITY%]+ba/b[height<=%CONF_QUALITY%]" %COOKIE_ARG% %PLAYLIST_ARG% -o "%%(title)s.%%(ext)s" "%URL%"
echo.
echo Download completed.
pause
goto main_menu

:download_mp3
call :get_url mp3
echo Starting audio download...
yt-dlp -x --audio-format mp3 --embed-thumbnail %COOKIE_ARG% %PLAYLIST_ARG% -o "%%(title)s.%%(ext)s" "%URL%"
echo.
echo Download completed.
pause
goto main_menu