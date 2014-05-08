require 'active_support/inflector'
require 'active_support/concern'
require 'active_support/core_ext/hash'
require 'active_support/hash_with_indifferent_access'

module Schemad
  module Extensions
    extend ActiveSupport::Concern

    module ClassMethods
      def base_class_name
        name.demodulize
      end
    end

    def base_class_name
      self.class.base_class_name
    end

    private
    # TODO: decide if I still want this method around. modifies repos
    # def add_behavior(repo, additions)
    #   repo.extend additions
    # end

    def constantize(string)
      string.to_s.constantize
    end

    def classify(string)
      string.to_s.classify
    end

    def indifferent_hash(hash)
      ActiveSupport::HashWithIndifferentAccess.new hash
    end
  end
end