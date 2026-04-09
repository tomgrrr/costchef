# encoding: utf-8
# ============================================================
# AUDIT HTML — Rapport complet Bureau light theme
# Usage: rails runner lib/scripts/audit_html.rb > /tmp/audit.html
# ============================================================

user = User.find_by!("email ILIKE ?", "dp.lassalas@outlook.fr")

# ── Collecte des données ─────────────────────────────────────

all_products = user.products.includes(:product_purchases, :recipe_components).order(:name).to_a
all_recipes  = user.recipes.includes(:recipe_components).order(:name).to_a
subrecipes   = all_recipes.select(&:sellable_as_component?)
main_recipes = all_recipes.reject(&:sellable_as_component?)

# 1. Recettes sans composants
empty_recipes = all_recipes.select { |r| r.recipe_components.empty? }

# 2. Produits sans conditionnement (aucun product_purchase)
zero_products = all_products.select { |p| p.product_purchases.empty? }

# 3. Produits avec conditionnements mais prix = 0
free_products = all_products.select { |p| p.product_purchases.any? && p.product_purchases.all? { |pp| pp.price_per_kg.to_f == 0 } }

# 4. Sous-recettes avec coût nul utilisées dans d'autres recettes
zero_cost_sr = subrecipes.select do |sr|
  sr.cached_cost_per_kg.to_f == 0 &&
    RecipeComponent.where(component_type: "Recipe", component_id: sr.id).exists?
end

# 5. Recettes finales coût nul
zero_cost_r = main_recipes.select { |r| r.cached_cost_per_kg.to_f == 0 }

# 6. Produits suspects doublon
product_suspects = []
all_products.each_with_index do |p1, i|
  all_products[(i+1)..].each do |p2|
    n1 = p1.name.downcase.gsub(/[^a-z0-9]/, '')
    n2 = p2.name.downcase.gsub(/[^a-z0-9]/, '')
    next if n1.length < 5 || n2.length < 5
    shorter, longer = [n1, n2].sort_by(&:length)
    if longer.include?(shorter) && shorter.length >= 5
      product_suspects << [p1, p2]
    end
  end
end

# 7. Recettes suspects doublon
recipe_suspects = []
all_recipes.each_with_index do |r1, i|
  all_recipes[(i+1)..].each do |r2|
    n1 = r1.name.downcase.gsub(/[^a-z0-9]/, '')
    n2 = r2.name.downcase.gsub(/[^a-z0-9]/, '')
    next if n1.length < 6 || n2.length < 6
    shorter, longer = [n1, n2].sort_by(&:length)
    if longer.include?(shorter) && shorter.length >= 6
      recipe_suspects << [r1, r2]
    end
  end
end

# 8. Composants à quantité nulle
zero_qty_comps = RecipeComponent
  .joins("INNER JOIN recipes ON recipes.id = recipe_components.recipe_id")
  .where(recipes: { user_id: user.id })
  .where("recipe_components.quantity_kg = 0 OR recipe_components.quantity_kg IS NULL")
  .includes(:recipe)

# 9. Catch-all products (prix très variable)
catch_alls = []
all_products.each do |p|
  condits = p.product_purchases.to_a
  next if condits.size < 3
  prix = condits.map { |c| c.price_per_kg.to_f }.select { |v| v > 0 }
  next if prix.size < 3
  ratio = prix.max / prix.min
  next if ratio < 5
  catch_alls << { product: p, min: prix.min, max: prix.max, ratio: ratio }
end

# 10. Sous-recettes non utilisées
unused_sr = subrecipes.select do |sr|
  !RecipeComponent.where(component_type: "Recipe", component_id: sr.id).exists?
end

# 11. Produits utilisés dans aucune recette
unused_products = all_products.select { |p| p.recipe_components.empty? }

# ── Points manuels connus ─────────────────────────────────────
manual_tasks = [
  { priority: "HIGH",   text: "Pâte brisée : placeholder (1ml eau) — compléter les vrais ingrédients" },
  { priority: "HIGH",   text: "Crème anglaise : Vanille non ajoutée (pas de quantité sur la fiche photo)" },
  { priority: "HIGH",   text: "Pricer les produits créés à 0€ dans l'onglet Produits" },
  { priority: "MEDIUM", text: "Feuilleté jambon : quantité jambon estimée à 100g — à vérifier" },
  { priority: "MEDIUM", text: "Quiche légumes : quantités julienne/gruyère estimées proportionnellement" },
  { priority: "MEDIUM", text: "Quiche thon tomate : quantités estimées proportionnellement (batch de 160)" },
  { priority: "MEDIUM", text: "Croissants : oeufs indiqués en kg sur la fiche (pas en pièces)" },
  { priority: "LOW",    text: "Sauce lapin : ingrédients importés mais vérifier usage (recette rare)" },
  { priority: "LOW",    text: "Crème : même produit utilisé pour crème liquide ET crème épaisse — quantités cumulées" },
]

