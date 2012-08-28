# encoding: utf-8

require 'redmine'
require 'chiliproject_flot'

Redmine::Plugin.register :chiliproject_flot do
  name 'Chiliproject Flot Plugin'
  author 'cj Advertising, LLC'
  description 'Javascript graphs for chiliproject plugins'
  version '0.0.1'
  url 'http://github.com/cjAdvertising/chiliproject_flot'
  author_url 'http://cjadvertising.com'

  ChiliprojectFlot::Patches::Plugin.patch
end
