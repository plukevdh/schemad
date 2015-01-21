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

  context "normalization" do
    When(:normalized) { normalizer.normalize(data) }

    context "maps specified keys" do
      Then { normalized[:world].should == "COORDINATES" }
      And { normalized[:roads].should == 50 }
    end

    context "does not pass through unspecified keys" do
      Then { normalized[:cool].should be_nil }
      And { normalized[:beasts].should be_nil }
    end
  end

  context "additional fields" do
    Given { normalizer.class.include_fields :beasts, :cool }
    When(:normalized) { normalizer.normalize(data) }

    context "can be specified" do
      Then { normalized[:cool].should == "true" }
      And { normalized[:beasts].should == "1337" }
    end

    context "converts all keys to symbols" do
      Then { normalized[:cool].should_not be_nil }
      And { normalized[:beasts].should_not be_nil }
      And { normalized["Middle Earth"].should be_nil }
    end
  end

  context "can mine nested properties" do
    class BucketNormalizer < Schemad::Normalizer
      normalize :answer_to_the_universe, key: "useless_root"
      normalize :username, key: "author/user/username"
      normalize :avatar_url, key: "author/user/links/avatar/href"
      normalize :email, key: "author/raw" do |value|
        value.match(/\A[\w|\s]+<(.+)>\z/).captures.first
      end
    end

    class BadNormalizer < Schemad::Normalizer
      # missing the "links" part of the path
      normalize :avatar_url, key: "author/user/avatar/href"
    end

    Given(:data) {
    { useless_root: 42,
      author: {
        raw: "Joseph Walton <jwalton@atlassian.com>",
        user: {
          username: "jwalton",
          display_name: "Joseph Walton",
          links: {
            self: {
              href: "https://api.bitbucket.org/2.0/users/jwalton"
            },
            avatar: {
              href: "funk_blue.png"
            }
          }
          }
      }
    } }

    context "parses paths" do
      Given(:normalizer) { BucketNormalizer.new }
      When(:results) { normalizer.normalize(data) }
      Then { results[:username].should == "jwalton" }
      And { results[:avatar_url].should == "funk_blue.png" }
      And { results[:email].should == "jwalton@atlassian.com" }
      And { results[:answer_to_the_universe].should == 42 }
    end

    context "bad path throws exception" do
      Given(:normalizer) { BadNormalizer.new }
      When(:results) { normalizer.normalize(data) }
      Then { expect(results).to have_failed(Schemad::Normalizer::InvalidPath, /author\/user\/avatar\/href/) }
    end

    context "can allow fields from nested data" do
      Given { BucketNormalizer.include_fields "author/user/display_name" }
      Given(:normalizer) { BucketNormalizer.new }
      When(:results) { normalizer.normalize(data) }
      Then { results[:display_name].should == "Joseph Walton" }
    end

  end
end
