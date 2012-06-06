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
    self.self_call
    Class1.new
  end
  def self.self_call
  end
end

class Test < MiniTest::Unit::TestCase
  ExpectedTestGraph =                     {
      Class1 => Set.new([Class2])         ,
      Class2 => Set.new([Class3, Class4]) ,
      Class3 => Set.new([Class5])         ,
      Class5 => Set.new([Class1])         ,
      Class4 => Set.new([Class5])         }

  ExpectedGraphvizGraph = 'digraph callgraph {"Class1" -> "Class2";
"Class2" -> "Class3";
"Class2" -> "Class4";
"Class3" -> "Class5";
"Class5" -> "Class1";
"Class4" -> "Class5";
}'

  def test_class_dependency_tracing
    assert_equal ClassGraphR.trace_class_dependencies{ Class1.new.test }, ExpectedTestGraph
  end

  def test_graphviz_output
    assert_equal ClassGraphR.make_graphviz_graph(ExpectedTestGraph), ExpectedGraphvizGraph
  end

  def test_file_whitelist
    assert_equal ClassGraphR.trace_class_dependencies([]) { Class1.new.test}, {}
    assert_equal ClassGraphR.trace_class_dependencies([__FILE__]) { Class1.new.test}, ExpectedTestGraph
  end

  # This test doesn't assert anything, it's just convenient to have the tests
  # call Graphviz for you so you can manually inspect the output.
  def test_make_graph
    ClassGraphR.make_graph ExpectedGraphvizGraph
  end
end
