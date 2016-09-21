class Tembin::Element::Visualizations < Tembin::Element::Base
  class Chart < Tembin::Element::Base
    class XAxis < Tembin::Element::Base
      field :scale, :string, only: ['Datetime', 'Linear', 'Logarithmic', 'Category']
      field :name, :string
      field :sort, :boolean
      field :labels, :boolean
      field :height, :numeric
    end

    class YAxis < Tembin::Element::Base
      class Value < Tembin::Element::Base
        field :scale, :string, only: ['Datetime', 'Linear', 'Logarithmic']
        field :name, :string
      end

      field :left, :element, class: Chart::YAxis::Value
      field :right, :element, class: Chart::YAxis::Value
    end

    field :type, :string, only: ['Line', 'Bar', 'Area', 'Pie', 'Scatter']
    field :x_column, :string
    field :y_columns, :array
    field :group_by, :string
    field :show_legend, :boolean
    field :stacking, :string
    field :x_axis, :element, class: Chart::XAxis
    field :y_axis, :element, class: Chart::YAxis
  end

  field :chart, :element, class: Chart
end
