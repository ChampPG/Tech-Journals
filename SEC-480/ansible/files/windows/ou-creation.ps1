New-ADOrganizationalUnit -Name "blue1" -Path "DC=blue1,DC=local"

New-ADOrganizationalUnit -Name "Accounts" -Path "OU=blue1,DC=blue1,DC=local"
New-ADOrganizationalUnit -Name "Groups" -Path "OU=Accounts,OU=blue1,DC=blue1,DC=local"

New-ADOrganizationalUnit -Name "Computer" -Path "OU=blue1,DC=blue1,DC=local"
New-ADOrganizationalUnit -Name "Workstations" -Path "OU=Computer,OU=blue1,DC=blue1,DC=local"
New-ADOrganizationalUnit -Name "Servers" -Path "OU=Computer,OU=blue1,DC=blue1,DC=local"