# Функция выбора действия
function Get-choice {
  do {
    write-host "Y/N"
    write-host "y/n"
    write-host "или"
    write-host "Д/Н"
    write-host "д/н"
    write-host -nonewline "Необходимо удалять индексную базу? : "
    $choice = read-host
    write-host ""
    $ok = @("Y","y","N","n","Д","д","Н","н","X","x","Х","х") -contains $choice
    if ( -not $ok) { write-host "Неверный выбор. Введите y/n или д/н в любом регистре." }
  }
  until ( $ok )
  
  $yes = @("Y","y","Д","д") -contains $choice
  if ( $choice -in $yes ) {
	  write-host "Вы подтвердили удаление индексной базы 'Y'"
	  Write-Host "Остановка службы Поиск Windows." -ForegroundColor Cyan
      net stop "Windows Search"
	  Write-Host "Удаление файла Windows.edb и генерация нового файла." -ForegroundColor Cyan
      REG ADD "HKLM\SOFTWARE\Microsoft\Windows Search" /v SetupCompletedSuccessfully /t REG_DWORD /d 0 /f
	  Remove-Item -Path C:\ProgramData\Microsoft\Search\Data\Applications\Windows\Windows.edb -Confirm:$false -Recurse -Force
	  net start "Windows Search"
  }
  else{
	  write-host "Вы отказались от удаления индексной базы 'N'"
  }
}

# Выставляем параметры консоли. По моему желанию консоль черная, текст белый, так привычнее.
(Get-Host).UI.RawUI.CursorSize=12;
if ($psISE) {
    $psISE.Options.RestoreDefaults();
    $psISE.Options.ConsolePaneBackgroundColor     = 'Black'
    $psISE.Options.ConsolePaneTextBackgroundColor = 'Black'
    $psISE.Options.ConsolePaneForegroundColor     = 'White'
	$psISE.Options.FontSize = 12
}
if ($Host.UI.RawUI) {
    $Host.UI.RawUI.BackgroundColor = 'Black';
    $Host.UI.RawUI.ForegroundColor = 'White';
}

# Текст желтым цветом
$colors = (Get-Host).PrivateData
$colors.ErrorBackgroundColor = "Black"
$colors.ErrorForegroundColor = "Yellow"


# Очистка, аналог cls
Clear-Host
# Очистка предыдущих сообщений
cls

# Переменные
$Date = Get-Date -Format "dd_MM_yyyy-HH_mm"
$DateInfo = Get-Date -Format "dd.MM.yyyy HH:mm"
$Username = "СИСТЕМА"
$version = "3.2.0"
$Dates = "22.04.2022"
$IP = "10.1.114.24"

# Логирование всех действий в отдельный лог фаил:
Start-Transcript -Append $env:SystemDrive\LogsCache\itsCleanable_"$date".txt
# Название окна:
[System.Console]::Title = "Очистка диска $env:computername | $env:USERDNSDOMAIN | itsCleanable | Version: $version | Update $Dates"
# Информация:
Write-Host "====="
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
Write-Host "Запущен ли скрипт от админа (True/False): " -ForegroundColor Red -NoNewline
$currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
Write-Host "====="
Write-Host "Имя компьютера: $env:computername" -ForegroundColor Yellow
Write-Host "Дата и время отработки скрипта: $DateInfo" -ForegroundColor Yellow
Write-Host "Имя пользователя, запустивший скрипт: $env:UserName" -ForegroundColor Yellow
Write-Host "Имя домена: $env:USERDNSDOMAIN" -ForegroundColor Yellow
Write-Host "====="
Write-Host "Имя скрипта: Очистка диска $env:computername | $env:USERDNSDOMAIN | itsCleanable | Version: $version | Update $Dates" -ForegroundColor Yellow
Write-Host "Версия скрипта: $version" -ForegroundColor Yellow
Write-Host "Дата последних изменений скрипта: $Dates" -ForegroundColor Yellow
Write-Host "====="

