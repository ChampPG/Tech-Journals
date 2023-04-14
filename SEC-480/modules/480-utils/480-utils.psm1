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
    [6] Create New Virtual Switch or Virtual Port Group
    [7] Get VM IP and MacAddresses
    [8] Windows Config
    "
    $selection = Read-Host "Enter the option above"
    
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
            SwitchOnOff($config)
        }
        '5'{
            Clear-Host
            NetworkChange($config)
        }
        '6'{
            Clear-Host
            New-Network($config)
        }
        '7'{
            Clear-Host
            Get-IP($config)
        }
        '8'{
            Clear-Host
            WindowsConfig($config)
        }
        Default {
            Write-Host -ForegroundColor "Red" "Please rerun you have selected outside the range" 
            break
        }
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

    # $isFound = $null
    $folder = $config.vm_folder
    $vm = Select-VM -folder $folder

    # foreach ($realvm in Get-VM){
    #     if (“{0}.linked” -f $vm.name -eq $realvm.name){
    #         Write-Host "Link is already created"
    #         $isFound = $true
    #         break
    #     }else{
    #         $linkedClone = “{0}.linked” -f $vm.name 
    #         $isFound = $false
    #         break
    #     }
    # }
    # if (!$isFound){
    #     # To create new linked clone
    #     Write-Host "Creating Linked Clone"
    #     New-VM -LinkedClone -Name $linkedClone -VM $vm -ReferenceSnapshot $config.snapshot -VMHost $config.esxi_host -Datastore $config.default_datastore
    # }

    $linkedClone = Read-Host "What would you like to name the linkedclone"
    Write-Host "Creating Linked Clone"
    New-VM -LinkedClone -Name $linkedClone -VM $vm -ReferenceSnapshot $config.snapshot -VMHost $config.esxi_host -Datastore $config.default_datastore

    Start-Sleep -Seconds 3
    Menu($config)
}
# Turn on and off vm
function SwitchOnOff($config){
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
   
    Menu($config)
}
function New-Network($config){
    Write-Host "
    Please select which operation you would like to do.

    [1] Only Create Virtual Switch
    [2] Only Create Virtual Port Group
    [3] Do Both Above
    [4] Assign Existing Virtual Port Group to Virtual Switch
    "
    $selection = Read-Host "Which index number [x] do you wish?"
    
    switch($selection){
        '1'{
            NewVirtualSwitch($config)
        }
        '2'{
            NewPortGroup($config)
        }
        '3'{
            NewVirtualSwitch($config)
            NewPortGroup($config)
        }
    }

    Read-Host "Press Enter to Continue"
    Menu($config)
}
Function NewVirtualSwitch($config){
    $switchName = Read-Host "What would you like to name the new virtual switch"
    $found = $null
    foreach($switch in Get-VirtualSwitch){
        if ($switchName -eq $switch.Name){
            $found = $true
            break
        }
    }
    if ($found){
        Write-Host -ForegroundColor "Red" "This switch already exists!"
    }else {
        New-VirtualSwitch -VMHost $config.esxi_host -Name $switchName
    }
}
Function NewPortGroup($config){
    $portGroupName = Read-Host "What would you like to name the new PortGroup"
    $found = $null
    foreach($group in Get-VirtualPortGroup){
        if ($portGroupName -eq $group.Name){
            $found = $true
            break
        }
    }
    if($found){
        Write-Host -ForegroundColor "Red" "This group already exists!"
    }else{
        $selected_switch = $null
        $switch = Get-VirtualSwitch
        $index = 1
        foreach($switch in $switches){
            Write-Host [$index] $switch.Name
            $index+=1
        }
        $pick_index = Read-Host "Which index number [x] do you wish?"
        try {
            $selected_switch = $vms[$pick_index -1]
            Write-Host "You picked " $selected_switch.Name -ForegroundColor "Green"
        }
        catch [Exception]{
            $msg = 'Invalid format please select [1-{0}]' -f $index-1
            Write-Host -ForgroundColor "Red" $msg
        }
        New-VirtualPortGroup -VirtualSwitch $selected_switch -Name $portGroupName
    }
}
function Get-IP($config){
    #$vm = Select-VM($config)

    Write-Host "Select VM Below to get IP, Hostname, Mac Address"

    $selected_vm=$null
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
        $selected_vm = $vms[$pick_index - 1]
        Write-Host "You picked" $selected_vm.Name -ForegroundColor "Green"
    }
    catch [Exception]{
        $msg = 'Invalid format please select [1-{0}]' -f $index-1
        Write-Host -ForgroundColor "Red" $msg
    }

    #Get-VM -Name $vm | Get-VMGuest | Format-Table VM, IPAddress

    # if ($selected_vm.PowerState -eq "PoweredOn"){
    #     $vars = @()
    #     $vmView = Get-View $selected_vm.ID
    #     $hw = $vmView.guest.net
    #     foreach($dev in $hw)
    #     {
    #         foreach ($ip in $dev.ipaddress)
    #         {
    #             $vars += $dev | Select-Object @{Name = "Name"; Expression = {$selected_vm.Name}}, @{Name = "IP"; Expression = {$ip}}, @{Name = "MAC"; Expression = {$dev.macaddress}}
    #         }
    #     }
    #     $vars | Format-Table
    # }else{
    #     Write-Host "VM is off so I can only get name and MacAddress"
    #     $adapters = Get-NetworkAdapter -VM $selected_vm | Select-Object MacAddress
    #     foreach($adapter in $adapters){
    #         $msg = 'Name = {0} | {1}' -f $selected_vm.Name, $adapter
    #         Write-Host $msg 
    #     }
    # }

    $IpAddress = Get-VM $selected_vm | Select-Object @{N="IP Address";E={@($_.Guest.IPAddress[0])}} | Select-Object -ExpandProperty "IP Address"
    $Mac = Get-VM $selected_vm | Get-NetworkAdapter -Name "Network adapter 1" | Select-Object -ExpandProperty MacAddress

    $msg = "{0} hostname={1} mac={2}" -f $IpAddress,$selected_vm,$Mac

    Write-Host $msg
    
    Read-Host "Press Enter to Continue"
    Menu($config)
}
# Change Network Adapter
function NetworkChange($config){
    
    $selected_vm=$null
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

    Get-VirtualNetwork
    $network = Read-Host "Enter network from above you would like to use"

    Get-NetworkAdapter -VM $selected_vm | Select-Object Name -ExpandProperty Name
    $adapter_select = Read-Host "What adpater would you like to change?"

    Get-VM $selected_vm | Get-NetworkAdapter -Name $adapter_select | Set-NetworkAdapter -NetworkName $network -Confirm:$false

    Read-Host "Press Enter to Continue"
    Menu($config)
}

