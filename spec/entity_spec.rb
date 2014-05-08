require 'spec_helper'
require 'timecop'
require 'schemad/entity'

require_relative 'fixtures/demo_class'

describe Schemad::Entity do
  before { Timecop.freeze }
  after { Timecop.return }

  Given(:normal_data) {{
    world: "coordinates",
    cool: true,
    roads: 5,
    beasts: "1337"
  }}

  context "#from_data" do
    Given(:ent) { Ent.from_data(normal_data) }

    Then { ent.attribute_names.should == [:forest, :roads, :beasts, :world, :cool, :created]}

    context "defaults or nil get used when no data" do

      Then { ent.forest.should == "Green" }
      And { ent.cool.should be_true }
      And { ent.created.should eq(Time.now) }
      And { ent.roads.should == 5 }
      And { ent.world.should == "coordinates" }
    end

    context "parses types" do
      Then { ent.beasts.should == 1337 }
    end

    context "defines #? method for bools" do
      Then { ent.should be_cool }
    end

    context "assumes string if no type given" do
      Then { ent.world.should be_a(String) }
    end

    context "can get all params as a hash" do
      When(:hash) { ent.to_hash }
      Then { hash.should == {
        forest: "Green",
        roads: 5,
        beasts: 1337,
        world: "coordinates",
        cool: true,
        created: Time.now
      }}
    end
  end
end
