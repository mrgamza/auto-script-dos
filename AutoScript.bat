@ECHO OFF
SETLOCAL

:INITIALIZATION (
	SET COUNT=2147483647
	SET PACKAGE_CookieRun=com.devsisters.CookieRunForKakao
	SET PACKAGE_Magu2=com.netmarble.magu2
	SET PACKAGE_WindRunner=com.linktomorrow.windrunner
	SET PACKAGE_Friends=com.NextFloor.FriendsRunForKakao
	SET MONKEY=com.android.commands.monkey

	SET ADB=.\adb\adb_script.exe
	SET FILE_NAME=script.txt
	SET DATA_FOLDER=.\data\
	SET NOX_LOG_NAME=Nox_1 Nox_2 nox Nox_3
	SET NOX_LOG_PATH=%USERPROFILE%\AppData\Roaming\Nox\bin\BignoxVMS\

	SET MENU_SELECT=
	SET RUNNING_PID=
	SET DEVICE=
	SET ADB_COMMAND=

	SET DEFAULT_HEIGHT=
	SET DEFAULT_WIDTH=
	SET DEVICE_HEIGHT=
	SET DEVICE_WIDTH=

	adb.exe devices > nul
	IF "%ERRORLEVEL%" == "0" (
		SET ADB=adb.exe
	)

	GOTO :SELECT_MENU
)

:SELECT_MENU (
	ECHO ------------------------
	ECHO # SELECT MENU
	ECHO ------------------------
	ECHO 1. CookieRun Start
	ECHO 2. CookieRun Gift
	ECHO 3. CookieRun Stop
	ECHO ------------------------
	ECHO 4. WindRunner Start
	ECHO 5. WindRunner Stop
	ECHO ------------------------
	ECHO 6. FriendsRun Start
	ECHO 7. FriendsRun Stop
	ECHO ------------------------
	ECHO 8. MaguMagu2 Start
	ECHO 9. MaguMagu2 Stop
	ECHO ------------------------
	ECHO 0. All Stop
	ECHO ------------------------
	SET MENU_SELECT=
	SET /p MENU_SELECT=Select : 

	IF "%MENU_SELECT%" == "1" (
		SET PACKAGE=%PACKAGE_CookieRun%
		CALL :START_OR_STOP true CookieRun_Default.txt
	)
	IF "%MENU_SELECT%" == "2" (
		SET PACKAGE=%PACKAGE_CookieRun%
		CALL :START_OR_STOP true CookieRun_Gift.txt
	)
	IF "%MENU_SELECT%" == "3" (
		SET PACKAGE=%PACKAGE_CookieRun%
		CALL :START_OR_STOP false
	)

	IF "%MENU_SELECT%" == "4" (
		SET PACKAGE=%PACKAGE_WindRunner%
		CALL :START_OR_STOP true WindRunner_Adventure.txt
	)
	IF "%MENU_SELECT%" == "5" (
		SET PACKAGE=%PACKAGE_WindRunner%
		CALL :START_OR_STOP false
	)

	IF "%MENU_SELECT%" == "6" (
		SET PACKAGE=%PACKAGE_Friends%
		CALL :START_OR_STOP true FriendsRun.txt
	)
	IF "%MENU_SELECT%" == "7" (
		SET PACKAGE=%PACKAGE_Friends%
		CALL :START_OR_STOP false
	)

	IF "%MENU_SELECT%" == "8" (
		SET PACKAGE=%PACKAGE_Magu2%
		CALL :START_OR_STOP true MaguMagu2.txt
	)
	IF "%MENU_SELECT%" == "9" (
		SET PACKAGE=%PACKAGE_Magu2%
		CALL :START_OR_STOP false
	)

	IF "%MENU_SELECT%" == "" (
		SET PACKAGE=%PACKAGE_CookieRun%
		CALL :START_OR_STOP true CookieRun_Default.txt
		SET PACKAGE=%PACKAGE_WindRunner%
		CALL :START_OR_STOP true WindRunner_Champion.txt
		SET PACKAGE=%PACKAGE_Friends%
		CALL :START_OR_STOP true FriendsRun.txt
		SET PACKAGE=%PACKAGE_Magu2%
		CALL :START_OR_STOP true MaguMagu2.txt
	)
	IF "%MENU_SELECT%" == "0" (
		SET PACKAGE=%PACKAGE_CookieRun%
		CALL :START_OR_STOP false
		SET PACKAGE=%PACKAGE_WindRunner%
		CALL :START_OR_STOP false
		SET PACKAGE=%PACKAGE_Friends%
		CALL :START_OR_STOP false
		SET PACKAGE=%PACKAGE_Magu2%
		CALL :START_OR_STOP false
	)

	ECHO.
	GOTO :SELECT_MENU
)

:CONNECT_NOXS (
	ECHO # Device Search.
	FOR %%a IN (%NOX_LOG_NAME%) do (
		CALL :CONNECT_NOX %%a
	)

	EXIT /B 0
)

:CONNECT_NOX (
	SET TEMP_FILE=%NOX_LOG_PATH%\%~1\%~1.vbox
	IF exist %TEMP_FILE% (
	  FOR /f tokens^=8delims^=^" %%e in ('findstr /i "5555" %TEMP_FILE%') DO (
		%ADB% connect 127.0.0.1:%%e > nul
	  )
	)
	
	EXIT /B 0
)

