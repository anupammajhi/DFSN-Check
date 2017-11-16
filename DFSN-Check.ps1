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
    
