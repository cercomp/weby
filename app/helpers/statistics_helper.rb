module StatisticsHelper
  def metrics_select_tag
    select_tag :metric, options_for_select([[t('.views'), 'views'], [t('.visitors'), 'visitors']]), class: 'form-control' # , [t('.uniq_visitors'), 'uniq_visitors']])
  end

  def statistics_style
    content_tag :style do
      <<STYLE
      .stats {
      font: 13px sans-serif;
    }

    .axis path,
    .axis line {
      fill: none;
      stroke: #000;
      shape-rendering: crispEdges;
    }

    .bar {
      fill: steelblue;
    }

    .line {
      fill: none;
      stroke: steelblue;
      stroke-width: 1.5px;
    }

    .stats-label{
      font-size: 15px;
      border: 1px solid #DDD;
    }
STYLE
    end
  end
end
