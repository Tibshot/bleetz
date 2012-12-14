require 'rubygems'
require 'net/ssh'
require 'yaml'
require 'bleetz/conf.rb'
require 'bleetz/object.rb'

class Bleetz

  VERSION = "1.0"

  USAGE = <<-EOF
Usage: bleetz [-c conf_file -h -l -s][[-t -v -c conf_file] task]

-c <conf_file>         - Specify a special bleetz configuration file.
-h                     - Help.
-l                     - List available task(s) defined in bleetz configuration file.
-s                     - Test ssh connection defined in bleetz conf.
-t <task_name>         - Test tasks (just print command that will be executed.
-v                     - Verbose Mode.
-V                     - Print bleetz version.
EOF

  def initialize
    arg_get
    @cmd_to_exec = []
    begin
      if @file.nil?
        cnf = YAML::load(File.open("#{Dir.pwd}/.bleetz"))
        @file = cnf[:config] || cnf['config']
      end
      load @file
    rescue Exception => e
      abort "Problem during configuration loading: #{e.message}"
    end
    list if @list
    test_ssh if @ssh_test
    abort "You need to specify a task." if @action.nil?
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
    abort "Unknown task: '#{action}'." unless @@actions.include?(action.to_sym)
    @@actions[action.to_sym].each { |c|
      if c.is_a? Symbol
        abort "Undefined task: :#{c}. You have to define it." unless @@tasks.include?(c)
        format_cmds(c)
      else
        @cmd_to_exec << c
      end
    }
  end

  def list
    puts "Available tasks:"
    @@tasks.each { |k,v|
      desc = (v.empty? ? "No desc" : v)
      puts "#{k}: #{desc}"
    }
    exit(0)
  end

  def test
    puts "Simulation, command printing without SSH. No excution."
    @cmd_to_exec.each { |c| puts c }
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
  end

  def usage
    puts USAGE
    @help ? exit(0) : exit(1)
  end

  def version
    puts "bleetz version #{VERSION}. Fuck yeah !"
    exit(0)
  end

end

