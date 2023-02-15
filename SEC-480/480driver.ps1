Import-Module '480-utils' -Force
#Call the Banner Function
480Banner
$conf = Get-480Config -config_path = "/home/paul/Documents/Tech-Journals/SEC-480/480.json"
480Connect -server $conf.vcenter_server

Write-Host "Selecting your VM" -ForegroundColor "Cyan"

Select-VM -folder $conf.vm_folder