# Paul Gleason
# 9/29/23
# Purpose: Connect to vCenter and print out the about info

import ssl, configparser
from pyVim.connect import SmartConnect

class pyvmomi_modules:
    """Connect to vCenter and print out the about info"""
    def __init__(self):
        self.si = None

    def connect(self, file):
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

        self.si = SmartConnect(host=Hostinfo, user=Userinfo, pwd=Passinfo, sslContext=s)

        option = input("Enter 1 to print all Sessions or 2 to print Current Session: ")

        match option:
            case '1':
                self.show_connections()
            case '2':
                self.show_current_session()

    def get_vm(self):
        """Print information for a particular virtual machine or recurse into a folder with depth protection"""

        option = input("Enter 1 to print all VMs or 2 to print specific VM: ")

        match option:
            case '1':
                for datacenter in self.si.content.rootFolder.childEntity:
                    print(f"Datacenter: {datacenter.name}")
                    print("VMs:")
                    for vm in datacenter.vmFolder.childEntity:
                        if vm.name != "vcenter":
                            self.printing_vms(vm)
            case '2':
                vm_name = input("Enter the name of the VM: ")
                vm = self.si.content.searchIndex.FindByDnsName(None, vm_name, True)
                self.printing_vms(vm)

                
    @classmethod
    def printing_vms(self, vm):
        """Print information for a particular virtual machine or recurse into a folder with depth protection
        
        :param vm: Virtual Machine Object
        """
        if vm.guest.ipAddress == None:
            print("VM doesn't have an IP address")
            print(f"Name: {vm.name} \n Power State: {vm.runtime.powerState} \n CPU: {vm.config.hardware.numCPU} \n Memory: {vm.config.hardware.memoryMB / 1000} \n Guest OS: {vm.config.guestFullName} \n")
        else:
            print(f"Name: {vm.name} \n Power State: {vm.runtime.powerState} \n IP Address: {vm.guest.ipAddress} \n CPU: {vm.config.hardware.numCPU} \n Memory: {vm.config.hardware.memoryMB / 1000} \n Guest OS: {vm.config.guestFullName} \n")

    @classmethod
    def show_current_session(self):
        """Print information for the current session"""
        print("Current session info")
        print(f"Username: {self.si.content.sessionManager.currentSession.userName} \n vCenter IP: {self.si.content.sessionManager.currentSession.ipAddress} \n Source IP: {self.si.content.sessionManager.currentSession.callerIp}")
    
    @classmethod
    def show_connections(self):
        """Print information for all sessions that are connected"""
        aboutInfo = self.si.content.about
        print(aboutInfo)

        print("All sessions that are connected")
        for session in self.si.content.sessionManager.sessionList:
            print(f"Username: {session.userName} \n vCenter IP: {session.ipAddress} \n Source IP: {session.callerIp}")

    def exit_handler(self):
        """Disconnect from vCenter"""
        self.si.content.sessionManager.Logout()
        print('Logged out!')


# creds = configparser.ConfigParser()
# creds.read('creds.ini')

# Hostinfo = creds['SERVERINFO']['host']
# Userinfo = creds['SERVERINFO']['user']
# Passinfo = creds['SERVERINFO']['password']

# s = ssl.SSLContext(ssl.PROTOCOL_TLSv1_2)
# s.verify_mode = ssl.CERT_NONE
# # si = SmartConnect(host=creds['SERVERINFO']['host'], user=creds['SERVERINFO']['user'], pwd=creds['SERVERINFO']['password'], sslContext=s)

# si = SmartConnect(host=Hostinfo, user=Userinfo, pwd=Passinfo, sslContext=s)

# aboutInfo=si.content.about
# print(aboutInfo)

# print("All sessions that are connected")
# for session in si.content.sessionManager.sessionList:
#     print("Username: " + session.userName + " vCenter Server: " + session.fullName + " Vcenter IP: " + session.ipAddress)

# pause = input("Press any key to continue...")