:: QSanguosha Online Update from GitHub

:: Author: wch5621628

:: Declaration: This is NOT a virus. You can use it safely.

:: Instruction: Drag this bat file into the root directory of QSanguosha, execute it and wait until the program finishes.
::				After that, QSanguosha.exe will be executed automatically.

:: For Developers: You may set your own url and file lists in order to fulfill your QSanguosha MOD requirement.
::				   You are responsible for the following:
::				   1. Write update serial in QSanguoshaUpdateLog.txt under your MOD's root directory
::				   2. Upload your MOD to Github (better to use GitHub Desktop client)

:: Grammar of update serial:
:: Tag	Desc	Path
:: -a	anime	image/system/emotion/NEWFOLDER	PS:Need to speficy the last index of image files, e.g. yuudachi-25 (download 0.png to 25.png)
:: -b	bgm	audio/system/
:: -c	card(not equip)	image/big-card/	image/card/	audio/card/female/	audio/card/male/
:: -e	equip	image/big-card/	image/card/	image/equips/	image/fullskin/small-equips/
:: -g	general	image/fullskin/generals/full/	image/generals/card/	audio/death/
:: -k	kingdom	image/fullskin/kingdom/frame/	image/fullskin/kingdom/frame/dashboard/	image/kingdom/icon/	image/system/backdrop/	skins/defaultSkin.image.json	skins/fulldefaultSkin.image.json
:: -m	mark	image/mark/
:: -p	pass	etc/customScenes/	lang/zh_CN/Mini.lua
:: -s	skill	audio/skill/	PS:Need to specify the # of audio files, e.g. jianhun-4 (download 4 files) or baiyin-1/dahe (only download baiyin.ogg/dahe.ogg)
:: -o	other	relative path
:: BIGUPDATE	Download from Baidu Pan (better to clear QSanguoshaUpdateLog.txt and only include one line, e.g. 20181231:BIGUPDATE)
:: After updating from tags, LUA and AI will be updated by default. Serial without tags only updates LUA and AI (e.g. 20181001:)

:: Sample of update serial (multiple lines of serial is acceptable, good to sort by version no. ascendingly):
:: 20181001:-g ASTRAY_RED -s jianhun-4 huishou-3 guanglei-4
:: 20181020:-a yuudachi-25 -b BGM1 -c final_vent decade -e laplace_box -g caocao -k ZEON -m @kuangxi -p 1 -s baiyin-1 dahe -o QSanguosha.exe

@echo off
color 3F

SETLOCAL ENABLEDELAYEDEXPANSION

:: Your GitHub url (append /raw/master/ for successful download)
set "url=https://github.com/wch5621628/GundamKillV2/raw/master/"
:: Baidu Pan url for BIGUPDATE
set "pan=https://pan.baidu.com/s/1c2IcEsw"
set "ver=0"
:: QVersion.txt stores the current version no. in form of date serial (e.g. 20181001) which is generated automatically after online update.
if exist QVersion.txt set /p ver=< QVersion.txt
:: Latest version no. which is obtained from QSanguoshaUpdateLog.txt
set "new=0"

echo ^<GundamKillV2 Online Update Programme^>			Author: wch5621628
if !ver! GTR 0 (
	echo Current Version: !ver!
)
echo Checking Update...
call :Download QSanguoshaUpdateLog.txt

set "tag="

for /f "delims=" %%x in (QSanguoshaUpdateLog.txt) do (
	set "var=%%x"
	
	for /f "tokens=1* delims=:" %%y in ("!var!") do (		
		if !ver! LSS %%y (
			echo New Version: %%y
			
			if !new! LSS %%y (
				set "new=%%y"
			)
			
			set "list=%%z"
			if !list! == BIGUPDATE (
				echo There is a BIG UPDATE^^!
				echo Please download it from !pan!
				echo Thanks for your support^^!
				goto :end
			)
			call :Parse "!list!"
		)
	)
)

if !new! == 0 echo No Update Found ^(GuGuGu^)
if !new! GTR !ver! (

	:: Update LUA
	set "lua_list=gaoda gaodacard gaodaexcard boss zabing"
	for %%i in (!lua_list!) do (
		call :Download extensions/%%i.lua
	)

	:: Update AI
	set "ai_list=gaoda-ai gaodacard-ai"
	for %%i in (!ai_list!) do (
		call :Download lua/ai/%%i.lua
	)

	echo !new!> QVersion.txt
	echo Update Completed^^!
)

:end
timeout /T 5
start QSanguosha.exe

:: Tag Parsing Function
:Parse
	for /f "tokens=1* delims= " %%a in (%*) do (
		set "a=%%a"
		if "!a:~0,1!" == "-" (
			set "tag=!a!"
		)
		
		if not "!a:~0,1!" == "-" (
			:: anime
			if "!tag!" == "-a" (
				for /f "tokens=1* delims=-" %%c in ("!a!") do (
					:: create folder first
					if not exist image\system\emotion\%%c mkdir image\system\emotion\%%c
					
					for /L %%i in (0, 1, %%d) do (
						call :Download image/system/emotion/%%c/%%i.png
					)
				)
			)
			:: bgm
			if "!tag!" == "-b" (
				call :Download audio/system/!a!.ogg
			)
			:: card(not equip)
			if "!tag!" == "-c" (
				call :Download image/big-card/!a!.png
				call :Download image/card/!a!.png
				call :Download audio/card/female/!a!.ogg
				call :Download audio/card/male/!a!.ogg
			)
			:: equip
			if "!tag!" == "-e" (
				call :Download image/big-card/!a!.png
				call :Download image/card/!a!.png
				call :Download image/equips/!a!.png
				call :Download image/fullskin/small-equips/!a!.png
			)
			:: general
			if "!tag!" == "-g" (
				call :Download image/fullskin/generals/full/!a!.png
				call :Download image/generals/card/!a!.jpg
				call :Download audio/death/!a!.ogg
			)
			:: kingdom
			if "!tag!" == "-k" (
				call :Download image/fullskin/kingdom/frame/!a!.png
				call :Download image/fullskin/kingdom/frame/dashboard/!a!.png
				call :Download image/kingdom/icon/!a!.png
				call :Download image/system/backdrop/!a!.png
				call :Download skins/defaultSkin.image.json
				call :Download skins/fulldefaultSkin.image.json
			)
			:: mark
			if "!tag!" == "-m" (
				call :Download image/mark/!a!.png
			)
			:: pass
			if "!tag!" == "-p" (
				call :Download etc/customScenes/!a!.txt
				call :Download lang/zh_CN/Mini.lua
			)
			:: skill
			if "!tag!" == "-s" (
				for /f "tokens=1* delims=-" %%c in ("!a!") do (
					if %%d GTR 1 (
						for /L %%i in (1, 1, %%d) do (
							call :Download audio/skill/%%c%%i.ogg
						)
					)
					if %%d == 1 call :Download audio/skill/%%c.ogg
					if [%%d] == [] call :Download audio/skill/%%c.ogg
				)
			)
			:: other
			if "!tag!" == "-o" (
				call :Download !a!
			)
			
		)
		
		set "list=%%b"
		call :Parse "!list!"
	)
exit /B 0

:: Download Function
:Download
	:: download
	certutil.exe -urlcache -split -f %url%%* %*
	:: delete cache
	certutil.exe -urlcache %url%%* delete
exit /B 0