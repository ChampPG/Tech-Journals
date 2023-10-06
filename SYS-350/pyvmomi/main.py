import pyvmoni_functions as pyvmomi_functions

creds = pyvmomi_functions.parse_creds('creds.ini')
connection = pyvmomi_functions.connect(creds[0], creds[1], creds[2], creds[3])

# vm_name = input("Please enter the name of a VM: ")
# pyvmomi_functions.search_vms(connection, vm_name)

# pyvmomi_functions.search_vms(connection, 'win-server19-base', False)

# pyvmomi_functions.linked_clone_vm(connection, 'Rock-01-Paul', 'linked-Rock-Clone', False)

pyvmomi_functions.restore_last_snapshot_vm(connection, 'linked-Rock-Clone', False)

pyvmomi_functions.exit_handler(connection)
