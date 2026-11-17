# frozen_string_literal: true

# One-time data migration (ai/v1-redesign-plan.md's category audit,
# 2026-11-18): updates the `definition` text on the 19 existing Category
# rows to the V1 editorial copy. Runs exactly once per environment
# (tracked in schema_migrations like any other migration) — this is
# deliberately NOT part of db/seeds.rb, which now runs on every deploy;
# a migration is the mechanism that gives "runs once, ever" for free,
# so a future editor's own manual definition edit is never silently
# overwritten by a later deploy.
#
# Matches existing rows by `name` only — never creates, renames, or
# deletes a Category, and never touches `popular_drinks`, `id`, or any
# cocktail association. A category whose name doesn't match this list
# (shouldn't happen — the 19 names are stable, confirmed against
# db/seeds.rb) is left untouched rather than guessed at.
class UpdateCategoryEditorialDefinitionsV1 < ActiveRecord::Migration[7.0]
  class MigrationCategory < ActiveRecord::Base
    self.table_name = 'categories'
  end

  DEFINITIONS = {
    'Ancestral' => 'Spirit-forward cocktails rooted in the earliest cocktail formula: a base spirit, a ' \
                   'modest amount of sugar or liqueur, bitters, and dilution. Old Fashioneds and Sazeracs ' \
                   'exemplify this foundational style.',
    'Duos and Trios' => 'Duos are simple combinations, typically pairing a spirit with a liqueur. Trios ' \
                        'build on this idea by adding cream or a cream liqueur, creating a richer, softer ' \
                        'drink.',
    'French Italian' => 'Spirit-forward cocktails featuring vermouth or another aromatized or fortified ' \
                        'wine, sometimes complemented by bitters or liqueurs. This family includes ' \
                        'classics such as the Manhattan, Martini, and Negroni.',
    'Simple Sour' => 'Cocktails balancing a base spirit with citrus juice and a nonalcoholic sweetener, ' \
                     'such as sugar, honey, or flavored syrup. Egg white may be added for texture.',
    'Enhanced Sour' => 'Sour-style cocktails that combine spirit, citrus, and sweetness with vermouth or ' \
                       'another aromatized or fortified wine, adding an extra layer of complexity.',
    'New Orleans Sour' => 'A style of Sour balancing a base spirit and citrus juice with orange liqueur, ' \
                          'such as curaçao or triple sec. Margaritas and Sidecars are classic examples.',
    'International Sour' => 'Sours incorporating liqueurs other than orange liqueur as important sources ' \
                            'of sweetness and flavor. Ingredients such as maraschino and herbal liqueurs ' \
                            'introduce additional complexity.',
    'Sparkling Sour' => 'Sour-style cocktails combining a spirit, citrus, and sweetness with an ' \
                        'effervescent ingredient such as soda water or sparkling wine. The bubbles add ' \
                        'lift and a refreshing finish.',
    'Champagne Cocktail' => 'Cocktails built primarily around Champagne or another sparkling wine, ' \
                            'complemented by ingredients such as bitters, sugar, liqueurs, or fruit juice. ' \
                            'These range from the traditional Champagne Cocktail to the Mimosa.',
    'Frozen' => 'Cocktails blended with ice to create a smooth, slushy texture. Frozen describes the ' \
                'preparation rather than a particular recipe family; drinks such as Daiquiris and ' \
                'Margaritas may also be served this way.',
    'Highball' => 'Tall, refreshing drinks combining a base spirit with a carbonated mixer such as soda, ' \
                  'tonic, ginger ale, or cola. Traditionally served over ice, often with a citrus garnish.',
    'Toddy' => 'Warming cocktails traditionally combining a spirit, hot water, and a sweetener, often with ' \
               'citrus or aromatic spices. Hot Buttered Rum is a richer variation of this comforting style.',
    'Flips and Nogs' => 'Two traditional egg-based cocktail families. Flips typically combine a spirit or ' \
                        'fortified wine with sugar and whole egg or yolk, while Nogs add milk or cream ' \
                        'for a richer, custard-like texture.',
    'Juleps and Smashes' => 'Refreshing spirit-based cocktails built around fresh herbs, sweetener, and ' \
                            'ice. Juleps traditionally feature mint and crushed ice, while Smashes may ' \
                            'incorporate other herbs, seasonal fruit, and citrus.',
    'Punch' => 'One of the oldest mixed-drink traditions, historically balancing spirit, citrus, sugar, ' \
               'water, and sometimes spices. Modern punches may incorporate additional juices, liqueurs, ' \
               'or sparkling ingredients and can be prepared individually or for sharing.',
    'Pousse' => 'Small, visually distinctive drinks made by carefully layering spirits, liqueurs, or ' \
                'syrups of different densities. Also known as Pousse-Cafés, they showcase the art of ' \
                'layered presentation.',
    'Tiki' => 'A distinctive American tropical-cocktail tradition associated with pioneers such as Donn ' \
              'Beach and Trader Vic. Often featuring layered rum flavors, juices, spices, and house-made ' \
              'syrups, Tiki drinks are defined by their historical style and creative complexity rather ' \
              'than a single formula.',
    'Snapper' => 'Savory, tomato-based cocktails combining spirits with tomato juice, seasoning, acidity, ' \
                 'and often elaborate garnishes. The Bloody Mary and gin-based Red Snapper are familiar ' \
                 'examples.',
    'Orphan' => 'An internal editorial classification for cocktails that do not yet fit an established ' \
                'family. Assignments should be reviewed as Kinpour\'s collection develops. This is not a ' \
                'public cocktail style.'
  }.freeze

  def up
    MigrationCategory.reset_column_information
    DEFINITIONS.each do |name, definition|
      category = MigrationCategory.find_by(name:)
      next unless category

      category.update_column(:definition, definition) if category.definition != definition
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
