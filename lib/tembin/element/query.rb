require 'tembin/element/visualizations'

class Tembin::Element::Query < Tembin::Element::Base
  field :data_source, :string
  field :schedule, :time
  field :sql, :string
  field :visualizations, :element, class: Tembin::Element::Visualizations
end
