require 'spec_helper'
require 'timecop'
require 'schemad/default_types'
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

  context "introspection" do
    Given(:fields) { %i[forest roads beasts world cool created] }

    context "on class" do
      When(:attrs) { Ent.attribute_names }
      Then { attrs.should == fields }
    end

    context "on instance" do
      When(:attrs) { Ent.new.attribute_names }
      Then { attrs.should == fields }
    end
  end

  context "#from_data" do
    Given(:ent) { Ent.from_data(normal_data) }

    Then { ent.attribute_names.should == [:forest, :roads, :beasts, :world, :cool, :created]}

    context "defaults or nil get used when no data" do

      Then { ent.forest.should == "Green" }
      And { ent.cool.should eq true }
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

  context "inherited entities" do
    class Base
      include Schemad::Entity

      attribute :name
    end

    class Sub < Base
      attribute :place
    end

    context "via setters" do
      Given(:parent) { Base.new }
      Given(:child) { Sub.new }

      context "parent has top-level attributes" do
        When { parent.name = "Whil Wheaton" }
        Then { parent.name.should == "Whil Wheaton" }
      end

      context "parent does not get child attributes" do
        When(:result) { parent.place }
        Then { expect(result).to have_failed(NoMethodError) }
      end

      context "child has all attributes" do
        Given do
          child.name = "Bill Cosby"
          child.place = "NY, NY"
        end
        Then { child.name.should == "Bill Cosby" }
        And { child.place.should == "NY, NY" }
      end
    end

    context 'via #from_data' do
      Given(:parent) { Base.from_data({ name: "Whil Wheaton", place: "Burt's Bees" }) }

      context "parent has top-level attributes" do
        Then { parent.name.should == "Whil Wheaton" }
      end

      context "parent does not get child attributes" do
        When(:result) { parent.place }
        Then { expect(result).to have_failed(NoMethodError) }
      end

      context "child has all attributes" do
        Given(:child) { Sub.from_data({ name: "Jim Beam", place: "Black, Not" }) }
        Then { child.name.should == "Jim Beam" }
        And { child.place.should == "Black, Not" }
      end
    end
  end
end
