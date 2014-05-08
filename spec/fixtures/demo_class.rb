class Ent < Schemad::Entity
  attribute :forest, type: :string, default: "Green"
  attribute :roads, type: :integer
  attribute :beasts, type: :integer
  attribute :world
  attribute :cool, type: :boolean
  attribute :created, type: :date_time, default: -> { Time.now }
end