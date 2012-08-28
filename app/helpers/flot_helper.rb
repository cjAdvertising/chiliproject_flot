module FlotHelper

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

  def flot_encode_val(val)
    case val
      when Fixnum then val
      when String then val.to_f
      when Array  then val.map { |v| flot_encode_val(v) }
      when Time   then val.to_i * 1000
      when Date   then val.to_time.to_i * 1000
      else raise ArgumentError, "Unhandled type #{val.class}"
    end
  end

  # data - Array of Hashes with the :data key containing the data set Array.
  def flot_encode(data)
    data.each { |d| d[:data] = flot_encode_val d[:data] }
  end

  def flot_func_encode(funcs)
    parts = []
    funcs.each do |k, v|
      val = v.is_a?(String) ? v : flot_func_encode(v)
      parts << "'#{k}': #{val}"
    end
    "{#{parts.join ', '}}"
  end
  
  def flot_for(container_id, data, options={}, func_options={})
    include_flot_header_tags
    js = "var flot_options_#{container_id} = #{options.to_json};"
    if func_options.present?
      js += "jQuery.extend(true, flot_options_#{container_id}, #{flot_func_encode(func_options)});"
    end
    js += "jQuery.plot(jQuery('##{container_id}'), #{flot_encode(data).to_json}, flot_options_#{container_id})"
    javascript_tag(js)
  end

  def flot_granularity_select_for(name, range=nil, options={})
    render :partial => 'flot/granularity_select', :locals => {
      :name => name,
      :range => range,
      :granularities => [:month, :week, :day, :hour]
    }.merge(options)
  end

  # Options:
  # :granularities => [:month, :week, :day, :hour]
  # :presets => [:last_week, :last_month]
  # :comparable => true
  # :comparable_presets => [:last_year, :time_previous]
  def flot_date_range_for(name, range=nil, options={})
    render :partial => 'flot/date_range_select', :locals => {
      :name => name,
      :range => range,
      :granularities => [:month, :week, :day, :hour],
      :presets => range.presets,
      :comparable => true,
      :compare_presets => range.compare_presets
    }.merge(options)
  end

  def flot_calendar_for(field_id, options={})
    options = options.merge :dateFormat => 'yy-mm-dd'
    javascript_tag("jQuery('##{field_id}').datepicker(#{options.to_json})")
  end
end
