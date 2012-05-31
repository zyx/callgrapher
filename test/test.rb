require 'classgraphr'

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

show_class_graph trace_class_dependencies{ Class1.new.test }
