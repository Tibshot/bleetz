class BleetzException < Exception
  attr_accessor :message

  def initialize(message)
    @message = message
  end
end

module Conf

  MAIN_CALLS = {:func => ['action', 'before', 'after', 'set'],
                :from => ['load']}

  SUB_CALLS =  {:shell => ['action', 'before', 'after'],
                :call => ['action'],
                :error => { :shell => "'shell'. 'shell' has to be called in 'action', 'before' or 'after' functions.",
                            :call => "'call'. 'call' has to be called in 'action' function."} }

  @@before = {}
  @@actions = {}
  @@after = {}
  @@tasks = {}
  @@options = {}

  def self.included(base)
    base.extend(self)
  end

  def action(action, desc = "")
    check_call(:action)
    load_conf { yield }
    h = { action.to_sym => @cmds }
    t = { action.to_sym => desc.to_s }
    @@actions = @@actions.merge(h)
    @@tasks = @@tasks.merge(t)
  end

  def before(action)
    check_call(:before)
    load_conf { yield }
    h = { action.to_sym => @before }
    if @@before[action.to_sym].nil?
      @@before = @@before.merge(h)
    else
      raise "You specified two 'before' callbacks for :#{action} action."
    end
  end

  def after(action)
    check_call(:after)
    load_conf { yield }
    h = { action.to_sym => @after }
    if @@before[action.to_sym].nil?
      @@after = @@after.merge(h)
    else
      raise "You specified two 'after' callbacks for :#{action} action."
    end
  end

  def shell(cmd)
    check_call(:shell)
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
    check_call(:call)
    raise "'call :action_name'. You didn't pass a Symbol." unless action.is_a? Symbol
    @cmds << action
  end

  def set(opt, value)
    check_call(:set)
    @@options[opt.to_sym] = value
  end

  private

  def check_call(func)
    if MAIN_CALLS[:func].include?(func.to_s)
      parent_call = caller[2][/`([^']*)'/, 1]
      unless MAIN_CALLS[:from].include?(parent_call)
        raise "#{caller[1].split(" ")[0]} '#{func}'. Main functions cannot be called in functions."
      end
    else
      parent_call = caller[4][/`([^']*)'/, 1]
      unless SUB_CALLS[func].include?(parent_call)
        raise "#{caller[1].split(" ")[0]} #{SUB_CALLS[:error][func]}"
      end
    end
  end

  def load_conf
    @after = @cmds = @before = []
    begin
      yield
    rescue Exception => e
      if e.class.eql? RuntimeError
        raise BleetzException.new(e.message)
      else
        raise BleetzException.new("#{e.class}: #{e.message} in #{e.backtrace[0]}")
      end
    end
  end

end
