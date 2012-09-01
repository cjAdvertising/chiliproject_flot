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
    render :partial => 'flot/granularity_select', :locals => {
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
    render :partial => 'flot/date_range_select', :locals => {
      :name => name,
      :range => range,
      :comparable => true,
      :date_format => (Setting.date_format.present? && Setting.date_format || '%b %e, %Y')
    }.merge(options)
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
    plugins = %w{ resize pie stack time crosshair time }.map { |p| "flot/jquery.flot.#{p}.js" }
    scripts = %w{ flot/jquery.flot.js } + plugins
    content_for :header_tags do
      scripts.map do |s| 
        javascript_include_tag s, :plugin => :chiliproject_flot
      end.join + stylesheet_link_tag('flot', :plugin => :chiliproject_flot)
    end
    @flot_included = true
  end

  # Internal: Encodes data values into numeric values Flot and then JSON.
  #
  # data - Array plot data points or data objects.
  #
  # Returns String encoded data Array as JSON.
  def flot_encode_data(data)
    return data.to_json unless data.is_a?(Array) && data.length > 0
    if data.first.is_a? Hash
      data.map { |d| d.merge :data => flot_encode_data_val(d[:data]) }.to_json
    elsif
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
