# encoding: utf-8

module ChiliprojectFlot
  module Patches

    # Public: Patch module to add flot support for plugins.
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

        # Public: Register a flot date range preset.
        #
        # name    - Symbol name for the preset.
        # options - Array of arguments to pass to the provider.
        # block   - The preset block.
        #
        # Returns nothing.
        def flot_date_range_preset(name, options={}, &block)
          ChiliprojectFlot.register :presets, name, options, &block
        end

        # Public: Register a flot date range compare preset.
        #
        # name    - Symbol name for the preset.
        # options - Array of arguments to pass to the provider.
        # block   - The preset block.
        #
        # Returns nothing.
        def flot_date_range_compare_preset(name, options={}, &block)
          ChiliprojectFlot.register :compare_presets, name, options, &block
        end
      end
    end
  end
end
