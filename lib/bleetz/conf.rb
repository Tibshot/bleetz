class BleetzException < Exception
  attr_accessor :message

  def initialize(message)
    @message = message
  end
end

module Conf

  @@actions = {}
  @@tasks = {}
  @@options = {}

  def self.included(base)
    base.extend(self)
  end

  def action(action, desc = "")
    check_main_call(:action)
    @cmds = []
    begin
      yield
    rescue Exception => e
      if e.class.eql? RuntimeError
        raise BleetzException.new(e.message)
      else
        raise BleetzException.new("#{e.class}: #{e.message} in #{e.backtrace[0]}")
      end
    end
    h = { action.to_sym => @cmds }
    t = { action.to_sym => desc.to_s }
    @@actions = @@actions.merge(h)
    @@tasks = @@tasks.merge(t)
  end

  def shell(cmd)
    check_sub_call(:shell)
    raise "'shell' needs a String as parameter." unless cmd.is_a? String
    @cmds << cmd
  end

  def call(action)
    check_sub_call(:call)
    raise "'call :action_name'. You didn't pass a Symbol." unless action.is_a? Symbol
    @cmds << action
  end

  def set(opt, value)
    check_main_call(:set)
    @@options[opt.to_sym] = value
  end

  private

  def check_main_call(func)
    method = caller[2][/`([^']*)'/, 1]
    raise "#{caller[1].split(" ")[0]} '#{func}'. Main functions cannot be called in functions." unless method.eql?("load")
  end

  def check_sub_call(func)
    method = caller[2][/`([^']*)'/, 1]
    raise "#{caller[1].split(" ")[0]} '#{func}'. '#{func}' has to be called in 'action' function." unless method.eql?("action")
  end

end
