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

callstack = []
call_graph = Hash.new{ |hash, key| hash[key] = Set.new }

call_graph_tracer = proc do |event, file, line, id, binding, classname|
  case event
    when 'call','c-call'
      caller = callstack[-1]
      callee = "#{classname}##{id}"
      call_graph[caller].add callee if caller
      callstack.push callee
    when 'return','c-return'
      callstack.pop
  end
end

def show_call_graph(call_graph)
  output = File.new '/tmp/graph.dot', 'w'
  output.write 'digraph callgraph {'

  call_graph.each do |func, dependencies|
    dependencies.each do |d|
      output.write "\"#{func}\" -> \"#{d}\";"
    end
  end

  output.write '}'
  output.close

  system 'dot -Tpng /tmp/graph.dot -o/tmp/graph.png'
  system 'eog /tmp/graph.png'
end

set_trace_func call_graph_tracer
func1
set_trace_func nil
show_call_graph call_graph
