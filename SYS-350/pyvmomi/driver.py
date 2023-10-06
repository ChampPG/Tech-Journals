# Paul Gleason
# 10/05/23
# Purpose: Connect to vCenter and print out the about info

import pyvmomi_modules as pm

connection = pm.pyvmomi_modules()

connection.connect('cred.ini')
connection.get_vm()
connection.exit_handler()
