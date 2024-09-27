Connect-MsolService
$groupname ='group'
$Licensedusers = get-msoluser | Where-Object {$_.isLicensed -eq 'True'}
$GroupId = Get-MsolGroup | Where-Object { $_.DisplayName -eq $groupname } | Select-Object -ExpandProperty ObjectID
$GRoupUsers  = Get-MsolGroupMember -GroupObjectId $GroupId
$missingusers = Compare-Object -ReferenceObject $Licensedusers.DisplayName -DifferenceObject $GRoupUsers.DisplayName -PassThru | Where-Object { $_.SideIndicator -eq "<=" }

Write-Host -ForegroundColor Cyan "Missing users`n---------------"
foreach ($user in $missingusers){
    Write-Host $user
}
