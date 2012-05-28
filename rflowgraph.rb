require 'set'

class Class1
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
  end
end

def trace_class_dependencies
  callstack = []
  classgraph = Hash.new{ |hash, key| hash[key] = Set.new }

  set_trace_func proc{ |event, file, line, id, binding, classname|
    case event
      when 'call','c-call'
        caller = callstack[-1]
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

def show_call_graph(call_graph)
  class_blacklist = [Object, Class]

  IO.popen('dot -Tpng -o/tmp/graph.png', 'w') do |output|
    output.write 'digraph callgraph {'

    call_graph.each do |func, dependencies|
      dependencies.each do |dependency|
        next if (class_blacklist & [func, dependency]).any?
        output.write "\"#{func}\" -> \"#{dependency}\";"
      end
    end

    output.write '}'
  end

  system 'eog /tmp/graph.png'
end

show_call_graph trace_class_dependencies{ Class1.new.test }
