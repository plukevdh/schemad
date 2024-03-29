require 'spec_helper'

require 'schemad/type_handler'
require 'schemad/abstract_handler'

require 'schemad/types/boolean_handler'
require 'schemad/types/string_handler'
require 'schemad/types/time_handler'
require 'schemad/types/integer_handler'

describe Schemad::TypeHandler do

  context "rejects unknown types" do
    When(:typer) { Schemad::TypeHandler.new(:fake_type) }
    Then { typer == Failure(Schemad::TypeHandler::UnknownHandler, /No known handlers for FakeType/) }
  end

  context "defaults to string type" do
    When(:typer) { Schemad::TypeHandler.new }
    Then { expect(typer.instance_variable_get(:@handler)).to be_a(Schemad::StringHandler) }
  end

  context "can register custom handlers" do
    class YouMomHandler < Schemad::AbstractHandler
      handle :your_mom

      def parse(value)
        "Your Mom"
      end
    end

    Given { Schemad::TypeHandler.register(YouMomHandler) }
    Given(:typer) { Schemad::TypeHandler.new(:your_mom) }
    When(:parsed) { typer.parse("Good vs. Evil") }
    Then { expect(parsed).to eq "Your Mom" }
  end

  context "can handle bools" do
    Given(:bool_handler) { Schemad::TypeHandler.new(:boolean) }

    context "knows trues" do
      Schemad::BooleanHandler::VALID_TRUTHS.each do |val|
        When(:parsed) { bool_handler.parse(val) }
        Then { expect(parsed).to eq true }
      end
    end

    context "rejects falses" do
      [42, "Hello World", nil, String].each do |val|
        When(:parsed) { bool_handler.parse(val) }
        Then { expect(parsed).to eq false }
      end
    end
  end

  context "can parse integers" do
    Given(:int_handler) { Schemad::TypeHandler.new(:integer) }

    context "true to 1" do
      When(:result) { int_handler.parse(true) }
      Then { expect(result).to eq(1) }
    end

    context "false to 0" do
      When(:result) { int_handler.parse(false) }
      Then { expect(result).to eq(0) }
    end

    context "strings to numbers" do
      When(:result) { int_handler.parse("42") }
      Then { expect(result).to eq 42 }
    end

    context "odd strings to 0" do
      When(:result) { int_handler.parse("sneeze") }
      Then { expect(result).to eq 0 }
    end

    context "nil for unknown items" do
      When(:result) { int_handler.parse(String) }
      Then { expect(result).to eq nil }
    end
  end

  context "can parse dates" do
    Given(:date_handler) { Schemad::TypeHandler.new(:date_time) }
    Given(:time) { DateTime.now.to_time }

    context "knows unix time" do
      When(:result) { date_handler.parse(time.to_i) }
      Then { expect(result.to_i).to eq time.to_i }
    end

    context "knows iso8601 time" do
      When(:result) { date_handler.parse(time.iso8601) }
      Then { expect(result.to_i).to eq time.to_i }
    end

    context "knows ruby date format time" do
      When(:result) { date_handler.parse(time.to_s) }
      Then { expect(result.to_i).to eq time.to_i }
    end

    context "knows ruby date object" do
      Given(:date) { Date.today }
      When(:result) { date_handler.parse(date) }
      Then { expect(result).to be_a(Time) }
      And { expect(result.to_i).to eq date.to_time.to_i }
    end

    context "knows ruby time objects" do
      Given(:time) { Time.now }
      When(:result) { date_handler.parse(time) }
      Then { expect(result).to be_a(Time) }
      Then { expect(result.to_i).to eq time.to_i }
    end

    context "knows ruby time objects" do
      Given(:date_time) { DateTime.now }
      When(:result) { date_handler.parse(date_time) }
      Then { expect(result).to be_a(Time) }
      Then { expect(result.to_i).to eq date_time.to_time.to_i }
    end

    context "bails on nils" do
      When(:result) { date_handler.parse nil }
      Then { expect(result).to be_nil }
    end

    context "bails on empty strings" do
      When(:result) { date_handler.parse "" }
      Then { expect(result).to be_nil }
    end
  end
end
