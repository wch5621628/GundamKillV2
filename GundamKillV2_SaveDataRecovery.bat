:: QSanguosha Save Data Recovery

:: Author: wch5621628

:: Declaration: This is NOT a virus. You can use it safely.

:: Instruction: Use this program ONLY when you lost your save data contents in g.json by some error.
::				gbackup.json ONLY backups your g.json when you start QSanguosha.exe for the first time everyday.
::				Drag this bat file into the root directory of QSanguosha, execute it and wait until the program finishes.
::				After that, g.json (current save data) is replaced by gbackup.json (daily backup save data).

@echo off
color 3F

SETLOCAL ENABLEDELAYEDEXPANSION

set "data=g.json"
set "backup=gbackup.json"

echo ^<GundamKillV2 Save Data Recovery^>			Author: wch5621628
echo Checking Backup...
set /p id="You may lose current save data. Are you sure to proceed? [y/n]: "

if "%id%" == "y" (
	:: Copy backup to data file
	copy /y %backup% %data%
) else (
	exit 0
)

echo Recovery Completed^^!

timeout /T 1