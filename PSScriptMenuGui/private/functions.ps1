function Hide-Console {
    Write-Verbose 'Hiding PowerShell console...'
    Add-Type -Name Window -Namespace Console -MemberDefinition '
    [DllImport("Kernel32.dll")]
    public static extern IntPtr GetConsoleWindow();

    [DllImport("user32.dll")]
    public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);
    '
    $consolePtr = [Console.Window]::GetConsoleWindow()
    [Console.Window]::ShowWindow($consolePtr, 0) # 0 = hide
}

Function New-GuiHeading {
    param(
        [Parameter(Mandatory)][string]$name
    )
    $string = Get-Content "$moduleRoot\xaml\heading.xaml"
    $string = $string.Replace('INSERT_SECTION_HEADING',(Get-XamlSafeString $name) )
    $string = $string.Replace('INSERT_ROW',$row)
    $script:row++

    return $string
}

Function New-GuiRow {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][PSCustomObject]$item
    )
    Write-Verbose $item

    $string = Get-Content "$moduleRoot\xaml\item.xaml"
    $string = $string.Replace('INSERT_BACKGROUND_COLOR',$buttonBackgroundColor)
    $string = $string.Replace('INSERT_FOREGROUND_COLOR',$buttonForegroundColor)
    $string = $string.Replace('INSERT_BUTTON_TEXT',(Get-XamlSafeString $item.Name) )
    if ($item.Description) {
        $string = $string.Replace('INSERT_DESCRIPTION',(Get-XamlSafeString $item.Description) )
    }
    else {
        $string = $string.Replace('INSERT_DESCRIPTION','')
    }
    $string = $string.Replace('INSERT_BUTTON_NAME',$item.Reference)
    $string = $string.Replace('INSERT_ROW',$row)
    $script:row++

    return $string
}

Function Get-XamlSafeString {
    param(
        [Parameter(Mandatory)][string]$string
    )
    $string = $string.Replace('&','&amp;').Replace('<','&lt;').Replace('>','&gt;').Replace('"','&quot;')
    $string = $string -replace '&lt;\s*?LineBreak\s*?\/\s*?&gt;','<LineBreak />'

    return $string
}

