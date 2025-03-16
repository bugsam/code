Import-Module WebAdministration

$APP_POOL_NAME = "vuln_site"
$APPLICATION_POOL = "IIS:\AppPools\$APP_POOL_NAME"
$HOST_HEADER = "$($env:COMPUTERNAME).$($env:USERDNSDOMAIN)"
$SITE_NAME = "vuln_site"
$SITE_LOCATION = "C:\inetpub\$SITE_NAME"
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
New-Website -Name $SITE_NAME -ApplicationPool $APP_POOL_NAME -HostHeader $HOST_HEADER -PhysicalPath $SITE_LOCATION  -Port 8001

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
