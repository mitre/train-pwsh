require "ruby-pwsh"
class PwshTeamsExecutor < Inspec.resource(1)
  name 'pwsh_teams_executor'
  def initialize(script)
    @script = script
  end
  
  def run_script_in_teams_pnp()
    return_data = inspec.backend.run_command(@script, {teams_pnp_session: 2})
    return return_data
  end
end
