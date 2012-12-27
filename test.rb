require 'minitest/autorun'
class TestEsy < MiniTest::Unit::TestCase
  Dir["*.esy"].each do |fn|
    define_method "test_#{fn}" do
     res = %x{ ruby -w esy.rb #{fn} }
     assert_equal File.read(fn.sub('esy', 'out')), res
    end
  end
end

