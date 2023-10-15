import pyvmoni_functions as pyvmomi_functions

creds = pyvmomi_functions.parse_creds('creds.ini')
connection = pyvmomi_functions.connect(creds[0], creds[1], creds[2], creds[3])

# vm_name = input("Please enter the name of a VM: ")
# pyvmomi_functions.search_vms(connection, vm_name)

# pyvmomi_functions.search_vms(connection, 'win-server19-base', False)


pyvmomi_functions.linked_clone_vm(connection, 'Rock-01-Paul', 'linked-Rock-Clone', True)

pause = input("Press Enter to continue...")

pyvmomi_functions.power_off_vm(connection, 'linked-Rock-Clone', True)

pause1 = input("Press Enter to continue...")

pyvmomi_functions.power_on_vm(connection, 'linked-Rock-Clone', True)

pause2 = input("Press Enter to continue...")

pyvmomi_functions.take_snapshot_vm(connection, 'linked-Rock-Clone', 'Linked Clone Snapshot', True)

pause3 = input("Press Enter to continue...")

pyvmomi_functions.restore_last_snapshot_vm(connection, 'linked-Rock-Clone', True)

pause4 = input("Press Enter to continue...")

pyvmomi_functions.delete_snapshot_vm(connection, 'linked-Rock-Clone', 'Linked Clone Snapshot', True)

pause5 = input("Press Enter to continue...")

pyvmomi_functions.delete_vm(connection, 'linked-Rock-Clone', True)

pause6 = input("Press Enter to continue...")

pyvmomi_functions.exit_handler(connection)
