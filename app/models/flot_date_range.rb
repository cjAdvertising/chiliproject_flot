require 'hashie'
require 'chiliproject_flot'

# Public: Date range data model for Flot graphs.
#
# Parses String values into Date objects where appropriate, turns all other 
# String values into Symbols (except compare) and then resets the dates to
# those determined by a preset if one is given.
class FlotDateRange < Hashie::Mash
  unloadable

  # Public: Create a date range instance.
  #
  # You must specify either :start_date and :end_date OR a valid :preset.
  #
  # attrs - Hash of attributes (default: {}):
  #         :start_date         - Date or String beginning date.
  #         :end_date           - Date or String ending date.
  #         :compare_start_date - Date or String beginning date (optional).
  #         :compare_end_date   - Date or String ending date (optional).
  #         :granularity        - Symbol or String granularity.
  #         :compare            - String '0' or '1' whether to compare dates.
  #         :preset             - String or Symbol preset name to use.
  #         :compare_preset     - String or Symbol compare preset name to use.
  #
  def initialize(attrs={}, default={}, &block)
    super(attrs)
    parse_dates
    symbolize_values
    preset_dates
  end

  # Public: Fetch all available presets based on granularity.
  #
  # Returns Array preset names as Symbols.
  def presets
    presets_by_key :presets
  end

  # Public: Fetch all available compare_presets based on granularity.
  #
  # Returns Array compare_preset names as Symbols.
  def compare_presets
    presets_by_key :compare_presets
  end

  private 

  # Internal: Fetch presets by key for the current granularity.
  #
  # preset_key - Symbol preset name (:presets or :compare_presets).
  #
  # Returns Array preset names as Symbols.
  def presets_by_key(preset_key)
    ChiliprojectFlot.registered[preset_key].select do |n, p|
      g = [p[:options][:granularity]].flatten.compact
      !g.present? || g.include?(granularity)
    end.keys
  end

  # Internal: Change all String attribute values into Symbols.
  #
  # Returns nothing.
  def symbolize_values
    ignore = [:compare]
    each { |k, v| self[k] = v.to_sym if v.is_a?(String) && !ignore.include?(k.to_sym) }
  end

  # Internal: Turn all date attributes into Date objects.
  #
  # Returns nothing.
  def parse_dates
    dates = %w{start_date end_date compare_start_date compare_end_date}
    dates.each { |d| self[d] = Date.parse self[d].to_s if self[d].is_a?(String) }
  end

  # Internal: Sets start and end dates from presets if given.
  #
  # Returns nothing.
  # Raises RuntimeError if preset is invalid.
  def preset_dates
    ['', 'compare_'].each do |prefix|

      p = "#{prefix}preset"
      ps = "#{p}s".to_sym

      if self.send(ps).include? self[p]
        # Call preset block and update dates from result.
        dates = ChiliprojectFlot.registered[ps][self[p]][:block].call self
        self["#{prefix}start_date"], self["#{prefix}end_date"] = dates
      else
        # Ensure start and end dates are set.
        unless self["#{prefix}start_date"].is_a?(Date) && self["#{prefix}end_date"].is_a?(Date)
          raise "Invalid #{p}: #{self[p]}"
        end

        # Change prefix to :custom.
        self[p] = :custom
      end
    end
  end
end