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
  context "indifferent hash wrapper" do
    When(:converted) { ext.send :indifferent_hash, {one: 1, "two" => 2, "Three and Four" => 34} }
    Then { converted["one"].should == 1 }
    And { converted[:two].should == 2 }
    And { converted["Three and Four"].should == 34 }
  end
end