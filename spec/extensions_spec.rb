require 'spec_helper'
require 'schemad/extensions'

class Demo
  class Foo
    class Bar
      include Schemad::Extensions
    end
  end
end

describe Schemad::Extensions do
  Given(:ext) { Demo::Foo::Bar.new }

  When(:class_base) { Demo::Foo::Bar.base_class_name }
  Then { class_base.should == "Bar" }

  When(:base) { ext.base_class_name }
  Then { base.should == "Bar" }

  When(:const) { ext.send :constantize, "Demo::Foo::Bar" }
  Then { const.should == Demo::Foo::Bar }
end