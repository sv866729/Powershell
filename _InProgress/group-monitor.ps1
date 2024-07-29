<# funtion def

if it does exist then read the current group memebers for said group
compare to the currnet group memebres if there the same take no action
confirm each user is there
confirm there are no new users
output log of what happened
update the group list if applicapble
close file and exist
#>

funtion monitor-group{
    param(
        [Parameter(Mandatory=$true)]
        [string]
        $group,
        [file]
        $filepath = "C:\$group.txt"
    )
    

    # File Path operations
    if ((-not(test-path $filepath)) -or $filepath -notcontains ".txt"){
        try{
            new-item -path "C:\" -name $($group + ".txt") -ItemType "file" -ErrorAction Stop
        }catch{
            Write-Error "Run as a administrator"
        }

    }else{
        write to file a footer for group memebers
        and output the group memebers to this locatoin
    }
}



