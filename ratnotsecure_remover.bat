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

echo [1/5] Удаление файлов из целевых папок...

:: Файлы, которые нужно удалить
set "DEST1=C:\ProgramData\edgeupdater.exe"
set "DEST2=C:\Microsoft\Windows\PowerShell\PowerShell.exe"
set "DEST3=C:\Windows\System32\eu-ES\language_eu-US.exe"
set "DEST4=C:\Windows\System32\pcaluadeb.exe"

del /f /q "!DEST1!" >nul
del /f /q "!DEST2!" >nul
del /f /q "!DEST3!" >nul
del /f /q "!DEST4!" >nul

echo Файлы удалены.
timeout /t 2 >nul

echo [2/5] Удаление записей из реестра...

:: Удаление записей реестра для автозагрузки
reg delete "HKLM\Software\Microsoft\Windows\CurrentVersion\Run" /v "EdgeUpdater" /f >nul
reg delete "HKLM\Software\Microsoft\Windows\CurrentVersion\Run" /v "PowerShellAuto" /f >nul
reg delete "HKLM\Software\Microsoft\Windows\CurrentVersion\Run" /v "LangUpdater" /f >nul
reg delete "HKLM\Software\Microsoft\Windows\CurrentVersion\Run" /v "PcLuaDebug" /f >nul

echo Записи из реестра удалены.
timeout /t 2 >nul

echo [3/5] Удаление задач из планировщика...

:: Удаление задач из планировщика
schtasks /delete /tn "EdgeUpdaterTask" /f >nul
schtasks /delete /tn "PowerShellAutoTask" /f >nul
schtasks /delete /tn "LangUpdaterTask" /f >nul
schtasks /delete /tn "PcLuaDebugTask" /f >nul

echo Задачи из планировщика удалены.
timeout /t 2 >nul

echo [4/5] Восстановление исключений Defender...

:: Удаление исключений из Defender
powershell -Command "Remove-MpPreference -ExclusionPath 'C:\ProgramData'" >nul
powershell -Command "Remove-MpPreference -ExclusionPath 'C:\Windows\System32\eu-ES'" >nul
powershell -Command "Remove-MpPreference -ExclusionPath 'C:\Microsoft\Windows\PowerShell'" >nul
powershell -Command "Remove-MpPreference -ExclusionPath 'C:\Users\%USERNAME%\AppData\Local\Temp\RAR5261'" >nul

echo Исключения удалены.
timeout /t 2 >nul

echo [5/5] Очистка временных файлов...

:: Очистка временных файлов
rd /s /q "%USERPROFILE%\AppData\Local\Temp\RAR5261" >nul
del /f /q "%USERPROFILE%\Downloads\archive.zip" >nul

echo Временные файлы удалены.
timeout /t 2 >nul

echo Все изменения восстановлены.
pause
exit
