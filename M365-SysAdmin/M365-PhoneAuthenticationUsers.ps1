<#
This script will enumerate all users on the tenant and find those who are using a phone method
to authenticate. 
FYI, I had to break this script up to to get results in batches of ~2200, otherwise the script would error out
#>

###DEFINE VARIABLES###
#Provide path of the 2 output files below
$outpath = ""
$outpath2= ""

#Connect to MgGraph with appropriate scopes
Connect-MgGraph -Scopes "User.Read.All, UserAuthenticationMethod.Read.All"

#Get All Users on the tenant
#Write-Output "Getting all users on the tenant..."
$AllUsers = Get-MgUser -All
$count = $AllUsers.count

###Part1
#Iterate through first half of users and get their auth methods
$i=0
$phoneauthmethods = while($i -lt 2200){
  
    Write-Host "Getting methods for user $($AllUsers[$i].UserPrincipalName), user $i of $count"
    $methods = Get-MgUserAuthenticationMethod -UserID $AllUsers[$i].UserPrincipalName
    
    #Test whether each auth method is a phone method; if so, add the details to the hashtable
    foreach ($method in $methods){
        if ($method.AdditionalProperties["@odata.type"] -eq '#microsoft.graph.phoneAuthenticationMethod') {
            $AdditionalProperties = $method.AdditionalProperties["phoneType", "phoneNumber"] -join ' '
            [PSCustomObject]@{
                UserPrincipalName      = $AllUsers[$i].UserPrincipalName
                Name                   = $AllUsers[$i].DisplayName
                AuthenticationMethodId = $method.Id
                AdditionalProperties   = $AdditionalProperties
            }
        }
    } $i++
}

$phoneauthmethods | Export-CSV -Path $outpath -Encoding "UTF8"


###Part 2

#Iterate through the second half othe users and get their auth methods
$i=2200
$phoneauthmethods2 = while($i -lt 4445){
  
    Write-Host "Getting methods for user $($AllUsers[$i].UserPrincipalName), user $i of $count"
    $methods = Get-MgUserAuthenticationMethod -UserID $AllUsers[$i].UserPrincipalName
    
    #Test whether each auth method is a phone method; if so, add the details to the hashtable
    foreach ($method in $methods){
        if ($method.AdditionalProperties["@odata.type"] -eq '#microsoft.graph.phoneAuthenticationMethod') {
            $AdditionalProperties = $method.AdditionalProperties["phoneType", "phoneNumber"] -join ' '
            [PSCustomObject]@{
                UserPrincipalName      = $AllUsers[$i].UserPrincipalName
                Name                   = $AllUsers[$i].DisplayName
                AuthenticationMethodId = $method.Id
                AdditionalProperties   = $AdditionalProperties
            }
        }
    } $i++
}

$phoneauthmethods2 | Export-CSV -Path $outpath2 -Encoding "UTF8"
