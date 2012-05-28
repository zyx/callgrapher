# TODO blacklist & just class mode

require 'set'

def func1
  func2
end

def func2
  func3a
  func3b
end

def func3a
end

def func3b
  Class1.new.test
end

class Class1
  def test
    Class2.new.test
  end
end

class Class2
  def test
    Class3.new.test
  end
end

class Class3
  def test
  end
end

def start_trace
  $callstack = []
  $call_graph = Hash.new{ |hash, key| hash[key] = Set.new }

  set_trace_func proc{ |event, file, line, id, binding, classname|
    case event
      when 'call','c-call'
        caller = $callstack[-1]
        $call_graph[caller].add classname
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

  IO.popen('dot -Tpng /tmp/graph.dot -o/tmp/graph.png', 'w') do |output|
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
func1
stop_trace
show_call_graph $call_graph
