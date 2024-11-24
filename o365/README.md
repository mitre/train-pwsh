# Example InSpec Profile

This example shows the implementation of an InSpec profile.

#Control descriptions

Controls 1.1.3 and 1.2.1 are examples of Graph module in use. This uses the graph/exchange pwsh session.
Control 1.3.6 is an example of ExchangeOnline module in use. This uses the graph/exchange pwsh session. 
Control 7.2.3 is an example of Powershell.PnP module in use. This uses the teams/pnp pwsh session. 
Control 8.5.3 is an example of MicrosoftTeams module in use. This uses the teams/pnp pwsh session. 

To run this example profile, enter this is the command:

```sh
time bundle exec inspec exec . --controls=microsoft-365-foundations-1.1.3 microsoft-365-foundations-1.2.1 microsoft-365-foundations-1.3.6 microsoft-365-foundations-7.2.3 microsoft-365-foundations-8.5.3 --input client_id=$CLIENT_ID tenant_id=$TENANT_ID client_secret=$CLIENT_SECRET certificate_path=$CERTIFICATE_PATH certificate_password=$CERTIFICATE_PASSWORD organization=$ORGANIZATION --input-file=inputs.yml
```

This example profile uses two custom resources named pwsh_single_session_graph_exchange and pwsh_single_session_teams_pnp. The names imply which modules in powershell they connect to. The goal of these resources is to establish one session and make the running of our other microsoft profile with more controls much faster. 
