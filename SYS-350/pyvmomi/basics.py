import ssl, configparser
from pyVim.connect import SmartConnect
from pyVmomi import vim


file = configparser.ConfigParser()
file.read('creds.ini')

Hostinfo = file['SERVERINFO']['host']
Userinfo = file['SERVERINFO']['user']
Passinfo = file['SERVERINFO']['password']
vCenterIP = file['SERVERINFO']['vcenter_ip']

s = ssl.SSLContext(ssl.PROTOCOL_TLSv1_2)
s.verify_mode = ssl.CERT_NONE

si = SmartConnect(host=Hostinfo, user=Userinfo, pwd=Passinfo, sslContext=s)


current_session = si.content.sessionManager.currentSession
print(f"Current Session: \nUser Name: {current_session.userName} \nSource IP: {current_session.ipAddress} \nvCenter IP: {vCenterIP} \n")

vm_name = input("Enter the name of the VM: ")

def is_folder(obj):
    """Check if the object is a folder"""
    if type(obj) == vim.Folder:
        return True


vmfolder = si.content.rootFolder.childEntity[0].vmFolder.childEntity
for vcenter_object in vmfolder:
        try:
            if vm_name:
                if vcenter_object.name == vm_name:
                    vm = vcenter_object
                    print(vm.name)
                    if vm.guest.ipAddress == None:
                        print("VM doesn't have an IP address")
                        print(f"Name: {vm.name} \nPower State: {vm.runtime.powerState} \nCPU: {vm.config.hardware.numCPU} \nMemory: {vm.config.hardware.memoryMB / 1000} \nGuest OS: {vm.config.guestFullName} \n")
                    else:
                        print(f"Name: {vm.name} \nPower State: {vm.runtime.powerState} \nIP Address: {vm.guest.ipAddress} \nCPU: {vm.config.hardware.numCPU} \nMemory: {vm.config.hardware.memoryMB / 1000} \nGuest OS: {vm.config.guestFullName} \n")
            else:
                vm = vcenter_object
                if vm.guest.ipAddress == None:
                    print("VM doesn't have an IP address")
                    print(f"Name: {vm.name} \nPower State: {vm.runtime.powerState} \nCPU: {vm.config.hardware.numCPU} \nMemory: {vm.config.hardware.memoryMB / 1000} \nGuest OS: {vm.config.guestFullName} \n")
                else:
                    print(f"Name: {vm.name} \nPower State: {vm.runtime.powerState} \nIP Address: {vm.guest.ipAddress} \nCPU: {vm.config.hardware.numCPU} \nMemory: {vm.config.hardware.memoryMB / 1000} \nGuest OS: {vm.config.guestFullName} \n")
        except AttributeError:
            print("Folder")
            # for vm in vcenter_object:
            #     if vm_name:
            #         if vm_name == vm.name:
            #             if vm.guest.ipAddress == None:
            #                 print("VM doesn't have an IP address")
            #                 print(f"Name: {vm.name} \nPower State: {vm.runtime.powerState} \nCPU: {vm.config.hardware.numCPU} \nMemory: {vm.config.hardware.memoryMB / 1000} \nGuest OS: {vm.config.guestFullName} \n")
            #             else:
            #                 print(f"Name: {vm.name} \nPower State: {vm.runtime.powerState} \nIP Address: {vm.guest.ipAddress} \nCPU: {vm.config.hardware.numCPU} \nMemory: {vm.config.hardware.memoryMB / 1000} \nGuest OS: {vm.config.guestFullName} \n")
            #     else:
            #         if vm.guest.ipAddress == None:
            #             print("VM doesn't have an IP address")
            #             print(f"Name: {vm.name} \nPower State: {vm.runtime.powerState} \nCPU: {vm.config.hardware.numCPU} \nMemory: {vm.config.hardware.memoryMB / 1000} \nGuest OS: {vm.config.guestFullName} \n")
            #         else:
            #             print(f"Name: {vm.name} \nPower State: {vm.runtime.powerState} \nIP Address: {vm.guest.ipAddress} \nCPU: {vm.config.hardware.numCPU} \nMemory: {vm.config.hardware.memoryMB / 1000} \nGuest OS: {vm.config.guestFullName} \n")