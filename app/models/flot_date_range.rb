require 'hashie'
require 'chiliproject_flot'

# Public: Date range data model for Flot graphs.
class FlotDateRange < Hashie::Mash
  unloadable

  # Public: Create a date range instance.
  #
  # You must specify either start_date and end_date OR a valid preset.
  #
  # attributes - Hash of attributes.
  #
  def initialize(attributes={}, default={}, &block)
    super(attributes)
    parse_dates
    symbolize_values
    preset_dates
  end

  # Public: Fetch all available presets based on granularity.
  #
  # Returns Array preset names as Symbols.
  def presets
    ChiliprojectFlot.registered[:presets].select do |n, p|
      g = [p[:options][:granularity]].flatten.compact
      !g.present? || g.include?(granularity)
    end.keys
  end

  # Public: Fetch all available compare_presets based on granularity.
  #
  # Returns Array compare_preset names as Symbols.
  def compare_presets
    ChiliprojectFlot.registered[:compare_presets].select do |n, p|
      g = [p[:options][:granularity]].flatten.compact
      !g.present? || g.include?(granularity)
    end.keys
  end

  private 

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