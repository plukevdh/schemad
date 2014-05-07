require 'spec_helper'
require 'schemad/normalizer'

class Demalizer < Schemad::Normalizer
  normalize :world, key: "Middle Earth" do |val|
    val.upcase
  end
  normalize :roads do |val|
    val * 10
  end
end

describe Schemad::Normalizer do
  Given(:data) {{
    "Middle Earth" => "coordinates",
    cool: "true",
    roads: 5,
    "beasts" => "1337"
  }}

  Given(:normalizer) { Demalizer.new }
  When(:normalized) { normalizer.normalize(data) }

  context "maps specified keys" do
    Then { normalized[:world].should == "COORDINATES" }
    And { normalized[:cool].should == "true" }
  end

  context "runs converters where specified" do
    Then { normalized[:roads].should == 50 }
  end

  context "passes through unspecified keys" do
    Then { normalized[:cool].should == "true" }
    And { normalized[:beasts].should == "1337" }
  end

  context "converts all keys to symbols" do
    Then { normalized[:cool].should_not be_nil }
    And { normalized[:beasts].should_not be_nil }
    And { normalized["Middle Earth"].should be_nil }
  end

  context "can force only properties from entity" do
    Given(:entity) { double(attribute_names: [:world, :beasts]) }
    Given { normalizer.class.filter_attributes_with(entity) }
    When(:results) { normalizer.normalize(data) }
    Then { results.values_at(:world, :beasts).all? {|v| v.nil? }.should be_false }
    And { results[:world].should == "COORDINATES" }
    And { results.values_at(:cool, "Middle Earth", :roads).all? {|v| v.nil? }.should be_true }
  end
end