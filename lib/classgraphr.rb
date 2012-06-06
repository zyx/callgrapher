require 'set'

module ClassGraphR

  # @param [Array<String>] file_whitelist only include classes defined in these files.
  def self.trace_class_dependencies(file_whitelist = nil)
    callstack = []
    classgraph = Hash.new{ |hash, key| hash[key] = Set.new }

    set_trace_func proc{ |event, file, line, id, binding, classname|
      next unless !file_whitelist || file_whitelist.include?(file)
      case event
        when 'call'
          caller = callstack[-1]
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
  def self.make_graph(graph)
    IO.popen('dot -Tpng -o/tmp/graph.png', 'w') { |out| out.write graph }
  end

end
