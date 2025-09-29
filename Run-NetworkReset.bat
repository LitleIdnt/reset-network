@echo off
:: Run with elevated rights
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command ^
"Start-Process PowerShell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File ""%~dp0Reset-Network.ps1""' -Verb RunAs"