# ── Génération HTML ───────────────────────────────────────────

def badge(count, ok_zero: true)
  color = (count == 0 && ok_zero) ? "#16a34a" : (count > 0 ? "#dc2626" : "#16a34a")
  "<span style='background:#{color};color:#fff;padding:2px 8px;border-radius:10px;font-size:12px;font-weight:600'>#{count}</span>"
end

def priority_badge(p)
  colors = { "HIGH" => "#dc2626", "MEDIUM" => "#f59e0b", "LOW" => "#6b7280" }
  "<span style='background:#{colors[p] || '#6b7280'};color:#fff;padding:1px 7px;border-radius:8px;font-size:11px;font-weight:600'>#{p}</span>"
end

html = <<~HTML
<!DOCTYPE html>
<html lang="fr">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Audit CostChef — Lassalas — #{Date.today.strftime('%d/%m/%Y')}</title>
  <style>
    *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
      background: #f8fafc;
      color: #1e293b;
      font-size: 14px;
      line-height: 1.5;
    }
    header {
      background: #fff;
      border-bottom: 1px solid #e2e8f0;
      padding: 20px 40px;
      display: flex;
      align-items: center;
      justify-content: space-between;
    }
    header h1 { font-size: 20px; font-weight: 700; color: #0f172a; }
    header small { color: #64748b; font-size: 12px; }
    .container { max-width: 1100px; margin: 0 auto; padding: 32px 24px; }

    .summary-grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(160px, 1fr));
      gap: 16px;
      margin-bottom: 32px;
    }
    .stat-card {
      background: #fff;
      border: 1px solid #e2e8f0;
      border-radius: 10px;
      padding: 16px 20px;
      text-align: center;
    }
    .stat-card .num { font-size: 28px; font-weight: 700; }
    .stat-card .lbl { font-size: 12px; color: #64748b; margin-top: 4px; }
    .stat-card.warn .num { color: #dc2626; }
    .stat-card.ok   .num { color: #16a34a; }
    .stat-card.info .num { color: #2563eb; }

    .section {
      background: #fff;
      border: 1px solid #e2e8f0;
      border-radius: 10px;
      margin-bottom: 24px;
      overflow: hidden;
    }
    .section-header {
      padding: 14px 20px;
      background: #f1f5f9;
      border-bottom: 1px solid #e2e8f0;
      display: flex;
      align-items: center;
      gap: 10px;
      font-weight: 600;
      font-size: 14px;
    }
    .section-header .icon { font-size: 16px; }
    .section-body { padding: 0; }

    table { width: 100%; border-collapse: collapse; font-size: 13px; }
    th {
      background: #f8fafc;
      color: #64748b;
      font-weight: 600;
      text-align: left;
      padding: 8px 16px;
      border-bottom: 1px solid #e2e8f0;
      font-size: 11px;
      text-transform: uppercase;
      letter-spacing: 0.04em;
    }
    td { padding: 9px 16px; border-bottom: 1px solid #f1f5f9; vertical-align: middle; }
    tr:last-child td { border-bottom: none; }
    tr:hover td { background: #f8fafc; }

    .tag {
      display: inline-block;
      padding: 1px 7px;
      border-radius: 8px;
      font-size: 11px;
      font-weight: 600;
    }
    .tag-sr  { background: #dbeafe; color: #1d4ed8; }
    .tag-r   { background: #dcfce7; color: #15803d; }
    .tag-warn{ background: #fef3c7; color: #92400e; }
    .tag-err { background: #fee2e2; color: #991b1b; }
    .tag-ok  { background: #dcfce7; color: #15803d; }

    .empty-state { padding: 20px; color: #16a34a; font-weight: 500; }
    .empty-state::before { content: '✅ '; }

    .manual-task {
      display: flex;
      align-items: flex-start;
      gap: 10px;
      padding: 10px 16px;
      border-bottom: 1px solid #f1f5f9;
    }
    .manual-task:last-child { border-bottom: none; }

    code { background: #f1f5f9; padding: 1px 5px; border-radius: 4px; font-family: monospace; font-size: 12px; }
    .id-badge { color: #94a3b8; font-size: 11px; }
  </style>
</head>
<body>
<header>
  <div>
    <h1>🔍 Audit CostChef — Dimitry Lassalas</h1>
    <small>Généré le #{Time.now.strftime('%d/%m/%Y à %H:%M')}</small>
  </div>
</header>
<div class="container">

  <!-- Summary -->
  <div class="summary-grid">
    <div class="stat-card info">
      <div class="num">#{all_recipes.size}</div>
      <div class="lbl">Recettes totales</div>
    </div>
    <div class="stat-card info">
      <div class="num">#{subrecipes.size}</div>
      <div class="lbl">Sous-recettes</div>
    </div>
    <div class="stat-card info">
      <div class="num">#{all_products.size}</div>
      <div class="lbl">Produits</div>
    </div>
    <div class="stat-card #{empty_recipes.size > 0 ? 'warn' : 'ok'}">
      <div class="num">#{empty_recipes.size}</div>
      <div class="lbl">Recettes vides</div>
    </div>
    <div class="stat-card #{zero_products.size > 0 ? 'warn' : 'ok'}">
      <div class="num">#{zero_products.size}</div>
      <div class="lbl">Produits sans prix</div>
    </div>
    <div class="stat-card #{zero_cost_r.size > 0 ? 'warn' : 'ok'}">
      <div class="num">#{zero_cost_r.size}</div>
      <div class="lbl">Recettes coût 0</div>
    </div>
  </div>

  <!-- 1. À faire manuellement -->
  <div class="section">
    <div class="section-header">
      <span class="icon">📋</span>
      Actions manuelles requises
      <span style="margin-left:auto">#{badge(manual_tasks.count { |t| t[:priority] == 'HIGH' }, ok_zero: true)} HIGH &nbsp; #{badge(manual_tasks.count { |t| t[:priority] == 'MEDIUM' }, ok_zero: true)} MEDIUM</span>
    </div>
    <div class="section-body">
      #{manual_tasks.map { |t|
        "<div class='manual-task'>#{priority_badge(t[:priority])} <span>#{t[:text]}</span></div>"
      }.join}
    </div>
  </div>

  <!-- 2. Recettes sans composants -->
  <div class="section">
    <div class="section-header">
      <span class="icon">⚠️</span>
      Recettes sans ingrédients
      <span style="margin-left:auto">#{badge(empty_recipes.size)}</span>
    </div>
    <div class="section-body">
      #{if empty_recipes.empty?
        "<div class='empty-state'>Aucune recette vide</div>"
      else
        "<table><thead><tr><th>ID</th><th>Nom</th><th>Type</th></tr></thead><tbody>" +
        empty_recipes.map { |r|
          type = r.sellable_as_component? ? "<span class='tag tag-sr'>Sous-recette</span>" : "<span class='tag tag-r'>Recette</span>"
          "<tr><td class='id-badge'>#{r.id}</td><td>#{r.name}</td><td>#{type}</td></tr>"
        }.join + "</tbody></table>"
      end}
    </div>
  </div>

  <!-- 3. Produits sans conditionnement -->
  <div class="section">
    <div class="section-header">
      <span class="icon">💸</span>
      Produits sans conditionnement (prix inconnu)
      <span style="margin-left:auto">#{badge(zero_products.size)}</span>
    </div>
    <div class="section-body">
      #{if zero_products.empty?
        "<div class='empty-state'>Tous les produits ont un prix</div>"
      else
        "<table><thead><tr><th>ID</th><th>Nom</th><th>Unité</th><th>Utilisé dans</th></tr></thead><tbody>" +
        zero_products.map { |p|
          rc = p.recipe_components.count
          used = rc > 0 ? "<span class='tag tag-warn'>#{rc} recette(s)</span>" : "<span class='tag' style='background:#f1f5f9;color:#64748b'>inutilisé</span>"
          "<tr><td class='id-badge'>#{p.id}</td><td>#{p.name}</td><td><code>#{p.base_unit}</code></td><td>#{used}</td></tr>"
        }.join + "</tbody></table>"
      end}
    </div>
  </div>

  <!-- 4. Sous-recettes coût nul utilisées -->
  <div class="section">
    <div class="section-header">
      <span class="icon">🔗</span>
      Sous-recettes avec coût nul (utilisées dans d'autres recettes)
      <span style="margin-left:auto">#{badge(zero_cost_sr.size)}</span>
    </div>
    <div class="section-body">
      #{if zero_cost_sr.empty?
        "<div class='empty-state'>Aucune</div>"
      else
        "<table><thead><tr><th>ID</th><th>Sous-recette</th><th>Utilisée dans</th></tr></thead><tbody>" +
        zero_cost_sr.map { |sr|
          used_in = RecipeComponent.where(component_type: "Recipe", component_id: sr.id).count
          "<tr><td class='id-badge'>#{sr.id}</td><td>#{sr.name}</td><td><span class='tag tag-warn'>#{used_in} recette(s)</span></td></tr>"
        }.join + "</tbody></table>"
      end}
    </div>
  </div>

  <!-- 5. Recettes finales coût nul -->
  <div class="section">
    <div class="section-header">
      <span class="icon">📊</span>
      Recettes finales avec coût = 0
      <span style="margin-left:auto">#{badge(zero_cost_r.size)}</span>
    </div>
    <div class="section-body">
      #{if zero_cost_r.empty?
        "<div class='empty-state'>Aucune</div>"
      else
        "<table><thead><tr><th>ID</th><th>Recette</th><th>Poids total (kg)</th></tr></thead><tbody>" +
        zero_cost_r.map { |r|
          "<tr><td class='id-badge'>#{r.id}</td><td>#{r.name}</td><td>#{r.cached_total_weight.to_f.round(3)}</td></tr>"
        }.join + "</tbody></table>"
      end}
    </div>
  </div>

  <!-- 6. Produits doublons suspects -->
  <div class="section">
    <div class="section-header">
      <span class="icon">🔴</span>
      Produits potentiellement en doublon
      <span style="margin-left:auto">#{badge(product_suspects.size)}</span>
    </div>
    <div class="section-body">
      #{if product_suspects.empty?
        "<div class='empty-state'>Aucun doublon évident</div>"
      else
        "<table><thead><tr><th>Produit A</th><th>ID A</th><th>Produit B</th><th>ID B</th></tr></thead><tbody>" +
        product_suspects.map { |p1, p2|
          "<tr><td>#{p1.name}</td><td class='id-badge'>#{p1.id}</td><td>#{p2.name}</td><td class='id-badge'>#{p2.id}</td></tr>"
        }.join + "</tbody></table>"
      end}
    </div>
  </div>

  <!-- 7. Recettes doublons suspects -->
  <div class="section">
    <div class="section-header">
      <span class="icon">🔴</span>
      Recettes potentiellement en doublon
      <span style="margin-left:auto">#{badge(recipe_suspects.size)}</span>
    </div>
    <div class="section-body">
      #{if recipe_suspects.empty?
        "<div class='empty-state'>Aucun doublon évident</div>"
      else
        "<table><thead><tr><th>Recette A</th><th>ID A</th><th>Type</th><th>Recette B</th><th>ID B</th><th>Type</th></tr></thead><tbody>" +
        recipe_suspects.map { |r1, r2|
          t1 = r1.sellable_as_component? ? "<span class='tag tag-sr'>SR</span>" : "<span class='tag tag-r'>R</span>"
          t2 = r2.sellable_as_component? ? "<span class='tag tag-sr'>SR</span>" : "<span class='tag tag-r'>R</span>"
          "<tr><td>#{r1.name}</td><td class='id-badge'>#{r1.id}</td><td>#{t1}</td><td>#{r2.name}</td><td class='id-badge'>#{r2.id}</td><td>#{t2}</td></tr>"
        }.join + "</tbody></table>"
      end}
    </div>
  </div>

  <!-- 8. Composants à quantité nulle -->
  <div class="section">
    <div class="section-header">
      <span class="icon">0️⃣</span>
      Composants avec quantité = 0
      <span style="margin-left:auto">#{badge(zero_qty_comps.count)}</span>
    </div>
    <div class="section-body">
      #{if zero_qty_comps.empty?
        "<div class='empty-state'>Aucun</div>"
      else
        "<table><thead><tr><th>Recette</th><th>Composant</th><th>Quantité</th></tr></thead><tbody>" +
        zero_qty_comps.map { |rc|
          "<tr><td>#{rc.recipe.name}</td><td>#{rc.component.name}</td><td><span class='tag tag-err'>#{rc.quantity_kg}</span></td></tr>"
        }.join + "</tbody></table>"
      end}
    </div>
  </div>

  <!-- 9. Catch-all produits -->
  <div class="section">
    <div class="section-header">
      <span class="icon">📦</span>
      Produits "catch-all" suspects (prix trop variables, ratio > 5×)
      <span style="margin-left:auto">#{badge(catch_alls.size)}</span>
    </div>
    <div class="section-body">
      #{if catch_alls.empty?
        "<div class='empty-state'>Aucun</div>"
      else
        "<table><thead><tr><th>Produit</th><th>ID</th><th>Prix min (€/kg)</th><th>Prix max (€/kg)</th><th>Ratio</th></tr></thead><tbody>" +
        catch_alls.sort_by { |c| -c[:ratio] }.map { |c|
          "<tr><td>#{c[:product].name}</td><td class='id-badge'>#{c[:product].id}</td><td>#{c[:min].round(3)}</td><td>#{c[:max].round(3)}</td><td><span class='tag tag-warn'>×#{c[:ratio].round(1)}</span></td></tr>"
        }.join + "</tbody></table>"
      end}
    </div>
  </div>

  <!-- 10. Sous-recettes non utilisées -->
  <div class="section">
    <div class="section-header">
      <span class="icon">🏝</span>
      Sous-recettes non utilisées dans aucune recette
      <span style="margin-left:auto">#{badge(unused_sr.size, ok_zero: true)}</span>
    </div>
    <div class="section-body">
      #{if unused_sr.empty?
        "<div class='empty-state'>Toutes les sous-recettes sont utilisées</div>"
      else
        "<table><thead><tr><th>ID</th><th>Nom</th><th>Ingrédients</th></tr></thead><tbody>" +
        unused_sr.map { |sr|
          "<tr><td class='id-badge'>#{sr.id}</td><td>#{sr.name}</td><td>#{sr.recipe_components.count}</td></tr>"
        }.join + "</tbody></table>"
      end}
    </div>
  </div>

  <!-- 11. Produits inutilisés -->
  <div class="section">
    <div class="section-header">
      <span class="icon">🏝</span>
      Produits non utilisés dans aucune recette
      <span style="margin-left:auto">#{badge(unused_products.size, ok_zero: true)}</span>
    </div>
    <div class="section-body">
      #{if unused_products.empty?
        "<div class='empty-state'>Tous les produits sont utilisés</div>"
      else
        "<table><thead><tr><th>ID</th><th>Nom</th><th>Unité</th><th>Conditionnements</th></tr></thead><tbody>" +
        unused_products.map { |p|
          condits = p.product_purchases.count
          flag = condits == 0 ? "<span class='tag tag-err'>0 prix</span>" : "#{condits}"
          "<tr><td class='id-badge'>#{p.id}</td><td>#{p.name}</td><td><code>#{p.base_unit}</code></td><td>#{flag}</td></tr>"
        }.join + "</tbody></table>"
      end}
    </div>
  </div>

  <!-- 12. Tableau de bord recettes finales -->
  <div class="section">
    <div class="section-header">
      <span class="icon">📈</span>
      Toutes les recettes finales — poids & coût
    </div>
    <div class="section-body">
      <table>
        <thead>
          <tr>
            <th>ID</th>
            <th>Recette</th>
            <th>Poids total (kg)</th>
            <th>Coût/kg</th>
            <th>Statut</th>
          </tr>
        </thead>
        <tbody>
          #{main_recipes.map { |r|
            poids = r.cached_total_weight.to_f.round(3)
            cout  = r.cached_cost_per_kg.to_f.round(4)
            if cout == 0
              status = "<span class='tag tag-err'>Coût manquant</span>"
            elsif poids == 0
              status = "<span class='tag tag-warn'>Poids 0</span>"
            else
              status = "<span class='tag tag-ok'>OK</span>"
            end
            "<tr><td class='id-badge'>#{r.id}</td><td>#{r.name}</td><td>#{poids}</td><td>#{cout} €</td><td>#{status}</td></tr>"
          }.join}
        </tbody>
      </table>
    </div>
  </div>

</div>
</body>
</html>
HTML

print html
