require 'spec_helper'
require 'timecop'
require 'schemad/entity'

data = {
  "Middle Earth" => "coordinates",
  cool: true,
  roads: 5,
  "beasts" => "1337",
}

class Ent < Schemad::Entity
  attribute :forest, type: :string, default: "Green"
  attribute :roads, type: :integer do |value|
    value * 10
  end
  attribute :beasts, type: :integer
  attribute :world, type: :string, key: "Middle Earth" do |value|
    value.upcase
  end
  attribute :cool, type: :boolean
  attribute :created, type: :date_time, default: -> { Time.now }
end

describe Schemad::Entity do

  context "#from_data" do
    Given(:ent) { Ent.from_data(data) }

    Then { ent.attribute_names.should == [:forest, :roads, :beasts, :world, :cool, :created]}

    context "defaults or nil get used when no data" do
      Then { ent.forest.should == "Green" }
      And { ent.cool.should be_true }
      And { ent.created.to_i.should eq(Time.now.to_i) }
    end

    context "converters modify data" do
      Then { ent.roads.should == 50 }
    end

    context "can alias lookup key" do
      Then { ent.world.should == "COORDINATES" }
    end

    context "parses types" do
      Then { ent.beasts.should == 1337 }
    end

    context "defines #? method for bools" do
      Then { ent.should be_cool }
    end

    context "can get all params as a hash" do
      before { Timecop.freeze }
      after { Timecop.return }

      When(:hash) { ent.to_hash }
      Then { hash.should == {
        forest: "Green",
        roads: 50,
        beasts: 1337,
        world: "COORDINATES",
        cool: true,
        created: Time.now
      }}
    end
  end
end