# Вывод размера диска в консоль и по директории в лог фаил:
mkdir C:\LogsCache\
fsutil volume diskfree $env:SystemDrive\ > $env:SystemDrive\LogsCache\log-volume-start-itsCleanable_"$date".txt
fsutil volume diskfree $env:SystemDrive\

Write-Host "====="
Write-Host "========== Остановка центр обновления Windows =========="
Write-Host "====="

net stop wuauserv

Write-Host "====="
Write-Host "========== Остановка других служб =========="
Write-Host "====="

Write-Host "XBOX" -ForegroundColor Cyan
net stop "Xbox Accessory Management Service"

Write-Host "Биометрическая служба Windows" -ForegroundColor Cyan
net stop "WbioSrvc"

Write-Host "Диспетчер проверки подлинности Xbox Live" -ForegroundColor Cyan
net stop "XblAuthManager"

Write-Host "Родительский контроль" -ForegroundColor Cyan
net stop "WpcMonSvc"

Write-Host "Сетевая служба Xbox Live" -ForegroundColor Cyan
net stop "XboxNetApiSvc"

Write-Host "Служба Windows License Manager" -ForegroundColor Cyan
net stop "LicenseManager"

Write-Host "Windows Mobile Hotspot" -ForegroundColor Cyan
net stop "icssvc"

Write-Host "Служба демонстрации магазина" -ForegroundColor Cyan
net stop "RetailDemo"

Write-Host "Служба управления радио" -ForegroundColor Cyan
net stop "RmSvc"

Write-Host "Факс" -ForegroundColor Cyan
net stop "Fax"

Write-Host "====="
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
Write-Host "Запущен ли скрипт от админа (True/False): " -ForegroundColor Red -NoNewline
$currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
Write-Host "====="

Write-Host ""
Write-Host "========== Остановка службы поиска для удаления файла =========="
Write-Host "====="

Write-Host "Windows.edb является индексной базой данных службы поиска Windows. Благодаря такой индексации поиск происходит быстрее и эффективнее. Необходимо ли удалять Windows.edb и генерировать новый фаил для освобождения пространства? (Y/N)"

# Вызов функции для выбора удаления индексной базы или нет.
Get-choice

# Отключение гипернации и удаление файла.
powercfg -h off

Remove-Item -Path C:\LogsCache\check-itsCleanable.txt -Confirm:$false -Recurse -Force
Remove-Item -Path C:\LogsCache\checkout-itsCleanable.txt -Confirm:$false -Recurse -Force

# Чек до и после удаления файлов.
$Logfile1 = 'C:\LogsCache\check-itsCleanable.txt'
$Logfile2 = 'C:\LogsCache\checkout-itsCleanable.txt'

# Список директорий подлежащих удалению
cd $moduleRoot\start
$SourceDir = Get-Content -Path @("file-check.txt")

# Далее проверка директорий и запись в лог фаил file1.txt
$FileList = Get-ChildItem -LiteralPath $SourceDir -File -Recurse

$Results = foreach ($FL_Item in $FileList)
    {
		
    
	gci -force '$SourceDir'-ErrorAction SilentlyContinue | ? { $_ -is [io.directoryinfo] } | % {
	$len = 0
	gci -recurse -force $_.fullname -ErrorAction SilentlyContinue | % { $len += $_.length }
	$_.fullname, '{0:N2} GB' -f ($len / 1Gb)
	$sum = $sum + $len
	}
	“Общий размер профилей”,'{0:N2} GB' -f ($sum / 1Gb)
	
    [PSCustomObject]@{
        Location = $FL_Item.Directory
        Name = $FL_Item.Name
        Size_GB = '{0,7:N2}' -f ($FL_Item.Length / 1GB)
        } | Add-content $Logfile1
    }

$Results
# Удаление файлов согласно списку file-check.txt
function Remove_files {
	 Remove-Item -Path $SourceDir -Confirm:$false -Recurse -Force
}

#Удаления файлов
Remove_files


