# Example InSpec Profile

This example shows the implementation of an InSpec profile.

#Control descriptions

Controls 1.1.3 and 1.2.1 are examples of Graph module in use. This uses the graph/exchange pwsh session.
Control 1.3.6 is an example of ExchangeOnline module in use. This uses the graph/exchange pwsh session. 
Control 7.2.3 is an example of Powershell.PnP module in use. This uses the teams/pnp pwsh session. 
Control 8.5.3 is an example of MicrosoftTeams module in use. This uses the teams/pnp pwsh session. 

To run this example profile, enter this is the command:

```sh
time bundle exec inspec exec . -t pwsh://pwsh-options --controls=microsoft-365-foundations-1.1.3 microsoft-365-foundations-1.2.1 microsoft-365-foundations-1.3.6 microsoft-365-foundations-7.2.3 microsoft-365-foundations-8.5.3
```

This example profile uses two a custom resource named pwsh_single_session_executor. Within it, there are two functions named run_script_in_graph_exchange and run_script_in_teams_pnp. The names of these methods imply which modules in powershell they connect to. The goal of these methods is to establish one session for commands that connect to graph/exchange and one session for commands that connect to teams/pnp. The result of this will allow the microsoft profile to run its controls much faster. 
