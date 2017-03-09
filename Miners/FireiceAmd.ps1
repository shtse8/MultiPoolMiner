﻿$Path = '.\Bin\Cryptonight-AMD\xmr-stak-amd.exe'
$Uri = 'https://github.com/fireice-uk/xmr-stak-amd/releases/download/v1.0.0-1.3.0/xmr-stak-amd-win64.zip'

if((Test-Path $Path) -eq $false)
{
    $FolderName_Old = ([IO.FileInfo](Split-Path $Path -Leaf)).BaseName
    $FolderName_New = Split-Path (Split-Path $Path) -Leaf
    $FileName = "$FolderName_New$(([IO.FileInfo](Split-Path $Uri -Leaf)).Extension)"

    if(Test-Path $FileName){Remove-Item $FileName}
    if(Test-Path "$(Split-Path (Split-Path $Path))\$FolderName_New"){Remove-Item "$(Split-Path (Split-Path $Path))\$FolderName_New" -Recurse}
    if(Test-Path "$(Split-Path (Split-Path $Path))\$FolderName_Old"){Remove-Item "$(Split-Path (Split-Path $Path))\$FolderName_Old" -Recurse}

    Invoke-WebRequest $Uri -OutFile $FileName -UseBasicParsing
    Start-Process "7z" "x $FileName -o$(Split-Path (Split-Path $Path))\$FolderName_Old -y -spe" -Wait
    Rename-Item "$(Split-Path (Split-Path $Path))\$FolderName_Old" "$FolderName_New"
}

$Name = (Get-Item $script:MyInvocation.MyCommand.Path).BaseName

$Port = 3336

(Get-Content "$(Split-Path $Path)\config.txt") `
-replace """pool_address"" : ""[^""]*"",", """pool_address"" : ""$($Pools.Cryptonight.Host):$($Pools.Cryptonight.Port)""," `
-replace """wallet_address"" : ""[^""]*"",", """wallet_address"" : ""$($Pools.Cryptonight.User)""," `
-replace """pool_password"" : ""[^""]*"",", """pool_password"" : ""x""," `
-replace """httpd_port"" : [^""]*,", """httpd_port"" : $Port," | `
Set-Content "$(Split-Path $Path)\config.txt"

[PSCustomObject]@{
    Type = 'AMD'
    Path = $Path
    Arguments = ''
    HashRates = [PSCustomObject]@{Equihash = '$($Stats.' + $Name + '_Equihash_HashRate.Week)'}
    API = 'FireIce'
    Port = $Port
    Wrap = $false
    URI = $Uri
}