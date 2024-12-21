# Connection definition file for an example Train plugin.

# Most of the work of a Train plugin happens in this file.
# Connections derive from Train::Plugins::Transport::BaseConnection,
# and provide a variety of services.  Later generations of the plugin
# API will likely separate out these responsibilities, but for now,
# some of the responsibilities include:
# * authentication to the target
# * platform / release /family detection
# * caching
# * filesystem access
# * remote command execution
# * API execution
# * marshalling to / from JSON
# You don't have to worry about most of this.

# This allow us to inherit from Train::Plugins::Transport::BaseConnection
require "train"

# Push platform detection out to a mixin, as it tends
# to develop at a different cadence than the rest
require "train-pwsh/platform"

# This is a support library for our file content meddling
# require "train-pwsh/file_content_rotator"

# This is a support library for our holding powershell session
require "ruby-pwsh"

module TrainPlugins
  module Pwsh
    # You must inherit from BaseConnection.
    class Connection < Train::Plugins::Transport::BaseConnection
      # We've placed platform detection in a separate module; pull it in here.
      include TrainPlugins::Pwsh::Platform

      def initialize(options)
        # 'options' here is a hash, Symbol-keyed,
        # of what Train.target_config decided to do with the URI that it was
        # passed by `inspec -t` (or however the application gathered target information)
        # Some plugins might use this moment to capture credentials from the URI,
        # and the configure an underlying SDK accordingly.
        # You might also take a moment to manipulate the options.
        # Have a look at the Local, SSH, and AWS transports for ideas about what
        # you can do with the options.

        # Regardless, let the BaseConnection have a chance to configure itself.
        super(options)
        puts('Please wait a few minutes to let the Powershell modules download and connection get established... ')
        #Instance variables that store the necessary authentication credentials
        #@pwsh_session_graph_exchange = ::Pwsh::Manager.instance('/opt/homebrew/bin/pwsh', ['-NoLogo'])
        #@pwsh_session_teams_pnp = ::Pwsh::Manager.instance('/opt/homebrew/bin/pwsh', [])
        @pwsh_session_graph_exchange = @options.delete(:graph_exchange_session)
        @pwsh_session_teams_pnp = @options.delete(:teams_pnp_session)
        @client_id = @options.delete(:client_id)
        @tenant_id = @options.delete(:tenant_id)
        @client_secret = @options.delete(:client_secret)
        @certificate_path = @options.delete(:certificate_path)
        @certificate_password = @options.delete(:certificate_password)
        @organization = @options.delete(:organization)
        @sharepoint_admin_url = @options.delete(:sharepoint_admin_url)
        
        exit_status_graph_exchange = install_connect_graph_exchange()
        exit_status_teams_pnp = install_connect_teams_pnp()
        if exit_status_graph_exchange != 0
          return exit_status_graph_exchange
        elsif exit_status_teams_pnp != 0
          return exit_status_teams_pnp
        end
        
      end

      def file_via_connection(path)
        return Train::File::Local::Windows.new(self,path)
      end

      def run_command_via_connection(script, session_type_hash)
        if session_type_hash.key?(:graph_exchange_session)
          return run_script_in_graph_exchange(script)
        elsif session_type_hash.key?(:teams_pnp_session)
          return run_script_in_teams_pnp(script)
        else
          return CommandResult.new("","",0)
        end
      end
            #Establishes connection for modules such as mggraph, exchangeonline
      def install_connect_graph_exchange()
        pwsh_graph_exchange_install_connect = %{
          #Collect designated inputs required for Graph and Exchange connections
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
          Connect-IPPSSession -AppID $client_id -CertificateFilePath $certificate_path -CertificatePassword (ConvertTo-SecureString -String $certificate_password -AsPlainText -Force) -Organization $organization -ShowBanner:$false
          Connect-ExchangeOnline -CertificateFilePath $certificate_path -CertificatePassword (ConvertTo-SecureString -String $certificate_password -AsPlainText -Force)  -AppID $client_id -Organization $organization -ShowBanner:$false
        }
        
        pwsh_graph_exchange_install_connect_result = @pwsh_session_graph_exchange.execute(pwsh_graph_exchange_install_connect)
        return pwsh_graph_exchange_install_connect_result[:exitcode]
      end

      def uri
        return 'pwsh://'
      end

      def install_connect_teams_pnp()
        pwsh_teams_pnp_install_connect = %{
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
          Connect-PnPOnline -Url $sharepoint_admin_url -ClientId $client_id -CertificatePath $certificate_path -CertificatePassword $password -Tenant $tenantid
        }
        pwsh_teams_pnp_install_connect_result = @pwsh_session_teams_pnp.execute(pwsh_teams_pnp_install_connect)
        return pwsh_teams_pnp_install_connect_result[:exitcode]
      end

      def run_script_in_graph_exchange(script)
        result = @pwsh_session_graph_exchange.execute(script)
        if result[:stdout].nil?
          result[:stdout] = ""
        end
        return CommandResult.new(result[:stdout],result[:stderr],result[:exitcode])
      end

      def run_script_in_teams_pnp(script)
        result = @pwsh_session_teams_pnp.execute(script)
        if result[:stdout].nil?
          result[:stdout] = ""
        end
        return CommandResult.new(result[:stdout],result[:stderr],result[:exitcode])
      end
    end
  end
end