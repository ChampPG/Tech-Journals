Invoke-WebRequest -Uri https://packages.wazuh.com/4.x/windows/wazuh-agent-4.3.10-1.msi -OutFile ${env:tmp}\wazuh-agent-4.3.10.msi; msiexec.exe /i ${env:tmp}\wazuh-agent-4.3.10.msi /q WAZUH_MANAGER='172.16.200.10' WAZUH_REGISTRATION_SERVER='172.16.200.10' WAZUH_AGENT_GROUP='windows'
