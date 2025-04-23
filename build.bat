@echo off
del dist/helper.exe >nul 2>&1
gcc helper/helper.c -o helper.exe
move helper.exe dist >nul 2>&1
iexpress.exe /N iexpress.sed