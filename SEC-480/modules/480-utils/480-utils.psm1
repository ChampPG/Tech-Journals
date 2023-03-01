function 480Banner()
{
    $banner=@"
Author: Paul Gleason

    ,---. ,---.   ,--.      ,--. ,--.  ,--.  ,--.,--.        
   /    ||  o  | /    \     |  | |  |,-'  '-.`--'|  | ,---.  
  /  '  |.'   '.|  ()  |    |  | |  |'-.  .-',--.|  |(  .-'  
  '--|  ||  o  | \    /     '  '-'  '  |  |  |  ||  |.-'  `) 
     `--' `---'   `--'       `-----'   `--'  `--'`--'`----'  
"@
    
    Write-Host $banner
}
function 480Connect([string] $server)
{
    $conn = $global:DefaultVIServer
    # Already connect?
    if ($conn){
        $msg = "Already Connect to: {0}" -f $conn

        Write-Host -ForegroundColor Green $msg
    }else {
        try {
            $conn = Connect-VIServer -Server $server
        }
        catch [Exception]{
            $exception = $_.Exception
            Write-Host -ForgroundColor Green $exception 
        }
        
    }

}
function Menu($config)
{
    Clear-Host
    480Banner
    Write-Host "
    Please select an option:
    [1] Exit
    [2] Full Clone
    [3] Linked Clone
    [4] Power on/off VM
    [5] Change Network For VM
    "
    $selection = Read-Host "Enter the option above"

    try {
        switch($selection){
            '1' {
                Clear-Host
                $conn = $global:DefaultVIServer
                # Already connect?
                if ($conn){
                    Disconnect-VIServer -server * -Force -Confirm:$false
                }
                Exit
            }
            '2' {
                Clear-Host
                FullClone($config)
            }
            '3' {
                Clear-Host
                LCloneVM($config)
            }
            '4' {
                Clear-Host
                SwitchOnOff
            }
        }
    }
    catch [Exception]{
        Write-Host "Please rerun you were outside the selection for Menu"
    }
    
}
function Get-480Config([string] $config_path)
{
    Write-Host 'Reading ' $config_path
    $conf = $null
    if ( Test-Path $config_path )
    {
        $conf = (Get-Content -Raw -path $config_path | ConvertFrom-Json)
        $msg = "Using Configuration at {0}" -f $config_path
        Write-Host -ForegroundColor "Green" $msg
    }else {
        Write-Host -ForegroundColor "Yellow" "No Configuration"
    }
    return $conf
}

# Select VM
function Select-VM([string] $folder)
{
    Write-Host "Selecting your VM" -ForegroundColor "Cyan"
    $selected_vm=$null
    try {
        $vms = Get-VM -Location $folder
        $index = 1
        foreach($vm in $vms)
        {
            # if ( $vm.name -NotLike "*.base"){
            #     Write-Host [$index] $vm.Name
            #     $index+=1
            # }
            Write-Host [$index] $vm.Name
            $index+=1
        }
        $pick_index = Read-Host "Which index number [x] do you wish?"
        try {
            $selected_vm = $vms[$pick_index -1]
            Write-Host "You picked " $selected_vm.Name -ForegroundColor "Green"
        }
        catch [Exception]{
            $msg = 'Invalid format please select [1-{0}]' -f $index-1
            Write-Host -ForgroundColor "Red" $msg
        }
        
        #not ethis is a full on vm object we can interract with
        return $selected_vm 
    }
    catch 
    {
        Write-Host "Invalid folder: $folder" -ForegroundColor "Red"    
    }

}

# Full Clone
function FullClone($config){
    Write-Host "Base Clone"

    $folder = $config.vm_folder
    $vm = Select-VM -folder $folder

    $newVMName = Read-Host "Please enter new VM Name"

    $iflinked = $false
    foreach ($realvm in Get-VM){
        if (“{0}.linked” -f $vm.name -eq $realvm.name){
            Write-Host "Link is already created"
            $iflinked = $true
            $linkedvmName = “{0}.linked” -f $vm.name
            $linkedvm = Get-VM -Name $linkedvmName
            break
        }else{
            $linkedClone = “{0}.linked” -f $vm.name 
            # To create new linked clone
            $linkedvm = New-VM -LinkedClone -Name $linkedClone -VM $vm -ReferenceSnapshot $config.snapshot -VMHost $config.esxi_host -Datastore $config.default_datastore
            break
        }
    }
    # Create full independent version from linked clone
    Write-Host "Creating full clone"
    $newvm = New-VM -Name $newVMName -VM $linkedvm -VMHost $config.esxi_host -Datastore $config.default_datastore
    
    # Create snapshot of new vm
    Write-Host "Setting base snap shot"
    $newvm | New-Snapshot -Name $config.snapshot
    
    # Removed old link
    if (!$iflinked){
        $linkedvm | Remove-VM -DeletePermanently -Confirm:$false
    }
    
    Start-Sleep -Seconds 3
    Menu($config)
}

# Linked Clone
function LCloneVM($config){
    Write-Host "Linked Clone"

    $isFound = $null
    $folder = $config.vm_folder
    $vm = Select-VM -folder $folder

    foreach ($realvm in Get-VM){
        if (“{0}.linked” -f $vm.name -eq $realvm.name){
            Write-Host "Link is already created"
            $isFound = $true
            break
        }else{
            $linkedClone = “{0}.linked” -f $vm.name 
            $isFound = $false
            break
        }
    }
    if (!$isFound){
        # To create new linked clone
        Write-Host "Creating Linked Clone"
        New-VM -LinkedClone -Name $linkedClone -VM $vm -ReferenceSnapshot $config.snapshot -VMHost $config.esxi_host -Datastore $config.default_datastore
    }

    Start-Sleep -Seconds 3
    Menu($config)
}

# Turn on and off vm
function SwitchOnOff(){
    Write-Host "Selecting your VM" -ForegroundColor "Cyan"
    $selected_vm=$null
    $vms = Get-VM
    $index = 1
    foreach($vm in $vms)
    {
        # if ( $vm.name -NotLike "*.base"){
        #     Write-Host [$index] $vm.Name
        #     $index+=1
        # }
        Write-Host [$index] $vm.Name
        $index+=1
    }
    $pick_index = Read-Host "Which index number [x] do you wish?"
    try {
        $selected_vm = $vms[$pick_index -1]
        Write-Host "You picked " $selected_vm.Name -ForegroundColor "Green"
    }
    catch [Exception]{
        $msg = 'Invalid format please select [1-{0}]' -f $index-1
        Write-Host -ForgroundColor "Red" $msg
    }

    $OnorOff = Read-Host "Would you like to turn that VM 'on' or 'off'?"

    if($OnorOff -like 'on'){
        Start-VM -VM $selected_vm -Confirm:$true -RunAsync
    }elseif ($OnorOff -like 'off') {
        Stop-VM -VM $selected_vm -Confirm:$true
    }

    

}

# Change Network Adapter
function NetworkChange(){
    
    $selected_vm
    foreach($vm in $vms)
        {
            # if ( $vm.name -NotLike "*.base"){
            #     Write-Host [$index] $vm.Name
            #     $index+=1
            # }
            Write-Host [$index] $vm.Name
            $index+=1
        }
        $pick_index = Read-Host "Which index number [x] do you wish?"
        try {
            $selected_vm = $vms[$pick_index -1]
            Write-Host "You picked " $selected_vm.Name -ForegroundColor "Green"
        }
        catch [Exception]{
            $msg = 'Invalid format please select [1-{0}]' -f $index-1
            Write-Host -ForgroundColor "Red" $msg
        }
}