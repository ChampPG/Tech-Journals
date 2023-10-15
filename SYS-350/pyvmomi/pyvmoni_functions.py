"""
Author: Paul Gleason
File: pyvmomi_functions.py
"""

import ssl, configparser
from pyVim.connect import SmartConnect
from pyVmomi import vim


def parse_creds(file_name):
    """Parse the credentials from the config file
    
    param file_name (str): The name of the config file

    This return is in list format: [Hostinfo, Userinfo, Passinfo, vCenterIP]
    return Hostinfo (str): The IP address of the vCenter server
    return Userinfo (str): The username of the vCenter server
    return Passinfo (str): The password of the vCenter server
    return vCenterIP (str): The IP address of the vCenter server"""
    file = configparser.ConfigParser()
    file.read(file_name)

    Hostinfo = file['SERVERINFO']['host']
    Userinfo = file['SERVERINFO']['user']
    Passinfo = file['SERVERINFO']['password']
    vCenterIP = file['SERVERINFO']['vcenter_ip']

    return Hostinfo, Userinfo, Passinfo, vCenterIP


def connect(Hostinfo, Userinfo, Passinfo, vCenterIP):
    """Connect to vCenter

    param Hostinfo (str): The IP address of the vCenter server
    param Userinfo (str): The username of the vCenter server
    param Passinfo (str): The password of the vCenter server
    param vCenterIP (str): The IP address of the vCenter server
    
    return si (obj): The connection to vCenter
    
    return None"""
    s = ssl.SSLContext(ssl.PROTOCOL_TLSv1_2)
    s.verify_mode = ssl.CERT_NONE

    si = SmartConnect(host=Hostinfo, user=Userinfo, pwd=Passinfo, sslContext=s)
    current_session = si.content.sessionManager.currentSession
    print(f"Current Session: \nUser Name: {current_session.userName} \nSource IP: {current_session.ipAddress} \nvCenter IP: {vCenterIP} \n")
    return si


def power_on_vm(si, vm_name, silent):
    """Power on a VM
    
    param si (obj): The connection to vCenter
    param vm_name (str): The name of the VM to power on
    param silent (bool): Whether or not to print the VM info
    
    return None"""
    vm = search_vms(si, vm_name, silent)
    if vm.runtime.powerState == 'poweredOff':
        vm.PowerOn()
        print(f"VM {vm_name} has been powered on")
    else:
        print(f"VM {vm_name} is already powered on")


def power_off_vm(si, vm_name, silent):
    """Power off a VM

    param si (obj): The connection to vCenter
    param vm_name (str): The name of the VM to power off
    param silent (bool): Whether or not to print the VM info
    
    return None"""
    vm = search_vms(si, vm_name, silent)
    if vm.runtime.powerState == 'poweredOn':
        vm.PowerOff()
        print(f"VM {vm_name} has been powered off")
    else:
        print(f"VM {vm_name} is already powered off")


def restore_last_snapshot_vm(si, vm_name, silent):
    """Restore the last snapshot of a VM
    
    param si (obj): The connection to vCenter
    param vm_name (str): The name of the VM to restore the snapshot
    param silent (bool): Whether or not to print the VM info
    
    return None"""
    vm = search_vms(si, vm_name, silent)
    if vm.runtime.powerState == 'poweredOn':
        print(f"VM {vm_name} is powered on. Please power off the VM before restoring a snapshot")
        power_off_vm(si, vm_name, silent)
        input("Press Enter to continue... Once the VM is powered off")
        restore_last_snapshot_vm(si, vm_name, silent)
    else:
        try:
            vm.snapshot.rootSnapshotList[-1].snapshot.RevertToSnapshot_Task()
            print(f"Snapshot {vm.snapshot.rootSnapshotList[-1].name} has been restored for VM {vm_name}")
        except:
            print(f"VM {vm_name} does not have any snapshots. Taking a snapshot now")
            take_snapshot_vm(si, vm_name, 'Base', silent)
            input("Press Enter to continue... Once the snapshot is taken")
            restore_last_snapshot_vm(si, vm_name, silent)


