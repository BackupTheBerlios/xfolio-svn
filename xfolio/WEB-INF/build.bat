@echo off
:: ------------------------------------------------------------------------
:: 2004-04-28 frederic.glorieux@ajlsm.com <strabon.org> (FG)
:: a little shell to run a build embed in a webapp
:: this is a first step for lots of possible runing things
:: especially static generation
:: this script assume you have a JAVA_HOME or a classical strabon distrib
:: where to find a JRE
:: ------------------------------------------------------------------------

:: Configuration variables
:vars


:: JAVA_HOME
::   Home of Java installation.

if not "%JAVA_HOME%" == "" goto gotJavaHome
set JAVA_HOME=..\..\bin\jre-win
:: distribution may contain a valid distributable JRE
:gotJavaHome


:: Slurp the command line arguments. This loop allows for an unlimited number
:: of arguments (up to the command line limit, anyway).


set ANT_ARGS=%1
if ""%1""=="""" goto cmd
shift
:setupArgs

if ""%1""=="""" goto cmd
set ANT_ARGS=%ANT_ARGS% %1
shift
goto setupArgs

:cmd
set CMD=%JAVA_HOME%\bin\java.exe
:: TODO, check ant last distrib
set CMD=%CMD% -cp lib\ant-launcher.jar org.apache.tools.ant.launch.Launcher %ANT_ARGS%
%CMD%

:cleanVars
set CMD=
set ANT_ARGS=
