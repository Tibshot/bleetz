module Conf

  @@actions = {}
  @@tasks = {}
  @@options = {}

  def self.included(base)
    base.extend(self)
  end

  def task(action, desc = "")
    check_main_call(:task)
    @cmds = []
    yield
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

  def call(task)
    check_sub_call(:call)
    raise "'call :task_name'. You didn't pass a Symbol." unless task.is_a? Symbol
    @cmds << task
  end

  def set(opt, value)
    check_main_call(:set)
    @@options[opt.to_sym] = value
  end

  private

  def check_main_call(func)
    method = caller[2][/`([^']*)'/, 1]
    raise "Main configuration function, you cannot call '#{func}' it in '#{method}'." unless method.eql?("load")
  end

  def check_sub_call(func)
    method = caller[2][/`([^']*)'/, 1]
    raise "'#{func}' has to be called in 'task'." unless method.eql?("task")
  end

end
