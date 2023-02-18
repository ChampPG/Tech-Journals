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
        $conn = Connect-VIServer -Server $server
    }

}
function Menu()
{
    Write-Host "
    Please select an option:
    [1] Exit
    [2] Base Clone
    [3] Linked Clone
    "
    $selection = Read-Host "Enter the option above"

    switch($selection){
        '1' {
            $conn = $global:DefaultVIServer
            # Already connect?
            if ($conn){
                Disconnect-VIServer -server * -Force -Confirm:$false
            }
            Exit
        }
        '2' {
            BaseClone
        }
        '3' {
            LCloneVM
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
function Select-VM([string] $folder)
{
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
        #480-TODO need to deal with an invalid index | conside making this check a function
        $selected_vm = $vms[$pick_index -1]
        Write-Host "You picked " $selected_vm.Name -ForegroundColor "Green"
        #not ethis is a full on vm object we can interract with
        return $selected_vm 
    }
    catch 
    {
        Write-Host "Invalid folder: $folder" -ForegroundColor "Red"    
    }

}
function BaseClone(){
    Write-Host "Base Clone"
}

function LCloneVM(){
    Write-Host "Linked Clone"
}
# Make Selector for linked or full

# Add linked and full 