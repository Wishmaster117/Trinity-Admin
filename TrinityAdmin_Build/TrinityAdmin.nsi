!include "MUI2.nsh"
!include "WordFunc.nsh"   ; ${For}
!include "StrFunc.nsh"    ; ${StrRep}
${StrRep}

Name "TrinityAdmin"
OutFile "TrinityAdmin_Setup.exe"
RequestExecutionLevel user
InstallDir "$PROGRAMFILES\World of Warcraft\_retail_\Interface\AddOns"
Page directory
Page instfiles

Var KEY
Var TMP
Var BATPATH

Section "Install" SEC
  SetOutPath "$INSTDIR\TrinityAdmin"

  ;--- Génération d’une clé hexadécimale de 32 car. ---
  StrCpy $KEY ""
  ${For} $0 1 8
    System::Call 'kernel32::GetTickCount() i .r1'
    IntFmt $1 "%04X" $1
    StrCpy $KEY "$KEY$1"
  ${Next}

  ;--- Copie des fichiers ---
  File /r "payload\TrinityAdmin\*.*"

  ;--- Remplacement dans les deux fichiers ---
  Push "$INSTDIR\TrinityAdmin\TrinityAdmin.lua"
  Call InjectKey
  Push "$INSTDIR\TrinityAdmin\Modules\tad.lua"
  Call InjectKey
SectionEnd

; ---------------------------------------------------------------------
; Post-install : générer un .bat, le lancer détaché, puis quitter
; ---------------------------------------------------------------------
Function .onInstSuccess
  GetTempFileName $R0
  Delete         $R0
  StrCpy         $R0 "$R0.bat"

  FileOpen  $0 $R0 w
  FileWrite $0 "@echo off$\r$\n"
  FileWrite $0 "echo Finalising installation...$\r$\n"
  FileWrite $0 "ping -n 6 127.0.0.1>nul$\r$\n"
  FileWrite $0 'del /f /q "%~1"$\r$\n'
  FileWrite $0 'del /f /q "%~f0"$\r$\n'
  FileClose $0

  Exec '"$R0" "$EXEPATH"'
  Quit
FunctionEnd

;--------------------------------------
; InjectKey : remplace @KEY@ par la valeur générée
;--------------------------------------
Function InjectKey
  Exch $0                ; $0 = chemin fichier
  GetTempFileName $TMP

  FileOpen  $1 $0 r
  FileOpen  $2 $TMP w

  loop:
    FileRead $1 $3
    IfErrors done
      ${StrRep} $3 "$3" "@KEY@" "$KEY"
      FileWrite $2 $3
    Goto loop
  done:

  FileClose $1
  FileClose $2
  Delete $0
  Rename $TMP $0
FunctionEnd
