<#
This script will add devices (requires the devices' objectID) from a CSV to an M365 security group (for Intune deployments)
#>

###DEFINE VARIABLES###
#Add Group GUID and Path to CSV below
$groupID = ""
$filepath = ""

#Connect to Microsoft Graph via Graph Powershell SDK
Connect-MgGraph -Scopes "Directory.ReadWrite.All"

#Import devices list from CSV
$devices = Import-CSV -Path $filepath

#Add each device in list to the group
foreach ($device in $devices){
    New-MgGroupMember -GroupId $groupID -DirectoryObjectId $device.Id
}