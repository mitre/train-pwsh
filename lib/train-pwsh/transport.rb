# Train Plugins v1 are usually declared under the TrainPlugins namespace.
# Each plugin has three components: Transport, Connection, and Platform.
# We'll only define the Transport here, but we'll refer to the others.
require "train-pwsh/connection"
require "ruby-pwsh"
module TrainPlugins
  module Pwsh
    class Transport < Train.plugin(1)
      name "pwsh"

      # The only thing you MUST do in a transport is a define a
      # connection() method that returns a instance that is a
      # subclass of BaseConnection.
      # Required fields in order for connection to be valid

      #option :client_id, required: true, default: proc { ENV['CLIENT_ID'] } unless ENV['CLIENT_ID'].empty? 
      #option :tenant_id, required: true, default: proc { ENV['TENANT_ID'] } unless ENV['TENANT_ID'].empty? 
      #option :client_secret, required: true, default: proc { ENV['CLIENT_SECRET'] } unless ENV['CLIENT_SECRET'].empty? 
      #option :certificate_path, required: true, default: proc { ENV['CERTIFICATE_PATH'] } unless ENV['CERTIFICATE_PATH'].empty? 
      #option :certificate_password, required: true, default: proc { ENV['CERTIFICATE_PASSWORD'] } unless ENV['CERTIFICATE_PASSWORD'].empty? 
      #option :organization, required: true, default: proc { ENV['ORGANIZATION'] } unless ENV['ORGANIZATION'].empty? 
      #option :sharepoint_admin_url, required: true, default: proc { ENV['SHAREPOINT_ADMIN_URL'] } unless ENV['SHAREPOINT_ADMIN_URL'].empty? 
      
      # The options passed to this are undocumented and rarely used.
      def connection(_instance_opts = nil)
        # Typical practice is to cache the connection as an instance variable.
        # Do what makes sense for your platform.
        # @options here is the parsed options that the calling
        # app handed to us at process invocation. See the Connection class
        # for more details.
        @connection ||= TrainPlugins::Pwsh::Connection.new(@options)
      end
    end
  end
end