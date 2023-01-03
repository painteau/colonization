@echo OFF
set CSV_FILE=docker-data.csv

for /f "skip=1 tokens=1,2,3,4 delims=," %%a in (%CSV_FILE%) do (
    set hub=%%a
    set user=%%b
    set repo=%%c
    set version=%%d
)
set major=%version:~0,1%
set minor=%version:~2,1%
set revision=%version:~4,1%
set /a revision=%revision%+1
set version=%major%.%minor%.%revision%
echo This will build and push to %hub%/%user%/%repo%:v%version% 
pause
echo #########################
echo #
echo # Login to Docker
echo #
echo #########################
docker login %hub%
echo #########################
echo #
echo # Building container
echo #
echo #########################
docker build -t %hub%/%user%/%repo%:v%version% .
echo #########################
echo #
echo # Pushing to registry
echo #
echo #########################
docker push %hub%/%user%/%repo%:v%version%
echo #########################
echo #
echo # Job Done, Incrementing Version for next push
echo #
echo #########################
echo hub,user,repo,version > %CSV_FILE%
echo %hub%,%user%,%repo%,%version% >> %CSV_FILE%

CHOICE /T 20 /D N /C YN /N /M "Do you want to push this version to latest tag [Y/N] ? "
IF ERRORLEVEL 2 GOTO END
IF ERRORLEVEL 1 GOTO LATEST
GOTO END

:LATEST
cls
echo #########################
echo #
echo # Login to Docker
echo #
echo #########################
docker login %hub%
echo #########################
echo #
echo # Building container
echo #
echo #########################
docker build -t %hub%/%user%/%repo%:latest .
echo #########################
echo #
echo # Pushing to registry
echo #
echo #########################
docker push %hub%/%user%/%repo%:latest

:END
pause