Function New-GuiForm {
    param (
        [Parameter(Mandatory)][array]$inputXml
    )
    $inputXML = $inputXML -replace 'mc:Ignorable="d"','' -replace "x:N",'N' -replace '^<Win.*','<Window'

    [void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')
    [xml]$xaml = $inputXML
    $reader = (New-Object System.Xml.XmlNodeReader $xaml)
    try {
        $form = [Windows.Markup.XamlReader]::Load($reader)
    }
    catch {
        Write-Warning "Unable to parse XML!
Ensure that there are NO SelectionChanged or TextChanged properties in your textboxes (PowerShell cannot process them).
Note that this module does not currently work with PowerShell 7-preview and the VS Code integrated console."
        throw
    }

    $script:buttons = @()
    $xaml.SelectNodes("//*[@Name]") | ForEach-Object {
        try {
            $script:buttons += $Form.FindName($_.Name)
        }
        catch {
            throw
        }
    }

    return $form
}

Function Invoke-ButtonAction {
    param(
        [Parameter(Mandatory)][string]$buttonName
    )
    Write-Verbose "$buttonName clicked"

    $csvMatch = $csvData | Where-Object {$_.Reference -eq $buttonName}
    Write-Verbose $csvMatch

    try {
        $csvMatch | Start-Script -ErrorAction Stop
    }
    catch {
        Write-Error $_
    }
}

Function Start-Script {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
        [ValidateSet('.\itsCleanable.ps1','cmd','powershell_file','powershell_inline','pwsh_file','pwsh_inline')]
        [string]$method,

        [Parameter(Mandatory,ValueFromPipelineByPropertyName)][string]$command,

        [Parameter(ValueFromPipelineByPropertyName)][string]$arguments
    )

    if ($method -eq 'cmd') {
        if ($arguments) {
            $process = New-Object System.Diagnostics.Process
            $process.StartInfo.FileName = $command
            $process.StartInfo.Arguments = $arguments
            $process.StartInfo.WorkingDirectory = $PWD
            $process.Start()
        }
        else {
            Start-Process -FilePath $command -Verbose:$verbose
        }
        return
    }

    $psArguments = @()
    $psArguments += '-ExecutionPolicy Bypass'
    $psArguments += '-NoLogo'
    if ($noExit) {
        $psArguments += '-NoExit'
    }
    if ($arguments) {
        $psArguments += $arguments
    }

    $splitMethod = $method.Split('_')
    $encodedCommand = [Convert]::ToBase64String( [System.Text.Encoding]::Unicode.GetBytes($command) )
    switch ($splitMethod[0]) {
        powershell {
            $filePath = 'powershell.exe'
        }
        pwsh {
            $filePath = 'pwsh.exe'
        }
    }
    switch ($splitMethod[1]) {
        file {
            $psArguments += "-File `"$command`""
        }
        inline {
            $psArguments += "-EncodedCommand `"$encodedCommand`""
        }
    }

    $psArguments | ForEach-Object { Write-Verbose $_ }
    #Start-Process -FilePath $filePath -ArgumentList $psArguments -Verbose:$verbose
	

    if ($command) {
        if ($command -eq '.\itsCleanable.ps1') {
			Start-Process -FilePath $filePath "-ExecutionPolicy Bypass -NoProfile -NoExit -NoLogo -Command `"pushd \`"$moduleRoot\start\`"; & \`"$command`"`"" -Verb RunAs -Verbose:$verbose
        }
        elseif ($command -eq '.\itsDiagnostics.ps1') {
			Start-Process -FilePath $filePath "-ExecutionPolicy Bypass -NoProfile -NoExit -NoLogo -Command `"pushd \`"$moduleRoot\start\`"; & \`"$command`"`"" -Verb RunAs -Verbose:$verbose
        }
        elseif ($command -eq '.\itsCMD.ps1') {
            Start-Process -FilePath $filePath "-ExecutionPolicy Bypass -NoProfile -NoExit -NoLogo -Command `"pushd \`"$moduleRoot\old\`"; & \`"$command`"`"" -Verb RunAs -Verbose:$verbose
        }
        elseif ($command -eq '.\itsControl.ps1') {
            Start-Process -FilePath $filePath "-ExecutionPolicy Bypass -NoProfile -NoExit -NoLogo -Command `"pushd \`"$moduleRoot\old\`"; & \`"$command`"`"" -Verb RunAs -Verbose:$verbose
        }
        elseif ($command -eq '.\itsDevmgmt.ps1') {
            Start-Process -FilePath $filePath "-ExecutionPolicy Bypass -NoProfile -NoExit -NoLogo -Command `"pushd \`"$moduleRoot\old\`"; & \`"$command`"`"" -Verb RunAs -Verbose:$verbose
        }
        elseif ($command -eq '.\itsDisk.ps1') {
            Start-Process -FilePath $filePath "-ExecutionPolicy Bypass -NoProfile -NoExit -NoLogo -Command `"pushd \`"$moduleRoot\old\`"; & \`"$command`"`"" -Verb RunAs -Verbose:$verbose
        }
        elseif ($command -eq '.\itsMMC.ps1') {
            Start-Process -FilePath $filePath "-ExecutionPolicy Bypass -NoProfile -NoExit -NoLogo -Command `"pushd \`"$moduleRoot\old\`"; & \`"$command`"`"" -Verb RunAs -Verbose:$verbose
        }
        elseif ($command -eq '.\itsPH.ps1') {
            Start-Process -FilePath $filePath "-ExecutionPolicy Bypass -NoProfile -NoExit -NoLogo -Command `"pushd \`"$moduleRoot\old\`"; & \`"$command`"`"" -Verb RunAs -Verbose:$verbose
        }
        elseif ($command -eq '.\itsRegedit.ps1') {
            Start-Process -FilePath $filePath "-ExecutionPolicy Bypass -NoProfile -NoExit -NoLogo -Command `"pushd \`"$moduleRoot\old\`"; & \`"$command`"`"" -Verb RunAs -Verbose:$verbose
        }
		elseif ($command -eq '.\itsTaskmgr.ps1') {
			Start-Process -FilePath $filePath "-ExecutionPolicy Bypass -NoProfile -NoExit -NoLogo -Command `"pushd \`"$moduleRoot\old\`"; & \`"$command`"`"" -Verb RunAs -Verbose:$verbose
		}
		elseif ($command -eq '.\itsStart.ps1') {
			Start-Process -FilePath $filePath "-ExecutionPolicy Bypass -NoProfile -NoExit -NoLogo -Command `"pushd \`"$moduleRoot\old\`"; & \`"$command`"`"" -Verb RunAs -Verbose:$verbose
		}
        return
    }
	
	Start-Process -FilePath $filePath -ArgumentList $psArguments -Verbose:$verbose
}
# SIG # Begin signature block
# MIIPaAYJKoZIhvcNAQcCoIIPWTCCD1UCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUTjlv6r75+EZ6chEQzfiaRZem
# RKWgggzVMIIGTjCCBDagAwIBAgITTwAAB6r7HLyYxe8w1QABAAAHqjANBgkqhkiG
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
# BDEWBBSKjeqiFqcepngbJgkjeJhlrx4PcjANBgkqhkiG9w0BAQEFAASCAQCjcHMs
# cPTYAn4/DVi4U7P3YFMV5AHT+r1pwUMIDS+TYowLg7Bk/jx5LKf671ehXuCc3XY1
# l5fFFL75CTwfU9/f9wOmCjFQ0BrVUwlpE/FhqM99R7tmz5zJ0qtYojQjyyz6pkAB
# j/NeG4aaRGztLgmPw7a7JgtEPLrbZKPIhELkYMojvrQZ2sgZN8zD0T9TeAY/QbSj
# t5IDc6dBw6y/2kdntZRUqAnkhA2UG0MFRGnTYdedcy3BEqB9xmcj87iKLwghlyzf
# rIkZOZCBMwVGIyAYSu5uiFXvuxfpZP9j1gfVsuOh2a/YRTgMFdgjd72DFfbbKH+0
# uSsjHFjIBZfDSBc6
# SIG # End signature block
