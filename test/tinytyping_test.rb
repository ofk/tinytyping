require 'test_helper'

class TinyTypingTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::TinyTyping::VERSION
  end

  def test_test!
    assert_nil TinyTyping.test!('a', String)
    assert_raises(ArgumentError) { TinyTyping.test!(123, String) }
    assert_nil TinyTyping.test!(nil, String, nil)
    assert_nil TinyTyping.test!([123], Array)
    assert_nil TinyTyping.test!([123], [Numeric])
    assert_raises(ArgumentError) { TinyTyping.test!(['a'], [Numeric]) }
    assert_nil TinyTyping.test!([123, 456, '7'], [Numeric, String])
    assert_nil TinyTyping.test!({ k: 1 }, k: Numeric)
    assert_raises(ArgumentError) { TinyTyping.test!({ k: 1 }, k: Numeric, x: String) }
    assert_nil TinyTyping.test!({ k: 1 }, k: Numeric, 'a' => [String, nil])
  end

  def test_test?
    assert TinyTyping.test?('a', String)
    refute TinyTyping.test?(123, String)
    assert TinyTyping.test?(nil, String, nil)
    assert TinyTyping.test?([123], Array)
    assert TinyTyping.test?([123], [Numeric])
    refute TinyTyping.test?(['a'], [Numeric])
    assert TinyTyping.test?([123, 456, '7'], [Numeric, String])
    assert TinyTyping.test?({ k: 1 }, k: Numeric)
    refute TinyTyping.test?({ k: 1 }, k: Numeric, x: String)
    assert TinyTyping.test?({ k: 1 }, k: Numeric, 'a' => [String, nil])
  end
end
