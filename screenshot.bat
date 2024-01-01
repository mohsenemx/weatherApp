@echo off
adb exec-out screencap -p > screen.png 
nircmd clipboard copyimage screen.png
del /Q screen.png
