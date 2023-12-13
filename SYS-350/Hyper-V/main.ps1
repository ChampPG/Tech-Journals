# PowerOn
function Start-VMInstance {
    param (
        [string]$vmName
    )
    Start-VM -Name $vmName
}

# PowerOff
function Stop-VMInstance {
    param (
        [string]$vmName
    )
    Stop-VM -Name $vmName -Force
}

# Snapshot VMs
function New-VMSnapshot {
    param (
        [string]$vmName,
        [string]$snapshotName
    )
    Checkpoint-VM -Name $vmName -SnapshotName $snapshotName
}

# Create a Linked Clone of a VM
function New-LinkedClone {
    param (
        [string]$originalVM,
        [string]$cloneName
    )
    $Path = "C:\Users\Public\Documents\Hyper-V\Virtual hard disks\"
    $originalVHD = $Path + $originalVM + ".vhdx"
    $cloneVHD = $Path + $cloneName + ".vhdx"
    New-VHD -Path $originalVHD -Path $cloneVHD -Differencing

    New-VM -Name $cloneName -MemoryStartupBytes 1GB -NewVHDPath $cloneVHD -NewVHDSizeBytes 10GB -Generation 2 -SwitchName "LAN-INTERNAL"
    Set-Firmware -VMName $cloneName -EnableSecureBoot Off
    Checkpoint-VM -Name $cloneName -SnapshotName "Base"

    Write-Host "Would you like to turn on the VM? (Y/N): "
    $choice = Read-Host
    if ($choice -eq "Y") {
        Start-VM -Name $cloneName
    }
}

# Tweak the Performance of a VM
function Set-VMPerformance {
    param (
        [string]$vmName,
        [int]$memory, # in MB
        [int]$cpuCount
    )
    Set-VM -Name $vmName -MemoryStartupBytes ($memory * 1MB)
    Set-VMProcessor -VMName $vmName -Count $cpuCount
}

# Delete a VM from Disk
function Remove-VMInstance {
    param (
        [string]$vmName
    )
    Remove-VM -Name $vmName -Force
}

function Get-VMDetails {
    param (
        [string]$vmName
    )

    if ($null -eq $vmName) {
        Get-VM | Select-Object -Property Name, State, 
            @{Name='IPAddresses'; Expression={($_.NetworkAdapters).IPAddresses}},
            HardDrives,
            @{Name='MemoryAssignedMB'; Expression={$_.MemoryAssigned / 1MB}},
            Uptime, 
            Status
    } else {
        $vm = Get-VM -Name $vmName
        $vm | Select-Object -Property Name, State, 
            @{Name='IPAddresses'; Expression={($_.NetworkAdapters).IPAddresses}},
            HardDrives,
            @{Name='MemoryAssignedMB'; Expression={$_.MemoryAssigned / 1MB}},
            Uptime, 
            Status
    }
    
}

# Function to display menu and get user choice
function Show-Menu {
    param (
        [string]$title = 'VM Management Menu'
    )

    Clear-Host
    Write-Host "================ $title ================"

    Write-Host "1: Power On VM"
    Write-Host "2: Power Off VM"
    Write-Host "3: Snapshot VM"
    Write-Host "4: Create a Linked Clone of a VM"
    Write-Host "5: Tweak the Performance of a VM"
    Write-Host "6: Delete a VM"
    Write-Host "7: Get VM Details"
    Write-Host "Q: Quit"

    Write-Host "Select an option:"
    $choice = Read-Host
    return $choice
}

# Main loop
do {
    $userChoice = Show-Menu

    switch ($userChoice) {
        '1' {
            $vmName = Read-Host "Enter VM name to power on"
            Start-VMInstance -vmName $vmName
        }
        '2' {
            $vmName = Read-Host "Enter VM name to power off"
            Stop-VMInstance -vmName $vmName
        }
        '3' {
            $vmName = Read-Host "Enter VM name to snapshot"
            $snapshotName = Read-Host "Enter Snapshot name"
            New-VMSnapshot -vmName $vmName -snapshotName $snapshotName
        }
        '4' {
            $originalVM = Read-Host "Enter original VM name"
            $cloneName = Read-Host "Enter new clone VM name"
            New-LinkedClone -originalVM $originalVM -cloneName $cloneName
        }
        '5' {
            $vmName = Read-Host "Enter VM name to tweak"
            $memory = Read-Host "Enter new memory size (in MB)"
            $cpuCount = Read-Host "Enter new CPU count"
            Set-VMPerformance -vmName $vmName -memory $memory -cpuCount $cpuCount
        }
        '6' {
            $vmName = Read-Host "Enter VM name to delete"
            Remove-VMInstance -vmName $vmName
        }
        '7' {
            $vmName = Read-Host "Enter VM name to get details"
            Get-VMDetails -vmName $vmName
        }
        'Q' { break }
        default { Write-Host "Invalid option, please try again." }
    }

    Write-Host "Press Enter to continue..."
    Read-Host

} while ($userChoice -ne 'Q')

Write-Host "Exiting VM Management Tool."
