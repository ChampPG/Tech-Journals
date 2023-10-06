import ssl, configparser
from pyVim.connect import SmartConnect


file = configparser.ConfigParser()
file.read('creds.ini')

Hostinfo = file['SERVERINFO']['host']
Userinfo = file['SERVERINFO']['user']
Passinfo = file['SERVERINFO']['password']

s = ssl.SSLContext(ssl.PROTOCOL_TLSv1_2)
s.verify_mode = ssl.CERT_NONE

si = SmartConnect(host=Hostinfo, user=Userinfo, pwd=Passinfo, sslContext=s)


current_session = si.content.sessionManager.currentSession
print(f"Current Session: \n User Name: {current_session.userName} \n Source IP: {current_session.callerIp} \n vCenter IP: {current_session.ipAddress} \n")

vm_name = input("Enter the name of the VM: ")

try:
    vmfolder = si.content.rootFolder.childEntity[0].vmFolder.childEntity
    vm = [vm for vm in vmfolder if vm.name == vm_name][0]
    if vm.guest.ipAddress == None:
        print("VM doesn't have an IP address")
        print(f"Name: {vm.name} \n Power State: {vm.runtime.powerState} \n CPU: {vm.config.hardware.numCPU} \n Memory: {vm.config.hardware.memoryMB / 1000} \n Guest OS: {vm.config.guestFullName} \n")
    else:
        print(f"Name: {vm.name} \n Power State: {vm.runtime.powerState} \n IP Address: {vm.guest.ipAddress} \n CPU: {vm.config.hardware.numCPU} \n Memory: {vm.config.hardware.memoryMB / 1000} \n Guest OS: {vm.config.guestFullName} \n")
except:
    print("VM not found")


