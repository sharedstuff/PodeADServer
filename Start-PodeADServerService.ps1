#Requires -Modules @{ ModuleName='Pode'; GUID='e3ea217c-fc3d-406b-95d5-4304ab06c6af'; ModuleVersion='2.9.0' }
#Requires -Modules @{ ModuleName='ActiveDirectory'; GUID='43c15630-959c-49e4-a977-758c5cc93408'; ModuleVersion='1.0.1.0' }
#Requires -RunAsAdministrator
#Requires -Version 7.4

pwsh.exe -NonInteractive -F .\Start-PodeADServer.ps1
