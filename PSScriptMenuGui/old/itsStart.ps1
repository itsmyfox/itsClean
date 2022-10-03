﻿# Выставляем параметры консоли. По моему желанию консоль черная, текст белый, так привычнее.
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

function Get-choice {
  do {
    write-host "Y/N"
    write-host "y/n"
    write-host "или"
    write-host "Д/Н"
    write-host "д/н"
    write-host -nonewline "Необходимо исправлять неработающий пуск? : "
    $choice = read-host
    write-host ""
    $ok = @("Y","y","N","n","Д","д","Н","н","X","x","Х","х") -contains $choice
    if ( -not $ok) { write-host "Неверный выбор. Введите y/n или д/н в любом регистре." }
  }
  until ( $ok )
  
  $yes = @("Y","y","Д","д") -contains $choice
  if ( $choice -in $yes ) {
	  
	  # Сообщение о подтверждении или отказе от исправления неработающего пуска.
	  write-host "Вы подтвердили исправления неработающего пуска - 'Y'"
	  
      # Добавляем в реестр параметр EnableXAMLStartMenu со значением "0". 
	  REG ADD "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /V EnableXAMLStartMenu /T REG_DWORD /D 0 /F 

	  # Перезапускаем explorer 
	  taskkill /f /im explorer.exe 
	  start explorer.exe 

	  # Перезапуск службы Удостоверение приложения (AppIDSvc) 
	  # Определяет и проверяет удостоверение приложения. Отключение данной службы делает невозможным принудительное применение политики AppLocker. 

	  Stop-Service -Name "AppIDSvc"
	  Start-Service -Name "AppIDSvc"

	  # Выдать окно уведомления о перезагрузке ПК.
	  $wshell = New-Object -ComObject Wscript.Shell
	  $Output = $wshell.Popup("Исправление пуска успешно произведено. Пожалуйста, перезапустите компьютер.")
  }
  else{
	  write-host "Вы отказались от исправления неработающего пуска - 'N'"
  }
}

# Переменные
$Date = Get-Date -Format "dd_MM_yyyy-HH_mm"
$DateInfo = Get-Date -Format "dd.MM.yyyy HH:mm"
$Username = "СИСТЕМА"
$version = "3.2.0"
$Dates = "22.04.2022"
$IP = "10.1.114.24"

# Название окна:
[System.Console]::Title = "Start $env:computername | $env:USERDNSDOMAIN | itsStart | Version: $version | Update $Dates"

# Запустить подтверждение исправления.
Get-choice


[Environment]::Exit(0)
# SIG # Begin signature block
# MIIPaAYJKoZIhvcNAQcCoIIPWTCCD1UCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUvKzUktQhy/S41PIeyoxv2coC
# /oygggzVMIIGTjCCBDagAwIBAgITTwAAB6r7HLyYxe8w1QABAAAHqjANBgkqhkiG
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
# BDEWBBRKJY5kfMVqOmvC8fMk92DZCdG4AzANBgkqhkiG9w0BAQEFAASCAQCMwjdQ
# WNYub/dF0CaJunZHi2QjeJGksFGQjPWENEUXakegSQmOuiWAmyDPmTGSJ+FsN7jn
# atxeuDedhe1gITsLxGdX5svMZ5DCTSSu8jmi0XdrwXYMQCLTv9Y6QmGcBo0V8AKH
# Cmyx6+XhcRROjkXYoUhCJ2zLBe+alNvf8prQ4040pYU62zo0/8HiZiohuqp8/wj/
# TgOgNBcdwOdA8j/JmTsB6yjJGg/vB7x1wMxCFtJsy/LgYGekLpHwmeLoMwjP2C6B
# mTvr1VeU21A9HprdX4zgYKqvmENyvxJ4F568btk7mPe1Ba7qdROqD3LjoA6uLrOq
# QPdbC+S6vc7plQ17
# SIG # End signature block
