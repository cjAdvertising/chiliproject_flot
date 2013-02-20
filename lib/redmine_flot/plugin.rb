module RedmineFlot
  module Plugin
    extend ActiveSupport::Concern

    # Public: Instance methods to include in the patched class.
    module InstanceMethods

      # Public: Register a Flot date range preset.
      #
      # Examples:
      #
      #   # vendor/plugins/redmine_example/init.rb
      #   Redmine::Plugin.register :redmine_example do
      #     requires_redmine_plugin :redmine_flot, '0.0.1'
      #
      #     flot_date_range_preset :last_6_months, granularity: [:month, :week] do |dr|
      #       [Date.yesterday - 6.months, Date.yesterday]
      #     end
      #
      #     # ... other plugin initialization
      #   end
      #
      # name    - Symbol name for the preset.
      # options - Hash options for the preset (default: {}):
      #           :granularity - Array of granularities where this preset 
      #                          should be an available option.
      # block   - Block date generator for the preset.
      #
      # Returns nothing.
      def flot_date_range_preset(name, options={}, &block)
        RedmineFlot.register :presets, name, options, &block
      end

      # Public: Register a flot date range compare preset.
      #
      # name    - Symbol name for the preset.
      # options - Hash options for the preset (default: {}):
      #           :granularity - Array of granularities where this preset 
      #                          should be an available option.
      # block   - Block date generator for the preset.
      #
      # Returns nothing.
      def flot_date_range_compare_preset(name, options={}, &block)
        RedmineFlot.register :compare_presets, name, options, &block
      end
    end
  end
end