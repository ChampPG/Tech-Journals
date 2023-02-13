param($network, $server)
for($ip=1;$ip -le 254;$ip++){
    $ipaddr="$network.$ip"
    $dns=Resolve-DnsName -DnsOnly $ipaddr -Server $server -ErrorAction Ignore | Select -ExpandProperty NameHost
    if (-not ([string]::IsNullOrEmpty($dns))){
        Write-Host $ipaddr $dns
    }
} 
