function Get_Errors{
	param([string]$LogName, [int]$Level)
	$Events = Get-WinEvent -FilterHashtable @{logname=$LogName; level=$Level} -erroraction 'silentlycontinue'
	$EventID_Counter = @{}
	$EventMessage_Counter = @{}
	$EventProvider_Counter = @{}
	$UniqueEvent_Counter = @{}
	foreach ($Event in $Events){
		if ($Event.Id){
			if ($EventID_Counter.ContainsKey($Event.Id)){
				$EventID_Counter[$Event.Id] += 1
			}else {
				$EventID_Counter[$Event.Id] = 1
			}
		}
		else{
			if ($EventID_Counter.ContainsKey(" ")){
				$EventID_Counter["0"] += 1
			}
			else{
				$EventID_Counter["0"] = 1
			}
		}
		if ($Event.Message){
			if ($EventMessage_Counter.ContainsKey($Event.Message)){
				$EventMessage_Counter[$Event.Message] += 1
			}else {
				$EventMessage_Counter[$Event.Message] = 1
			}
		}
		else{
			if ($EventMessage_Counter.ContainsKey("NULL")){
				$EventMessage_Counter["NULL"] += 1
			}
			else{
				$EventMessage_Counter["NULL"] = 1
			}
		}
		if ($Event.ProviderName){
			if ($EventProvider_Counter.ContainsKey($Event.ProviderName)){
				$EventProvider_Counter[$Event.ProviderName] += 1
			}else {
				$EventProvider_Counter[$Event.ProviderName] = 1
			}
		}
		else{
			if ($EventProvider_Counter.ContainsKey(" ")){
				$EventProvider_Counter["NULL"] += 1
			}
			else{
				$EventProvider_Counter["NULL"] = 1
			}
		}
		if ($Event.Id){
			$EventId = $Event.Id | Out-String
		}
		else{
			$EventId = "0"
		}
		if ($Event.ProviderName){
			$EventProviderName = $Event.ProviderName | Out-String
		}
		else{
			$EventProviderName = "NULL"
		}
		if ($Event.Message){
			$EventMessage = $Event.Message | Out-String
		}
		else{
			$EventMessage = "NULL"
		}
		$UniqueEventIndex = $EventId.trim().replace(',', '.')+ "," +$EventProviderName.trim().replace(',', '.')+ "," +$EventMessage.trim().replace(',', '.')
		if ($UniqueEvent_Counter.ContainsKey($UniqueEventIndex)){
			$UniqueEvent_Counter[$UniqueEventIndex] += 1
		}
		else{
			$UniqueEvent_Counter[$UniqueEventIndex] = 1
		}
	}
	$Sorted_UniqueEvent_Counter = $UniqueEvent_Counter.GetEnumerator() | sort -Property value -Descending
	foreach ($Sorted_UniqueEvent in $Sorted_UniqueEvent_Counter){
		$Sorted_UniqueEventID = $Sorted_UniqueEvent.Name.Split(",")[-3]
		$Sorted_UniqueEventProvider = $Sorted_UniqueEvent.Name.Split(",")[-2]
		$Sorted_UniqueEventMessage = $Sorted_UniqueEvent.Name.Split(",")[-1]
		$Sorted_UniqueEventValue = $Sorted_UniqueEvent.value

		if ($Level -eq 1){
			Add-Content $EventLogReportFileName '<tr bgcolor="Red">'
		}
		elseif ($Level -eq 2){
			Add-Content $EventLogReportFileName '<tr bgcolor="Orange">'
		}
		elseif ($Level -eq 3){
			Add-Content $EventLogReportFileName '<tr bgcolor="Yellow">'
		}
		else{
			Write-Host "ERROR: Invalid event level."
		}
		Add-Content $EventLogReportFileName "<td> $Sorted_UniqueEventValue </td>"
		Add-Content $EventLogReportFileName "<td> $Sorted_UniqueEventID </td>"
		Add-Content $EventLogReportFileName "<td> $Sorted_UniqueEventProvider </td>"
		Add-Content $EventLogReportFileName "<td> $Sorted_UniqueEventMessage </td>"
		Add-Content $EventLogReportFileName "</tr>"
	}
}
$EventLogReportFileName = "EventReport-$((Get-Date).ToUniversalTime().ToString(`"MMddyyyyTHHmmssZ`"))`.htm"
Set-Content $EventLogReportFileName "<html>"
Add-Content $EventLogReportFileName "<head>"
Add-Content $EventLogReportFileName "<style>"
Add-Content $EventLogReportFileName "table, th, td {"
Add-Content $EventLogReportFileName "border: 1px solid black;"
Add-Content $EventLogReportFileName "}"
Add-Content $EventLogReportFileName "</style>"
Add-Content $EventLogReportFileName "</head>"
Add-Content $EventLogReportFileName '<body style="background-color:lightgrey;">'
Add-Content $EventLogReportFileName "<center><H2>Event Log Report for $(hostname)</H2></center>"
Add-Content $EventLogReportFileName "<p>&nbsp;&nbsp</p>"
1..3 | % {
	$EventType = $_
	if ($EventType -eq 1){
		Add-Content $EventLogReportFileName "<center><h3>Setup</h3></center>"
	}
	elseif ($EventType -eq 2){
		Add-Content $EventLogReportFileName "<center><h3>Application</h3></center>"
	}
	elseif ($EventType -eq 3){
		Add-Content $EventLogReportFileName "<center><h3>System</h3></center>"
	}
	else{
		Write-Host "ERROR: Index out of range."
	}
	Add-Content $EventLogReportFileName '<table style="width:100%">'
	Add-Content $EventLogReportFileName '<tr bgcolor="LightBlue">'
	Add-Content $EventLogReportFileName "<th>Occurance</th>"
	Add-Content $EventLogReportFileName "<th>Event ID</th>"
	Add-Content $EventLogReportFileName "<th>Event Provider</th>"
	Add-Content $EventLogReportFileName "<th>Message</th>"
	Add-Content $EventLogReportFileName "</tr>"
	1..3 | % {
		if ($EventType -eq 1){
			Get_Errors "setup" $_
		}
		elseif ($EventType -eq 2){
			Get_Errors "application" $_
		}
		elseif ($EventType -eq 3){
			Get_Errors "system" $_
		}
		else{
			Write-Host "ERROR: Index out of range."
		}
	}
	Add-Content $EventLogReportFileName "</table>"
	Add-Content $EventLogReportFileName "<p>&nbsp;&nbsp</p>"
}
Add-Content $EventLogReportFileName "<p>&nbsp;&nbsp</p>"
Add-Content $EventLogReportFileName "</body>"
Add-Content $EventLogReportFileName "</html>"
