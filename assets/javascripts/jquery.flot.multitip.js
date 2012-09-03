(function($) {
  
  var options = {
    multitip: {
      show: false,
      tipper: function(plot, highlighted) {
        var tip = '', series = plot.getData();
        $.each(highlighted, function(i, h) {
          var x = new Date(h[1][0]), y = h[1][1];
          tip += '<span style="color:' + series[h[0]].color + '">' + series[h[0]].label + '</span> for ' + x.toDateString() + ': ' + y + '<br>';
        });
        return tip;
      }
    }
  };
  
  function init(plot) {

    var previousPoint = null;

    function showTooltip(x, y, contents) {
      var css = {
          position: 'absolute',
          display: 'none',
          padding: '5px',
          zIndex: 10000
      };
      if (x > plot.offset().left + 300) {
        css.right = ($(window).width() - x + 15) + 'px';
      } else {
        css.left = (x + 15) + 'px';
      }
      if (y > plot.offset().top + 100) {
        css.bottom = ($(window).height() - y + 15) + 'px';
      } else {
        css.top = (y + 15) + 'px';
      }
      $('<div id="flot-tooltip" class="ui-widget ui-widget-content ui-corner-all">' + contents + '</div>').css(css).appendTo("body").fadeIn(300);
    }

    function onPlotHover(event, position, item) {
      if (!plot.getOptions().multitip.show) return;
      plot.unhighlight();
      if (!item) {
        $("#flot-tooltip").remove();
        previousPoint = null;
        return;
      }
      plot.highlight(item.seriesIndex, item.dataIndex);
      var highlighted = [];
      $.each(plot.getData(), function(i, serie) {
        if (serie.data[item.dataIndex]) {
          plot.highlight(i, item.dataIndex);
          highlighted.push([i, serie.data[item.dataIndex]]);
        }
      });
      if (previousPoint != item.dataIndex) {
        previousPoint = item.dataIndex;
        $("#flot-tooltip").remove();
        
        // TIPPER
        var tip = plot.getOptions().multitip.tipper(plot, highlighted);
          
        showTooltip(item.pageX, item.pageY, tip);
      }
    }
    
    function onMouseOut(event) {
      if (!plot.getOptions().multitip.show) return;
      plot.unhighlight();
    }
    
    plot.hooks.bindEvents.push(function(plot, eventHolder) {
      if (!plot.getOptions().multitip.show) return;
      plot.getPlaceholder().bind('plothover', onPlotHover);
      plot.getPlaceholder().bind('mouseout', onMouseOut);
    });

    plot.hooks.shutdown.push(function(plot, eventHolder) {
      plot.getPlaceholder().unbind('plothover', onPlotHover);
      plot.getPlaceholder().unbind('mouseout', onMouseOut);
    });
  }
  
  $.plot.plugins.push({
    init: init,
    options: options,
    name: 'multitip',
    version: '1.0'
  });
})(jQuery);