Function WindowsConfig($config){
    
    Write-Host "Select VM Below to get IP, Hostname, Mac Address"

    $selected_vm=$null
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
        $selected_vm = $vms[$pick_index - 1]
        Write-Host "You picked" $selected_vm.Name -ForegroundColor "Green"
    }
    catch [Exception]{
        $msg = 'Invalid format please select [1-{0}]' -f $index-1
        Write-Host -ForgroundColor "Red" $msg
    }

    # Authentication
    $user = Read-Host "What user account would you like to authenticate with"
    $user_pass = Read-Host -AsSecureString "What is that user's password"

    # Gathering info for invoke script
    Write-Host""
    Invoke-VMScript -ScriptText "Get-NetAdapter | Select-Object Name" -VM $selected_vm -GuestUser $user -GuestPassword $user_pass
    Write-Host ""
    $adapterName = Read-Host "Please enter the name of the network adapter you'd like to use"

    $ip = Read-Host "What would you like the IP address to be"
    $netmask = Read-Host "What would you like the netmask to be"
    $gw = Read-Host "What would you like the gateway to be"
    $dns = Read-Host "What would you like to set the name server to"

    $cmd1 = "netsh interface ipv4 set address '$adapterName' static $ip $netmask $gw"
    $cmd2 = "netsh interface ipv4 add dns '$adapterName' $dns index=1"
    Invoke-VMScript -ScriptText $cmd1 -VM $selected_vm -GuestUser $user -GuestPassword $user_pass
    Invoke-VMScript -ScriptText $cmd2 -VM $selected_vm -GuestUser $user -GuestPassword $user_pass

    Start-Sleep -Seconds 3

    Menu($config)
}