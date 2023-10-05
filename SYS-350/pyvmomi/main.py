# Paul Gleason
# 9/29/23
# Purpose: Connect to vCenter and print out the about info

import ssl, configparser, atexit
from pyVim.connect import SmartConnect


creds = configparser.ConfigParser()
creds.read('creds.ini')

Hostinfo = creds['SERVERINFO']['host']
Userinfo = creds['SERVERINFO']['user']
Passinfo = creds['SERVERINFO']['password']

s = ssl.SSLContext(ssl.PROTOCOL_TLSv1_2)
s.verify_mode = ssl.CERT_NONE
# si = SmartConnect(host=creds['SERVERINFO']['host'], user=creds['SERVERINFO']['user'], pwd=creds['SERVERINFO']['password'], sslContext=s)

si = SmartConnect(host=Hostinfo, user=Userinfo, pwd=Passinfo, sslContext=s)

aboutInfo=si.content.about
print(aboutInfo)

print("All sessions that are connected")
for session in si.content.sessionManager.sessionList:
    print("Username: " + session.userName + " vCenter Server: " + session.fullName + " Vcenter IP: " + session.ipAddress)

pause = input("Press any key to continue...")
si.content.sessionManager.Logout()

