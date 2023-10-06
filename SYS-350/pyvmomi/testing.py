import ssl, configparser
from pyVim.connect import SmartConnect

si = None

def connect(file):
    """Connect to vCenter and print out the about info
    
    :param file: File containing the credentials
    """
    file = configparser.ConfigParser()
    file.read('creds.ini')

    Hostinfo = file['SERVERINFO']['host']
    Userinfo = file['SERVERINFO']['user']
    Passinfo = file['SERVERINFO']['password']

    s = ssl.SSLContext(ssl.PROTOCOL_TLSv1_2)
    s.verify_mode = ssl.CERT_NONE

    si = SmartConnect(host=Hostinfo, user=Userinfo, pwd=Passinfo, sslContext=s)

    option = input("Enter 1 to print all Sessions or 2 to print Current Session: ")

    match option:
        case '1':
            show_connections()
        case '2':
            show_current_session()

def get_vm():
    """Print information for a particular virtual machine or recurse into a folder with depth protection"""

    option = input("Enter 1 to print all VMs or 2 to print specific VM: ")

    match option:
        case '1':
            for datacenter in si.content.rootFolder.childEntity:
                print(f"Datacenter: {datacenter.name}")
                print("VMs:")
                for vm in datacenter.vmFolder.childEntity:
                    if vm.name != "vcenter":
                        printing_vms(vm)
        case '2':
            vm_name = input("Enter the name of the VM: ")
            vm = si.content.searchIndex.FindByDnsName(None, vm_name, True)
            printing_vms(vm)

            

def printing_vms(vm):
    """Print information for a particular virtual machine or recurse into a folder with depth protection
    
    :param vm: Virtual Machine Object
    """
    if vm.guest.ipAddress == None:
        print("VM doesn't have an IP address")
        print(f"Name: {vm.name} \n Power State: {vm.runtime.powerState} \n CPU: {vm.config.hardware.numCPU} \n Memory: {vm.config.hardware.memoryMB / 1000} \n Guest OS: {vm.config.guestFullName} \n")
    else:
        print(f"Name: {vm.name} \n Power State: {vm.runtime.powerState} \n IP Address: {vm.guest.ipAddress} \n CPU: {vm.config.hardware.numCPU} \n Memory: {vm.config.hardware.memoryMB / 1000} \n Guest OS: {vm.config.guestFullName} \n")


def show_current_session():
    """Print information for the current session"""
    print("Current session info")
    print(f"Username: {si.content.sessionManager.currentSession.userName} \n vCenter IP: {self.si.content.sessionManager.currentSession.ipAddress} \n Source IP: {self.si.content.sessionManager.currentSession.callerIp}")


def show_connections():
    """Print information for all sessions that are connected"""
    aboutInfo = si.content.about
    print(aboutInfo)

    print("All sessions that are connected")
    for session in si.content.sessionManager.sessionList:
        print(f"Username: {session.userName} \n vCenter IP: {session.ipAddress} \n Source IP: {session.callerIp}")

def exit_handler():
    """Disconnect from vCenter"""
    si.content.sessionManager.Logout()
    print('Logged out!')


if __name__ == "__main__":
    connect('cred.ini')
    get_vm()
    exit_handler()