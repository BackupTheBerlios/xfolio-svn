@echo off
if "%OS%" == "Windows_NT" setlocal
rem ---------------------------------------------------------------------------
rem Start script for the CATALINA Server
rem
rem $Id: tomcat.bat,v 1.4 2004/06/21 09:40:07 frederic Exp $
rem ---------------------------------------------------------------------------

rem   CATALINA_OPTS   (Optional) Java runtime options used when the "start",
rem                   "stop", or "run" command is executed.

:: uncompatible with tomcat
:: set JAVA_OPTS="-Xms256m -Xmx512m"


:: changed by frederic.glorieux@ajlsm.com for xfolio (TODO add memory as java options)
set CATALINA_HOME=tomcat


rem Guess CATALINA_HOME if not defined
if not "%CATALINA_HOME%" == "" goto gotHome
set CATALINA_HOME=.
if exist "%CATALINA_HOME%\bin\catalina.bat" goto okHome
set CATALINA_HOME=..
:gotHome
if exist "%CATALINA_HOME%\bin\catalina.bat" goto okHome
echo The CATALINA_HOME environment variable is not defined correctly
echo This environment variable is needed to run this program
goto end
:okHome


if not "%JAVA_HOME%" == "" goto gotJavaHome
set JAVA_HOME=jre-win
:: distribution may contain a valid distributable JRE
:gotJavaHome



set EXECUTABLE=%CATALINA_HOME%\bin\catalina.bat

rem Check that target executable exists
if exist "%EXECUTABLE%" goto okExec
echo Cannot find %EXECUTABLE%
echo This file is needed to run this program
goto end
:okExec

rem Get remaining unshifted command line arguments and save them in the
set CMD_LINE_ARGS=
:setArgs
if ""%1""=="""" goto doneSetArgs
set CMD_LINE_ARGS=%CMD_LINE_ARGS% %1
shift
goto setArgs
:doneSetArgs

call "%EXECUTABLE%" run %CMD_LINE_ARGS%

:end
