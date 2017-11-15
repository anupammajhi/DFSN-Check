$domain = "vcn.ds.volvo.net"

$root = "cli-hm"


$NameSpaceServers = dfsutil client property state \\$domain\$root | %{$_.trimstart("Active, ").trimstart("Online ")} | ?{$_ -like "*$root"}

$DefaultNS = $NameSpaceServers[0]

$NameSpaceServers | %{
    Write-Host "Checking $_" -ForegroundColor Green
    dfsutil client property state active \\$domain\$root $_
    dfsutil client property state \\$domain\$root
}

#Resetting Active Referral Namespace Server to as it was before test
dfsutil client property state active \\$domain\$root $DefaultNS
    dfsutil client property state \\$domain\$root
