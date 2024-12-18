require "ruby-pwsh"

class PwshGraphExecutor < Inspec.resource(1)
  name 'pwsh_graph_executor'
  def initialize(script)
    @script = script
  end
  
  def run_script_in_graph()
    return_data = inspec.backend.run_command(@script, {graph_exchange_session: 1})
    return return_data
  end
end
