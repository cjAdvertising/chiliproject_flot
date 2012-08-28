# encoding: utf-8

require 'redmine'
require 'chiliproject_flot/patches/base'
require 'chiliproject_flot/patches/plugin'

# Public: Chiliproject Flot support module.
module ChiliprojectFlot

  @@registered = {:presets => {}, :compare_presets => {}}

  # Public: Register an flot date range preset.
  #
  # provider - Symbol name of the OmniAuth strategy.
  # args     - Array provider arguments.
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