$domain = "contoso.com"

$root = "myRoot"


$NameSpaceServers = dfsutil client property state \\$domain\$root | %{$_.trimstart("Active, ").trimstart("Online ")} | ?{$_ -like "*$root"}


$NameSpaceServers | %{
    
    Write-host "`n`n`n`n====================================================" -ForegroundColor DarkGreen

    Write-Host "Checking $_" -ForegroundColor Green
    dfsutil client property state active \\$domain\$root $_

    Write-host "Checking Active Server" -ForegroundColor Yellow
    $ActiveServer = (dfsutil client property state \\$domain\$root | %{$_.trimstart("Active, ").trimstart("Online ")} | ?{$_ -like "*$root"})[0]
    Write-Host "Active-Server : $ActiveServer"

    $targetCount = ls \\$domain\$root | Measure-Object | select -ExpandProperty count
    Write-Host $targetCount
    if($targetCount -gt 0){
        Write-Host "Target Accessible" -ForegroundColor Green
    }
    else{
        Write-Host "Target NOT Accessible"  -ForegroundColor Red
    }
}

#Resetting Active Referral Namespace Server to as it was before test
    Write-Host "`n`n`n`nResetting Active Referral Namespace Server to as it was before test"
    dfsutil cache referral flush
    
Write-Host "`n`n===================================`nChecking Share Accessibility by UNC`n===================================`n`n"

   $TargetShares = (dfsutil root \\$domain\$root | ?{$_ -like '*State="ONLINE"*' -and $_ -notlike "*$root*"})  | %{$_.SubString($_.IndexOf('"')+1,$_.IndexOf('$')-$_.IndexOf('"'))}
  
   $TargetShares | %{
    $targetDirCount = ls $_ -ErrorAction SilentlyContinue| Measure-Object | select -ExpandProperty count
    if($targetDirCount -gt 0 -or $targetDirCount -eq $null){
        Write-Host "$_ `t Target Accessible - Data Found `t`t`t Count : $targetDirCount" -ForegroundColor Green
    }
    else{
        Write-Host "$_ `t Target NOT Accessible OR Data NOT Found `t Count : $targetDirCount"  -ForegroundColor Red
    }
   }
