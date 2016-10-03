require "globalid"

class Bg::BackgroundableObject
  include ::GlobalID::Identification

  def self.find(id)
    new id
  end

  attr_accessor :id

  def initialize(id)
    @id = id
  end

  def update(attrs={})
    true
  end

  def wait(seconds=0)
    sleep seconds.to_i
    true
  end

  def eigen
    class << self
      self
    end
  end
end
