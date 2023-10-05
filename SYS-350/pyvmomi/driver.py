# Paul Gleason
# 10/05/23
# Purpose: Connect to vCenter and print out the about info

import pyvmomi_modules

connection = pyvmomi_modules.connect('creds.ini')
connection.get_vm()
pyvmomi_modules.exit_handler()
