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
    class Connection < Inspec::Train::Plugins::Transport::BaseConnection
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
        #Instance variables that store the necessary authentication credentials
        @pwsh = Pwsh::Manager.instance
        @client_id = @options.delete(:client_id)
        @tenant_id = @options.delete(:tenant_id)
        @client_secret = @options.delete(:client_secret)
        @certificate_path = @options.delete(:certificate_path)
        @certificate_password = @options.delete(:certificate_password)
        @organization = @options.delete(:organization)
      end

      #Establishes connection for modules such as mggraph, exchangeonline, and pnp (sharepoint)
      def initiate_train_pwsh_session()
        powershell_auth_mggraph_script = %{
          #Collect designated inputs required for Graph, Exchange, and PnP connections
          $client_id = '#{@client_id}'
          $tenantid = '#{@tenant_id}'
          $clientSecret = '#{@client_secret}'
          $certificate_password = '#{@certificate_password}'
          $certificate_path = '#{@certificate_path}'
          $organization = '#{@organization}'

          #Connect to Graph module
          Install-Module -Name Microsoft.Graph -Force -AllowClobber
          import-module microsoft.graph
          $password = ConvertTo-SecureString -String $clientSecret -AsPlainText -Force
          $ClientSecretCredential = New-Object -TypeName System.Management.Automation.PSCredential($client_id,$password)
          Connect-MgGraph -TenantId $tenantid -ClientSecretCredential $ClientSecretCredential -NoWelcome

          #Connect to Exchange module
          Install-Module -Name ExchangeOnlineManagement -Force -AllowClobber
          import-module exchangeonlinemanagement
          $password = ConvertTo-SecureString -String $clientSecret -AsPlainText -Force
          $ClientSecretCredential = New-Object -TypeName System.Management.Automation.PSCredential($client_id,$password)
          Connect-ExchangeOnline -CertificateFilePath $certificate_path -CertificatePassword (ConvertTo-SecureString -String $certificate_password -AsPlainText -Force)  -AppID $client_id -Organization $organization -ShowBanner:$false

          #Connect to PnP module
          Install-Module -Name PnP.PowerShell -Force -AllowClobber
          import-module pnp.powershell
          $password = (ConvertTo-SecureString -AsPlainText $certificate_password -Force)
          Connect-PnPOnline -Url $sharepoint_admin_url -ClientId $client_id -CertificatePath $certificate_path -CertificatePassword $password  -Tenant $tenantid
        }
        OpenStruct.new(
          # Get stdout, stderr, and exit_status for initial connection.
          stdout: @pwsh.execute(powershell_auth_mggraph_script)[:stdout],
          stderr: @pwsh.execute(powershell_auth_mggraph_script)[:stderr],
          exit_status: @pwsh.execute(powershell_auth_mggraph_script)[:exit_status]
        )
      end

      #Make this run_command_via_connection
      def run_train_pwsh_command(script)
        OpenStruct.new(
          # Get stdout, stderr, and exit_status for following commands ran.
          stdout: @pwsh.execute(script)[:stdout],
          stderr: @pwsh.execute(script)[:stderr],
          exit_status: @pwsh.execute(script)[:exit_status]
        )
      end
    end
  end
end