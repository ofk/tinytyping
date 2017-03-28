require 'test_helper'

class T < TinyTyping::Base
  typed_attr_accessor value: String

  def initialize(t)
    test! t, String
  end

  typed_def :succ, Integer do |t|
    t + 1
  end
end

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
    assert_nil TinyTyping.test!({ k: 1 }, Symbol => Numeric)
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
    assert TinyTyping.test?({ k: 1 }, Symbol => Numeric)
    refute TinyTyping.test?({ k: 1 }, k: Numeric, x: String)
    assert TinyTyping.test?({ k: 1 }, k: Numeric, 'a' => [String, nil])
  end

  def test_base_class
    assert_raises(ArgumentError) { T.new(123) }
    t = T.new('a')
    assert t.succ(1) == 2
    assert_raises(ArgumentError) { t.succ(nil) }
    t.value = 'a'
    assert t.value == 'a'
    assert_raises(ArgumentError) { t.value = 123 }
    assert t.value == 'a'
  end
end
