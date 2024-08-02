###############################################################################
###This script will find all resources on a given subscription that have a
### given tag pair and replace the with a new tag pair.
### NOTE: resource group objects are not included and will not be updated
###############################################################################

#SET VARIABLES
$tenantId = "TENANT_ID" ### Replace with Tenant ID
$Subscription = "SUBSCRIPTION_ID" ### Replace with relevant subscription ID
$csvexportpath = "PATH" ### Replace with local path for csv export. If not needed, comment out lines 10 and 20
$incorrectTags = @{"TAG_NAME"="TAG_VALUE";} ### Replace with current incorrect tag Name:Value pair
$correctTags = @{"TAG_NAME"="TAG_VALUE";} ### Replace with new correct tag Name:Value pair

#Connect to relevant tenant and subscription
Connect-AzAccount -TenantId $tenantId
Set-AzContext -Subscription $Subscription

#Get all resources with incorrect tag name:value pair
$resourcestochange = Get-AzResource -Tag $incorrectTags
$resourcestochange | Export-CSV -Path $csvexportpath -encoding utf8
$count = $resourcestochange.count
Write-Host "$count resources to update"

$i=0
foreach($resource in $resourcestochange){
    Update-AzTag -ResourceId $resource.ResourceId -Tag $correctTags -Operation Merge
    $i++
}
Write-Host "$i resources have been updated"