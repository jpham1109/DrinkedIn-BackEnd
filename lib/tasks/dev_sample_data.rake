# frozen_string_literal: true

# Development-only sample data, relocated out of db/seeds.rb 2026-11-17
# (ai/v1-redesign-plan.md's "Separate workstream: production seed
# safety," following an incident where seeds.rb's old unconditional
# destroy_all calls wiped the shared development database). Content is
# otherwise unchanged from the old seeds.rb: 5 sample users, 41 sample
# cocktails with their images, destructively reset first.
#
# Explicitly invoked only — never runs as a side effect of db:prepare,
# db:setup, or any deploy step. All safety logic lives in
# DevSampleDataGuard (lib/dev_sample_data_guard.rb), not here — see that
# file for the four checks and why none of them alone would have been
# sufficient to catch the original incident.
require_relative '../dev_sample_data_guard'

namespace :dev do
  desc 'Destructively reset and reload development sample data (users, cocktails, likes, follows). ' \
       'Development only. Requires CONFIRM_RESET=yes.'
  task reset_sample_data: :environment do
    begin
      DevSampleDataGuard.new.check!
    rescue DevSampleDataGuard::GuardError => e
      abort(e.message)
    end

    puts "Resetting sample data in '#{ActiveRecord::Base.connection.pool.db_config.configuration_hash[:database]}' " \
         "(Rails.env=#{Rails.env}, confirmed)..."

    Follow.destroy_all
    Follow.all.reset_pk_sequence
    Like.destroy_all
    Like.all.reset_pk_sequence
    Cocktail.destroy_all
    Cocktail.all.reset_pk_sequence
    User.destroy_all
    User.all.reset_pk_sequence
    Bar.destroy_all
    Bar.all.reset_pk_sequence

    # Foundational Category reference data stays owned by db/seeds.rb —
    # ensure it exists (idempotent) rather than duplicating its content
    # here.
    Rails.application.load_seed

    # editor: true here only — a dev-only stand-in for the founder's own
    # account, so local editor-gated testing (catalog
    # create/update/destroy/publish/unpublish) doesn't require a manual
    # console step every reset. Never set this way outside this
    # dev-only task; the real grant is a documented, one-time Rails
    # console action (ai/v1-redesign-plan.md).
    jamie = User.create(full_name: 'Jamie Pham', username: 'ninjacat', password: '123', location: 'Brooklyn, NY',
                        bartender: true, editor: true)
    toggie = User.create(full_name: 'Toggie Pham', username: 'puglife', password: '123', location: 'Heaven, SK',
                         bartender: true)
    jack = User.create(full_name: 'Jack Rose', username: 'jackrose', password: '123', location: 'Queens, NY',
                       bartender: true)
    doug = User.create(full_name: 'Douglas Fairbanks', username: 'fairbanks', password: '123',
                       location: 'New York, NY', bartender: true)
    User.create(full_name: 'Mia Wallace', username: 'mrswallace', password: '123', location: 'New York, NY',
                bartender: false)

    new_orleans_sour = Category.find_by!(name: 'New Orleans Sour')
    tiki = Category.find_by!(name: 'Tiki')
    french_italian = Category.find_by!(name: 'French Italian')
    ancestral = Category.find_by!(name: 'Ancestral')
    simple_sour = Category.find_by!(name: 'Simple Sour')
    duos_and_trios = Category.find_by!(name: 'Duos and Trios')
    international_sour = Category.find_by!(name: 'International Sour')
    snapper = Category.find_by!(name: 'Snapper')
    frozen = Category.find_by!(name: 'Frozen')
    highball = Category.find_by!(name: 'Highball')
    toddy = Category.find_by!(name: 'Toddy')
    juleps_and_smashes = Category.find_by!(name: 'Juleps and Smashes')
    champagne_cocktail = Category.find_by!(name: 'Champagne Cocktail')
    pousse = Category.find_by!(name: 'Pousse')
    enhanced_sour = Category.find_by!(name: 'Enhanced Sour')
    sparkling_sour = Category.find_by!(name: 'Sparkling Sour')
    flips_and_nogs = Category.find_by!(name: 'Flips and Nogs')
    punch = Category.find_by!(name: 'Punch')

    cocktail_data = [
      { name: 'Margarita',
        description: 'The Margarita is one of the most popular cocktails in North America—for good reason. ' \
                     'Combining the tang of lime and the sweetness of orange liqueur with the distinctive ' \
                     'strength of tequila, our classic Margarita strikes all of the right keys.',
        execution: 'Add all ingredients into a shaker with ice and shake. Strain into a rocks glass over ' \
                   'fresh ice. Garnish with a lime wheel.',
        ingredients: ['2 oz Tequila', '1 oz Lime Juice', '0.75 oz Orange Liqueur'],
        submitted_by_id: jamie.id, category_id: new_orleans_sour.id, image_path: 'Margarita.jpg' },
      { name: 'Jungle Bird',
        description: 'The Jungle Bird is a modern classic tiki cocktail that was created in 1978 at the ' \
                     'Aviary Bar in Kuala Lumpur, Malaysia. Its a tropical, tiki cocktail thats a little ' \
                     'bitter, a little sweet, and a little strong.',
        execution: 'Add all ingredients into a shaker with ice and shake. Strain into a rocks glass over ' \
                   'fresh ice. Garnish with a lime wheel.',
        ingredients: ['1.5 oz Dark Rum', '0.75 oz Campari', '0.5 oz Lime Juice', '0.5 oz Simple Syrup',
                      '1.5 oz Pineapple Juice'],
        submitted_by_id: toggie.id, category_id: tiki.id, image_path: 'Jungle-Bird.jpg' },
      { name: 'Brooklyn',
        description: 'The Brooklyn cocktail is a classic drink made with rye whiskey, dry vermouth, ' \
                     "maraschino liqueur, and Amer Picon. It's a boozy, spirit-forward cocktail that's " \
                     'easy to make and a great alternative to a Manhattan.',
        execution: 'Add all ingredients into a mixing glass with ice and stir until well-chilled. Strain ' \
                   'into a chilled cocktail glass. Garnish with a cherry.',
        ingredients: ['2 oz Rye Whiskey', '0.75 oz Dry Vermouth', '0.25 oz Maraschino Liqueur',
                      '0.25 oz Amer Picon'],
        submitted_by_id: jack.id, category_id: french_italian.id, image_path: 'Brooklyn.jpg' },
      { name: 'Old Fashioned',
        description: 'The Old Fashioned is a cocktail made by muddling sugar with bitters and water, adding ' \
                     'whiskey or, less commonly, brandy, and garnishing with orange slice or zest and a ' \
                     'cocktail cherry. It is traditionally served in an old fashioned glass, which predated ' \
                     'the cocktail.',
        execution: 'Add sugar cube to old fashioned glass and saturate with bitters, add a dash of plain ' \
                   'water. Muddle until dissolved. Fill the glass with ice cubes and add whiskey. Garnish ' \
                   'with orange twist, and a cocktail cherry.',
        ingredients: ['2 oz Bourbon or Rye Whiskey', '1 Sugar Cube', '2 Dashes Angostura Bitters',
                      '1 Dash Plain Water'],
        submitted_by_id: doug.id, category_id: ancestral.id, image_path: 'old-fashioned.jpg' },
      { name: 'Daiquiri',
        description: 'The Daiquiri is a classic rum cocktail that is simple, refreshing and timeless. The ' \
                     'balance of sweet, sour and spirit is perfectly balanced and the drink can be easily ' \
                     'modified to suit your taste.',
        execution: 'Add all ingredients into a shaker with ice and shake. Strain into a chilled cocktail ' \
                   'glass, garnish with a lime wheel.',
        ingredients: ['2 oz choiced Rum', '0.75 oz Lime Juice', '0.75 oz Simple Syrup'],
        submitted_by_id: jamie.id, category_id: simple_sour.id, image_path: 'daiquiri.webp' },
      { name: 'Negroni',
        description: 'The Negroni is a popular Italian cocktail, made of one part gin, one part vermouth ' \
                     'rosso, and one part Campari, garnished with orange peel. It is considered an apéritif.',
        execution: 'Add all ingredients into mixing glass with ice and stir until well-chilled. Strain into ' \
                   'chilled cocktail glass. Garnish with an orange peel.',
        ingredients: ['1 oz Gin', '1 oz Campari', '1 oz Sweet Vermouth'],
        submitted_by_id: jamie.id, category_id: french_italian.id, image_path: 'negroni.jpg' },
      { name: 'Whiskey Sour',
        description: 'The whiskey sour is a mixed drink containing whiskey, lemon juice and simple syrup. ' \
                     'It is shaken and served either straight or over ice. The traditional garnish is half ' \
                     'an orange slice and a maraschino cherry.',
        execution: 'Add all ingredients into a shaker with ice and shake. Strain into a rocks glass over ' \
                   'fresh ice. Garnish with a cherry and an orange slice.',
        ingredients: ['2 oz Bourbon Whiskey', '0.75 oz Lemon Juice', '0.75 oz Simple Syrup'],
        submitted_by_id: jack.id, category_id: simple_sour.id, image_path: 'whiskey_sour.jpg' },
      { name: 'Clover Club',
        description: 'The Clover Club is a cocktail consisting of gin, lemon juice, raspberry syrup, and an ' \
                     'egg white. It is traditionally served in a cocktail glass, but may also be served in ' \
                     'a Collins glass or an Old Fashioned glass without ice.',
        execution: 'Add all ingredients into a shaker with ice and shake. Strain into a chilled cocktail ' \
                   'glass. Garnish with a raspberry.',
        ingredients: ['2 oz Gin', '0.75 oz Lemon Juice', '0.75 oz Raspberry Syrup', '1 Egg White'],
        submitted_by_id: toggie.id, category_id: simple_sour.id, image_path: 'Clover-club-cocktail-5.jpg' },
      { name: 'White Russian',
        description: 'The White Russian is a cocktail made with vodka, coffee liqueur and cream served ' \
                     'with ice in an old fashioned glass. Often milk will be used as an alternative to cream.',
        execution: 'Add all ingredients into old fashioned glass filled with ice. Stir gently.',
        ingredients: ['2 oz Vodka', '1 oz Coffee Liqueur', '1 oz Fresh Cream'],
        submitted_by_id: doug.id, category_id: duos_and_trios.id, image_path: 'white_russian.jpg' },
      { name: 'Aviation',
        description: 'The Aviation is a classic cocktail made with gin, maraschino liqueur, crème de ' \
                     'violette, and lemon juice. Some recipes omit the crème de violette. It is served ' \
                     'straight up, in a cocktail glass.',
        execution: 'Add all ingredients into a shaker with ice and shake. Strain into a chilled cocktail ' \
                   'glass. Garnish with a cherry.',
        ingredients: ['2 oz Gin', '0.5 oz Maraschino Liqueur', '0.5 oz Crème de Violette', '0.75 oz Lemon Juice'],
        submitted_by_id: jamie.id, category_id: international_sour.id, image_path: 'aviation.jpg' },
      { name: 'Gun Metal Blue',
        description: 'The Gun Metal Blue is a cocktail made with gin, blue curaçao, lemon juice, and simple ' \
                     'syrup. It is served straight up, in a cocktail glass.',
        execution: 'Add all ingredients into a shaker with ice and shake. Strain into a chilled cocktail ' \
                   'glass. Garnish with a lemon twist.',
        ingredients: ['2 oz Gin', '0.5 oz Blue Curaçao', '0.75 oz Lemon Juice', '0.75 oz Simple Syrup'],
        submitted_by_id: toggie.id, category_id: new_orleans_sour.id, image_path: 'gunmetal_blue.jpg' },
      { name: 'Blood Mary',
        description: 'The Bloody Mary is a cocktail containing vodka, tomato juice, and other spices and ' \
                     'flavorings including Worcestershire sauce, hot sauces, garlic, herbs, horseradish, ' \
                     'celery, olives, salt, black pepper, lemon juice, lime juice and celery salt.',
        execution: 'Add all ingredients into highball glass filled with ice. Stir gently. Garnish with ' \
                   'celery stalk and lemon wedge.',
        ingredients: ['1.5 oz Vodka', '3 oz Tomato Juice', '0.5 oz Lemon Juice', '1 dash Worcestershire Sauce',
                      '1 dash Tabasco Sauce', '1 pinch Celery Salt', '1 pinch Black Pepper'],
        submitted_by_id: jack.id, category_id: snapper.id, image_path: 'bloody-mary.webp' },
      { name: 'Frozen Pina Colada',
        description: 'The Piña Colada is a sweet cocktail made with rum, coconut cream or coconut milk, and ' \
                     'pineapple juice, usually served either blended or shaken with ice.',
        execution: 'Add all ingredients into blender with ice and blend until smooth. Pour into a chilled ' \
                   'hurricane glass. Garnish with a pineapple wedge and a cherry.',
        ingredients: ['2 oz White Rum', '3 oz Pineapple Juice', '1 oz Coconut Cream', '1 cup of ice'],
        submitted_by_id: doug.id, category_id: frozen.id, image_path: 'Frozen-pina-colada.jpg' },
      { name: 'Cuba Libre',
        description: 'The Cuba Libre is a highball cocktail consisting of cola, lime, and light rum. This ' \
                     'cocktail is often referred to as a Rum and Coke in many countries.',
        execution: 'Add all ingredients into highball glass filled with ice. Stir gently. Garnish with a ' \
                   'lime wedge.',
        ingredients: ['2 oz White Rum', '4 oz Cola', '0.5 oz Lime Juice'],
        submitted_by_id: jack.id, category_id: highball.id, image_path: 'Cuba-libre.jpg' },
      { name: 'Hot Toddy',
        description: 'The hot toddy is a mixed drink made of liquor and water with honey, herbs (such as ' \
                     'tea) and spices, and served hot. Hot toddy recipes vary and are traditionally drunk ' \
                     'before going to bed or in cold weather.',
        execution: 'Add all ingredients into mug. Stir gently. Garnish with a lemon wedge.',
        ingredients: ['2 oz Whiskey', '1 tbsp Honey', '1 Lemon Wedge', '1 cup Hot Water'],
        submitted_by_id: doug.id, category_id: toddy.id, image_path: 'RP-Hot-toddy.jpg' },
      { name: 'Mint Julep',
        description: 'The mint julep is a mixed alcoholic drink, or cocktail, consisting primarily of ' \
                     'bourbon, sugar, water, crushed or shaved ice, and fresh mint. As a bourbon-based ' \
                     'cocktail, it is associated with the American South and the cuisine of the Southern ' \
                     'United States in general, and the Kentucky Derby in particular.',
        execution: 'Add mint leaves and simple syrup into julep cup. Muddle gently. Fill the cup with ' \
                   'crushed ice and add bourbon. Stir gently. Garnish with a mint sprig.',
        ingredients: ['2 oz Bourbon', '1 tbsp Simple Syrup', '8 Mint Leaves'],
        submitted_by_id: toggie.id, category_id: juleps_and_smashes.id, image_path: 'Mint_Julep.jpg' },
      { name: 'Champagne Cocktail',
        description: 'The Champagne Cocktail is a classic drink made with champagne or sparkling wine as ' \
                     'the main ingredient with a splash of liqueur and/or fruit juice, or sugar and bitters.',
        execution: 'Add sugar cube to champagne flute. Saturate with bitters. Fill the glass with champagne. ' \
                   'Garnish with a lemon twist.',
        ingredients: ['1 Sugar Cube', '2 Dashes Angostura Bitters', '4 oz Champagne'],
        submitted_by_id: jamie.id, category_id: champagne_cocktail.id, image_path: 'Champagne_cocktail.jpg' },
      { name: 'Pousse Cafe',
        description: 'The Pousse Cafe is a layered drink made with liqueurs and syrups. The ingredients are ' \
                     'poured into a glass in order of their density.',
        execution: 'Pour ingredients into pousse glass in order of their density. Do not stir.',
        ingredients: ['0.5 oz Grenadine', '0.5 oz Green Chartreuse', '0.5 oz Yellow Chartreuse'],
        submitted_by_id: jack.id, category_id: pousse.id, image_path: 'Pousse-cafe.jpg' },
      { name: 'Mai Tai',
        description: 'The Mai Tai is a cocktail made with rum, lime juice, orgeat syrup, and orange ' \
                     'liqueur. It is served over ice in a rocks glass.',
        execution: 'Add all ingredients into shaker with ice and shake. Strain into rocks glass over fresh ' \
                   'ice. Garnish with a mint sprig.',
        ingredients: ['2 oz White Rum', '0.75 oz Lime Juice', '0.5 oz Orgeat Syrup', '0.5 oz Orange Liqueur'],
        submitted_by_id: jamie.id, category_id: tiki.id, image_path: 'MaiTai-Spruce.jpg' },
      { name: 'Cosmopolitan',
        description: 'The Cosmopolitan is a cocktail made with vodka, triple sec, cranberry juice, and ' \
                     'fresh lime juice. It is served in a cocktail glass.',
        execution: 'Add all ingredients into shaker with ice and shake. Strain into chilled cocktail glass. ' \
                   'Garnish with a lime wheel.',
        ingredients: ['1.5 oz Vodka', '0.5 oz Triple Sec', '0.5 oz Lime Juice', '1 oz Cranberry Juice'],
        submitted_by_id: doug.id, category_id: new_orleans_sour.id, image_path: 'cosmo.jpg' },
      { name: 'Corpse Reviver no.2',
        description: 'The Corpse Reviver no.2 is a cocktail made with gin, Cointreau, Lillet Blanc, and ' \
                     'absinthe. It is served in a cocktail glass.',
        execution: 'Add all ingredients into shaker with ice and shake. Strain into chilled cocktail glass. ' \
                   'Garnish with a lemon twist.',
        ingredients: ['1 oz Gin', '1 oz Cointreau', '1 oz Lillet Blanc', '1 oz Absinthe'],
        submitted_by_id: toggie.id, category_id: enhanced_sour.id, image_path: 'corpse_reviver.webp' },
      { name: 'Vesper Martini',
        description: 'The Vesper Martini is a cocktail made with gin, vodka, and Lillet Blanc. It is ' \
                     'served in a cocktail glass.',
        execution: 'Add all ingredients into mixing glass with ice and stir until well-chilled. Strain into ' \
                   'chilled cocktail glass. Garnish with a lemon twist.',
        ingredients: ['2 oz Gin', '1 oz Vodka', '0.5 oz Lillet Blanc'],
        submitted_by_id: jack.id, category_id: french_italian.id, image_path: 'lillet-vesper-martini.webp' },
      { name: 'Manhattan',
        description: 'The Manhattan is a cocktail made with rye whiskey, sweet vermouth, and bitters. It ' \
                     'is served in a cocktail glass.',
        execution: 'Add all ingredients into mixing glass with ice and stir until well-chilled. Strain into ' \
                   'chilled cocktail glass. Garnish with a cherry.',
        ingredients: ['2 oz Rye Whiskey', '1 oz Sweet Vermouth', '2 Dashes Angostura Bitters'],
        submitted_by_id: doug.id, category_id: french_italian.id, image_path: 'manhattan.jpg' },
      { name: 'French 75',
        description: 'The French 75 is a cocktail made with gin, lemon juice, sugar, and champagne. It is ' \
                     'served in a champagne flute.',
        execution: 'Add gin, lemon juice, and sugar into shaker with ice and shake. Strain into chilled ' \
                   'champagne flute. Top with champagne. Garnish with a lemon twist.',
        ingredients: ['2 oz Gin', '0.5 oz Lemon Juice', '0.5 oz Simple Syrup', '4 oz Champagne'],
        submitted_by_id: jamie.id, category_id: sparkling_sour.id, image_path: 'French-75-Sipsmith.jpg' },
      { name: 'Ramos Gin Fizz',
        description: 'The Ramos Gin Fizz is a cocktail made with gin, lemon juice, lime juice, sugar, ' \
                     'cream, egg white, orange flower water, and soda water. It is served in a highball ' \
                     'glass.',
        execution: 'Add all ingredients into shaker with ice and shake. Strain into highball glass without ' \
                   'ice. Top with soda water. Garnish with a lemon twist.',
        ingredients: ['2 oz Gin', '0.5 oz Lemon Juice', '0.5 oz Lime Juice', '1 oz Simple Syrup', '1 oz Cream',
                      '1 Egg White', '3 drops Orange Flower Water', '1 oz Soda Water'],
        submitted_by_id: toggie.id, category_id: sparkling_sour.id, image_path: 'Ramos-Gin-Fizz-Tonique.jpg' },
      { name: 'Airmail',
        description: 'The Airmail is a cocktail made with rum, lime juice, honey, and champagne. It is ' \
                     'served in a champagne flute.',
        execution: 'Add rum, lime juice, and honey into shaker with ice and shake. Strain into chilled ' \
                   'champagne flute. Top with champagne. Garnish with a lime wheel.',
        ingredients: ['2 oz White Rum', '0.75 oz Lime Juice', '0.5 oz Honey', '4 oz Champagne'],
        submitted_by_id: jack.id, category_id: sparkling_sour.id, image_path: 'Airmail.jpg' },
      { name: 'Mimosa',
        description: 'The Mimosa is a cocktail made with champagne and orange juice. It is served in a ' \
                     'champagne flute.',
        execution: 'Add orange juice into champagne flute. Top with champagne. Garnish with an orange twist.',
        ingredients: ['4 oz Champagne', '2 oz Orange Juice'],
        submitted_by_id: doug.id, category_id: champagne_cocktail.id, image_path: 'mimosa.jpg' },
      { name: 'Tequila Watermelon Jalapenos',
        description: 'The Tequila Watermelon Jalapenos is a cocktail made with tequila, watermelon juice, ' \
                     'lime juice, and jalapenos syrup. It is served in a highball glass.',
        execution: 'Add all ingredients into shaker with ice and shake. Strain into highball glass over ' \
                   'fresh ice. Garnish with a watermelon slice.',
        ingredients: ['2 oz Tequila', '3 oz Watermelon Juice', '0.5 oz Lime Juice', '0.5 oz jalapenos syrup'],
        submitted_by_id: toggie.id, category_id: simple_sour.id, image_path: 'Tequila-watermelon-punch.jpg' },
      { name: 'Peach Whiskey Smash',
        description: 'The Peach Whiskey Smash is a cocktail made with bourbon, peach, lemon juice, and ' \
                     'mint. It is served in a rocks glass.',
        execution: 'Add peach, lemon juice, and mint into shaker and muddle. Add bourbon and ice and shake. ' \
                   'Strain into rocks glass over fresh ice. Garnish with a mint sprig.',
        ingredients: ['2 oz Bourbon', '1 Peach', '0.5 oz Lemon Juice', '4 Mint Leaves'],
        submitted_by_id: jamie.id, category_id: juleps_and_smashes.id,
        image_path: 'grilled-peach-whiskey-smash.webp' },
      { name: 'Boston Flip',
        description: 'The Boston Flip is a cocktail made with rum, port, sugar, egg, and nutmeg. It is ' \
                     'served in a rocks glass.',
        execution: 'Add all ingredients into shaker without ice and shake. Add ice and shake again. Strain ' \
                   'into rocks glass. Garnish with nutmeg.',
        ingredients: ['2 oz Rum', '0.5 oz Port', '1 tsp Sugar', '1 Egg', '1 pinch Nutmeg'],
        submitted_by_id: jack.id, category_id: flips_and_nogs.id, image_path: 'boston-flip.jpeg' },
      { name: 'Brandy Flip',
        description: 'The Brandy Flip is a cocktail made with brandy, sugar, egg, and nutmeg. It is served ' \
                     'in a rocks glass.',
        execution: 'Add all ingredients into shaker without ice and shake. Add ice and shake again. Strain ' \
                   'into rocks glass. Garnish with nutmeg.',
        ingredients: ['2 oz Brandy', '1 tsp Sugar', '1 Egg', '1 pinch Nutmeg'],
        submitted_by_id: doug.id, category_id: flips_and_nogs.id, image_path: 'Brandy-Flip-2.jpg' },
      { name: 'Gin Punch',
        description: "The Gin Punch is a adapted recipe from Jerry Thomas's 1862 How to Mix Drinks or the " \
                     "Bon Vivant's Companion, originally a recipe for a single serving. It called for " \
                     'Holland gin—or genever, as we know it today—and was probably a very popular drink. ' \
                     'It was the precursor to the Tom Collins. This recipe is adapted from the original, ' \
                     "but it's still a very good punch. It's a little tart, a little sweet, and a little " \
                     "strong. It's a great drink for a party.",
        execution: 'Combine all the fruits in a large punch bowl. Add the gin, juice, syrups, crème de ' \
                   'framboise, and water. Refrigerate for at least 4 to 5 hours. Just before serving, add ' \
                   'the champagne and the decorative ice block',
        ingredients: ['1 (750 ml) bottle Plymouth gin', '1 3/4 cups freshly squeezed lemon juice',
                      '1 1/4 cups simple syrup', '1/2 cup orgeat or almond syrup', '1 cup crème de framboise',
                      '3 cups cold water', '1 (750 ml) bottle Perrier-Jouët Grand Brut champagne',
                      '1 decorative ice block'],
        submitted_by_id: toggie.id, category_id: punch.id, image_path: 'Gin-punch-epicurious.webp' },
      { name: 'B52',
        description: 'The B52 is a cocktail made with Kahlúa, Baileys Irish Cream, and Grand Marnier. It ' \
                     'is served in a shot glass.',
        execution: 'Layer ingredients into shot glass in order of their density. Do not stir.',
        ingredients: ['0.5 oz Kahlúa', '0.5 oz Baileys Irish Cream', '0.5 oz Grand Marnier'],
        submitted_by_id: jamie.id, category_id: pousse.id, image_path: 'B52-Shooter.jpg' },
      { name: 'Dark and Stormy',
        description: 'The Dark and Stormy is a cocktail made with dark rum and ginger beer. It is served ' \
                     'in a highball glass.',
        execution: 'Add rum and lime juice into highball glass filled with ice. SHort shake. Top with ' \
                   'ginger beer. Garnish with a lime wedge.',
        ingredients: ['2 oz Dark Rum', '0.5 oz lime juice', '3 oz Ginger Beer'],
        submitted_by_id: jack.id, category_id: highball.id, image_path: 'DarkNStormy.png' },
      { name: 'Whiskey Highball',
        description: 'The Whiskey Highball is a cocktail made with whiskey and soda water. It is served ' \
                     'in a highball glass.',
        execution: 'Add whiskey into highball glass filled with ice. Top with soda water. Garnish with a ' \
                   'lemon twist.',
        ingredients: ['2 oz Whiskey', '4 oz Soda Water'],
        submitted_by_id: doug.id, category_id: highball.id, image_path: 'Toki-highball.jpg' },
      { name: 'Hot Buttered Rum',
        description: 'The Hot Buttered Rum is a cocktail made with rum, butter, sugar, and spices. It is ' \
                     'served in a mug.',
        execution: 'Add rum, butter, sugar, and spices into mug. Fill with hot water. Stir gently.',
        ingredients: ['2 oz Rum', '1 tbsp Butter', '1 tbsp Sugar', '1 pinch Cinnamon', '1 pinch Nutmeg'],
        submitted_by_id: jamie.id, category_id: toddy.id, image_path: 'Hot-buttered-rum.jpg' },
      { name: 'Irish Coffee',
        description: 'The Irish Coffee is a cocktail made with Irish whiskey, coffee, sugar, and cream. It ' \
                     'is served in a mug.',
        execution: 'Add whiskey, coffee, and sugar into mug. Fill with hot water. Stir gently. Float cream ' \
                   'on top.',
        ingredients: ['2 oz Irish Whiskey', '1 cup Coffee', '1 tbsp Sugar', '1 tbsp Cream'],
        submitted_by_id: toggie.id, category_id: toddy.id, image_path: 'irish-coffee.jpg' },
      { name: 'Jack Rose',
        description: 'The Jack Rose is a cocktail made with applejack, grenadine, and lime juice. It is ' \
                     'served in a cocktail glass.',
        execution: 'Add all ingredients into shaker with ice and shake. Strain into chilled cocktail glass. ' \
                   'Garnish with a lime wheel.',
        ingredients: ['2 oz Applejack', '0.5 oz Grenadine', '0.5 oz Lime Juice'],
        submitted_by_id: jamie.id, category_id: new_orleans_sour.id,
        image_path: 'Calvados-Jack-Rose-Cocktail-2.jpg' },
      { name: 'Hemingway Daiquiri',
        description: 'The Hemingway Daiquiri is a cocktail made with rum, lime juice, grapefruit juice, ' \
                     'and maraschino liqueur. It is served in a cocktail glass.',
        execution: 'Add all ingredients into shaker with ice and shake. Strain into chilled cocktail glass. ' \
                   'Garnish with a lime wheel.',
        ingredients: ['2 oz White Rum', '0.75 oz Lime Juice', '0.5 oz Grapefruit Juice',
                      '0.5 oz Maraschino Liqueur'],
        submitted_by_id: toggie.id, category_id: international_sour.id, image_path: 'hemingway_daiquiri.jpeg' },
      { name: 'Bronx Cocktail',
        description: 'The Bronx Cocktail is a cocktail made with gin, sweet vermouth, dry vermouth, and ' \
                     'orange juice. It is served in a cocktail glass.',
        execution: 'Add all ingredients into shaker with ice and shake. Strain into chilled cocktail glass. ' \
                   'Garnish with an orange twist.',
        ingredients: ['2 oz Gin', '0.5 oz Sweet Vermouth', '0.5 oz Dry Vermouth', '0.5 oz Orange Juice'],
        submitted_by_id: doug.id, category_id: french_italian.id, image_path: 'bronx_cocktail.jpg' },
      { name: 'Godfather',
        description: 'The Godfather is a cocktail made with scotch and amaretto. It is served in a rocks ' \
                     'glass.',
        execution: 'Add all ingredients into rocks glass filled with ice. Stir gently.',
        ingredients: ['2 oz Scotch', '1 oz Amaretto'],
        submitted_by_id: jack.id, category_id: duos_and_trios.id, image_path: 'godfather-cocktail.jpg' }
    ]

    cocktail_data.each do |data|
      cocktail = Cocktail.create(data.except(:image_path))
      file_path = Rails.public_path.join('photos', 'cocktails', data[:image_path])
      content_type = MIME::Types.type_for(file_path.to_s).first.content_type
      cocktail.image.attach(io: File.open(file_path), filename: data[:image_path], content_type:)
    end

    puts '🍸🗾🧉✨SAMPLE DATA RESET 🧚‍♀️🍹🍾🏝'
  end
end
