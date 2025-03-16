Import-Module WebAdministration

$APP_POOL_NAME = "vuln_site"
$APPLICATION_POOL = "IIS:\AppPools\$APP_POOL_NAME"
$HOST_HEADER = "$($env:COMPUTERNAME).$($env:USERDNSDOMAIN)"
$SITE_NAME = "vuln_site"
$SITE_LOCATION = "C:\inetpub\$SITE_NAME"
$SITE_PORT = 8001
$WEBROOT_APPHOST = "MACHINE/WEBROOT/APPHOST"
$WEBROOT_APPHOST_SITE = "$WEBROOT_APPHOST/$APP_POOL_NAME"

# Creating the APP POOL
$Credential = Get-Credential -Message "Enter the credentials for the app pool identity"

New-WebAppPool -Name $APP_POOL_NAME
Set-ItemProperty "$APPLICATION_POOL" -Name "managedRuntimeVersion" -Value "v2.0"
Set-ItemProperty "$APPLICATION_POOL" -Name "managedPipelineMode" -Value "Integrated"

Set-ItemProperty "$APPLICATION_POOL" -Name "processModel.identityType" -Value "SpecificUser"
Set-ItemProperty "$APPLICATION_POOL" -Name "processModel.userName" -Value $Credential.UserName
Set-ItemProperty "$APPLICATION_POOL" -Name "processModel.password" -Value $Credential.GetNetworkCredential().Password

# Site directory
New-Item $SITE_LOCATION -ItemType Directory

# Removing inheritance
Remove-Item 'IIS:\Sites\Default Web Site' -Confirm:$false -Recurse

Get-WebConfigurationLock -PSPath $WEBROOT_APPHOST -Filter "system.webServer/security/authentication/windowsAuthentication"
Remove-WebConfigurationLock -PSPath $WEBROOT_APPHOST -Filter "system.webServer/security/authentication/windowsAuthentication" -Force
Clear-WebConfiguration -PSPath $WEBROOT_APPHOST -Filter "system.webServer/security/authentication/windowsAuthentication"

Get-WebConfigurationLock -PSPath $WEBROOT_APPHOST -Filter "system.webServer/security/authentication/anonymousAuthentication"
Remove-WebConfigurationLock -PSPath $WEBROOT_APPHOST -Filter "system.webServer/security/authentication/anonymousAuthentication" -Force
Set-WebConfigurationProperty  -PSPath $WEBROOT_APPHOST -Filter "system.webServer/security/authentication/anonymousAuthentication" -Name "enabled" -Value "False"

# creating new site
New-Website -Name $SITE_NAME -ApplicationPool $APP_POOL_NAME -HostHeader $HOST_HEADER -PhysicalPath $SITE_LOCATION  -Port $SITE_PORT

Set-WebConfigurationProperty -PSPath $WEBROOT_APPHOST_SITE -Filter "system.webServer/directoryBrowse" -Name "enabled" -Value "True"
Set-WebConfigurationProperty -PSPath $WEBROOT_APPHOST_SITE -Filter "system.webServer/defaultDocument" -Name "enabled" -Value "False"
Set-WebConfigurationProperty -PSPath $WEBROOT_APPHOST_SITE -Filter "system.webServer/validation" -Name "validateIntegratedModeConfiguration" -Value "False"

Set-WebConfigurationProperty -pspath $WEBROOT_APPHOST_SITE -Filter "system.web/authentication" -Name "mode" -Value "Windows"

Set-WebConfigurationProperty -PSPath $WEBROOT_APPHOST_SITE -Filter "system.webServer/security/authentication/anonymousAuthentication" -Name "enabled" -Value "False" -Force

Set-WebConfigurationProperty -PSPath $WEBROOT_APPHOST -Location $SITE_NAME -filter "system.webServer/security/authentication/windowsAuthentication" -name "enabled" -value "True"
Set-WebConfigurationProperty -PSPath $WEBROOT_APPHOST -Location $SITE_NAME -Filter "system.webServer/security/authentication/windowsAuthentication" -Name "useKernelMode" -Value "False"
Set-WebConfigurationProperty -PSPath $WEBROOT_APPHOST -Location $SITE_NAME -Filter "system.webServer/security/authentication/windowsAuthentication" -Name "useAppPoolCredentials" -Value "True"
Add-WebConfigurationProperty -PSPath $WEBROOT_APPHOST -Location $SITE_NAME -Filter "system.webServer/security/authentication/windowsAuthentication/providers" -name "." -value @{value='Negotiate:Kerberos'}
Add-WebConfigurationProperty -PSPath $WEBROOT_APPHOST -Location $SITE_NAME -Filter "system.webServer/security/authentication/windowsAuthentication/providers" -name "." -value @{value='Negotiate'}

Restart-WebAppPool $APP_POOL_NAME

Invoke-WebRequest -Uri "http://$($HOST_HEADER):$($SITE_PORT)" -Credential $Credential

$NET_RUNTIME = [System.Runtime.InteropServices.RuntimeEnvironment]::GetRuntimeDirectory()
$NET_RUNTIME_TEMP = "$($NET_RUNTIME)\Temporary ASP.NET Files"
$_IIS_LOGFILE = Get-WebConfigurationProperty -PSPath $WEBROOT_APPHOST -filter "system.applicationHost/sites/siteDefaults/logfile" -name "directory" | Select-Object -ExpandProperty Value
$IIS_LOGFILE = [System.Environment]::ExpandEnvironmentVariables($_IIS_LOGFILE)

$SECURABLE_OBJECTS = @(
    $SITE_LOCATION,
    $NET_RUNTIME_TEMP,
    $IIS_LOGFILE
)

foreach ($SEC_OBJ in $SECURABLE_OBJECTS){
    $NEW_ACL = Get-Acl -Path $SEC_OBJ
    $IDENTITY = $Credential.UserName
    $ACCESS = "Modify"
    $TYPE = "Allow"
    $ACE = $IDENTITY, $ACCESS, $TYPE
    $NEW_ACL_PARAM = @{
        TypeName = 'System.Security.AccessControl.FileSystemAccessRule'
        ArgumentList = $ACE
    }
    $FILE_ACE = New-Object @NEW_ACL_PARAM
    $NEW_ACL.SetAccessRule($FILE_ACE)
    Set-Acl -Path $SEC_OBJ -AclObject $NEW_ACL
    Get-ChildItem -Path $SEC_OBJ -Recurse -Force | Set-Acl -AclObject $NEW_ACL
}

# on your DC (set SPN)
$IIS_SERVER = "YOUR_IIS_HOSTNAME"
$IIS_USER = "YOUR_IIS_IDENTITY_ACCOUNT"
$IIS_SPNS = Get-ADComputer -Identity $IIS_SERVER -Properties ServicePrincipalName | 
    Select-Object -ExpandProperty ServicePrincipalName |
    Where-Object { $_ -like 'HOST/*' } |
    ForEach-Object { $_ -replace '^HOST/', 'HTTP/' }

foreach ($SPN in $IIS_SPNS){
    Write-Host "$SPN"
    Set-ADUser -Identity $IIS_USER -ServicePrincipalNames @{Add="$SPN"}
}
Get-ADUser -Identity $IIS_USER -Properties ServicePrincipalNames
