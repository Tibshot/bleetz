require 'test/unit'
require 'bleetz'

class TestBleetz < Test::Unit::TestCase
  def assert_abort(message)
    orig_std = STDERR.dup
    $stderr.reopen '/dev/null', 'w'
    e = assert_raises SystemExit do
        yield
    end
    $stderr.reopen orig_std
    assert_equal message, e.message
  end

  def test_fail_loop
    assert_abort "You seem to create a call loop: stack level too deep" do
      ARGV.replace ["-c", "#{Dir.pwd}/test/files/fail_loop", "deploy"]
      Bleetz.new
    end
  end

  def test_fail_no_opt
    assert_abort "You have to configure SSH options." do
      ARGV.replace ["-c", "#{Dir.pwd}/test/files/fail_no_opt", "test"]
      Bleetz.new
    end
  end

  def test_fail_no_action
    assert_abort "Unknown action: 'test'." do
      ARGV.replace ["-c", "#{Dir.pwd}/test/files/fail_no_action", "test"]
      Bleetz.new
    end
  end

  def test_fail_no_action_2
    assert_abort "Unknown action: 'test'." do
      ARGV.replace ["-c", "#{Dir.pwd}/test/files/fail_no_action", "-t", "test"]
      Bleetz.new
    end
  end

end
