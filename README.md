# Train::Pwsh

A train-pwsh connection has eight fields that are needed for authentication, which are listed below:
- client_id (id of client)
- tenant_id (id of tenant)
- client_secret (secret key for client)
- certificate_path (path on machine where authentication certificate is stored)
- certificate_password (password for certificate)
- organization (organization domain)
- sharepoint_admin_url (sharepoint url for admin)
- pwsh_path (path on machine where the powershell executable is stored)

These fields need to be defined in the config file stored at this directory: `~/.inspec/config.json`. Particularly, under the `credentials` key of the json file, create a `pwsh` key with the value being another dictionary. This dictionary should have a key named `pwsh-options` with the value being another dictionary. This dictionary should contain the names of the eight fields above as well as their values. Please refer to this [link](https://origin.inspec.io/docs/reference/config/) for more detailed instructions.

On top of this, environment variables may need to be defined for some of these eight fields if they are to be used elsewhere in the profile as inputs. The README for the profile will specify which ones need to be stored as environment variables. 

To set an environment variable on Mac, go to the `zschrc` file located at `~/.zschrc` and enter in the following syntax: `export VARIABLE_NAME='insert_value'`

To se and environment variable on Windows, click `Win + R`, type `cmd`, and hit enter. Then, this syntax can be used `setx VARIABLE_NAME "Variable Value"`

If train is being invoked using code, this is how it can be used:

**Pwsh**

```ruby
require 'train'
train = Train.create('pwsh',
  client_id: '1', tenant_id: '2', client_secret: '3', certificate_path: '4', certificate_password: '5', organization: '6', sharepoint_admin_url: '7')
```

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add train-pwsh

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install train-pwsh

## Usage

Train-pwsh should be used alongside inspec-pwsh, which is a resource pack that is used by profiles to help maintain persisten sessions for the different modules that are called Powershell-based profiles.

Please refer to the following link for [inspec-pwsh documentation](https://github.com/mitre/inspec-pwsh)

To test if train-pwsh and inspec-pwsh is working correctly on your system, try running the `o365_example_baseline` profile and check the results. If it runs correctly based on your Microsoft 365 configurations, then train-pwsh and inspec-pwsh are properly set. 

Please refer to the following link for [o365_example_baseline documentation](https://github.com/mitre/o365_example_baseline)

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/train-pwsh. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/train-pwsh/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Train::Pwsh project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/train-pwsh/blob/main/CODE_OF_CONDUCT.md).
