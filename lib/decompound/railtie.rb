# frozen_string_literal: true

module Decompound
  class Railtie < Rails::Railtie
    config.eager_load_namespaces << Decompound
  end
end
