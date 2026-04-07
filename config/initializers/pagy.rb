# Pagy configuration
# https://ddnexus.github.io/pagy/docs/api/pagy/
require 'pagy/extras/bootstrap'
require 'pagy/extras/array'

Pagy::DEFAULT[:limit] = 20 # éléments par page (pagy v9+)
