@echo off
:: ------------------------------------------------------------------------
:: 2004-02-27 frederic.glorieux@ajlsm.com <strabon.org> (FG)
:: from Cocoon Win32 Shell Script
:: ------------------------------------------------------------------------

:: ------------------------
:: classpath add
:: if this batch is called with the -addcp option
:: next argument is a jar to add to the local classpath
:: ------------------------

if not "%1" == "-addcp" goto vars
set CP=%CP%;%2
goto end

:: Configuration variables
:vars

:: THIS
:: name of this file to be called to append classpath
set THIS=jetty.bat


:: JAVA_HOME
::   Home of Java installation.
:: DEBUG only, to verify if the local JRE is working
:: set JAVA_HOME=jre-win


::
:: JAVA_OPTIONS
::   Extra options to pass to the JVM

:: JAVA_DEBUG_PORT
::   The location where the JVM debug server should listen to

:: JETTY_HOME
::   Where is the jetty server to run
set JETTY_HOME=jetty
::
:: JETTY_PORT
::   Override the default port for the Jetty xfolio
set JETTY_PORT=80

::
:: JETTY_ADMIN_PORT
::   The port where the jetty web administration should bind for xfolio
set JETTY_ADMIN_PORT=88
::
:: XFOLIO_WEBAPP
::   The directory where the xfolio webapp that jetty has to execute
set XFOLIO_WEBAPP=../xfolio

:: XFOLIO_EFOLDER
:: you may want to precise which efolder to server, instead of setting it from webmin
:: the electronic folder of documents to serve, absolute or relative to XFOLIO_WEBAPP
set XFOLIO_EFOLDER=



:: ----- Verify and Set Required Environment Variables --------------------


if not "%JAVA_HOME%" == "" goto gotJavaHome
set JAVA_HOME=jre-win
:: distribution may contain a valid distributable JRE
:gotJavaHome

if not "%JAVA_OPTIONS%" == "" goto gotJavaOptions
set JAVA_OPTIONS=-Xms256m -Xmx512m
:: memory is needed for images
:gotJavaOptions

if not "%XFOLIO_WEBAPP%" == "" goto gotWebapp
set DEMO_WEBAPP=..\xfolio
if not exist %DEMO_WEBAPP% goto standardWebapp
set XFOLIO_WEBAPP=%DEMO_WEBAPP%
goto gotWebapp
:standardWebapp
set XFOLIO_WEBAPP=.\webapp
:gotWebapp



:: ----- Append to Classpath --------------------------------------------
:cp

set CP=
for %%i in (%JETTY_HOME%\lib\*) do call %THIS% -addcp %%i


:: Messages to display
:echos

echo.
echo.
echo --- fr ---
echo.
echo "strabon.org", le site sur votre bureau.
echo Votre ordinateur est maintenant un "serveur".
echo Ouvrez votre navigateur pr‚f‚r‚ … l'adresse "localhost".
echo Vous devriez y voir une page d'accueil.
echo Pour supprimer ce service ? Fermez cette fenˆtre.
echo.
echo Les messages qui suivent sont laiss‚s pour les d‚veloppeurs
echo.

echo.
echo.
echo --- en ---
echo.
echo "strabon.org", the site on your desktop.
echo Your computer is now a "server".
echo Open your favorite browser on the address "localhost".
echo You should see a welcome page.
echo To shutdown this service ? Close this window.
echo.
echo Following messages are for developpers.
echo.


echo JAVA_HOME=%JAVA_HOME%
echo claspath=%CP%
echo XFOLIO_EFOLDER=%XFOLIO_EFOLDER%
echo XFOLIO_WEBAPP=%XFOLIO_WEBAPP%


:: if not "%CMD%" == "" goto gotCmd
:: FG why ?
:: if not "%OS%" == "Windows_NT" goto noExecNT
:: set CMD=start "XFolio" 
set CMD=call 

:gotCmd

set CMD= %CMD% "%JAVA_HOME%\bin\java.exe" %JAVA_OPTIONS% -classpath "%CP%"
set CONF="%JETTY_HOME%\conf\main.xml"

:: if JETTY_ADMIN_PORT not empty, Jetty admin requested
if "%JETTY_ADMIN_PORT%" == "" goto notAdmin
set CMD= %CMD% -Djetty.admin.port=%JETTY_ADMIN_PORT%
set CONF= "%JETTY_HOME%\conf\admin.xml" %CONF%
:notAdmin

if not "%1" == "admin" goto start


:start

set CMD= %CMD% "-Dwebapp=%XFOLIO_WEBAPP%" -Dorg.xml.sax.parser=org.apache.xerces.parsers.SAXParser -Djetty.port=%JETTY_PORT% -Djetty.admin.port=%JETTY_ADMIN_PORT% "-Dhome=%JETTY_HOME%" "-Dxfolio.efolder=%XFOLIO_EFOLDER%" org.mortbay.jetty.Server %CONF% 


:: here is the executed command, short isnt'it ?

%CMD%

:: 2004-03-29 FG maybe interesting but heavy for dev, and need to wait till the server is started
:: start rundll32 url.dll,FileProtocolHandler http://127.0.0.1


goto clean


:clean

set CP=
set CMD=
set CONF=
set XFOLIO_EFOLDER=
set XFOLIO_WEBAPP=

:end
