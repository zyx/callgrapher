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


def start_trace
  $callstack = []
  $call_graph = Hash.new{ |hash, key| hash[key] = Set.new }

  set_trace_func proc{ |event, file, line, id, binding, classname|
    case event
      when 'call','c-call'
        caller = $callstack[-1]
        $call_graph[caller].add classname if caller
        $callstack.push classname
      when 'return','c-return'
        $callstack.pop
    end
  }
end

def stop_trace
  set_trace_func nil
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

start_trace
Class1.new.test
stop_trace

show_call_graph $call_graph
