require 'workarea/zipco'

module Workarea
  module Zipco
    class Engine < ::Rails::Engine
      include Workarea::Plugin
      isolate_namespace Workarea::Zipco
    end
  end
end
