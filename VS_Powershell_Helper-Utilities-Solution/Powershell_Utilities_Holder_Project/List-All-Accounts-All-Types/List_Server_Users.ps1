Write-Output "Windows Standard Accounts"
get-wmiobject -class "win32_account" -namespace "root\cimv2" | sort caption | format-table caption, __CLASS, FullName
Write-Output "Windows Service Accounts"
get-service | foreach {Write-Host NT Service\$($_.Name)}
Write-Output "Windows IIS - AppPool Accounts"
try{
    Import-Module WebAdministration
    Get-WebApplication
    
    $webapps = Get-WebApplication
    $list = @()
    foreach ($webapp in get-childitem IIS:\AppPools\)
    {
    $name = "IIS:\AppPools\" + $webapp.name
    $item = @{}
    
    $item.WebAppName = $webapp.name
    $item.Version = (Get-ItemProperty $name managedRuntimeVersion).Value
    $item.State = (Get-WebAppPoolState -Name $webapp.name).Value
    $item.UserIdentityType = $webapp.processModel.identityType
    $item.Username = $webapp.processModel.userName
    $item.Password = $webapp.processModel.password
    
    $obj = New-Object PSObject -Property $item
    $list += $obj
    }
    
    $list | Format-Table -a -Property "WebAppName", "Version", "State", "UserIdentityType", "Username", "Password"
    
    }catch
    {
    $ExceptionMessage = "Error in Line: " + $_.Exception.Line + ". " + $_.Exception.GetType().FullName + ": " + $_.Exception.Message + " Stacktrace: " + $_.Exception.StackTrace
    $ExceptionMessage
    }