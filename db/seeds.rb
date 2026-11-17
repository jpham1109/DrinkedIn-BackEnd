# frozen_string_literal: true

# Foundational reference data only — safe to run in any environment,
# including production, on every deploy. ai/v1-redesign-plan.md's
# "Separate workstream: production seed safety" (2026-11-17, following a
# real incident where this file's previous unconditional destroy_all
# calls wiped the shared development database).
#
# Hard rules for this file, going forward:
#   - No destroy_all, no reset_pk_sequence, no destructive operation of
#     any kind.
#   - Idempotent: running this any number of times against an existing,
#     populated database must never duplicate or overwrite a row.
#   - No Users, Cocktails, Likes, or Follows — those are development
#     sample data now, see `lib/tasks/dev_sample_data.rake`
#     (`dev:reset_sample_data`).
#
# find_or_create_by! with a block (not a flat attributes hash): the
# block only runs — setting `definition` — when a NEW record is being
# created. On every later run, `name` alone is the lookup key; an
# existing row is left untouched, never re-matched against (and
# therefore never duplicated by) its own definition text.
#
# V1 editorial definitions below (ai/v1-redesign-plan.md's category
# audit, 2026-11-18) replace the originals for NEW databases only — an
# already-existing database's current 19 rows are updated separately, in
# `db/migrate/20261118000000_update_category_editorial_definitions_v1.rb`
# (a one-time data migration, not here, so this file never overwrites a
# future manual editorial edit on every deploy).
#
# `popular_drinks` is no longer written here at all (removed 2026-11-18
# — see the same audit): category previews are now dynamic, sourced from
# each category's actual cocktail records (CategoryCard.jsx,
# CategoryDetail.jsx, Home's CategoryIndex.jsx), not a static per-
# category example list. The column itself still exists on existing rows
# (unused, not cleared — a separate future schema cleanup, not this PR's
# concern) but nothing reads or writes it anymore.

category_seeds = [
  { name: 'Ancestral',
    definition: 'Spirit-forward cocktails rooted in the earliest cocktail formula: a base spirit, a modest ' \
                'amount of sugar or liqueur, bitters, and dilution. Old Fashioneds and Sazeracs exemplify ' \
                'this foundational style.' },
  { name: 'Duos and Trios',
    definition: 'Duos are simple combinations, typically pairing a spirit with a liqueur. Trios build on ' \
                'this idea by adding cream or a cream liqueur, creating a richer, softer drink.' },
  { name: 'French Italian',
    definition: 'Spirit-forward cocktails featuring vermouth or another aromatized or fortified wine, ' \
                'sometimes complemented by bitters or liqueurs. This family includes classics such as the ' \
                'Manhattan, Martini, and Negroni.' },
  { name: 'Simple Sour',
    definition: 'Cocktails balancing a base spirit with citrus juice and a nonalcoholic sweetener, such as ' \
                'sugar, honey, or flavored syrup. Egg white may be added for texture.' },
  { name: 'Enhanced Sour',
    definition: 'Sour-style cocktails that combine spirit, citrus, and sweetness with vermouth or another ' \
                'aromatized or fortified wine, adding an extra layer of complexity.' },
  { name: 'New Orleans Sour',
    definition: 'A style of Sour balancing a base spirit and citrus juice with orange liqueur, such as ' \
                'curaçao or triple sec. Margaritas and Sidecars are classic examples.' },
  { name: 'International Sour',
    definition: 'Sours incorporating liqueurs other than orange liqueur as important sources of sweetness ' \
                'and flavor. Ingredients such as maraschino and herbal liqueurs introduce additional ' \
                'complexity.' },
  { name: 'Sparkling Sour',
    definition: 'Sour-style cocktails combining a spirit, citrus, and sweetness with an effervescent ' \
                'ingredient such as soda water or sparkling wine. The bubbles add lift and a refreshing ' \
                'finish.' },
  { name: 'Champagne Cocktail',
    definition: 'Cocktails built primarily around Champagne or another sparkling wine, complemented by ' \
                'ingredients such as bitters, sugar, liqueurs, or fruit juice. These range from the ' \
                'traditional Champagne Cocktail to the Mimosa.' },
  { name: 'Frozen',
    definition: 'Cocktails blended with ice to create a smooth, slushy texture. Frozen describes the ' \
                'preparation rather than a particular recipe family; drinks such as Daiquiris and ' \
                'Margaritas may also be served this way.' },
  { name: 'Highball',
    definition: 'Tall, refreshing drinks combining a base spirit with a carbonated mixer such as soda, ' \
                'tonic, ginger ale, or cola. Traditionally served over ice, often with a citrus garnish.' },
  { name: 'Toddy',
    definition: 'Warming cocktails traditionally combining a spirit, hot water, and a sweetener, often with ' \
                'citrus or aromatic spices. Hot Buttered Rum is a richer variation of this comforting style.' },
  { name: 'Flips and Nogs',
    definition: 'Two traditional egg-based cocktail families. Flips typically combine a spirit or fortified ' \
                'wine with sugar and whole egg or yolk, while Nogs add milk or cream for a richer, ' \
                'custard-like texture.' },
  { name: 'Juleps and Smashes',
    definition: 'Refreshing spirit-based cocktails built around fresh herbs, sweetener, and ice. Juleps ' \
                'traditionally feature mint and crushed ice, while Smashes may incorporate other herbs, ' \
                'seasonal fruit, and citrus.' },
  { name: 'Punch',
    definition: 'One of the oldest mixed-drink traditions, historically balancing spirit, citrus, sugar, ' \
                'water, and sometimes spices. Modern punches may incorporate additional juices, liqueurs, ' \
                'or sparkling ingredients and can be prepared individually or for sharing.' },
  { name: 'Pousse',
    definition: 'Small, visually distinctive drinks made by carefully layering spirits, liqueurs, or syrups ' \
                'of different densities. Also known as Pousse-Cafés, they showcase the art of layered ' \
                'presentation.' },
  { name: 'Tiki',
    definition: 'A distinctive American tropical-cocktail tradition associated with pioneers such as Donn ' \
                'Beach and Trader Vic. Often featuring layered rum flavors, juices, spices, and house-made ' \
                'syrups, Tiki drinks are defined by their historical style and creative complexity rather ' \
                'than a single formula.' },
  { name: 'Snapper',
    definition: 'Savory, tomato-based cocktails combining spirits with tomato juice, seasoning, acidity, ' \
                'and often elaborate garnishes. The Bloody Mary and gin-based Red Snapper are familiar ' \
                'examples.' },
  { name: 'Orphan',
    definition: 'An internal editorial classification for cocktails that do not yet fit an established ' \
                'family. Assignments should be reviewed as Kinpour\'s collection develops. This is not a ' \
                'public cocktail style.' }
].freeze

category_seeds.each do |attrs|
  Category.find_or_create_by!(name: attrs[:name]) do |category|
    category.definition = attrs[:definition]
  end
end

# rubocop:disable Rails/Output -- deliberate: production's log_level is
# :info (config/environments/production.rb), so Rails.logger.debug would
# be silently dropped during a real deploy — this message needs to
# actually appear in deploy output to confirm reference-data
# initialization succeeded, which is the entire point of it existing.
puts "Foundational reference data ready (#{Category.count} categories)."
# rubocop:enable Rails/Output
