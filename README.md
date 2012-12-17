# bleetz

Fast KISS deployment tool.

## Why bleetz ?

I tried Capistrano, Minas. There are great (No irony) but not for me.

I prefere the way where I am 

## Requirements

You need rubygems installed.

Tested with Ruby :

* 1.8.7
* 1.9.2

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

#### Mandatory:

Option :: Conf symbol :: Type
Host   :: :host :: String
Username :: :username :: String

#### Optionnal:

These options are set by default but you can overide them (if you are sure of what you are doing...)

Option :: Conf symbol :: Type :: Default value
Port :: :port :: Integer :: 22
Timeout :: :timeout :: Integer :: 10
Private key :: :keys :: Array of String :: ["$HOME/.ssh/id_dsa", "$HOME/.ssh2/id_dsa", "$HOME/.ssh/id_rsa", "$HOME/.ssh2/id_rsa"]
Compression :: :compresion :: String :: 'none'
Compression leve :: :compresion_level :: Integer :: 6
Encryption :: :encryption :: String || Array of String :: '3des-cbc'
Host Key :: :host_key :: String || Array of String :: 'ssh-dss'

Generally, you don't have to change thess options except :port, :timeout ans :keys.

#### How to configure

You have to use set function. In order to configure a user, you can do this:

    set :username, 'a_login'

### Tasks

This is the main feature of Bleetz. Tasks.

Tasks are kind of function where you write shell script that will be executed over SSH.

Bleetz has been coded to deploy code but you can use it for different pupose (restart some services, backup, etc).

#### Defining task

To define a task:

    task :task_name {
      # blabla
    }

or

    task :task_name do
      # blabla
    end

If you want to put a description, you can do this:

    task :task_name, "a fucking awesome description" {
    }

You will see why you've put this after :task_name (See Usage chapter, -l option).

#### Write shell script

Imagine that you want to write a task that print "42".

    task :forty_two {
      shell "echo '42'"
    }

This part will execute echo 42 after SSH connection.


#### Yo dawg, I heard you like to call task in task so...

You can !

Taking our previous :forty_two task:

    task :forty_two {
      shell "echo '42'"
    }

Imagine that you want print 42 in another task, :new_task here, but you want stay DRY:

   task :forty_two {
      shell "echo '42'"
   }
   task :new_task, "A description !" do
      shell "echo 'I will print 42 !'"
      call :forty_two
   end

That's it. If you call :new_tasks, 'I will print 42 !' and '42' will be printed after SSH connection. :)

## Usage

SOON.
