@echo off
:: ------------------------------------------------------------------------
:: 2004-07-14 frederic.glorieux@ajlsm.com <strabon.org> (FG)
:: from Cocoon Win32 Shell Script
:: ------------------------------------------------------------------------


:: Configuration variables
:vars

:: JETTY_PORT
::   Override the default port for the Jetty xfolio
:: set JETTY_PORT=8080



:: work of this batch is to build the command to start jetty
:: run from a JAVA_HOME environment variable may be the best practice
:: but the app should start with a java correctly installed, even if there's no JAVA_HOME


set CMD=call 

:: ----- Verify and Set Required Environment Variables --------------------


if not "%JAVA_HOME%" == "" goto gotJavaHome

:: try somewhere ?

:gotJavaHome

if not exist "%JAVA_HOME%\bin\java.exe" goto noJavaHome
if not exist "%JAVA_HOME%\bin\javaw.exe" goto noJavaHome

:: let's start from JAVA_HOME
set CMD= %CMD% "%JAVA_HOME%\bin\java.exe"
goto javaOK


:noJavaHome
:: No JAVA_HOME, let's pray JAVA is in the path
set CMD= %CMD% java
goto javaOK

:javaOK

:: JAVA_OPTIONS
::   Extra options to pass to the JVM (memory !)

if not "%JAVA_OPTIONS%" == "" goto gotJavaOptions
:: memory maybe needed
:: set JAVA_OPTIONS=-Xms256m -Xmx512m
:gotJavaOptions



:: ----- Absolutely not generic Classpath --------------------------------------------
:cp

set CP=tools\jetty\org.mortbay.jetty.jar;tools\jetty\javax.servlet.jar;tools\jetty\jasper-runtime.jar;tools\jetty\jasper-compiler.jar;lib\xalan-2.6.0.jar;lib\xercesImpl-2.6.2.jar;xml-apis.jar

set CMD= %CMD% -classpath "%CP%"

:jvmProperties


if "%JETTY_PORT%" == "" goto gotJettyPort
set CMD=%CMD% -Djetty.port=%JETTY_PORT%

:gotJettyPort


set CMD= %CMD% -Dorg.xml.sax.parser=org.apache.xerces.parsers.SAXParser org.mortbay.jetty.Server %CONF% tools\jetty\main.xml

:: here is the executed command, short isnt'it ?

%CMD%

echo %CMD%

:: Messages to display
:message

echo.
echo.
echo --- fr ---
echo.
echo Votre ordinateur est maintenant un "serveur".
echo Ouvrez votre navigateur à l'adresse "localhost".
echo Vous devriez y voir une page d'accueil.
echo Pour supprimer ce service ? Fermez cette fenêtre.
echo.

echo.
echo.
echo --- en ---
echo.
echo Your computer is now a "server".
echo Open your favorite browser on the address "localhost".
echo You should see a welcome page.
echo To shutdown this service ? Close this window.
echo.
echo.


echo JAVA_HOME=%JAVA_HOME%

:clean

set CP=
set CMD=
set JETTY_PORT=

:end
