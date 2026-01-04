# frozen_string_literal: true

require 'pagy'
require 'pagy/extras/overflow'
require 'pagy/extras/array'

# Pagy Configuration
# See https://ddnexus.github.io/pagy/docs/api/pagy

# Instance variables
# See https://ddnexus.github.io/pagy/docs/api/pagy#instance-variables

Pagy::DEFAULT[:items] = 20        # Items per page
Pagy::DEFAULT[:size]  = [1, 4, 4, 1] # Nav bar links

# Extras
# See https://ddnexus.github.io/pagy/categories/extra

Pagy::DEFAULT[:overflow] = :last_page
