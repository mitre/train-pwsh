# This is a support library for our holding powershell session
require "ruby-pwsh"
class PwshSingleSessionGraphExchange < Inspec.resource(1)
  name 'pwsh_single_session_graph_exchange'
  def initialize(client_id, tenant_id, client_secret, certificate_path, certificate_password, organization, script)
    @client_id = client_id
    @tenant_id = tenant_id
    @client_secret = client_secret
    @certificate_path = certificate_path
    @certificate_password = certificate_password
    @organization = organization
    @script = script
    @pwsh_session = Pwsh::Manager.instance('/opt/homebrew/bin/pwsh', ['-NoLogo'])
    ensure_modules_present_script = %{
    $modulesToCheck = @('Microsoft.Graph', 'ExchangeOnlineManagement')

      # Function to check if all modules are present
      function Check-Modules {
          param (
              [string[]]$Modules
          )

          # Initialize a counter for found modules
          $foundModules = 0

          # Check each module
          foreach ($module in $Modules) {
              if (Get-Module -ListAvailable -Name $module) {
                  $foundModules++
              }
          }

          # Return 2 if all modules are found
          if ($foundModules -eq $Modules.Count) {
              return 2
          } else {
              return 0
          }
      }

      # Call the function and store the result
      $result = Check-Modules -Modules $modulesToCheck

      # Output the result
      Write-Output $result
    }

    import_test = @pwsh_session.execute(ensure_modules_present_script)[:stdout].strip
    if import_test == "2"
      pwsh_module_connection_script = %{
          #Collect designated inputs required for Graph, Exchange, and PnP connections
          $client_id = '#{@client_id}'
          $tenantid = '#{@tenant_id}'
          $clientSecret = '#{@client_secret}'
          $certificate_password = '#{@certificate_password}'
          $certificate_path = '#{@certificate_path}'
          $organization = '#{@organization}'

          #Connect to Graph module
          $password = ConvertTo-SecureString -String $clientSecret -AsPlainText -Force
          $ClientSecretCredential = New-Object -TypeName System.Management.Automation.PSCredential($client_id,$password)
          Connect-MgGraph -TenantId $tenantid -ClientSecretCredential $ClientSecretCredential -NoWelcome

          #Connect to Exchange module
          Connect-ExchangeOnline -CertificateFilePath $certificate_path -CertificatePassword (ConvertTo-SecureString -String $certificate_password -AsPlainText -Force) -AppID $client_id -Organization $organization -ShowBanner:$false
        }

      pwsh_module_connection_results = @pwsh_session.execute(pwsh_module_connection_script)
      return pwsh_module_connection_results[:exit_status]
    else
      pwsh_module_connection_script = %{
          #Collect designated inputs required for Graph, Exchange, and PnP connections
          $client_id = '#{@client_id}'
          $tenantid = '#{@tenant_id}'
          $clientSecret = '#{@client_secret}'
          $certificate_password = '#{@certificate_password}'
          $certificate_path = '#{@certificate_path}'
          $organization = '#{@organization}'

          #Connect to Graph module
          If($null -eq (get-module -listavailable -name "microsoft.graph")){install-module microsoft.graph}
          If($null -eq (get-module -name "microsoft.graph")){import-module microsoft.graph}
          $password = ConvertTo-SecureString -String $clientSecret -AsPlainText -Force
          $ClientSecretCredential = New-Object -TypeName System.Management.Automation.PSCredential($client_id,$password)
          Connect-MgGraph -TenantId $tenantid -ClientSecretCredential $ClientSecretCredential -NoWelcome

          #Connect to Exchange module
          If($null -eq (get-module -listavailable -name "ExchangeOnlineManagement")){install-module ExchangeOnlineManagement}
          If($null -eq (get-module -name "ExchangeOnlineManagement")){import-module ExchangeOnlineManagement}
          $password = ConvertTo-SecureString -String $clientSecret -AsPlainText -Force
          $ClientSecretCredential = New-Object -TypeName System.Management.Automation.PSCredential($client_id,$password)
          Connect-ExchangeOnline -CertificateFilePath $certificate_path -CertificatePassword (ConvertTo-SecureString -String $certificate_password -AsPlainText -Force)  -AppID $client_id -Organization $organization -ShowBanner:$false
        }
      pwsh_module_connection_results = @pwsh_session.execute(pwsh_module_connection_script)

      return pwsh_module_connection_results[:exit_status]
    end
  end

  def stdout
    @pwsh_session.execute(@script)[:stdout]
  end
  
  def stderr
    @pwsh_session.execute(@script)[:stderr]
  end

  def exit_status
    @pwsh_session.execute(@script)[:exit_status]
  end

  def success?
    exit_status == 0
  end
