# encoding: utf-8

require 'redmine'
require 'chiliproject_flot/patches/base'
require 'chiliproject_flot/patches/plugin'

# Public: Chiliproject Flot support module.
module ChiliprojectFlot

  @@registered = {:presets => {}, :compare_presets => {}}

  # Public: Register a Flot date range preset.
  #
  # section - Symbol or String section name (:presets or :compare_presets).
  # name    - Symbol or String preset name.
  # options - Hash options for the preset.
  # block   - Block date generator for preset.
  #
  # Returns nothing.
  def self.register(section, name, options={}, &block)
    @@registered[section.to_sym][name.to_sym] = {:options => options, :block => block}
  end

  # Public: Fetch all registered presets.
  #
  # Returns Hash registered presets.
  def self.registered
    @@registered
  end

  # Public: Various patches for Redmine/Chiliproject core.
  module Patches
  end
end