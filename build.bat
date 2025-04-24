@echo off
del dist/helper.exe >nul 2>&1
gcc helper/helper.c -o dist/helper.exe
:: move helper.exe dist >nul 2>&1
iexpress.exe /N iexpress.sed
where rcedit >nul 2>&1
if %errorlevel%==0 (
	rcedit "./keyh.exe" --set-icon "./keyh.ico"
	goto :end
)
echo NOTE: rcedit not found in PATH.
:end
:: script ends here...