def delete_snapshot_vm(si, vm_name, snapshot_name, silent):
    """Delete a snapshot from a VM
    
    param si (obj): The connection to vCenter
    param vm_name (str): The name of the VM to delete the snapshot
    param snapshot_name (str): The name of the snapshot
    param silent (bool): Whether or not to print the VM info
    
    return None"""
    vm = search_vms(si, vm_name, silent)
    if vm.runtime.powerState == 'poweredOn':
        print(f"VM {vm_name} is powered on. Please power off the VM before deleting a snapshot")
        power_off_vm(si, vm_name, silent)
        input("Press Enter to continue... Once the VM is powered off")
        delete_snapshot_vm(si, vm_name, snapshot_name, silent)
    else:
        try:
            for snapshot in vm.snapshot.rootSnapshotList:
                if snapshot.name == snapshot_name:
                    snapshot.snapshot.RemoveSnapshot_Task(removeChildren=False)
                    print(f"Snapshot {snapshot_name} has been deleted for VM {vm_name}")
        except:
            print(f"VM {vm_name} does not have any snapshots. Taking a snapshot now")
            take_snapshot_vm(si, vm_name, 'Base', silent)
            input("Press Enter to continue... Once the snapshot is taken")
            delete_snapshot_vm(si, vm_name, snapshot_name, silent)


def take_snapshot_vm(si, vm_name, snapshot_name, silent):
    """Take a snapshot of a VM

    param si (obj): The connection to vCenter
    param vm_name (str): The name of the VM to take a snapshot
    param snapshot_name (str): The name of the snapshot
    param silent (bool): Whether or not to print the VM info
    
    return None"""
    vm = search_vms(si, vm_name, silent)
    if vm.runtime.powerState == 'poweredOff':
        vm.CreateSnapshot_Task(name=snapshot_name, memory=True, quiesce=False)
        print(f"Snapshot {snapshot_name} has been created for VM {vm_name}")
    else:
        print(f"VM {vm_name} is powered on. Please power on the VM before taking a snapshot")
        power_off_vm(si, vm_name, silent)
        input("Press Enter to continue... Once the VM is powered off")
        take_snapshot_vm(si, vm_name, snapshot_name, silent)


def full_clone_vm(si, vm_name, clone_name, silent):
    """Full clone a VM
    
    param si (obj): The connection to vCenter
    param vm_name (str): The name of the VM to clone
    param clone_name (str): The name of the clone
    param silent (bool): Whether or not to print the VM info
    
    return None"""
    vm = search_vms(si, vm_name, silent)
    if vm.runtime.powerState == 'poweredOn':
        print(f"VM {vm_name} is powered on. Please power off the VM before cloning")
        power_off_vm(si, vm_name, silent)
        input("Press Enter to continue... Once the VM is powered off")
        full_clone_vm(si, vm_name, clone_name, silent)
    else:
        relocate_spec = vim.vm.RelocateSpec()
        relocate_spec.datastore = vm.datastore[0]
        relocate_spec.pool = vm.resourcePool

        clone_spec = vim.vm.CloneSpec()
        clone_spec.powerOn = True
        clone_spec.location = vim.vm.RelocateSpec()

        vm.Clone(name=clone_name, folder=vm.parent, spec=clone_spec)
        print(f"Full cloned VM {vm_name} to {clone_name}")
    

def linked_clone_vm(si, vm_name, clone_name, silent):
    """Linked clone a VM
    
    param si (obj): The connection to vCenter
    param vm_name (str): The name of the VM to clone
    param clone_name (str): The name of the clone
    param silent (bool): Whether or not to print the VM info
    
    return None"""
    vm = search_vms(si, vm_name, silent)
    if vm.runtime.powerState == 'poweredOn':
        print(f"VM {vm_name} is powered on. Please power off the VM before cloning")
        power_off_vm(si, vm_name, silent)
        input("Press Enter to continue... Once the VM is powered off")
        linked_clone_vm(si, vm_name, clone_name, silent)
    else:
        relocate_spec = vim.vm.RelocateSpec()
        relocate_spec.diskMoveType = 'createNewChildDiskBacking'
        relocate_spec.pool = vm.resourcePool

        clone_spec = vim.vm.CloneSpec()
        clone_spec.powerOn = True
        clone_spec.location = relocate_spec
        try:
            clone_spec.snapshot = vm.snapshot.rootSnapshotList[0].snapshot
        except:
            print(f"VM {vm_name} does not have any snapshots. Taking a snapshot now")
            take_snapshot_vm(si, vm_name, 'Base', silent)

        vm.Clone(name=clone_name, folder=vm.parent, spec=clone_spec)
        print(f"Linked clone VM {vm_name} to {clone_name}")


