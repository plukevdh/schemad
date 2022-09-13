require 'spec_helper'
require 'schemad/normalizer'

class Demalizer
  include Schemad::Normalizer

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
      Then { expect(normalized[:world]).to eq "COORDINATES" }
      And { expect(normalized[:roads]).to eq 50 }
    end

    context "does not pass through unspecified keys" do
      Then { expect(normalized[:cool]).to be_nil }
      And { expect(normalized[:beasts]).to be_nil }
    end
  end

  context "reverse normalization" do
    Given(:normalized) { normalizer.normalize(data) }
    Given(:expected) { { "Middle Earth" => "COORDINATES", "roads" => 50 } }

    context "for given keys" do
      When(:reversed) { normalizer.reverse(normalized) }
      Then { expect(reversed).to eq expected }
    end

    context "ignores extra keys" do
      When(:reversed) { normalizer.reverse(normalized.merge({ billy: "joel" })) }
      Then { expect(reversed).to eq expected }
    end

    context "includes included_fields" do
      Given { Demalizer.include_fields(:cool) }
      When(:reversed) { normalizer.reverse(data) }
      Then { expect(reversed).to include({"cool" => "true"}) }
    end
  end

  context "additional fields" do
    Given { normalizer.class.include_fields :beasts, :cool }
    When(:normalized) { normalizer.normalize(data) }

    context "can be specified" do
      Then { expect(normalized[:cool]).to eq "true" }
      And { expect(normalized[:beasts]).to eq "1337" }
    end

    context "converts all keys to symbols" do
      Then { expect(normalized[:cool]).not_to be_nil }
      And { expect(normalized[:beasts]).not_to be_nil }
      And { expect(normalized["Middle Earth"]).to be_nil }
    end
  end

  context "can mine nested properties" do
    class BucketNormalizer
      include Schemad::Normalizer

      normalize :answer_to_the_universe, key: "useless_root"
      normalize :username, key: "author/user/username"
      normalize :avatar_url, key: "author/user/links/avatar/href"
      normalize :email, key: "author/raw" do |value|
        value.match(/\A[\w|\s]+<(.+)>\z/).captures.first
      end
    end

    class BadNormalizer
      include Schemad::Normalizer
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
      Then { expect(results[:username]).to eq "jwalton" }
      And { expect(results[:avatar_url]).to eq "funk_blue.png" }
      And { expect(results[:email]).to eq "jwalton@atlassian.com" }
      And { expect(results[:answer_to_the_universe]).to eq 42 }
    end

    context "bad path throws exception" do
      Given(:normalizer) { BadNormalizer.new }
      When(:results) { normalizer.normalize(data) }
      Then { results == Failure(Schemad::Normalizer::InvalidPath, /author\/user\/avatar\/href/) }
    end

    context "can allow fields from nested data" do
      Given { BucketNormalizer.include_fields "author/user/display_name" }
      Given(:normalizer) { BucketNormalizer.new }
      When(:results) { normalizer.normalize(data) }
      Then { expect(results[:display_name]).to eq "Joseph Walton" }
    end

    context "can reverse into nested key" do
      Given(:normalizer) { BucketNormalizer.new }
      Given(:normalized) { normalizer.normalize(data) }
      When(:reversed) { normalizer.reverse(normalized) }
      Then { expect(reversed['author']['user']['username']).to eq "jwalton" }
      And  { expect(reversed['author']['user']['links']['avatar']['href']).to eq "funk_blue.png" }
    end
  end
end
