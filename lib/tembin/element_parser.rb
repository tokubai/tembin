require 'tembin/element'

class Tembin::ElementParser
  def self.parse(dsl_filepath)
    new(dsl_filepath).elements
  end

  def initialize(dsl)
    @elements = []
    instance_eval(dsl.read, dsl.to_path, 1)
  end

  def elements
    @elements
  end

  private

  def query(name, &block)
    @elements << Tembin::Element::Query.build(name, &block)
  end

  def dashboard(name, &block)
    @elements << Tembin::Element::Dashboard.build(name, &block)
  end

  def alert(name, &block)
    @elements << Tembin::Element::Alert.build(name, &block)
  end
end
