function Elevate() {
param (     
[string]$CommandLine = $(throw "Please specify a exe path" )
)
Write-Warning "Elevating $CommandLine"
   If (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
  Write-Host "Script is not run with administrative user"

  If ( [convert]::ToInt32((Get-WmiObject Win32_OperatingSystem | select BuildNumber).BuildNumber) -ge 6000) {
    Write-Host "Found UAC-enabled system. Elevating ..."

    
    Write-Host "Command line to run:  $CommandLine"
 
    Start-Process -FilePath PowerShell.exe -Verb Runas -ArgumentList "$CommandLine">out.txt

  } else {
    Write-Host "System does not support UAC"
    Write-Warning "This script requires administrative privileges. Elevation not possible. Please re-run with administrative account."
  }
  Break
}
else
{
Write-Host "Script already run with administrative privileges" -foregroundcolor Green
}

Write-Verbose "Script is now running elevated"

}

function Ensure-Folder()
{
param (     
[string]$path,
[string]$name
)

if ((Test-Path -path $path) -eq $True) 
{ 
  write-Warning "$name already exists; creation skypped"
     
}
else
{
    md $path 
}

}

function Red-Host-Default()
{
param (     
[string]$description,
[string]$defaultValue 
)

$val=Read-Host - Prompt "Choose db path[$defaultValue]"
$val=if ($val -eq "") {  $defaultValue } else { $val }

return $val;
}

function Get-MongoDbPath()
{
param (     
[string]$container
)
 $file= Get-ChildItem -Path $container -Filter mongod.exe -Recurse
 return $file.FullName
}

function InstallAsService() {
param (     [string]$dbpath = $(throw "Please specify a db path" ),
            [string]$logpath = $(throw "Please specify a log path" ),
            [string]$confpath = $(throw "Please specify a conf path" ),
            [bool]$install )


Ensure-Folder $dbpath "Database"
Ensure-Folder $logpath "Logs"

$i=1
$tmp=$confpath
while ((Test-Path -path $tmp) -eq $True) 
{
 Write-Warning "config file exists. Cannot overwrite it. new configuration will be saved as  $confpath.$i"
  $tmp= $confpath+".$i"
  $i++
}
$confpath=$tmp



[System.IO.File]::AppendAllText("$confpath", "dbpath=$dbpath`r`n")
[System.IO.File]::AppendAllText("$confpath", "logpath=$logpath\\mongo.log`r`n")
[System.IO.File]::AppendAllText("$confpath", "smallfiles=true`r`n")
[System.IO.File]::AppendAllText("$confpath", "noprealloc=true`r`n")



$filePath=Get-MongoDbPath  "$env:ProgramFiles"+"\\MongoDb\\"
if($filePath -eq $null) 
{
    Write-Host "searching in file x86"
    $filePath=Get-MongoDbPath  "$env:ProgramFiles(x86)"+"\\MongoDb\\"
}

if($filePath -eq $null) 
{
    Write-Host "searching in file x86"
    $filePath=Get-MongoDbPath  "$env:ProgramFiles"
}

if($filePath -eq $null) 
{
    Write-Host "searching in file x86"
    $filePath=Get-MongoDbPath  "$env:ProgramFiles(x86)"
}
if($filePath -eq $null)
{
    $filePath=Read-Host - Prompt "Unable to find mongo db path, please insert manually"
}

$service
if(($service=Get-Service -Name mongodb ) -ne $null)
{
    $confirmation = Read-Host "Service already exist, remove it and recreare?"
    if ($confirmation -eq 'y' -or $confirmation -eq 'Y') {
    Write-host "stopping Service mongodb from $server" -ForegroundColor Green
    sc.exe  stop mongodb #Stop Service
    Start-Sleep -s 10 #Pause 10 seconds to wait for service stopped
    Write-host "Disabling Service mongodb from $server" -ForegroundColor Green
    sc.exe config mongodb start= disabled #Disable Service
    Write-host "Removing Service mongodb from $server" -ForegroundColor Green
    sc.exe  delete mongodb #Delete Service
}
else
{
    return
}
}

& $filePath --config $confpath --install
set-service mongodb -startuptype automatic
Start-Sleep -s 2
$service=Get-Service -Name mongodb
$service.Start()
Write-Host "waiting for start"
$service.WaitForStatus("Running")

$service





}
Write-Host "line"
Write-Host $MyInvocation.Line 
Write-Host "InvocationName"
Write-Host $MyInvocation.InvocationName
Write-Host "Definition"
Write-Host $MyInvocation.MyCommand.Definition

Elevate $MyInvocation.MyCommand.Definition

Write-Host "Choose db path[C:\\mongodb\\]"

$dbpath=Red-Host-Default  "Choose db path" "C:\\mongodb\\db\\"
$logPath=Red-Host-Default  "Choose log path" "C:\\mongodb\\log\\"
$configpath=Red-Host-Default  "Choose config path" "C:\\mongodb\\mongod.cfg"

Write-Host "Settings:"
Write-Host "------------------------------"
Write-Host "Config Path: $configpath"
Write-Host "Log Path   : $logPath"
Write-Host "Db Path    : $dbpath"

$confirmation = Read-Host "Are you Sure You Want To Proceed[y/n]:"
if ($confirmation -eq 'y' -or $confirmation -eq 'Y') {
  InstallAsService $dbpath $logPath $configpath $True
}
else
{
exit}

Read-Host