def delete_vm(si, vm_name, silent):
    """Delete a VM
    
    param si (obj): The connection to vCenter
    param vm_name (str): The name of the VM to delete
    param silent (bool): Whether or not to print the VM info
    
    return None"""
    vm = search_vms(si, vm_name, silent)
    if vm.runtime.powerState == 'poweredOn':
        print(f"VM {vm_name} is powered on. Please power off the VM before deleting")
        task = power_off_vm(si, vm_name, silent)
        while task.info.state != 'success':
            pass
        delete_vm(si, vm_name, silent)
    else:
        vm.Destroy_Task()
        print(f"VM {vm_name} has been deleted")


# Work in Progress
def change_vm_network(si, vm_name, network_name, silent):
    """Change a VMs network
    
    param si (obj): The connection to vCenter
    param vm_name (str): The name of the VM to change the network
    param network_name (str): The name of the network
    param silent (bool): Whether or not to print the VM info
    
    return None"""
    vm = search_vms(si, vm_name, silent)
    index = 1
    print("Networks:")
    for vm_network in vm.network:
        print(index + " " + vm_network.name)
        index += 1
    network_index = input("Enter the index of the network to change to: ")
    network = vm.network[int(network_index)]
    index2 = 1
    for device in vm.config.hardware.device:
        if isinstance(device, vim.vm.device.VirtualEthernetCard):
            print(index2 + " " + device.deviceInfo.label)
            index2 += 1
    device_index = input("Enter the index of the device to change to: ")
    device = vm.config.hardware.device[int(device_index)-1]
    config_spec = vim.vm.ConfigSpec(deviceChange=device)
    vm.ReconfigVM_Task(config_spec)
    print(f"VM {vm_name} has had network {network} changed to {network_name}")


def print_vm(vm):
    """Print the VM info

    param vm (obj): The VM object"""
    if vm.guest.ipAddress == None:
        print(f"Name: {vm.name} \nPower State: {vm.runtime.powerState} \nIP Address: VM doesn't have an IP address \nCPU: {vm.config.hardware.numCPU} \nMemory: {vm.config.hardware.memoryMB / 1000} \nGuest OS: {vm.config.guestFullName} \n")
    else:
        print(f"Name: {vm.name} \nPower State: {vm.runtime.powerState} \nIP Address: {vm.guest.ipAddress} \nCPU: {vm.config.hardware.numCPU} \nMemory: {vm.config.hardware.memoryMB / 1000} \nGuest OS: {vm.config.guestFullName} \n")


def folder_search(si, folder, vm_name, silent):
    """Search for VMs in a folder

    param si (obj): The connection to vCenter
    param folder (obj): The folder to search
    param vm_name (str): The name of the VM to search for
    param silent (bool): Whether or not to print the VM info
    
    return vm (obj): The VM object"""
    for vm in folder.childEntity:
        if type(vm) == vim.Folder:
            folder_search(si, vm, vm_name, silent)
        else:
            if vm_name:
                if vm.name == vm_name:
                    if not silent:
                        print_vm(vm)
                    return vm
            else:
                print_vm(vm)


def search_vms(si, vm_name, silent):
    """Search for VMs in vCenter

    param si (obj): The connection to vCenter
    param vm_name (str): The name of the VM to search for
    param silent (bool): Whether or not to print the VM info

    return vm (obj): The VM object"""
    vmfolder = si.content.rootFolder.childEntity[0].vmFolder.childEntity
    for vcenter_object in vmfolder:
            if type(vcenter_object) == vim.Folder:
                folder_search(si, vcenter_object, vm_name, silent)
            else:
                if vm_name:
                    if vcenter_object.name == vm_name:
                        vm = vcenter_object
                        if not silent:
                            print_vm(vm)
                        return vm
                else:
                    vm = vcenter_object
                    print_vm(vm)
    

def exit_handler(si):
    """Disconnect from vCenter
    
    param si (obj): The connection to vCenter
    
    return None"""
    si.content.sessionManager.Logout()
    print('Logged out!')