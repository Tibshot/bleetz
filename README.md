# bleetz

Fast KISS deployment tool.

## Why bleetz ?

I tried Capistrano, Minas. They are great (No irony) but not for me.

I prefere when I know what is going on.

## Requirements

You need rubygems installed.

Tested with Ruby:

* 1.8.7
* 1.9.2
* 1.9.3
* 2.0.0-preview1

## Installation

    gem install bleetz

or

    git clone https://github.com/TibshoOT/bleetz.git

## Configuration

There are two files. Main configuration file and .bleetz file:

* Main configuration is located where you want.
* .bleetz has to be in bleetz binary call directory.

For example:

    $ mkdir -p ~/bleetz
    $ touch ~/bleetz/bleetz.conf
    $ mkdir a_project_path
    $ cd a_project_path
    $ echo ':config: \'~/bleetz/bleetz.conf\'' > .bleetz
    $ bleetz -l

Following options have to be written in ~/bleetz/bleetz.conf in our example.

### Not the most important but...

The most helpful to understand your configuration, comment !

    # This is a fraking great comment !

### SSH configuration

Bleetz has wrapped net-ssh library options to configure your ssh connection(s).

###### Mandatory:

<table>
  <tr>
    <th>Option</th>
    <th>Conf symbol</th>
    <th>Type</th>
  </tr>
  <tr>
    <th>Host</th>
    <td>:host</td>
    <td>String</td>
  </tr>
  <tr>
    <th>Username</th>
    <td>:username</td>
    <td>String</td>
  </tr>
</table>

###### Optionnal:

These options are set by default but you can overide them (if you are sure what you are doing...)

<table>
  <tr>
    <th>Option</th>
    <th>Conf symbol</th>
    <th>Type</th>
    <th>Default value</th>
  </tr>
  <tr>
    <th>Port</th>
    <td>:port</td>
    <td>Integer</td>
    <td>22</td>
  </tr>
  <tr>
    <th>Timeout</th>
    <td>:timeout</td>
    <td>Integer</td>
    <td>10</td>
  </tr>
  <tr>
    <th>Private Key</th>
    <td>:keys</td>
    <td>Array of String</td>
    <td>["$HOME/.ssh/id_dsa", "$HOME/.ssh2/id_dsa", "$HOME/.ssh/id_rsa", "$HOME/.ssh2/id_rsa"]</td>
  </tr>
  <tr>
    <th>Compression</th>
    <td>:compression</td>
    <td>String</td>
    <td>'none'</td>
  </tr>
  <tr>
    <th>Compression level</th>
    <td>:compression_level</td>
    <td>Integer</td>
    <td>6</td>
  </tr>
  <tr>
    <th>Encryption</th>
    <td>:encryption</td>
    <td>String || Array of String</td>
    <td>'3des-cbc'</td>
  </tr>
  <tr>
    <th>Host key</th>
    <td>:host_key</td>
    <td>String || Array of String</td>
    <td>'ssh-dss'</td>
  </tr>
</table>

Check example file [here](https://github.com/TibshoOT/bleetz/blob/master/example/bleetz.conf.example).

Generally, you don't have to change these options except :port, :timeout and :keys.

###### How to configure

You have to use set function. In order to configure a user, you can do this:

    set :username, 'a_login'

### Actions

This is the main feature of Bleetz. Actions.

Actions are kind of functions where you write shell script that will be executed over SSH.

Bleetz has been coded to deploy code but you can use it for different purpose (restart some services, backup, etc).

###### Defining action

To define an action:

    action(:action_name) {
      # blabla
    }

or

    action :action_name do
      # blabla
    end

If you want to put a description, you can do this:

    action(:action_name, "a fraking awesome description") {
    }

You will see why you've put this after :action_name (See Usage chapter, -l option).

###### Write shell script

Imagine that you want to write an action that print "42".

    action(:forty_two) {
      shell "echo '42'"
    }

This part will execute echo 42 after SSH connection.


###### Yo dawg, I heard you like to call action, so I put an action in an action so...

You can !

Taking our previous :forty_two action:

    action(:forty_two) {
      shell "echo '42'"
    }

Imagine that you want print 42 in another action, :new_action here, but you want to stay DRY:

    action(:forty_two) {
      shell "echo '42'"
    }

    action :new_action, "A description !" do
      shell "echo 'I will print 42 !'"
      call :forty_two
    end

That's it. If you call :new_action, 'I will print 42 !' and '42' will be printed after SSH connection. :)

### .bleetz file (YAML)

At the moment, there is only one option. Mandatory if you don't use -c command option.

<table>
  <tr>
    <th>Attribute</th>
    <th>Argument</th>
    <th>Explanation</th>
  </tr>
  <tr>
    <th>:config</th>
    <td>A configuration filee path</td>
    <td>Tell bleetz binary to check configuration file without giving -c <conf>.</td>
  </tr>
</table>

Example:

    $ cat .bleetz

You should see:

    :config: 'a/path/to/bleetz/configuration/file'

## Usage

It's important to notice that action name has to be put at end of command.

### Available options

<table>
  <tr>
    <th>Option</th>
    <th>Need an argument ?</th>
    <th>Explanation</th>
  </tr>
  <tr>
    <th>-c</th>
    <td>Yes, a configuration file</td>
    <td>If you want to skip .bleetz file, use -c option.</td>
  </tr>
  <tr>
    <th>-h</th>
    <td>No.</td>
    <td>Display help.</td>
  </tr>
  <tr>
    <th>-l</th>
    <td>No.</td>
    <td>List configured actions in configuration file.</td>
  </tr>
  <tr>
    <th>-s</th>
    <td>No.</td>
    <td>Test configured SSH connection.</td>
  </tr>
  <tr>
    <th>-t</th>
    <td>Yes, action's name.</td>
    <td>Test actions, just print commands.</td>
  </tr>
  <tr>
    <th>-v</th>
    <td>No.</td>
    <td>Verbose mode.</td>
  </tr>
  <tr>
    <th>-V</th>
    <td>No.</td>
    <td>Display version.</td>
  </tr>
</table>

### Examples

List available actions:

    bleetz -c /etc/bleetz.conf -l

Test SSH connction (with .bleetz file):

    bleetz -s

Test :deploy action:

    bleetz -c /etc/bleetz.conf -t deploy

Exexute :deploy action in verbose mode (with .bleetz file):

    bleetz -v deploy

## Common errors

SOON.

## Want a feature ? Problem ?

Open an issue ;)
