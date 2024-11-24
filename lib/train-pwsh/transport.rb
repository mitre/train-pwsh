# Train Plugins v1 are usually declared under the TrainPlugins namespace.
# Each plugin has three components: Transport, Connection, and Platform.
# We'll only define the Transport here, but we'll refer to the others.
require "train-pwsh/connection"

module TrainPlugins
  module Pwsh
    class Transport < Inspec::Train.plugin(1)
      name "pwsh"

      # The only thing you MUST do in a transport is a define a
      # connection() method that returns a instance that is a
      # subclass of BaseConnection.
      # Required fields in order for connection to be valid
      option :client_id, required: true
      option :tenant_id, required: true
      option :client_secret, required: true
      option :certificate_path, required: true
      option :certificate_password, required: true
      option :organization, required: true
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