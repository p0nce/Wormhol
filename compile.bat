@echo off

set ROOT=c:\gamesfrommars

set PATH=%ROOT%\dmd.1.058\windows\bin

set MAINFILE=wormhol

rem set BUD_PARAMS= -release -inline -O -w -gui
set BUD_PARAMS= -g -debug=1

bud %MAINFILE%.d -I..\common2 %BUD_PARAMS% -w -full -names -cleanup -unittest


if errorlevel 1 goto fin

%MAINFILE%.exe -width 1024 -height 768 -windowed
rem -width 800 -height 600 -windowed
rem -width 1024 -height 1024 -windowed
rem -width 800 -height 600 -windowed


if errorlevel 1 goto erreur
goto fin

:erreur
echo The program terminated with an error



:fin

pause