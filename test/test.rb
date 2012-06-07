#  Copyright (C) 2012 Luke Andrew
#
#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program.  If not, see <http://www.gnu.org/licenses/>.

# This is the main executable for the whysynth-controller project. It also
# contains most of the code that relies on external libraries. 

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
    M1::M2::Class3.new.test
    Class4.new.test
  end
end

module M1
  module M2
    class Class3
      def test
        M3::Class5.test
      end
    end
  end
end

class Class4
  def test
    M3::Class5.test
  end
end

module M3
  class Class5

    def self.test
      self.self_call
      Class1.new
    end

    def self.self_call
    end

  end
end

class Test < MiniTest::Unit::TestCase

  ExpectedTestGraph =                                           {
      'Class1'         => Set.new(['Class2'])                   ,
      'Class2'         => Set.new(['M1::M2::Class3', 'Class4']) ,
      'M1::M2::Class3' => Set.new(['M3::Class5'])               ,
      'Class4'         => Set.new(['M3::Class5'])               ,
      'M3::Class5'     => Set.new(['Class1'])                   }

  ExpectedTestGraph_NamespaceDepth1 =       {
      'Class1' => Set.new(['Class2'])       ,
      'Class2' => Set.new(['M1', 'Class4']) ,
      'M1'     => Set.new(['M3'])           ,
      'Class4' => Set.new(['M3'])           ,
      'M3'     => Set.new(['Class1'])       }

  ExpectedTestGraph_NamespaceDepth2 =               {
      'Class1'     => Set.new(['Class2'])           ,
      'Class2'     => Set.new(['M1::M2', 'Class4']) ,
      'M1::M2'     => Set.new(['M3::Class5'])       ,
      'Class4'     => Set.new(['M3::Class5'])       ,
      'M3::Class5' => Set.new(['Class1'])           }

  ExpectedGraphvizGraph = 'digraph callgraph {"Class1" -> "Class2";
"Class2" -> "M1::M2::Class3";
"Class2" -> "Class4";
"M1::M2::Class3" -> "M3::Class5";
"Class4" -> "M3::Class5";
"M3::Class5" -> "Class1";
}'

  EmptyHash = {}

  def test_class_dependency_tracing
    assert_equal ExpectedTestGraph, ClassGraphR.trace_class_dependencies{ Class1.new.test }
  end

  def test_graphviz_output
    assert_equal ExpectedGraphvizGraph, ClassGraphR.make_graphviz_graph(ExpectedTestGraph)
  end

  def test_file_whitelist
    assert_equal EmptyHash,
                 ClassGraphR.trace_class_dependencies(0, []){ Class1.new.test }

    assert_equal ExpectedTestGraph,
                 ClassGraphR.trace_class_dependencies(0, [__FILE__]) { Class1.new.test}
  end

  def test_namespace_depth
    assert_equal ExpectedTestGraph_NamespaceDepth1,
                 ClassGraphR.trace_class_dependencies(1) { Class1.new.test }

    assert_equal ExpectedTestGraph_NamespaceDepth2,
                 ClassGraphR.trace_class_dependencies(2) { Class1.new.test }
  end

  # This test doesn't assert anything, it's just convenient to have the tests
  # call Graphviz for you so you can manually inspect the output.
  def test_make_graph
    ClassGraphR.make_graph ExpectedGraphvizGraph
  end
end
