require 'test_helper'

class TestInclude
  include TinyTyping

  def initialize(t)
    test! t, String
  end
end

class TestExtends < TinyTyping::Base
  typed_attr_accessor value: String

  def initialize(t)
    test! t, String
  end

  typed_def :succ, Integer do |t|
    t + 1
  end
end

class TinyTypingTest < Minitest::Test
  def test_version
    refute_nil TinyTyping::VERSION
  end

  def test_test!
    assert_nil TinyTyping.test!('a', String)
    assert_raises(ArgumentError) { TinyTyping.test!(123, String) }
    assert_nil TinyTyping.test!(nil, nil)
    assert_nil TinyTyping.test!(nil, NilClass)
    assert_nil TinyTyping.test!(true, true)
    assert_nil TinyTyping.test!(true, TrueClass)

    assert_nil TinyTyping.test!(123, String, Numeric)

    assert_nil TinyTyping.test!([123], Array)
    assert_nil TinyTyping.test!([123], [Numeric])
    assert_raises(ArgumentError) { TinyTyping.test!(['a'], [Numeric]) }
    assert_nil TinyTyping.test!([123, 456, '7'], [Numeric, String])

    assert_nil TinyTyping.test!({ k1: 1, 'k2' => '2' }, Hash)
    assert_nil TinyTyping.test!({ k1: 1, 'k2' => '2' }, k1: Numeric, 'k2' => String)
    assert_raises(ArgumentError) { TinyTyping.test!({ k1: 1, 'k2' => '2' }, k1: Numeric) }
    assert_raises(ArgumentError) { TinyTyping.test!({ k1: 1, 'k2' => '2' }, k1: Numeric, 'k2' => Numeric) }
    assert_raises(ArgumentError) { TinyTyping.test!({ k1: 1, 'k2' => '2' }, k1: Numeric, 'k2' => String, x: String) }
    assert_nil TinyTyping.test!({ k1: 1, 'k2' => '2' }, Symbol => Numeric, String => String)
    assert_nil TinyTyping.test!({ k1: 1, 'k2' => '2' }, [Symbol, String] => [Numeric, String])
    assert_nil TinyTyping.test!({ k1: 1, 'k2' => '2' }, [Symbol, String] => String, k1: Numeric)
    assert_nil TinyTyping.test!({ k1: 1, 'k2' => '2' }, [Symbol, String] => [Numeric, String], x: [String, nil])

    assert_nil TinyTyping.test!([ { k1: [ { k2: 'v3' } ] } ], [ k1: [ [ k2: String ] ] ])
    assert_nil TinyTyping.test!({ k1: [ { k2: [ 'v3' ] } ] }, k1: [ [ k2: [ [ String ] ] ] ])
  end

  def test_test?
    assert TinyTyping.test?('a', String)
    refute TinyTyping.test?(123, String)
  end

  def test_include
    assert_raises(ArgumentError) { TestInclude.new(123) }
    assert TestInclude.new('a')
  end

  def test_extends
    assert_raises(ArgumentError) { TestExtends.new(123) }
    t = TestExtends.new('a')
    assert t
    assert t.succ(1) == 2
    assert_raises(ArgumentError) { t.succ(nil) }
    t.value = 'a'
    assert t.value == 'a'
    assert_raises(ArgumentError) { t.value = 123 }
    assert t.value == 'a'
  end
end
