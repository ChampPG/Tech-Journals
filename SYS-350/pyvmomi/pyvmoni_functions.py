import ssl, configparser
from pyVim.connect import SmartConnect
from pyVmomi import vim

def parse_creds(file_name):
    file = configparser.ConfigParser()
    file.read(file_name)

    Hostinfo = file['SERVERINFO']['host']
    Userinfo = file['SERVERINFO']['user']
    Passinfo = file['SERVERINFO']['password']
    vCenterIP = file['SERVERINFO']['vcenter_ip']

    return Hostinfo, Userinfo, Passinfo, vCenterIP

def connect(Hostinfo, Userinfo, Passinfo, vCenterIP):
    s = ssl.SSLContext(ssl.PROTOCOL_TLSv1_2)
    s.verify_mode = ssl.CERT_NONE

    si = SmartConnect(host=Hostinfo, user=Userinfo, pwd=Passinfo, sslContext=s)
    current_session = si.content.sessionManager.currentSession
    print(f"Current Session: \nUser Name: {current_session.userName} \nSource IP: {current_session.ipAddress} \nvCenter IP: {vCenterIP} \n")
    return si

def power_on_vm(si, vm_name, silent):
    vm = search_vms(si, vm_name, silent)
    if vm.runtime.powerState == 'poweredOff':
        vm.PowerOn()
        print(f"VM {vm_name} has been powered on")
    else:
        print(f"VM {vm_name} is already powered on")

def restore_last_snapshot_vm(si, vm_name, silent):
    vm = search_vms(si, vm_name, silent)
    if vm.runtime.powerState == 'poweredOn':
        print(f"VM {vm_name} is powered on. Please power off the VM before restoring a snapshot")
        power_off_vm(si, vm_name, silent)
        input("Press Enter to continue... Once the VM is powered off")
        restore_last_snapshot_vm(si, vm_name, silent)
    else:
        try:
            vm.snapshot.rootSnapshotList[0].snapshot.RevertToSnapshot_Task()
            print(f"Snapshot {vm.snapshot.rootSnapshotList[0].name} has been restored for VM {vm_name}")
        except:
            print(f"VM {vm_name} does not have any snapshots. Taking a snapshot now")
            take_snapshot_vm(si, vm_name, 'Base', silent)
            input("Press Enter to continue... Once the snapshot is taken")
            restore_last_snapshot_vm(si, vm_name, silent)

def power_off_vm(si, vm_name, silent):
    vm = search_vms(si, vm_name, silent)
    if vm.runtime.powerState == 'poweredOn':
        vm.PowerOff()
        print(f"VM {vm_name} has been powered off")
    else:
        print(f"VM {vm_name} is already powered off")

def take_snapshot_vm(si, vm_name, snapshot_name, silent):
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


def print_vm(vm):
    if vm.guest.ipAddress == None:
        print(f"Name: {vm.name} \nPower State: {vm.runtime.powerState} \nIP Address: VM doesn't have an IP address \nCPU: {vm.config.hardware.numCPU} \nMemory: {vm.config.hardware.memoryMB / 1000} \nGuest OS: {vm.config.guestFullName} \n")
    else:
        print(f"Name: {vm.name} \nPower State: {vm.runtime.powerState} \nIP Address: {vm.guest.ipAddress} \nCPU: {vm.config.hardware.numCPU} \nMemory: {vm.config.hardware.memoryMB / 1000} \nGuest OS: {vm.config.guestFullName} \n")

def folder_search(si, folder, vm_name, silent):
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
    """Disconnect from vCenter"""
    si.content.sessionManager.Logout()
    print('Logged out!')