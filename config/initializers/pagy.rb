# Pagy configuration
# https://ddnexus.github.io/pagy/docs/api/pagy/
require 'pagy/extras/array'

Pagy::DEFAULT[:limit] = 20 # éléments par page (pagy v9+)

# Libellés de navigation en français (« Précédent », « Suivant »).
Pagy::I18n.load(locale: 'fr')
