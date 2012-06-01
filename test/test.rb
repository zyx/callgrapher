require 'classgraphr'
require 'minitest/autorun'

class Class1
  def initialize
  end
  def test
    Class2.new.test
  end
end

class Class2
  def test
    Class3.new.test
    Class4.new.test
  end
end

class Class3
  def test
    Class5.test
  end
end

class Class4
  def test
    Class5.test
  end
end

class Class5
  def self.test
    Class1.new
  end
end

class Test < MiniTest::Unit::TestCase
  def test_output_with_known_class_graph
    desired_graph =                                           {
      Class1 => Set.new([Class, BasicObject, Class2])         ,
      Class2 => Set.new([Class, BasicObject, Class3, Class4]) ,
      Class3 => Set.new([Class5])                             ,
      Class5 => Set.new([Class, Class1])                      ,
      Class4 => Set.new([Class5])                             }

    assert_equal trace_class_dependencies{ Class1.new.test }, desired_graph
  end
end
