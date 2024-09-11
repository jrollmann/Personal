#Connect to Graph
Connect-MgGraph

#Connect to Exchange Online
Connect-ExchangeOnline

#Define Device Group from Entra
$devicegroup = "<DEVICE GROUP NAME>"

#Define DL Group UPN
$dlupn = "<DL UPN>"

#Grab Group ID
$groupid = (Get-MgGroup -Filter "DisplayName eq '$devicegroup'").Id

try{

    #Get devices in the specified Entra Group
    $groupMembers = Get-MgGroupMember -GroupId $groupid -All

    #Create array to hold primary emails
    $primaryEmails = @()

    foreach ($member in $groupMembers) {
        #Grab device id
        $deviceid = (Get-MgDevice -DeviceId $member.Id).DeviceId

        #Grab primary email from Intune
        $primaryEmail = (Get-MgDeviceManagementManagedDevice -Filter "AzureAdDeviceId eq '$deviceid'").EmailAddress

        if($primaryEmail) {
            #Add primary email to array
            $primaryEmails += $primaryEmail
        }


    }

    #Remove duplicates if needed
    $primaryEmails = $primaryEmails | Sort-Object -Unique


    #Update distribution group with new list of emails
    Update-DistributionGroupMember -Identity "$dlupn" -Members $primaryEmails -Confirm:$false

} catch {Write-Error "Failed to process group members: $_" 
}
