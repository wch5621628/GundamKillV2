@echo off
color 3F
chcp 65001

mode con: cols=50 lines=7

if "%~1" == "" (
	goto A
) else (
	goto B
)

:A
start "" _temp20150926.bat 1
exit

:B
echo 【每日奖励】& echo.欢迎进入高达杀的世界& echo.你今天的运气真好！& echo.恭喜你获得 5 枚G币！
call _tempspplayer.bat "audio/system/gds_startup.wav"

exit