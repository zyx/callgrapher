require 'set'

module ClassGraphR

  def self.trace_class_dependencies
    callstack = []
    classgraph = Hash.new{ |hash, key| hash[key] = Set.new }

    set_trace_func proc{ |event, file, line, id, binding, classname|
      case event
        when 'call','c-call'
          caller = callstack[-1]

          # This line checks for the case where one class constructs another class
          # via the new method. The method usually invoked is Class.new, so we
          # check for that condition and create a direct dependency between the
          # class calling new and the initialized class.
          caller = callstack[-2] if caller == Class && id == :initialize

          classgraph[caller].add classname if caller
          callstack.push classname
        when 'return','c-return'
          callstack.pop
      end
    }

    yield

    set_trace_func nil
    classgraph
  end

  def self.make_graphviz_graph(call_graph)

    # Most ruby code ends up depending on these classes, so we keep the graph
    # cleaner by ignoring them.
    class_blacklist = [Object, Class, Kernel, IO, BasicObject]

    graph = ''
    graph << 'digraph callgraph {'

    call_graph.each do |klass, dependencies|
      next if class_blacklist.include? klass
      dependencies.each do |dependency|
        next if class_blacklist.include? dependency
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
