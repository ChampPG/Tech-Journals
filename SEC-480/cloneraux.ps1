###################
#  cloneraux.ps1  #
#   Paul Gleason  #
###################

# Check if connected to server
$connectCheck = $global:defaultviserver | Select-Object Name -ExpandProperty Name

# if not connected prompt to connect
if ( $connectCheck -eq ""){
    #Connect to vcenter
    $vcenterdomain = Read-Host "Please enter domain for vcenter"
    Connect-VISever -Server $vcenterdomain
}

# Show hosts
Write-Host "--VM Host--"
Get-VMHost | Select-Object Name -ExpandProperty Name
Write-Host "-----------"
$vmhostIP = Read-Host "Please enter VM Host IP you would like to use"

# Show VMs
Write-Host "--VMs--"
Get-VM | Select-Object Name -ExpandProperty Name
Write-Host "-------"
$vmname = Read-Host "Please enter VM that you would like to clone"

# Show VM Snapshots
Write-Host "--Snapshots--"
Get-Snapshot -VM $vmname | Select-Object Name -ExpandProperty Name
Write-Host "-------------"
$snapshotName = Read-Host "Enter Snapshot that you would like to clone"

# Show Datastores
Write-Host "--Datastores--"
Get-Datastore | Select-Object Name -ExpandProperty Name
Write-Host "--------------"
$dsName = Read-Host "Select Datastore you would like to use"

#  Get Clone name
$cloneName = Read-Host "Enter the name for the clone"

# Get vmhost
$vmhost = Get-VMHost -Name $vmhostIP
# Get VM
$vm = Get-VM -Name $vmname
# Get snapshot name
$snapshot = Get-Snapshot -VM $vm -Name $snapshotName
# Get Data Store
$ds = Get-Datastore -Name $dsName
# The name of the vm replaces {0}
$linkedClone = $cloneName
# To create new linked clone
$linkedvm = New-VM -LinkedClone -Name $linkedClone -VM $vm -ReferenceSnapshot $snapshot -VMHost $vmhost -Datastore $ds
# Set Adapter
$linkedvm | Get-NetworkAdapter | Set-NetworkAdapter -NetworkName 480-WAN