end

class PwshSingleSessionTeamsPnP < PwshSingleSessionGraphExchange
  name 'pwsh_single_session_teams_pnp'
  def initialize(client_id, tenant_id, certificate_path, certificate_password, sharepoint_admin_url, script)
    @client_id = client_id
    @tenant_id = tenant_id
    @certificate_path = certificate_path
    @certificate_password = certificate_password
    @script = script
    @sharepoint_admin_url = sharepoint_admin_url
    @pwsh_session = Pwsh::Manager.instance('/opt/homebrew/bin/pwsh', [])

    ensure_modules_present_script = %{
    $modulesToCheck = @('MicrosoftTeams', 'PnP.PowerShell')

      # Function to check if all modules are present
      function Check-Modules {
          param (
              [string[]]$Modules
          )

          # Initialize a counter for found modules
          $foundModules = 0

          # Check each module
          foreach ($module in $Modules) {
              if (Get-Module -ListAvailable -Name $module) {
                  $foundModules++
              }
          }

          # Return 2 if all modules are found
          if ($foundModules -eq $Modules.Count) {
              return 2
          } else {
              return 0
          }
      }

      # Call the function and store the result
      $result = Check-Modules -Modules $modulesToCheck

      # Output the result
      Write-Output $result
    }

    import_test = @pwsh_session.execute(ensure_modules_present_script)[:stdout].strip

    if import_test == "2"
      pwsh_module_connection_script = %{
          #Collect designated inputs required for Graph, Exchange, and PnP connections
          $client_id = '#{@client_id}'
          $tenantid = '#{@tenant_id}'
          $certificate_password = '#{@certificate_password}'
          $certificate_path = '#{@certificate_path}'
          $sharepoint_admin_url = '#{@sharepoint_admin_url}'

          #Connect to Teams module
          $cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2($certificate_path,$certificate_password)
          Connect-MicrosoftTeams -Certificate $cert -ApplicationId $client_id -TenantId $tenantid > $null

          #Connect to PnP module
          $password_pnp = (ConvertTo-SecureString -AsPlainText $certificate_password -Force)
          Connect-PnPOnline -Url $sharepoint_admin_url -ClientId $client_id -CertificatePath $certificate_path -CertificatePassword $password_pnp -Tenant $tenantid
        }

      pwsh_module_connection_results = @pwsh_session.execute(pwsh_module_connection_script)
      return pwsh_module_connection_results[:exit_status]
    else
      pwsh_module_connection_script = %{
          #Collect designated inputs required for Graph, Exchange, and PnP connections
          $client_id = '#{@client_id}'
          $tenantid = '#{@tenant_id}'
          $certificate_password = '#{@certificate_password}'
          $certificate_path = '#{@certificate_path}'
          $sharepoint_admin_url = '#{@sharepoint_admin_url}'

          #Connect to Teams module
          If($null -eq (get-module -listavailable -name "MicrosoftTeams")){install-module MicrosoftTeams}
          If($null -eq (get-module -name "MicrosoftTeams")){import-module MicrosoftTeams}
          $cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2($certificate_path,$certificate_password)
          Connect-MicrosoftTeams -Certificate $cert -ApplicationId $client_id -TenantId $tenantid > $null

          #Connect to PnP module
          If($null -eq (get-module -listavailable -name "PnP.PowerShell")){install-module PnP.PowerShell}
          If($null -eq (get-module -name "PnP.PowerShell")){import-module PnP.PowerShell}
          $password = (ConvertTo-SecureString -AsPlainText $certificate_password -Force)
          Connect-PnPOnline -Url $sharepoint_admin_url -ClientId $client_id -CertificatePath $certificate_path -CertificatePassword $password  -Tenant $tenantid
        }

      pwsh_module_connection_results = @pwsh_session.execute(pwsh_module_connection_script)
      return pwsh_module_connection_results[:exit_status]
    end
  end
end