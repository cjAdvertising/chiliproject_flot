# Public: Helper functions for Flot graphs.
module FlotHelper
  unloadable

  # Public: Render a Flot plot in a container.
  #
  # Examples:
  #
  #   # <div id="flot" style="height: 200px"></div>
  #   flot_for 'flot', [[0, 8], [1, 3], [2, 5]], :yaxis => {:max: 10}
  #
  #   flot_for 'flot', [{:data => [0, 8]}, {:data => [4, 2]}]
  #
  # container_id - String plot container ID.
  # data         - Array plot data points or data objects.
  # options      - Hash Flot options (default: {}).
  #
  # Returns nothing.
  def flot_for(container_id, data, options={})
    include_flot_header_tags
    javascript_tag("jQuery.plot(jQuery('##{container_id}'), #{flot_encode_data(data)}, #{flot_encode_options(options)});")
  end

  # Public: Display a granularity select control. 
  #
  # name    - String or Symbol name to use for form fields.
  # range   - FlotDateRange object to which the fields will be bound.
  # options - Hash optional options for the control (default: {}):
  #           :granularities - Array of granularities allowed for selection.
  #
  # Returns nothing.
  def flot_granularity_select_for(name, range=nil, options={})
    include_flot_header_tags
    render 'flot/granularity_select', {
      :name => name,
      :range => range,
      :granularities => [:month, :week, :day, :hour]
    }.merge(options)
  end

  # Public: Display a date range select control.
  #
  # name    - String or Symbol name to use for form fields.
  # range   - FlotDateRange object to which the fields will be bound.
  # options - Hash optional options for the control (default: {}):
  #           :comparable  - Boolean allow date comparison (default: true).
  #           :date_format - String date format for displayng dates (default: 
  #                          Setting.date_format or '%b %e, %Y' if not given).
  #
  # Returns nothing.
  def flot_date_range_for(name, range=nil, options={})
    include_flot_header_tags
    render 'flot/date_range_select', {
      :name => name,
      :range => range,
      :comparable => true,
      :date_format => (Setting.date_format.present? && Setting.date_format || '%b %e, %Y')
    }.merge(options)
  end

  def flot_timeline_for(name, range=nil, options={})
    include_flot_header_tags

    default_flot_options = {
      :xaxis => {:mode => 'time', :timezone => 'browser'}, 
      :series => {:lines => {:show => true}, :points => {:show => true}},
      :grid => {:hoverable => true, :autoHighlight => false},
      :crosshair => {:mode => 'x', :color => 'rgba(66, 66, 66, 0.20)'},
      :multitip => {
        :show => true,
        :tipper => %@function(plot, highlighted) {
          var $ = jQuery, tips = [], series = plot.getData(), 
            granularity = $('input:radio[name="#{name}[granularity]"]:checked, input:hidden[name="#{name}[granularity]"]').val(), 
            last = null;
          $.each(highlighted, function(i, h) {
            var d = new Date(h[1][0]), y = h[1][1], tip = '', df;
            switch(granularity) {
              case 'hour': df = 'ddd, MMM d, yyyy, H:mm - ' + d.clone().addHours(1).toString('H:mm'); break;
              case 'day': df = 'ddd, MMM d, yyyy'; break;
              case 'week': df = 'MMM d, yyyy'; break; // + d.clone().addDays(6).toString('MMM d, yyyy'); break;
              case 'month': df = 'MMM yyyy'; break;
            }
            ds = d.toString(df);
            if (last != ds) {
              if (last != null) tip += '<hr>';
              last = ds;
              tip += '<strong>' + ds + '</strong><br>';
            }
            tip += '<span style="color:' + series[h[0]].color + '">' + series[h[0]].label + '</span>: ' + 
              series[h[0]].yaxis.options.tickFormatter(y, series[h[0]].yaxis) + '<br>';
            tips.push(tip);
          });
          return tips.join('');
        }@.to_sym
      },
      :yaxis => {
        :tickFormatter => %@function(val, axis) {
          switch(axis.options.numberFormat) {
            case 'percent': return val.toFixed(2) + "%";
            case 'time':
              var d = Number(val), h = Math.floor(d / 3600), m = Math.floor(d % 3600 / 60), s = Math.floor(d % 3600 % 60);
              return ((h > 0 ? h + ":" : "") + (m > 0 ? (h > 0 && m < 10 ? "0" : "") + m + ":" : "0:") + (s < 10 ? "0" : "") + s);
          }
          return val;
        }@.to_sym
      }
    }

    flot_options = default_flot_options.merge(options[:flot_options] || {})

    render 'flot/timeline', {
      :name => name,
      :range => range,
      :flot_options => flot_options
    }.merge(options.reject { |k, v| k == :flot_options})
  end

  # Public: Display a calendar date select control. Identical to calendar_for
  # in the latest Chiliproject with a dateFormat supported by Date.parse.
  #
  # field_id - String or Symbol id of the text field to receive the date.
  # options  - Hash optional options for the calendar (default: {}):
  #            :dateFormat - String date format for text field (default: 
  #                          'yy-mm-dd').
  #
  # Returns nothing.
  def flot_calendar_for(field_id, options={})
    options = {:dateFormat => 'yy-mm-dd'}.merge options
    javascript_tag("jQuery('##{field_id}').datepicker(#{options.to_json})")
  end

  private

  # Internal: Includes header tags required by Flot once.
  #
  # Returns nothing.
  def include_flot_header_tags
    return if @flot_included
    plugins = %w{ resize pie stack time crosshair }.map { |p| "flot/jquery.flot.#{p}.js" }
    scripts = %w{ flot/jquery.flot.js jquery.flot.multitip.js jquery.flot.drilldown.js jquery.ui.selectmenu.js jquery.peek.js date.js} + plugins

    content_for :header_tags do
      scripts.map do |s| 
        javascript_include_tag s, :plugin => :chiliproject_flot
      end.join + 
      stylesheet_link_tag('flot', :plugin => :chiliproject_flot) +
      stylesheet_link_tag('jquery.ui.selectmenu.css', :plugin => :chiliproject_flot) +
      '<!--[if lte IE 8]>' + javascript_include_tag('flot/excanvas.min.js', :plugin => :chiliproject_flot) + '<![endif]-->'
    end
    @flot_included = true
  end

  # Internal: Encodes data values into numeric values Flot and then JSON.
  #
  # data - Array plot data points or data objects.
  #
  # Returns String encoded data Array as JSON.
  def flot_encode_data(data)
    Rails.logger.info "DATA: #{data.inspect}"
    return data.to_json unless data.is_a?(Array) && data.length > 0
    if data.first.is_a? Hash
      data.map { |d| d.merge :data => flot_encode_data_val(d[:data] || d['data']) }.to_json
    else
      data.map { |d| flot_encode_data_val(d) }.to_json
    end
  end

  # Internal: Encodes data value into numeric value Flot can understand.
  #
  # val - Mixed value to encode.
  #
  # Returns Mixed value encoded for flot.
  def flot_encode_data_val(val)
    case val
      when Fixnum then val
      when Bignum then val
      when Integer then val
      when Float then val
      when String then val.to_f
      when Array  then val.map { |v| flot_encode_data_val(v) }
      when Time   then val.to_i * 1000
      when Date   then val.to_time.to_i * 1000
      else raise ArgumentError, "Unhandled type #{val.class}"
    end
  end

  # Internal: Encodes Flot options Hash into JSON including Symbols as raw JS.
  #
  # options - Hash options to encode.
  #
  # Returns String JS encoded Hash.
  def flot_encode_options(options)
    options = options.dup
    syms = flot_extract_symbols(options)
    "jQuery.extend(true, #{options.to_json}, #{flot_encode_symbol_options(syms)})"
  end

  # Internal: Extracts all Symbol values recursively from a Hash destructively.
  #
  # options - Hash options to extract.
  #
  # Returns Hash of Symbols removed from options Hash.
  def flot_extract_symbols(options)
    syms = {}
    new_opts = options.select do |k, v|
      if v.is_a?(Symbol)
        syms[k] = v
        false
      else
        syms.merge!({k => flot_extract_symbols(v)}) if v.is_a? Hash
        true
      end
    end
    options.replace new_opts
    syms
  end

  # Internal: Encode Symbol options into JSON with unquoted values.
  #
  # options - Hash options to encode.
  #
  # Returns String options as JSON.
  def flot_encode_symbol_options(options)
    parts = []
    options.each do |k, v|
      val = v.is_a?(Symbol) ? v.to_s : flot_encode_symbol_options(v)
      parts << %@"#{k}":#{val}@
    end
    "{#{parts.join ','}}"
  end
end
