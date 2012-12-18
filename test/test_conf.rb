require 'test/unit'
require 'bleetz/conf'
require 'bleetz/object'

class TestConf < Test::Unit::TestCase

  def test_fail_action
      begin
        load Dir.pwd + '/test/files/fail_action'
      rescue Exception => e
        assert_equal "Main configuration function, you cannot call 'action' in 'action'.", e.message
      end
  end

  def test_fail_set
    begin
      load Dir.pwd + '/test/files/fail_set'
    rescue Exception => e
      assert_equal "Main configuration function, you cannot call 'set' in 'action'.", e.message
    end
  end

  def test_fail_shell
    begin
      load Dir.pwd + '/test/files/fail_shell'
    rescue Exception => e
      assert_equal "'shell' has to be called in 'action' function.", e.message
    end
  end

  def test_fail_call
    begin
      load Dir.pwd + '/test/files/fail_call'
    rescue Exception => e
      assert_equal "'call' has to be called in 'action' function.", e.message
    end
  end


end
