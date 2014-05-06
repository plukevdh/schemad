require 'spec_helper'
require 'schemad/type_handler'

describe Schemad::TypeHandler do

  context "rejects unknown types" do
    When(:typer) { Schemad::TypeHandler.new(:fake_type) }
    Then { expect(typer).to have_failed(Schemad::TypeHandler::UnknownDataType, /No known handlers for FakeType/) }
  end

  context "can handle bools" do
    Given(:bool_handler) { Schemad::TypeHandler.new(:boolean) }

    context "knows trues" do
      Schemad::BooleanHandler::VALID_TRUTHS.each do |val|
        When(:parsed) { bool_handler.parse(val) }
        Then { parsed.should be_true }
      end
    end

    context "rejects falses" do
      [42, "Hello World", nil, String].each do |val|
        When(:parsed) { bool_handler.parse(val) }
        Then { parsed.should be_false }
      end
    end

  end

  context "can parse integers" do
    Given(:int_handler) { Schemad::TypeHandler.new(:integer) }

    context "true to 1" do
      When(:result) { int_handler.parse(true) }
      Then { result.should eq(1) }
    end

    context "false to 0" do
      When(:result) { int_handler.parse(false) }
      Then { result.should eq(0) }
    end

    context "strings to numbers" do
      When(:result) { int_handler.parse("42") }
      Then { result.should == 42 }
    end

    context "odd strings to 0" do
      When(:result) { int_handler.parse("sneeze") }
      Then { result.should == 0 }
    end

    context "nil for unknown items" do
      When(:result) { int_handler.parse(String) }
      Then { result.should == nil }
    end
  end

  context "can parse dates" do
    Given(:date_handler) { Schemad::TypeHandler.new(:datetime) }
    Given(:time) { DateTime.now.to_time }

    context "knows unix time" do
      When(:result) { date_handler.parse(time.to_i) }
      Then { result.to_i.should == time.to_i }
    end

    context "knows iso8601 time" do
      When(:result) { date_handler.parse(time.iso8601) }
      Then { result.to_i.should == time.to_i }
    end

    context "knows ruby date format time" do
      When(:result) { date_handler.parse(time.to_s) }
      Then { result.to_i.should == time.to_i }
    end

    context "knows ruby date object" do
      Given(:date) { Date.today }
      When(:result) { date_handler.parse(date) }
      Then { result.should be_a(Time) }
      And { result.to_i.should == date.to_time.to_i }
    end

    context "knows ruby time objects" do
      Given(:time) { Time.now }
      When(:result) { date_handler.parse(time) }
      Then { result.should be_a(Time) }
      Then { result.to_i.should == time.to_i }
    end

    context "knows ruby time objects" do
      Given(:date_time) { DateTime.now }
      When(:result) { date_handler.parse(date_time) }
      Then { result.should be_a(Time) }
      Then { result.to_i.should == date_time.to_time.to_i }
    end
  end
end