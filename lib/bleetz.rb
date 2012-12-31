require 'rubygems'
require 'net/ssh'
require 'yaml'
require 'bleetz/conf.rb'
require 'bleetz/object.rb'

class Bleetz

  VERSION = "1.5"

  USAGE = <<-EOF
Usage: bleetz [-c conf_file -h -l -s][[-t -v -c conf_file] action]

-c <conf_file>         - Specify a special bleetz configuration file.
-h                     - Help.
-l                     - List available action(s) defined in bleetz configuration file.
-s                     - Test ssh connection defined in bleetz conf.
-t <action_name>         - Test actions (just print command that will be executed.
-v                     - Verbose Mode.
-V                     - Print bleetz version.
EOF

  def initialize
    arg_get
    @cmd_to_exec = []
    begin
      if @file.nil?
        cnf = YAML::load(File.open("#{Dir.pwd}/.bleetz"))
        @file = cnf['config']
      end
      load @file
    rescue TypeError
      abort "Didn't you make a mistake in .bleetz file ?"
    rescue BleetzException => e
      abort "Problem during configuration loading: #{e.message}"
    rescue ArgumentError
      abort "Did you configure attribute like this: 'attribute: <value>'"
    rescue Exception => e
      abort "Problem during configuration loading: #{e.message}"
    end
    list if @list
    test_ssh if @ssh_test
    abort "You need to specify an action." if @action.nil?
    format_cmds
    test if @test
    connect
  end

  private

  def arg_get
    @help = false
    if ARGV.empty?
      usage
    end
    @file = nil
    @test = @ssh_test = @list = @verbose = false
    loop {
      case ARGV[0]
      when '-t'
        ARGV.shift; @test = true
      when '-s'
        ARGV.shift; @ssh_test = true
      when '-l'
        ARGV.shift; @list = true
      when '-v'
        ARGV.shift; @verbose = true
      when '-V'
        ARGV.shift; version
      when '-c'
        ARGV.shift; @file = ARGV.shift
      when '-h'
        @help = true; usage
      when /^-/
        @help = false; puts("Unknown option: #{ARGV[0].inspect}"); usage
      else
        break
      end
    }
    @action = ARGV.shift if !ARGV[0].nil?
  end

  def format_cmds(action = @action)
    abort "Unknown action: '#{action}'." unless @@actions.include?(action.to_sym)
    begin
      @@actions[action.to_sym].each { |c|
        if c.is_a? Symbol
          abort "Undefined action: :#{c}. You have to define it." unless @@tasks.include?(c)
          format_cmds(c)
        else
          @cmd_to_exec << c
        end
      }
    rescue SystemStackError => e
      abort "You seem to create a call loop: #{e.message}"
    end
  end

  def list
    puts "Available actions:"
    @@tasks.each { |k,v|
      desc = (v.empty? ? "No desc" : v)
      puts "#{k}: #{desc}"
    }
    exit(0)
  end

  def test
    puts "Simulation, command printing without SSH. No excution."
    unless @@before[@action.to_sym].nil?
      @@before[@action.to_sym].each { |b| puts "before ssh (local): #{b}" }
    end
    @cmd_to_exec.each { |c| puts c }
    unless @@after[@action.to_sym].nil?
      @@after[@action.to_sym].each { |a| puts "after ssh (local): #{a}" }
    end
    exit(0)
  end

  def test_ssh
    puts "Test SSH connection:"
    connect
    puts "SSH connection: SUCCES"
    exit(0)
  end

  def connect
    abort "You have to configure SSH options." if @@options.empty?
    unless @ssh_test
      @@before[@action.to_sym].each { |b| execute!(b) } unless @@before[@action.to_sym].nil?
    end
    begin
        Timeout::timeout(@@options.delete(:timeout) || 10) {
          Net::SSH.start(@@options.delete(:host), @@options.delete(:username), @@options) { |ssh|
            if !@cmd_to_exec.empty?
              @cmd_to_exec.each { |command|
                output = ssh.exec!(command)
                puts output if @verbose
              }
            end
          }
        }
    rescue NotImplementedError => e
      abort "SSH error: #{e.message}"
    rescue Net::SSH::HostKeyMismatch => e
      e.remember_host!
      retry
    rescue Net::SSH::AuthenticationFailed => e
      abort "SSH auth failed: #{e.message}"
    rescue StandardError => e
      abort "SSH connection error: #{e.to_s}"
    rescue Timeout::Error
      abort "Timed out trying to get a connection."
    end
    unless @ssh_test
      @@after[@action.to_sym].each { |a| execute!(a) } unless @@after[@action.to_sym].nil?
    end
  end

  def execute!(cmd)
    out = `#{cmd} 2>&1`
    puts out if @verbose
  end

  def usage
    puts USAGE
    @help ? exit(0) : exit(1)
  end

  def version
    puts "bleetz version #{VERSION}. Frak yeah !"
    exit(0)
  end

end

