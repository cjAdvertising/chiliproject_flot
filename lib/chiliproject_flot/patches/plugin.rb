# encoding: utf-8

module ChiliprojectFlot
  module Patches

    # Public: Patch module to add Flot support for plugins.
    module Plugin
      extend Base

      # Public: Fetch the target class to patch.
      #
      # Returns Class target class.
      def self.target
        Redmine::Plugin
      end

      # Public: Instance methods to include in the patched class.
      module InstanceMethods

        # Public: Register a Flot date range preset.
        #
        # Examples:
        #
        #   # vendor/plugins/chiliproject_example/init.rb
        #   Redmine::Plugin.register :chiliproject_example do
        #     requires_redmine_plugin :chiliproject_flot, '0.0.1'
        #
        #     flot_date_range_preset :last_6_months, :granularity => [:month, :week] do |dr|
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
          ChiliprojectFlot.register :presets, name, options, &block
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
          ChiliprojectFlot.register :compare_presets, name, options, &block
        end
      end
    end
  end
end
