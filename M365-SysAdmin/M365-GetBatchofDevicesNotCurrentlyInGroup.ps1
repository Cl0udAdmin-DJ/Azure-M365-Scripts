<#
This script will get all recently active Windows Devices that exist in group A but not in group B.
Recently active is defined as having a user sign in in the last 30 days.
My original use case was to onboard devices to Microsoft Sentinel in batches of 300.
#>

###DEFINE VARIABLES###
#Provide file path of output CSV file, GUID of Group A, GUID of Group B, and Batch Size that you would like to generate below
$outfilepath = ""
$groupA = ""
$groupB = ""
$BatchSize = 300
$CutoffDate = (Get-Date).AddDays(-30)

###Connect to Microsoft Graph via Graph Powershell SDK###
Connect-MgGraph -Scopes "Device.Read.All"

#Get all devices on tenant that have signed in over the last 30 days
$AllDevices = Get-MgDevice -All | Where-Object {$_.approximateLastSignInDateTime -gt $CutoffDate}

#Get all devices in Autopilot Devices group
$AutopilotDevices = Get-MgGroupMember -GroupId $groupA -CountVariable CountVar -All -ConsistencyLevel eventual
#Get all devices in Sentinel Deployment group
$SentinelDevices = Get-MgGroupMember -GroupId $groupB -Sort "displayName asc" -CountVariable CountVar -All -ConsistencyLevel eventual

#Get all Autopilot devices that have signin Activity in the last 30 days
$InUseDevices = $AutopilotDevices | Where-Object {$AllDevices.ID -contains $_.ID}

#Further filter down to devices not currently in the Sentinel Onboarding group
$EligibleDevices = $InUseDevices | Where-Object {$SentinelDevices.ID -NotContains $_.ID}

#Get all eligible devices that have Windows OS
$EligibleWindowsDevices = $EligibleDevices | Where-Object {$_['operatingSystem'] -eq 'Windows'}

#Select a random batch of 200 from the list
$NextBatch = Get-Random -InputObject $EligibleWindowsDevices -Count $BatchSize

#Export the list to CSV
$NextBatch | Export-CSV -Path $outfilepath -Encoding UTF8