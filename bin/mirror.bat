@echo off
echo.
echo [fr] Votre serveur doit être démarré si vous voulez un miroir de quelque chose
echo [en] Your server must be started if you want to mirror something
echo.
httrack\httrack localhost/ -s0 -C0 -%k -%B -%l "fr, en, ar, *" -Q -q -o0 -%c1 -O "mirror"
echo.
echo [fr] Retrouvez votre site dans le répertoire localhost 
echo [en] Find your site in localhost folder 