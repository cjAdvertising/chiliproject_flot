require "active_support/concern"
require "redmine"
require "redmine_flot/plugin"

# Public: Redmine Flot support module.
module RedmineFlot

  @@registered = {presets: {}, compare_presets: {}}

  # Public: Register a Flot date range preset.
  #
  # section - Symbol or String section name (:presets or :compare_presets).
  # name    - Symbol or String preset name.
  # options - Hash options for the preset.
  # block   - Block date generator for preset.
  #
  # Returns nothing.
  def self.register(section, name, options={}, &block)
    @@registered[section.to_sym][name.to_sym] = {options: options, block: block}
  end

  # Public: Fetch all registered presets.
  #
  # Returns Hash registered presets.
  def self.registered
    @@registered
  end

  Redmine::Plugin.send :include, Plugin
end