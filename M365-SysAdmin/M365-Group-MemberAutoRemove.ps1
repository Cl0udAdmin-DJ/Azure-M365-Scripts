<#
This script will automatically remove users from a security group after a given number of days.
App Registration is needed with API permissions to read the Unified Audit Log, and read and update M365 security group members.
#>

###DEFINE VARIABLES###
#Add ObjectID of group to be maintained, tenantID, app registration ID and app registration secret below
$groupID = ""
$TenantId = ""
$clientId = ""
$clientSecret = ""
#Set the max number of days a member can be in a group before the object must be removed from the group
$max_time = (Get-Date).AddDays(-3)

###Connect to Microsoft Graph via Graph Powershell SDK###
Write-Host "Connecting to Graph..."

$pass = ConvertTo-SecureString -String $clientSecret -AsPlainText -Force
$cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $clientId, $pass

Connect-MgGraph -TenantId $TenantId -ClientSecretCredential $cred
Write-Host "Connected to MgGraph Successfully"

#Get all Group Members
$GroupMembers = Get-MgGroupMember -GroupId $groupID | Select -ExpandProperty Id

#Get all 'Add member to group' actions from the M365 Unified Audit log
$AddActions = Get-MgAuditLogDirectoryAudit -Filter "activityDisplayName eq 'Add member to group'" `
| Select ActivityDateTime, ActivityDisplayName, OperationType, TargetResources

#Iterate through each group member
foreach($member in $GroupMembers){
   
    #Get the time each member was added to the group
    $time = ($AddActions | ? {$_.TargetResources.Id -eq $member -and $_.TargetResources.Id -eq $groupID}).ActivityDateTime | Sort-Object -Descending | Select -First 1
   
    #If was added recently, note in output. If was added more than max time, remove user from group.
    if ($time -gt $max_time){
        Write-Host "Member: $member stay, he's new"
    }else{
        Remove-MgGroupMemberDirectoryObjectbyRef -GroupId $groupID -DirectoryObjectId $member
        Write-Output "Member: $member has been removed from the group, it's been too long."
    }
}

