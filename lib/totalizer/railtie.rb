require 'totalizer'
require 'rails'

module Totalizer
  class Railtie < Rails::Railtie
    railtie_name :totalizer

    rake_tasks do
      load "tasks/totalizer.rake"
    end
  end
end
