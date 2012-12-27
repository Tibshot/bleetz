require 'test/unit'
require 'bleetz/conf'
require 'bleetz/object'

class TestConf < Test::Unit::TestCase

  def test_fail_action
    begin
      load Dir.pwd + '/test/files/fail_action'
    rescue Exception => e
      assert_equal "#{Dir.pwd}/test/files/fail_action:2:in 'action'. Main functions cannot be called in functions.", e.message
    end
  end

  def test_fail_set
    begin
      load Dir.pwd + '/test/files/fail_set'
    rescue Exception => e
      assert_equal "#{Dir.pwd}/test/files/fail_set:2:in 'set'. Main functions cannot be called in functions.", e.message
    end
  end

  def test_fail_shell
    begin
      load Dir.pwd + '/test/files/fail_shell'
    rescue Exception => e
      assert_equal "#{Dir.pwd}/test/files/fail_shell:1:in 'shell'. 'shell' has to be called in 'action' function.", e.message
    end
  end

  def test_fail_call
    begin
      load Dir.pwd + '/test/files/fail_call'
    rescue Exception => e
      assert_equal "#{Dir.pwd}/test/files/fail_call:1:in 'call'. 'call' has to be called in 'action' function.", e.message
    end
  end

  # Thx @Nekith
  def test_fail_code_type_error
    begin
      load Dir.pwd + '/test/files/fail_type_error'
    rescue Exception => e
      assert_equal "TypeError: can't convert Fixnum into String in #{Dir.pwd}/test/files/fail_type_error:6:in `+'", e.message
    end
  end

end
