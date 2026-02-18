Workflow d'Achat : Vue Fournisseur (suppliers#show)
Lorsqu'un utilisateur ajoute un produit depuis la page d'un fournisseur, le flux suivant est imposé :


Entrée Utilisateur : Sélection d'un produit existant, saisie du conditionnement (quantité + unité) et du prix total HT.


Persistance : Création d'un product_purchase lié au supplier_id.


Traitement via Dispatcher : Le controller doit appeler explicitement le Recalculations::Dispatcher.

Séquence de Calcul :


Conversion : PricePerKgCalculator transforme l'unité saisie en package_quantity_kg et calcule le price_per_kg.


Moyenne Multi-Fournisseurs : AvgPriceRecalculator calcule le nouveau avg_price_per_kg du produit en faisant la moyenne pondérée de tous les achats actifs, peu importe le fournisseur.


Cascade : Mise à jour des recettes directes, puis des recettes parentes (propagation 1 niveau).
