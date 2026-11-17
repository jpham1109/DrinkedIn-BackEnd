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
# block only runs — setting definition/popular_drinks — when a NEW
# record is being created. On every later run, `name` alone is the
# lookup key; an existing row is left untouched, never re-matched
# against (and therefore never duplicated by) its own definition text.
#
# Content here is intentionally the pre-existing category copy/examples,
# unchanged from before this PR — the V1 editorial-definitions rewrite
# and the removal of `popular_drinks` are a separate, dependent PR
# (`feat/category-editorial-audit`, branched from this one) so this PR
# stays scoped to the seeding *mechanism*, not the content.

category_seeds = [
  { name: 'Ancestral',
    definition: 'Composed of a base spirit lightly adorned with sugar (in Improved versions, the sweetener ' \
                'appears in the form of a dash or two of liqueur such as maraschino or curacao), bitters, and ' \
                'water (usually in its frozen form), and served either straight up or on the rocks.',
    popular_drinks: [{ name: 'Old Fashioned', image: 'photos/cocktails/old-fashioned.jpg' },
                     { name: 'Sazerac', image: 'photos/cocktails/sazerac-768x768.jpg' }] },
  { name: 'Duos and Trios',
    definition: 'Duos are composed of two ingredients, usually a base spirit and a liqueur, and are normally ' \
                'served in an old-fashioned glass. Trios are duos to which cream or a cream liqueur has been ' \
                'added. Not all duos can be made into trios. Not all trios start out as duos',
    popular_drinks: [{ name: 'Godfather', image: 'photos/cocktails/godfather-cocktail.jpg' },
                     { name: 'White Russian', image: 'photos/cocktails/white_russian.jpg' }] },
  { name: 'French Italian',
    definition: 'Composed of a base spirit with a modifier of vermouth, or another fortified wine such as ' \
                'sherry, quinquina, or port, often accompanied by other ingredients such as bitters or small ' \
                'doses of liqueurs or syrups.',
    popular_drinks: [{ name: 'Vesper Martini', image: 'photos/cocktails/lillet-vesper-martini.webp' },
                     { name: 'Negroni', image: 'photos/cocktails/negroni.jpg' },
                     { name: 'Manhattan', image: 'photos/cocktails/manhattan.jpg' }] },
  { name: 'Simple Sour',
    definition: 'Contain a base spirit, citrus juice and a non-alcoholic sweetening agent such as simple ' \
                'syrup, grenadine or orgeat syrup (sometimes egg white is added for body and foam)',
    popular_drinks: [{ name: 'Daiquiri', image: 'photos/cocktails/daiquiri.webp' },
                     { name: 'Jack Rose', image: 'photos/cocktails/Calvados-Jack-Rose-Cocktail-2.jpg' },
                     { name: 'Whiskey Sour', image: 'photos/cocktails/whiskey_sour.jpg' }] },
  { name: 'Enhanced Sour',
    definition: 'Calls for a spirit, citrus juice, a sweetening agent of any kind , plus vermouth or any ' \
                'other aromatized or fortified wine',
    popular_drinks: [{ name: 'Clover Club', image: 'photos/cocktails/Clover-club-cocktail-5.jpg' },
                     { name: 'Bronx Cocktail', image: 'photos/cocktails/bronx_cocktail.jpg' },
                     { name: 'Ruby', image: 'photos/cocktails/Ruby_cocktail.jpg' }] },
  { name: 'New Orleans Sour',
    definition: 'Calls for a base spirit, citrus juice, and an orange-flavored liqueur',
    popular_drinks: [{ name: 'Cosmopolitan', image: 'photos/cocktails/cosmo.jpg' },
                     { name: 'Margarita', image: 'photos/cocktails/Margarita.jpg' },
                     { name: 'Corpse Reviver no.2', image: 'photos/cocktails/corpse_reviver.webp' }] },
  { name: 'International Sour',
    definition: 'Contains a spirit, citrus juice and a liqueur as sweetening agent',
    popular_drinks: [{ name: 'Hemingway Daiquiri', image: 'photos/cocktails/hemingway_daiquiri.jpeg' },
                     { name: 'Aviation', image: 'photos/cocktails/aviation.jpg' },
                     { name: 'Gun Metal Blue', image: 'photos/cocktails/gunmetal_blue.jpg' }] },
  { name: 'Sparkling Sour',
    definition: 'Contains a spirit, citrus juice, a sweetening agent of any kind and some bubbles either ' \
                'non-alcoholic or alcoholic',
    popular_drinks: [{ name: 'French 75', image: 'photos/cocktails/French-75-Sipsmith.jpg' },
                     { name: 'Ramos Gin Fizz', image: 'photos/cocktails/Ramos-Gin-Fizz-Tonique.jpg' },
                     { name: 'Airmail', image: 'photos/cocktails/Airmail.jpg' }] },
  { name: 'Champagne Cocktail',
    definition: 'Made with champagne or sparkling wine as the main ingredient with a splash of liqueur ' \
                'and/or fruit juice, or sugar and bitters',
    popular_drinks: [{ name: 'Champagne cocktail', image: 'photos/cocktails/Champagne_cocktail.jpg' },
                     { name: 'Mimosa', image: 'photos/cocktails/mimosa.jpg' }] },
  { name: 'Frozen',
    definition: 'Cocktails that are blended with ice, perfect for hot summer days',
    popular_drinks: [{ name: 'Frozen pina colada', image: 'photos/cocktails/Frozen-pina-colada.jpg' },
                     { name: 'Frozen Strawberry Daiquiri',
                       image: 'photos/cocktails/Frozen-Strawberry-Daiquiri.webp' }] },
  { name: 'Highball',
    definition: 'Made with a base spirit leavened with ice and a lengthener such as club soda, ginger ale or ' \
                'cola',
    popular_drinks: [{ name: 'Cuba Libre', image: 'photos/cocktails/Cuba-libre.jpg' },
                     { name: 'Dark and Stormy', image: 'photos/cocktails/DarkNStormy.png' },
                     { name: 'Whiskey Highball', image: 'photos/cocktails/Toki-highball.jpg' }] },
  { name: 'Toddy',
    definition: 'Old-fashioned style of cocktail with distilled spirit, sweetener and hot water, and other ' \
                'spices',
    popular_drinks: [{ name: 'Hot Toddy', image: 'photos/cocktails/RP-Hot-toddy.jpg' },
                     { name: 'Hot Buttered Rum', image: 'photos/cocktails/Hot-buttered-rum.jpg' },
                     { name: 'Irish Coffee', image: 'photos/cocktails/irish-coffee.jpg' }] },
  { name: 'Flips and Nogs',
    definition: 'Made with whole eggs, base spirits, cream and/or milk, sweetening agents such as maple ' \
                'syrup or sugar',
    popular_drinks: [{ name: 'Boston Flip', image: 'photos/cocktails/boston-flip.jpeg' },
                     { name: 'Brandy Flip', image: 'photos/cocktails/Brandy-Flip-2.jpg' }] },
  { name: 'Juleps and Smashes',
    definition: 'Made of a base spirit, fresh mint, sugar, sometimes with fruits in case of smashes, and a ' \
                'lot of ice',
    popular_drinks: [{ name: 'Mint Julep', image: 'photos/cocktails/Mint_Julep.jpg' },
                     { name: 'Peach Whiskey Smash', image: 'photos/cocktails/grilled-peach-whiskey-smash.webp' }] },
  { name: 'Punch',
    definition: 'Refers to a variety of festive drinks, non-alcoholic or alcoholic, generally containing ' \
                'fruits and fruit juices, spirits and liqueurs if alcoholic, and often topped with sparkling ' \
                'wine or soda. It is usually served at parties in large, wide bowls, known as punch bowls.',
    popular_drinks: [{ name: 'Gin Punch', image: 'photos/cocktails/Gin-punch-epicurious.webp' },
                     { name: 'Tequila Watermelon Punch', image: 'photos/cocktails/Tequila-watermelon-punch.jpg' }] },
  { name: 'Pousse',
    definition: 'Elaborately composed concoctions made of liqueurs and syrups, layered for a distinctive ' \
                'appearance',
    popular_drinks: [{ name: 'Pousse Cafe', image: 'photos/cocktails/Pousse-cafe.jpg' },
                     { name: 'B-52', image: 'photos/cocktails/B52-Shooter.jpg' }] },
  { name: 'Tiki',
    definition: 'Single-serving punch-style drinks featuring a base spirit(s), fruit juice and syrups or ' \
                'liqueurs, often deployed in various combinations.',
    popular_drinks: [{ name: 'Mai Tai', image: 'photos/cocktails/MaiTai-Spruce.jpg' },
                     { name: 'Luau Daiquiri', image: 'photos/cocktails/Luau-daiquiri-latitude29.jpg' },
                     { name: 'Zombie', image: 'photos/cocktails/Zombie-Original.jpg' }] },
  { name: 'Snapper',
    definition: 'Made with a base spirit, tomato juice and a variety of garnishes',
    popular_drinks: [{ name: 'Bloody Mary', image: 'photos/cocktails/bloody-mary.webp' },
                     { name: 'Red Snapper', image: 'photos/cocktails/red-snapper.jpg' }] },
  { name: 'Orphan',
    definition: 'Does not fit in any cocktail family, or you are just a renegade. Subjected to be moved to a ' \
                'more appropriate category.',
    popular_drinks: [{ name: 'Renegade', image: 'photos/cocktails/QuestionCocktail.jpg' }] }
].freeze

category_seeds.each do |attrs|
  Category.find_or_create_by!(name: attrs[:name]) do |category|
    category.definition = attrs[:definition]
    category.popular_drinks = attrs[:popular_drinks]
  end
end

# rubocop:disable Rails/Output -- deliberate: production's log_level is
# :info (config/environments/production.rb), so Rails.logger.debug would
# be silently dropped during a real deploy — this message needs to
# actually appear in deploy output to confirm reference-data
# initialization succeeded, which is the entire point of it existing.
puts "Foundational reference data ready (#{Category.count} categories)."
# rubocop:enable Rails/Output
