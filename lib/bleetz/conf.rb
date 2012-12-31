class BleetzException < Exception
  attr_accessor :message

  def initialize(message)
    @message = message
  end
end

module Conf

  @@before = {}
  @@actions = {}
  @@after = {}
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

  def before(action)
    check_main_call(:before)
    @before = []
    begin
      yield
    rescue Exception => e
      if e.class.eql? RuntimeError
        raise BleetzException.new(e.message)
      else
        raise BleetzException.new("#{e.class}: #{e.message} in #{e.backtrace[0]}")
      end
    end
    h = { action.to_sym => @before }
    if @@before[action.to_sym].nil?
      @@before = @@before.merge(h)
    else
      raise "You specified two 'before' callbacks for :#{action} action."
    end
  end

  def after(action)
    @after = []
    check_main_call(:after)
    begin
      yield
    rescue Exception => e
      if e.class.eql? RuntimeError
        raise BleetzException.new(e.message)
      else
        raise BleetzException.new("#{e.class}: #{e.message} in #{e.backtrace[0]}")
      end
    end
    h = { action.to_sym => @after }
    if @@before[action.to_sym].nil?
      @@after = @@after.merge(h)
    else
      raise "You specified two 'after' callbacks for :#{action} action."
    end
  end

  def shell(cmd)
    check_sub_call_for_shell
    raise "'shell' needs a String as parameter." unless cmd.is_a? String
    if caller[1][/`([^']*)'/, 1].eql?("action")
      @cmds << cmd
    elsif caller[1][/`([^']*)'/, 1].eql?("before")
      @before << cmd
    else
      @after << cmd
    end
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
    unless method.eql?("load")
      raise "#{caller[1].split(" ")[0]} '#{func}'. Main functions cannot be called in functions."
    end
  end

  def check_sub_call_for_shell
    method = caller[2][/`([^']*)'/, 1]
    if !method.eql?("action") && !method.eql?("before") && !method.eql?("after")
      raise "#{caller[1].split(" ")[0]} 'shell'. 'shell' has to be called in 'action', 'before' or 'after' functions."
    end
  end

  def check_sub_call(func)
    method = caller[2][/`([^']*)'/, 1]
    unless method.eql?("action")
      raise "#{caller[1].split(" ")[0]} '#{func}'. '#{func}' has to be called in 'action' function."
    end
  end

end
