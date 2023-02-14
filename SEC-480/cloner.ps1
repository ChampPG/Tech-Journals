################
#  Cloner.ps1  #
# Paul Gleason #
################

# Show hosts
Write-Host "--VM Host--"
Get-VMHost | Select-Object Name -ExpandProperty Name
Write-Host "-----------"
$vmhostIP = Read-Host "Please enter VM Host IP you would like to use:"

# Show VMs
Write-Host "--VMs--"
Get-VM | Select-Object Name -ExpandProperty Name
Write-Host "-------"
$vmname = Read-Host "Please enter VM that you would like to clone:"

# Show VM Snapshots
Write-Host "--Snapshots--"
Get-Snapshot -VM $vmname | Select-Object Name -ExpandProperty Name
Write-Host "-------------"
$snapshotName = Read-Host "Enter Snapshot that you would like to clone:"

# Show Datastores
Write-Host "--Datastores--"
Get-Datastore | Select-Object Name -ExpandProperty Name
Write-Host "--------------"
$dsName = Read-Host "Select Datastore you would like to use:"

# New VM name
$newVMName = Read-Host "Please enter new VM Name:"

$vm = Get-VM -Name $vmname
# Get snapshot name
$snapshot = Get-Snapshot -VM $vm -Name $snapshotName
# Get vmhost
$vmhost = Get-VMHost -Name $vmhostIP
# Get Data Store
$ds = Get-Datastore -Name $dsName
# The name of the vm replaces {0}
$linkedClone = “{0}.linked” -f $vm.name 
# To create new linked clone
$linkedvm = New-VM -LinkedClone -Name $linkedClone -VM $vm -ReferenceSnapshot $snapshot -VMHost $vmhost -Datastore $ds
# Create full independent version from linked clone
$newvm = New-VM -Name $newVMName -VM $linkedvm -VMHost $vmhost -Datastore $ds
# Create snapshot of new vm
$newvm | New-Snapshot -Name $snapshotName
# Removed old link
$linkedvm | Remove-VM -DeletePermanently
