function Help-User 
{
Param(
 [Parameter(Position=0,Mandatory=$True,
 HelpMessage="Search Computer")]
[string]$a
)


function Show-Menu
{
     param (
           [string]$Title = $computername
           
     )
     Write-Host "================ $Title == $loggedin is logged in  === $uptime =============" -ForegroundColor Green
    
     Write-Host "1: Remote Assist User." -ForegroundColor Yellow
     Write-Host "2: RDP to Computer." -ForegroundColor Yellow
     Write-Host "3: WSUS Sync" -ForegroundColor Yellow
     Write-Host "4: Open C:\." -ForegroundColor Yellow
     Write-Host "5: Computer Management.." -ForegroundColor Yellow
     Write-Host "6: Force Restart" -ForegroundColor Yellow
     Write-Host "7: Enter PSSession" -ForegroundColor Yellow
     Write-Host "8: Copy Computername" -ForegroundColor Yellow
     Write-Host "9: Dell Support Info" -ForegroundColor Yellow
     Write-Host "Z: Get Specs" -ForegroundColor Yellow
     Write-Host "Q: Press 'Q' to quit." -ForegroundColor Red
}
Write-Host "================ Results for $a ================" -ForegroundColor Green
$a = "*$a*"


$script:index=-1
$computers= (Get-ADComputer -Filter {Description -Like $a} -Properties Description | Select Name,Description)

$computers | Format-Table @{name="Option";expression={$script:index;$script:index+=1}},Description, Name
$script:index=-1
$indexno = Read-Host "Please Enter Option No."

$computername = $computers[$indexno] |  foreach { $_.Name }
$loggedin = (gwmi win32_computersystem -comp $computername | select username) | foreach { $_.username }
$uptime = Get-Uptime $computername | Select-Object uptime



do
{
     Show-Menu
     $input = Read-Host "Please make a selection"
     switch ($input)
     {
           '1' {
                &Start-Process -FilePath "C:\Windows\System32\msra.exe" -Args "/Offerra $computername"
                'You chose option #1'
           } '2' {
                mstsc /v:$computername /f
                'You chose option #2'
           } '3' {
                Force-WSUSCheckin($computername)
                'You chose option #3'
           } '4' {
                 ii \\$computername\c$\
                'You chose option #4'
           } '5' {
                 compmgmt.msc /computer=$computername
                'You chose option #5'
           } '6' {
                 Restart-Computer $computername -Force
                'You chose option #6'
           } '7' {
                 Enter-PSSession $computername
                'You chose option #7'
           } '8' {
                 $computername | clip
                'You chose option #8'
           } '9' {
                 
                 [Diagnostics.Process]::Start("https://www.dell.com/support/home/ca/en/cabsdt1/product-support/servicetag/$($computername.TrimStart("PREFIX-"))/overview")

                'You chose option #9'

           } 'z' {
                 Get-PCSpecs $computername
                'You chose option #Z M8'
                 
           } 'q' {
                return
           }
     }
     pause
}
until ($input -eq 'q')
}
