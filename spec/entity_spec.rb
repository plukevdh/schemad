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
      Then { expect(attrs).to eq(fields) }
    end

    context "on instance" do
      When(:attrs) { Ent.new.attribute_names }
      Then { expect(attrs).to eq fields }
    end
  end

  context "#from_data" do
    Given(:ent) { Ent.from_data(normal_data) }

    Then { expect(ent.attribute_names).to eq([:forest, :roads, :beasts, :world, :cool, :created])}

    context "defaults or nil get used when no data" do

      Then { expect(ent.forest).to eq "Green" }
      And { expect(ent.cool).to eq true }
      And { expect(ent.created).to eq(Time.now) }
      And { expect(ent.roads).to eq 5 }
      And { expect(ent.world).to eq "coordinates" }
    end

    context "parses types" do
      Then { expect(ent.beasts).to eq 1337 }
    end

    context "defines #? method for bools" do
      Then { expect(ent).to be_cool }
    end

    context "assumes string if no type given" do
      Then { expect(ent.world).to be_a(String) }
    end

    context "can get all params as a hash" do
      When(:hash) { ent.to_hash }
      Then { expect(hash).to eq({
          forest: "Green",
          roads: 5,
          beasts: 1337,
          world: "coordinates",
          cool: true,
          created: Time.now
        })
      }
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
        Then { expect(parent.name).to eq "Whil Wheaton" }
      end

      context "parent does not get child attributes" do
        When(:result) { parent.place }
        Then { result == Failure(NoMethodError) }
      end

      context "child has all attributes" do
        Given do
          child.name = "Bill Cosby"
          child.place = "NY, NY"
        end
        Then { expect(child.name).to eq "Bill Cosby" }
        And { expect(child.place).to eq "NY, NY" }
      end
    end

    context 'via #from_data' do
      Given(:parent) { Base.from_data({ name: "Whil Wheaton", place: "Burt's Bees" }) }

      context "parent has top-level attributes" do
        Then { expect(parent.name).to eq "Whil Wheaton" }
      end

      context "parent does not get child attributes" do
        When(:result) { parent.place }
        Then { result == Failure(NoMethodError) }
      end

      context "child has all attributes" do
        Given(:child) { Sub.from_data({ name: "Jim Beam", place: "Black, Not" }) }
        Then { expect(child.name).to eq "Jim Beam" }
        And { expect(child.place).to eq "Black, Not" }
      end
    end
  end
end