:START_OR_STOP (
    ECHO.
	SET DEVICE=
	CALL :CONNECT_NOXS
	SET START=%~1
	SET PACKAGE_FILE_NAME=%~2
	SET FIND=%ADB% devices -l
	SET DEVICE_LIST=
	FOR /f "tokens=1,2" %%a in ('"%FIND%"') do (
		IF %%b == device (
		  CALL :SET_DEVICE_LIST %%a
		)
	)

	FOR %%a IN (%DEVICE_LIST%) do (
		CALL :CHECK_PACKAGE %%a
	)

	IF NOT "%DEVICE%" == "" (
		ECHO # Device : %DEVICE%
		SET ADB_COMMAND=%ADB% -s %DEVICE%
			IF %START% == true (
			  CALL :SET_DEVICE_SIZE
			  CALL :MAKE_SCRIPT %PACKAGE_FILE_NAME%
			  CALL :START_SCRIPT
			) ELSE (
			  CALL :STOP_SCRIPT
			)
	) ELSE (
		ECHO Device Not Found
		EXIT /B -1
	)

	EXIT /b 0
)

:SET_DEVICE_LIST (
	SET DEVICE_LIST=%~1 %DEVICE_LIST% 
)

:CHECK_PACKAGE (
	SET TEMP_DEVICE=%~1
	CALL :SET_RUNNING false
	SET FIND="%ADB% -s %TEMP_DEVICE% shell ps | findstr /i %PACKAGE%"
	FOR /f "tokens=2" %%a in ('%FIND%') do (
		CALL :SET_RUNNING true
	)

	IF %IS_RUNNING% == true (
		SET DEVICE=%TEMP_DEVICE%
	)
)

:SET_RUNNING (
	SET IS_RUNNING=%~1
	EXIT /B 0
)

:SET_DEVICE_SIZE (
	SET FIND="%ADB_COMMAND% shell wm size"
	FOR /f "tokens=3" %%a in ('%FIND%') do (
		FOR /f "tokens=1,2 delims=x" %%b in ("%%a") do (
		  IF %%b GTR %%c (
			SET DEVICE_HEIGHT=%%c
			SET DEVICE_WIDTH=%%b
		  ) ELSE (
			SET DEVICE_HEIGHT=%%b
			SET DEVICE_WIDTH=%%c
		  )
		)
		EXIT /B 0
	)

	EXIT /B -1
)

:MAKE_SCRIPT (
	SET DEFAULT_HEIGHT=
	SET DEFAULT_WIDTH=
	SET FIND=type %DATA_FOLDER%%~1

	FOR /f "tokens=*" %%a IN ('"%FIND%"') do (
		FOR /f "tokens=1" %%b IN ("%%a") do (
		  IF "%%b" == "SIZE" (
			FOR /f "tokens=2,3" %%c in ("%%a") do (
			  IF %%c GTR %%d (
				SET DEFAULT_HEIGHT=%%d
				SET DEFAULT_WIDTH=%%c
			  ) ELSE (
				SET DEFAULT_HEIGHT=%%c
				SET DEFAULT_WIDTH=%%d
			  )
			)
		  )
		)
	)

	ECHO type= user>%FILE_NAME%
	ECHO start data ^>^>>>%FILE_NAME%

	FOR /f "tokens=*" %%a IN ('"%FIND%"') DO (
		FOR /f "tokens=1" %%b IN ("%%a") DO (
		  IF "%%b" == "CLICK" (
			FOR /f "tokens=2,3" %%c IN ("%%a") DO (
			  CALL :WRITE_CLICK %%c %%d
			)
		  )

		  IF "%%b" == "SLEEP" (
			FOR /f "tokens=2" %%c IN ("%%a") DO (
			  CALL :WRITE_WAIT %%c
			)
		  )
		)
	)

	EXIT /B 0
)

:WRITE_CLICK (
	SET /a positionX=%~1*DEVICE_WIDTH/DEFAULT_WIDTH
	SET /a positionY=%~2*DEVICE_HEIGHT/DEFAULT_HEIGHT
	ECHO Tap(%positionX%,%positionY%)>>%FILE_NAME%
	EXIT /B 0
)

:WRITE_WAIT (
	ECHO UserWait(%~1)>>%FILE_NAME%
	EXIT /B 0
)

:START_SCRIPT (
	CALL :STOP_SCRIPT
	ECHO # Start : %PACKAGE%
	%ADB_COMMAND% push ./%FILE_NAME% /mnt/sdcard/ > nul
	DEL %FILE_NAME% > nul
	start /b %ADB_COMMAND% shell monkey -p %PACKAGE% -v -f /mnt/sdcard/%FILE_NAME% %COUNT% > nul

	EXIT /B 0
)

:STOP_SCRIPT (
	SET IS_RUNNING=false
	SET FIND="%ADB_COMMAND% shell ps | findstr /i %MONKEY%"
	FOR /f "tokens=2" %%a in ('%FIND%') do (
		ECHO # Stop PID : %%a
		%ADB_COMMAND% shell kill %%a
		SET IS_RUNNING=true
	)

	IF %IS_RUNNING% == false (
		ECHO # Stop PID : NO
	)

	EXIT /B 0
)

:SCREEN_SHOT (
	SET DATETIME=%date:~0,4%%date:~5,2%%date:~8,2%_%time:~0,2%%time:~3,2%%time:~6,2%.png
	SET DATETIME=%DATETIME: =0%

	%ADB_COMMAND% shell screencap -p /sdcard/%DATETIME%
	%ADB_COMMAND% pull /sdcard/%DATETIME%
	%ADB_COMMAND% shell rm /sdcard/%DATETIME%
	EXIT /B 0
)

:END (
	ENDLOCAL
	@ECHO ON
)
