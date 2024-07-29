
<#Phishing
Source:https://github.com/luduslibrum/awesome-playbooks/blob/main/playbooks/microsoft/Phising-Microsoft.png

find the fishing email X
get the email address and subject X
get a list of all mailboxs who got that message
get the list of users who read the message
identify the content if it had a attachment and get the hash
get the source IP from the email X 
determine if the user clicked any linkes in the email
determine which endpoin ids opened the email
put a note to check process creation times on S1
Pull Signin Logs for all users
review sign in LogsInvestigate each appID


#>

#Import module
Import-Module ExchangeOnlineManagement

# Connect 
Connect-ExchangeOnline -erroraction stop

# Initale message ID
$messageid = ""
$last10Days = (Get-Date).AddDays(-10).ToString('M/d/yyyy')
$todaysDate = (Get-Date).ToString('M/d/yyyy')
# Get the iniale message and all its contents
$firstPhishingMessage = Get-MessageTrace -MessageId $messageid -StartDate $last10Days -EndDate $todaysDate
$badIp = $firstPhishingMessage.FromIP
$badSubject = $firstPhishingMessage.Subject
$badSender = $firstPhishingMessage.SenderAddress

# Getting a list of all users who recieved this mail or something simular

# getting dates
$dateThreeMonthsAgo = (Get-Date).AddDays(-90).ToString('M/d/yyyy')
$todaysDate = (Get-Date).ToString('M/d/yyyy')
# Starting search
$searchBySender = Start-HistoricalSearch -ReportTitle "BySender" -ReportType MessageTrace -SenderAddress $badSender -StartDate $dateThreeMonthsAgo -EndDate $todaysDate
# Wait while this is running
$searchByIP = Get-messageTrace -FromIP $badIp -StartDate $last10Days -EndDate $todaysDate
# Write-output
Write-Host "Getting all messages containing sender $badSender for the last 90 Days"
Write-Host "Getting all message containing BadIp $badIp for the last 10 days."


while($(Get-HistoricalSearch -JobId $searchBySender.JobId | Select-Object JobProgress) -ne ""){
Write-Host $(Get-HistoricalSearch -JobId $searchBySender.JobId | Select-Object JobProgress)
    # Display dots for 30 seconds
    for ($i = 0; $i -lt 30; $i++) {
        Write-Host -NoNewline "."
        Start-Sleep -Seconds 1
    }
    Write-Host ""
}
