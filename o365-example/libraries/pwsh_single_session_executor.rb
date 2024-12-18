require "ruby-pwsh"
class PwshSingleSessionExecutor < Inspec.resource(1)
  name 'pwsh_single_session_executor'

  def initialize(script)
    @script = script
  end

  def run_script_in_graph_exchange()
    return_data = inspec.backend.run_command(@script, {graph_exchange_session: 1})
    return return_data
  end

  def run_script_in_teams_pnp()
    return_data = inspec.backend.run_command(@script, {teams_pnp_session: 2})
    return return_data
  end
end