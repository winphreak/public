# List the users in c:\users and export to the local profile for calling later
dir C:\Users | select Name | Export-Csv -Path C:\users.csv -NoTypeInformation

#Path for scheduled task to restart chrome
$chromePath = "C:\Program Files\Google\Chrome\Application\chrome.exe"

#Check if Chrome is running and kill task
if (Get-Process -ProcessName chrome -ErrorAction SilentlyContinue){

#Close Chrome
taskkill /T /F /IM "chrome.exe" 

}

else{
}

#Wait
Start-Sleep -Seconds 5

#Get the local usernames
Import-CSV -Path C:\users.csv -Header Name | foreach {
        Remove-Item -path "C:\Users\$($_.Name)\AppData\Local\Google\Chrome\User Data\Default\Cache\*" -Recurse -Force -EA SilentlyContinue -Verbose
        Remove-Item -path "C:\Users\$($_.Name)\AppData\Local\Google\Chrome\User Data\Default\Cache2\entries\*" -Recurse -Force -EA SilentlyContinue -Verbose
        Remove-Item -path "C:\Users\$($_.Name)\AppData\Local\Google\Chrome\User Data\Default\Media Cache" -Recurse -Force -EA SilentlyContinue -Verbose
        Remove-Item -path "C:\Users\$($_.Name)\AppData\Local\Google\Chrome\User Data\Default\Cookies-Journal" -Recurse -Force -EA SilentlyContinue -Verbose
        Remove-Item -Path "C:\Users\$($_.Name)\AppData\Local\Google\Chrome\User Data\Default\Network\cookies" -Force -EA SilentlyContinue -Verbose 
		Remove-Item -Path "C:\Users\$($_.Name)\AppData\Local\Google\Chrome\User Data\Default\History" -Force -EA SilentlyContinue -Verbose
}        
	#delete temp file
	Remove-Item C:\users.csv
    
    Start-Sleep -Seconds 2
    
    #Restart Chrome
    $action = New-ScheduledTaskAction -Execute "C:\Program Files\Google\Chrome\Application\chrome.exe"
	$trigger = New-ScheduledTaskTrigger -AtLogOn
	$principal = New-ScheduledTaskPrincipal -UserId (Get-CimInstance –ClassName Win32_ComputerSystem | Select-Object -expand UserName)
	$task = New-ScheduledTask -Action $action -Trigger $trigger -Principal $principal
	Register-ScheduledTask ChromeStart -InputObject $task
	Start-ScheduledTask -TaskName ChromeStart
	Start-Sleep -Seconds 5
	Unregister-ScheduledTask -TaskName ChromeStart -Confirm:$false