# И снова проверка директорий. Если файлы не удалены, он запишет в фаил file2.txt
cd $moduleRoot\start
$SourceDir = Get-Content -Path @("file-check.txt")

$FileList = Get-ChildItem -LiteralPath $SourceDir -File -Recurse

$Results = foreach ($FL_Item in $FileList)
    {
    [PSCustomObject]@{
        Location = $FL_Item.Directory
        Name = $FL_Item.Name
        Size_GB = '{0,7:N2}' -f ($FL_Item.Length / 1GB)
        } | Add-content $Logfile2
    }


# Идет сравнение 2 файлов file1 и file2
# В file1 пишется список до удаления файлов.
# В file2 пишется список после удаления файлов.
# resultFile пишутся удаленные файлы после сравнения 2 документов.
$f1=get-content -Path C:\LogsCache\check-itsCleanable.txt
$f2=get-content -Path C:\LogsCache\checkout-itsCleanable.txt
foreach ($objf1 in $f1)
{
                $objf1 = $objf1.tostring().Trim()
                $objf1 = $objf1.Replace(" ","")
                $objf1 = $objf1.ToUpper()
                $found = $false
                foreach ($objf2 in $f2)
                {
                               $objf2=$objf2.Replace(" ", "")
                               $objf2=$objf2.Trim()
                               $objf2=$objf2.ToUpper()        
                               if ($objf1 -eq $objf2)
                               {                                            
                                               $found = $true                               
                               }                             
                }
                if ((!$found) -and ($objf1 -ne ""))
                {
                               $result += $objf1.tostring().trim() + "`r`n"
                }
}
# Результат удаленных файлов мы увидим в документе resultFile.txt
set-content -path C:\LogsCache\resultFile-itsCleanable_"$date".txt -value $result

cd $moduleRoot\start
$UsersDir = Get-Content -Path @("users-directory.txt")

