function Get-TimeStamp {   
    return "[{0:dd/MM/yy} {0:HH:mm:ss}]" -f (Get-Date)   
}

$Logfile = "C:\Logs\run-once.txt"

Write-Output "$(Get-TimeStamp) Starting Run Of run-once" | Out-file $Logfile -append

Write-Output "$(Get-TimeStamp) Attempting To Remove Reg Keys Via Powershell" | Out-file $Logfile -append
Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "AutoAdminLogon" -Force   2>&1 >> $Logfile
Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "DefaultUserName" -Force  2>&1 >> $Logfile
Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "DefaultPassword" -Force  2>&1 >> $Logfile
Write-Output "$(Get-TimeStamp) Completed Remove Reg Keys Via Powershell Block" | Out-file $Logfile -append

Write-Output "$(Get-TimeStamp) Starting The Sysprep Process" | Out-file $Logfile -append
C:\Windows\System32\sysprep\sysprep.exe /generalize /oobe /shutdown 2>&1 >> $Logfile
Write-Output "$(Get-TimeStamp) Finished The Sysprep Process" | Out-file $Logfile -append

Write-Output "$(Get-TimeStamp) Finished Run Of run-once" | Out-file $Logfile -append