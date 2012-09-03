(function($) {
  
  var init = function(plot) {
    var click = function(event, position, item) {
      if (!item) return;
      $(plot.getOptions().drilldown.toggle[item.seriesIndex]).siblings().hide().end().show();
    };

    var hovered = null;
    var unhover = function(event) {
      if (!plot.getOptions().drilldown.highlight) return;
      var hc = plot.getOptions().drilldown.highlightClass;
      $(plot.getOptions().drilldown.highlight).find('tr').css('background-color', '').removeClass(hc).css('background-color', '');
      hovered = null;
    };

    var hover = function(event, position, item) {
      if (!item) return unhover();
      if (item.series.label == hovered || !plot.getOptions().drilldown.highlight) return;
      hovered = item.series.label;
      var hc = plot.getOptions().drilldown.highlightClass;
      $(plot.getOptions().drilldown.highlight).find('td').filter(function(i) {
        return $.trim($(this).text()) == $.trim(item.series.label);
      }).parent().addClass(hc).css('background-color', item.series.color).siblings().removeClass(hc).css('background-color', '');
    };

    plot.hooks.bindEvents.push(function(plot, eventHolder) {
      plot.getPlaceholder().bind('plotclick', click);
      plot.getPlaceholder().bind('plothover', hover);
      plot.getPlaceholder().bind('mouseout', unhover);
      if (plot.getOptions().drilldown.toggle.length > 0) {
        $(function() {
          $(plot.getOptions().drilldown.toggle[0]).siblings().hide();
        });
      }
    });

    plot.hooks.shutdown.push(function(plot, eventHolder) {
      plot.getPlaceholder().unbind('plotclick', click);
      plot.getPlaceholder().unbind('plothover', hover);
      plot.getPlaceholder().unbind('mouseout', unhover);
    });
  };
  
  $.plot.plugins.push({
    init: init,
    options: {
      drilldown: {
        toggle: [],
        highlight: null,
        highlightClass: 'active'
      }
    },
    name: 'drilldown',
    version: '1.0'
  });
})(jQuery);