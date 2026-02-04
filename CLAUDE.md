# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

CostChef is a Ruby on Rails SaaS application for catering businesses to calculate recipe material costs. It replaces Excel spreadsheets with an automated cost management system.

**Tech Stack:** Rails 7.1 + Ruby 3.3.5 + PostgreSQL + Bootstrap 5 + Stimulus/Turbo (Hotwire)

## Development Commands

```bash
# Start development server (web + CSS watcher)
bin/dev

# Setup environment
bin/setup

# Database
bin/rails db:prepare      # Create + migrate
bin/rails db:migrate      # Run migrations
bin/rails db:seed         # Load seed data

# Testing
bin/rails test            # Run test suite

# Code quality
rubocop -a                # Lint and auto-fix Ruby

# CSS compilation
yarn build:css            # One-time build
yarn watch:css            # Watch mode (included in bin/dev)

# Console
bin/rails console         # Interactive Ruby shell
```

## Architecture

### Data Model (Multi-tenant with user isolation)

- **Users** - Authentication via Devise, subscription management
- **Products** - Ingredient library (name, price, unit) scoped to user
- **Recipes** - Cost calculations with cached metrics (total_cost, total_weight, cost_per_kg)
- **RecipeIngredients** - Join table with quantities

Key relationships:
- User `has_many` Products, Recipes (cascade delete)
- Product `has_many` RecipeIngredients (restrict delete if in use)
- Recipe `has_many` RecipeIngredients, Products (through)

### Cost Calculation Flow

1. Product prices are stored per user
2. RecipeIngredients link products to recipes with quantities
3. When product price or recipe ingredient changes, recipe cached costs auto-recalculate via callbacks
4. `cached_cost_per_kg` is the key comparison metric

### Frontend Architecture

- **CSS:** Sass compiled via `cssbundling-rails` → `/app/assets/builds/application.css`
- **JS:** Stimulus controllers in `/app/javascript/controllers/`
- **Views:** ERB templates with Bootstrap 5 components
- **Entry point:** `/app/assets/stylesheets/application.bootstrap.scss`

## Current Status

This is an MVP bootstrap. The scaffold exists but models, migrations, routes, controllers, and Devise configuration need to be implemented. See `PRD.md` for full requirements and database schema.
