import ssl, configparser
from pyVim.connect import SmartConnect


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


vmfolder = si.content.rootFolder.childEntity[0].vmFolder.childEntity
vm = [vm for vm in vmfolder if vm.name == vm_name][0]
if vm.guest.ipAddress == None:
    print("VM doesn't have an IP address")
    print(f"Name: {vm.name} \nPower State: {vm.runtime.powerState} \nCPU: {vm.config.hardware.numCPU} \nMemory: {vm.config.hardware.memoryMB / 1000} \nGuest OS: {vm.config.guestFullName} \n")
else:
    print(f"Name: {vm.name} \nPower State: {vm.runtime.powerState} \nIP Address: {vm.guest.ipAddress} \nCPU: {vm.config.hardware.numCPU} \nMemory: {vm.config.hardware.memoryMB / 1000} \nGuest OS: {vm.config.guestFullName} \n")



