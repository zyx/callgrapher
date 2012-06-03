ClassGraphR
===========

Produce class dependency graphs by tracing method calls while code runs. Outputs
a .dot file for use with [GraphViz](http://www.graphviz.org/).

Requirements
-----------
Ruby 1.9 or later & Graphviz on your $PATH

Usage
-----
Require 'classgraphr' and call trace_class_dependencies, passing in a block
containing the code you want to graph. A Hash of sets will be returned, ready
for proccesing with make_class_graph. Calling make_class_graph uses the `dot`
command to generate a graph & save it to /tmp/graph.png.

Known Limitations
-----------------
It does not pick up dependencies created by calling methods defined by the
attr_reader, attr_writer and attr_accessor methods. (see [this][bug] bug report)
). There's probably various other meta-programming techniques that will interact
poorly with this as well.

 [bug]: http://bugs.ruby-lang.org/issues/4583

License
-------
Copyright (c) 2010-2012 Luke Andrew

All code is distributed under the terms of the [GPL version 3][gpl]. All other
copyrightable material is distributed under the terms of the [Creative Commons
Attribution-ShareAlike 3.0 Unported License][cc]

Copies of these licenses are available in the files `LICENSE-GPLv3` and `LICENSE-CC-BY-SA`.

 [gpl]: http://www.gnu.org/licenses/gpl.html
 [cc]:  http://creativecommons.org/licenses/by-sa/3.0/
