$Scriptpath = split-path $SCRIPT:MyInvocation.MyCommand.Path -parent

#Enter Domain FQDN
$domain = "contoso.com"

#Enter DFS Root Name
$root = "myRoot"

$OutFile = "$Scriptpath\DFS-Check-Result.txt"

#Remove Output file if already exists
if(Test-Path $OutFile){
    Remove-Item $OutFile -Force
}

#Stop-Transcript if already running
Stop-Transcript | out-null

Start-Transcript -path $Scriptpath\DFS-Check-Result.txt -append


Write-Host "`n`n=======================================`nChecking Namespace Server Accessibility`n=======================================`n`n"

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

   $UNC = $_
   $targetDirCount = 0
    try{
        $targetDirCount = ls $UNC -ErrorAction Stop| Measure-Object | select -ExpandProperty count

        if($targetDirCount -gt 0){
            Write-Host "$UNC `t Target Accessible - Data Found `t`t Count : $targetDirCount" -ForegroundColor Green
        }
        else{
            Write-Host "$UNC `t Target Accessible - NO Data Found `t`t Count : $targetDirCount"  -ForegroundColor Yellow
        }
    }
    catch [System.Management.Automation.ItemNotFoundException]{
        #Item Not Found Exception
        Write-Host "$UNC `t Target NOT Accessible `t`t`t`t`t Count : NA"  -ForegroundColor Red
    }
    catch{
        #All other Exceptions
        Write-Host "$UNC `t Target NOT Accessible `t`t`t`t`t Count : NA `t`t`t $($_.Exception.Message)"  -ForegroundColor Red
    }
        
    
   }


   Stop-Transcript | out-null
