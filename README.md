# Cleanfb

Cleanfb is a tool that cleans a filebucket on a Puppet server by backing up files to a saved directory.
This tool intended to be used alongside a Ruby script, capture_config, that captures the configuration of a machine and checks it against copies sent to a Puppet server.

If a configuration is removed from the Puppet node, a new copy is automatically retrieved from the Puppet server's filebucket.

Cleanfb allows out of date configurations to be backed up on the server and for the Puppet node to capture a current configuration.

Old configurations can also be restored using cleanfb.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'cleanfb'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install cleanfb

## Usage

cleanfb [host] [options]

    Backup all files associated with the host on the server's filebucket.
    -y      | answer yes to all
    --help  | show help message

cleanfb restore [file] [options]

    Backup all files associated with the host on the server's filebucket, 
    and restore the given configuration file.
    -y      | answer yes to all
    --help  | show help message

###Updating Configuration

Clean the configuration for a host

    $ cleanfb hostname

The configuration is now backed up on the server at /root/saved_configs/hostname/date_time_hostname_configuration.yaml

A new configuration will be obtained for the host on the next Puppet run.


###Restoring a previous Configuration


To restore a previous saved configuration issue the following command

    $ cleanfb restore /root/saved_configs/hostname/date_time_host_configuration.yaml


The current configuration gets backed up and the selected configuration is restored as the primary configuration.

The restored configuration will be obtained by the host from the server on the next Puppet run.

