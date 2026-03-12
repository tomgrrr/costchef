# Déploiement CostChef

## Variables d'environnement obligatoires

| Variable | Description |
|----------|-------------|
| `RAILS_MASTER_KEY` | Clé de déchiffrement de `credentials.yml.enc` |
| `DATABASE_URL` | URL PostgreSQL (ex: `postgres://user:pass@host:5432/costchef_production`) |
| `SMTP_USERNAME` | Adresse Gmail utilisée pour l'envoi |
| `SMTP_PASSWORD` | App Password Gmail (voir ci-dessous) |

Les autres variables ont des valeurs par défaut dans `.env.example`.

## Obtenir un SMTP_PASSWORD Gmail (App Password)

1. Se connecter au compte Gmail utilisé pour l'envoi
2. Aller sur https://myaccount.google.com/apppasswords
3. La vérification en 2 étapes doit être activée au préalable
4. Créer un mot de passe d'application (nom : "CostChef")
5. Copier le mot de passe généré (16 caractères) dans `SMTP_PASSWORD`

## Commandes de déploiement

```bash
# Préparer la base de données
RAILS_ENV=production bin/rails db:prepare

# Précompiler les assets
RAILS_ENV=production bin/rails assets:precompile

# Lancer le serveur
RAILS_ENV=production bin/rails server
```

## Vérification

```bash
# Health check
curl https://costchef.fr/health

# Console production
RAILS_ENV=production bin/rails console
```
