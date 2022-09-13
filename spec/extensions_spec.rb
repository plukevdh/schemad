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

  context "base class name getter" do
    When(:class_base) { Demo::Foo::Bar.base_class_name }
    Then { expect(class_base).to eq "Bar" }
  end

  context "instance method for base class" do
    When(:base) { ext.base_class_name }
    Then { expect(base).to eq "Bar" }
  end

  context "constantizer" do
    When(:const) { ext.send :constantize, "Demo::Foo::Bar" }
    Then { expect(const).to eq Demo::Foo::Bar }
  end

  context "classifier" do
    When(:classy) { ext.send :classify, "demo_foo_bar" }
    Then { expect(classy).to eq "DemoFooBar" }
  end

  context "indifferent hash wrapper" do
    When(:converted) { ext.send :indifferent_hash, {one: 1, "two" => 2, "Three and Four" => 34} }
    Then { expect(converted["one"]).to eq 1 }
    And { expect(converted[:two]).to eq 2 }
    And { expect(converted["Three and Four"]).to eq 34 }
  end
end