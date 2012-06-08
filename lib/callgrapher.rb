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

require 'set'

module CallGrapher

  # @param [Array<String>] file_whitelist
  #   Only include classes defined in these files.
  # @param [Integer] namespace_depth 
  #   The number of namespaces to report. For example, a class name of
  #   Foo::Bar::Baz, when processed with namespace_depth == 1, would be reported
  #   as just Foo.  With namespace_depth == 2, as Foo::Bar, and so on. A
  #   namespace_depth of 0 indicates that the entire class name should be
  #   reported.
  def self.trace_class_dependencies(namespace_depth = 0,
                                    file_whitelist = nil,
                                    class_blacklist = nil)
    callstack = []
    classgraph = Hash.new{ |hash, key| hash[key] = Set.new }

    set_trace_func proc{ |event, file, line, id, binding, classname|
      next if file_whitelist && !file_whitelist.include?(file)
      next if class_blacklist && class_blacklist.include?(classname)
      case event
        when 'call'
          caller = callstack[-1]

          classname =
            if namespace_depth > 0
              classname.name.split('::').first(namespace_depth).join('::')
            else
              classname.name
            end

          classgraph[caller].add classname if caller && caller != classname
          callstack.push classname
        when 'return'
          callstack.pop
      end
    }

    yield

    set_trace_func nil
    classgraph
  end

  # @param [Hash<Class, Set>] call_graph
  #   the graph to transform into a Graphviz digraph
  def self.make_graphviz_graph(call_graph)

    graph = ''
    graph << 'digraph callgraph {'

    call_graph.each do |klass, dependencies|
      dependencies.each do |dependency|
        graph << "\"#{klass}\" -> \"#{dependency}\";\n"
      end
    end

    graph << '}'
  end

  # @param graph a string containing a dot format digraph
  def self.make_graph(graph, path)
    IO.popen("dot -Tpng -o#{path}", 'w') { |out| out.write graph }
  end

end