$Profiles = Get-ChildItem (Get-ItemProperty -path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList").ProfilesDirectory -Exclude "Администратор", "Administrator", "Setup", "Public", "All Users", "Default User"


ForEach ($Profile in $Profiles) {
ForEach ($Path in $UsersDir) {
Write-Host "====="
Write-Host "$Profile$Path"
Remove-Item -Path $Profile$Path -Recurse -Force -ErrorAction SilentlyContinue -WhatIf

}
}

# Информация о заполненности диска после очистки с выводом в лог фаил.
mkdir C:\LogsCache\
fsutil volume diskfree $env:SystemDrive\ > $env:SystemDrive\LogsCache\log-volume-end-itsCleanable_"$date".txt
fsutil volume diskfree $env:SystemDrive\



# Информация:
Write-Host "====="
Write-Host "Завершения работы..." -ForegroundColor Green
Write-Host "itsCleanable | Version: $version | Обновление от: $Dates" -ForegroundColor Green
Write-Host "Автор: Захаров Илья Алексеевич" -ForegroundColor Green
Write-Host "Новая версия github.com/itsmyfox в соответствующем разделе" -ForegroundColor Green
Write-Host "====="

# Включает максимальную политику безопасности.
# powershell -Command set-executionpolicy restricted -force

# SIG # Begin signature block
# MIIPaAYJKoZIhvcNAQcCoIIPWTCCD1UCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUFbeTA8ST7K9REtugJ/+FhbIu
# zxigggzVMIIGTjCCBDagAwIBAgITTwAAB6r7HLyYxe8w1QABAAAHqjANBgkqhkiG
# 9w0BAQsFADBFMRUwEwYKCZImiZPyLGQBGRYFbG9jYWwxEzARBgoJkiaJk/IsZAEZ
# FgNlcGsxFzAVBgNVBAMTDkVQSyBJc3N1aW5nIENBMB4XDTIyMDQyMjEzMTgzM1oX
# DTI3MDQyMTEzMTgzM1owITEfMB0GA1UEAwwWaS5hLnpha2hhcm92QGVway5sb2Nh
# bDCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAKkjypb2uAt53tRZgjW0
# 0p3w+ulu13GhMmGJHg43kcosEDYmJpNG7tx6PbnbXpFDMdvPTueYi9RN4z5C/aa6
# EdE6g+TVMPPMwhD05oRqrm4gUZgz+kspSnm9YPaJwUpkmYmcVmrJr+6FEkM8DTxd
# LMWtCy75H0q8Y/CPVACiwFmK2Wb9xEijU5cLQ/2yZW3iwVev4P4UUbKm3XEVqIsu
# LxVcgxNUD8TkgDp8biJqkjtcTJ9sBWaWvTv7JO65KCDdR/I8Gj8hoPHtdS5mfPRi
# uCurZgJblah7WCzgeeSP+z+E6LOnhwpHrl745e3GjeIOtIu4+hH3ao25ZZHJlrnE
# dSUCAwEAAaOCAlkwggJVMD4GCSsGAQQBgjcVBwQxMC8GJysGAQQBgjcVCIHvqnKB
# qqQLhuGND4TiiSmEo7MMgSaDlpR4hde4egIBZAIBCDATBgNVHSUEDDAKBggrBgEF
# BQcDAzAOBgNVHQ8BAf8EBAMCB4AwGwYJKwYBBAGCNxUKBA4wDDAKBggrBgEFBQcD
# AzAdBgNVHQ4EFgQUEQAZVKzatfEanIsUcZdklsFkeZAwMQYDVR0RBCowKKAmBgor
# BgEEAYI3FAIDoBgMFmkuYS56YWtoYXJvdkBlcGsubG9jYWwwHwYDVR0jBBgwFoAU
# HCrTmSlz/z4rX2EaS/G+V6VwhVAwgYkGA1UdHwSBgTB/MH2ge6B5hkNodHRwOi8v
# SVFEQy1WTS1DQS0wMi5lcGsubG9jYWwvQ2VydEVucm9sbC9FUEslMjBJc3N1aW5n
# JTIwQ0EoMSkuY3JshjJodHRwOi8vY2RwLmVway5sb2NhbC9wa2kvRVBLJTIwSXNz
# dWluZyUyMENBKDEpLmNybDCB0QYIKwYBBQUHAQEEgcQwgcEwZwYIKwYBBQUHMAKG
# W2h0dHA6Ly9JUURDLVZNLUNBLTAyLmVway5sb2NhbC9DZXJ0RW5yb2xsL0lRREMt
# Vk0tQ0EtMDIuZXBrLmxvY2FsX0VQSyUyMElzc3VpbmclMjBDQSgxKS5jcnQwVgYI
# KwYBBQUHMAKGSmh0dHA6Ly9jZHAuZXBrLmxvY2FsL3BraS9JUURDLVZNLUNBLTAy
# LmVway5sb2NhbF9FUEslMjBJc3N1aW5nJTIwQ0EoMSkuY3J0MA0GCSqGSIb3DQEB
# CwUAA4ICAQBWHET+8Vd8jok20npiifrq3W6WCd8xkxo7qADnE6xfP7ZnlMj5+sXD
# WqsXxG94f/aM05r+yW94EJSMMy58b909tJr6kSBBoGg8/ROdG/UhJb+TU1JVYDFO
# e2NV59+TRhnwbBoNT7vm8vpix41qPk9+N8tC+Abp9BrNZpOQjUxtf8030US31SVJ
# zhdzhkM5BwEU65kbctGZFHFX/8GnlkCV6/DDKnw2+OlVQOA3Yw9zhRslNBL42Yzp
# agG/dx8ott+1cHzdgi56vSqfjHaij1e7rMGwclIIUnY5L3OAmuUfO3RI16GWqMev
# 7XPaNd/j72jpALay2zimeCi+6015drPZ+2TfniX42Qxrh0CNmJ2hzVgW5697Ertq
# FdCV/kLGtldMeR9s5YDY7mHrdsPrM6bGKYPTjQ6BAE9twcPUk5OryTUFIWMDxo7I
# vtLsjdHBB2e6/1RCFqijZVdfJkrDLkQNqxBz+984aTeVUBxCKHdMEz9lFgC2SAik
# ZBeXa36+HZ3V9mCLbda+LqHe7hZVXFP1vW95u8YPC2w+MTSIyBVjYybjy96WvHbU
# QnCUGpCQuEmttT2aOFC2qKWA3njOir4R6U7nODoG7p3sid7N3l1Vd9TsUpaNQv2S
# oWyzJ0DlRTMjcstG/pn4V5g8mwZ0lYi/P2iaIl1Hagf6HOdWI50LvjCCBn8wggRn
# oAMCAQICE20AAAAEnTWjQIaVGfsAAAAAAAQwDQYJKoZIhvcNAQELBQAwFjEUMBIG
# A1UEAxMLRVBLIFJvb3QgQ0EwHhcNMjEwMjI0MTIzMjE3WhcNMzYwMjI0MTAwODAy
# WjBFMRUwEwYKCZImiZPyLGQBGRYFbG9jYWwxEzARBgoJkiaJk/IsZAEZFgNlcGsx
# FzAVBgNVBAMTDkVQSyBJc3N1aW5nIENBMIICIjANBgkqhkiG9w0BAQEFAAOCAg8A
# MIICCgKCAgEAyl14gp4L6Sdnuv/7rt/PFFFDVdpNqednuf56xW6pneQB615JjYfI
# kc2i9VaXgoWkMcy7fDukDf6g7oy17JvWUKxEDGAeGyu02fM0if+dKe9PccxUkJDQ
# BmLTDE6OxIHnOEHeYcuOBSnIGAxVaoB0QhMidtU0D6XXpXJvxxmM4JKXFPjvFga+
# 3FClJkRj5KcXly69DHDJoLbJJ8+QRVM2xoXoRdddmeVYK8TCJnRUOMcDdlyiTYBG
# VHVdd3d5GpKp5Y2259GtDP0ZIemlSLUVY7hxNnSjZT3IWwkATXAPWv3dfZw3XwUO
# 4h5e4xjdP5VQbmHfN1J61GlHRc+HMtA3CnwwRLTYtrzd0sYfQH8ASBJJURrJlizQ
# VjY3oZ9B3oLbjP96nM1AhJBcFzJpKwJdreujOESJR90jKxQnEOUcvGaVPLePpOi9
# iQoY2pEFWhSuDBGZkbxHqyiCjKPUxmASP/cFYMZSneorJNc4GzSYmlO913LWVsFj
# ni8O9UBXzP6XOPbR5/WVfWK11goBd7nMkyrgJlilj1cRBSIS7uCthKgvw1mH8WPN
# jr8xrvACmGk2S5D3SDUOqhnK2hKKb2Wm9+qjMzKaXv8jsbpqh4yWbd4uvELt7xWE
# je9sY708JH2DRrZdprlNNMB5OUA/bDVF60Qe5Jn2O9QIaoq34zNPjbcCAwEAAaOC
# AZUwggGRMBIGCSsGAQQBgjcVAQQFAgMBAAEwIwYJKwYBBAGCNxUCBBYEFMmBY9dc
# zTnZCFrXAxdQv5dApZv2MB0GA1UdDgQWBBQcKtOZKXP/PitfYRpL8b5XpXCFUDBG
# BgNVHSAEPzA9MDsGBFUdIAAwMzAxBggrBgEFBQcCARYlaHR0cDovL2NkcC5lcGsu
# bG9jYWwvcGtpL2Vway1jcHMuaHRtbDAZBgkrBgEEAYI3FAIEDB4KAFMAdQBiAEMA
# QTALBgNVHQ8EBAMCAYYwDwYDVR0TAQH/BAUwAwEB/zAfBgNVHSMEGDAWgBQf0Xr/
# XZ/Y1NJrTg9FsSGgXew6NTA9BgNVHR8ENjA0MDKgMKAuhixodHRwOi8vY2RwLmVw
# ay5sb2NhbC9wa2kvRVBLJTIwUm9vdCUyMENBLmNybDBWBggrBgEFBQcBAQRKMEgw
# RgYIKwYBBQUHMAKGOmh0dHA6Ly9jZHAuZXBrLmxvY2FsL3BraS9JUURDLVZNLUNB
# LTAxX0VQSyUyMFJvb3QlMjBDQS5jcnQwDQYJKoZIhvcNAQELBQADggIBAA32gS4k
# eXKLEWPxtVULnJ9+iTfSyN/gTvFjdTSq5lsbdcXfNDuxjmJXEGJGhwy0uj5903fp
# +wuiT0k9SjKJN86c+Qp6t/DtCNS+nddUiya8e1Lphrtb2AqujMAnNBPCSgfYE79r
# g509zbn5FZxPor5ixmNDqnwwAjArkmDM3pjBoHaaRHx1GlRxlhIY7FSo+ivw1sQn
# i64Pq2rkvxn8Z9Gj8lMk5lJMSjh8WVX6Mt9aRPp0rPpUdIN74yaCZXvHcO0lC2p/
# /eda8VFLcXGFeJf3dqfMvZOp5/Vd062iOlMtXStpGvD5+D/x3jPNonfsTUmbJJMP
# H51c9rIw0c5+BXkTcVsrm7AIBPmpdvtl8a7SDso4uEXJ6EznFtcNR53dLDhIh9zs
# hZwLR8NAwbQsRHhEYDWZ9iQpIg6tPKSzczW455DE+t9lMsEyoObTqGrAoaKz+FtD
# d2k8rrfDmju54Mtoq8Vc5Gjm8GzI9qGWpiwSM3mMM2nKMIRBCKFf/hI1OphDeNOw
# brF2cBL6f53tXM1HACRHE0bT/w5eZGbZtWcx63FP/toqLjkY/dPO/2rNl6jtTwmi
# GiER3DRFxSMnu6YdR6tcdptJzlqF3V1W5QhYhxZDJ1X7eRs6gd7XsUcsfKiTHxrF
# uiHbjAHnspaPDhJ/5iYO/EZAYkgkblRQN7BIMYIB/TCCAfkCAQEwXDBFMRUwEwYK
# CZImiZPyLGQBGRYFbG9jYWwxEzARBgoJkiaJk/IsZAEZFgNlcGsxFzAVBgNVBAMT
# DkVQSyBJc3N1aW5nIENBAhNPAAAHqvscvJjF7zDVAAEAAAeqMAkGBSsOAwIaBQCg
# eDAYBgorBgEEAYI3AgEMMQowCKACgAChAoAAMBkGCSqGSIb3DQEJAzEMBgorBgEE
# AYI3AgEEMBwGCisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJ
# BDEWBBTaKTdm0rEkjAX8kw3sAeJnHe6+MDANBgkqhkiG9w0BAQEFAASCAQBlEe+k
# /eL1idL3zHck/iUHfFGsj0HA3alxUmKFIxjMKziIZuDln3TX4AfngEg+cGof+xI1
# VuCA9PWWdVBpeBeU1MF5lTb4CiFtDZJLxb0OiFjN5vRHR/njV4KCLmE8d2hcWZfM
# Ttd26KFfNpzgEcxPQUl+Nn0v6uI99jfwNbEaCc+YYZmmF7yS+mzZzyBAKA0AvSHR
# uETNDtjZB3bghR6lPJ0f30Q5UlmP9/f1L//r1MddpPrEamJnrpYcXipFfRGPakfp
# uYMbmwW+s00NIc+iHyqteCcOZZq3ayN4AnR+8AwRol/Wd9j7Dxrs83prmpAESq7w
# AyheV0ilL3c4SKNg
# SIG # End signature block
