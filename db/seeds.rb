# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

Follow.all.destroy_all
Follow.all.reset_pk_sequence
Like.all.destroy_all
Like.all.reset_pk_sequence
Cocktail.all.destroy_all
Cocktail.all.reset_pk_sequence
User.all.destroy_all
User.all.reset_pk_sequence
Category.all.destroy_all
Category.all.reset_pk_sequence
Bar.all.destroy_all
Bar.all.reset_pk_sequence

ancestral = Category.create(name: 'Ancestral',
                            definition: 'Composed of a base spirit lightly adorned with sugar (in Improved versions, the sweetener appears in the form of a dash or two of liqueur such as maraschino or curacao), bitters, and water (usually in its frozen form), and served either straight up or on the rocks.', popular_drinks: [{ name: 'Old Fashioned', image: "#{ENV['HOST_URL']}/photos/cocktails/old-fashioned.jpg" }, { name: 'Sazerac', image: "#{ENV['HOST_URL']}/photos/cocktails/sazerac-768x768.jpg" }])

duos_and_trios = Category.create(name: 'Duos and Trios',
                                 definition: 'Duos are composed of two ingredients, usually a base spirit and a liqueur, and are normally served in an old-fashioned glass. Trios are duos to which cream or a cream liqueur has been added. Not all duos can be made into trios. Not all trios start out as duos', popular_drinks: [{ name: 'Godfather', image: "#{ENV['HOST_URL']}/photos/cocktails/godfather-cocktail.jpg" }, { name: 'White Russian', image: "#{ENV['HOST_URL']}/photos/cocktails/white_russian.jpg" }])

french_italian = Category.create(name: 'French Italian',
                                 definition: 'Composed of a base spirit with a modifier of vermouth, or another fortified wine such as sherry, quinquina, or port, often accompanied by other ingredients such as bitters or small doses of liqueurs or syrups.', popular_drinks: [{ name: 'Vesper Martini', image: "#{ENV['HOST_URL']}/photos/cocktails/lillet-vesper-martini.webp" }, { name: 'Negroni', image: "#{ENV['HOST_URL']}/photos/cocktails/negroni.jpg" }, { name: 'Manhattan', image: "#{ENV['HOST_URL']}/photos/cocktails/manhattan.jpg" }])

simple_sour = Category.create(name: 'Simple Sour',
                              definition: 'Contain a base spirit, citrus juice and a non-alcoholic sweetening agent such as simple syrup, grenadine or orgeat syrup (sometimes egg white is added for body and foam)', popular_drinks: [{ name: 'Daiquiri', image: "#{ENV['HOST_URL']}/photos/cocktails/daiquiri.webp" }, { name: 'Jack Rose', image: "#{ENV['HOST_URL']}/photos/cocktails/Calvados-Jack-Rose-Cocktail-2.jpg" }, { name: 'Whiskey Sour', image: "#{ENV['HOST_URL']}/photos/cocktails/whiskey_sour.jpg" }])

enhanced_sour = Category.create(name: 'Enhanced Sour',
                                definition: 'Calls for a spirit, citrus juice, a sweetening agent of any kind , plus vermouth or any other aromatized or fortified wine', popular_drinks: [{ name: 'Clover Club', image: "#{ENV['HOST_URL']}/photos/cocktails/Clover-club-cocktail-5.jpg" }, { name: 'Bronx Cocktail', image: "#{ENV['HOST_URL']}/photos/cocktails/bronx_cocktail.jpg" }, { name: 'Ruby', image: "#{ENV['HOST_URL']}/photos/cocktails/Ruby_cocktail.jpg" }])

new_orleans_sour = Category.create(name: 'New Orleans Sour',
                                   definition: 'Calls for a base spirit, citrus juice, and an orange-flavored liqueur', popular_drinks: [{ name: 'Cosmopolitan', image: "#{ENV['HOST_URL']}/photos/cocktails/cosmo.jpg" }, { name: 'Margarita', image: "#{ENV['HOST_URL']}/photos/cocktails/Margarita.jpg" }, { name: 'Corpse Reviver no.2', image: "#{ENV['HOST_URL']}/photos/cocktails/corpse_reviver.webp" }])

international_sour = Category.create(name: 'International Sour',
                                     definition: 'Contains a spirit, citrus juice and a liqueur as sweetening agent', popular_drinks: [{ name: 'Hemingway Daiquiri', image: "#{ENV['HOST_URL']}/photos/cocktails/hemingway_daiquiri.jpeg" }, { name: 'Aviation', image: "#{ENV['HOST_URL']}/photos/cocktails/aviation.jpg" }, { name: 'Gun Metal Blue', image: "#{ENV['HOST_URL']}/photos/cocktails/gunmetal_blue.jpg" }])

sparkling_sour = Category.create(name: 'Sparkling Sour',
                                 definition: 'Contains a spirit, citrus juice, a sweetening agent of any kind and some bubbles either non-alcoholic or alcoholic', popular_drinks: [{ name: 'French 75', image: "#{ENV['HOST_URL']}/photos/cocktails/French-75-Sipsmith.jpg" }, { name: 'Ramos Gin Fizz', image: "#{ENV['HOST_URL']}/photos/cocktails/Ramos-Gin-Fizz-Tonique.jpg" }, { name: 'Airmail', image: "#{ENV['HOST_URL']}/photos/cocktails/Airmail.jpg" }])

champagne_cocktail = Category.create(name: 'Champagne Cocktail',
                                     definition: 'Made with champagne or sparkling wine as the main ingredient with a splash of liqueur and/or fruit juice, or sugar and bitters', popular_drinks: [{ name: 'Champagne cocktail', image: "#{ENV['HOST_URL']}/photos/cocktails/Champagne_cocktail.jpg" }, { name: 'Mimosa', image: "#{ENV['HOST_URL']}/photos/cocktails/mimosa.jpg" }])

frozen = Category.create(name: 'Frozen',
                         definition: 'Cocktails that are blended with ice, perfect for hot summer days', popular_drinks: [{ name: 'Frozen pina colada', image: "#{ENV['HOST_URL']}/photos/cocktails/Frozen-pina-colada.jpg" }, { name: 'Frozen Strawberry Daiquiri', image: "#{ENV['HOST_URL']}/photos/cocktails/Frozen-Strawberry-Daiquiri.webp" }])

highball = Category.create(name: 'Highball',
                           definition: 'Made with a base spirit leavened with ice and a lengthener such as club soda, ginger ale or cola', popular_drinks: [{ name: 'Cuba Libre', image: "#{ENV['HOST_URL']}/photos/cocktails/Cuba-libre.jpg" }, { name: 'Dark and Stormy', image: "#{ENV['HOST_URL']}/photos/cocktails/DarkNStormy.png" }, { name: 'Whiskey Highball', image: "#{ENV['HOST_URL']}/photos/cocktails/Toki-highball.jpg" }])

toddy = Category.create(name: 'Toddy',
                        definition: 'Old-fashioned style of cocktail with distilled spirit, sweetener and hot water, and other spices', popular_drinks: [{ name: 'Hot Toddy', image: "#{ENV['HOST_URL']}/photos/cocktails/RP-Hot-toddy.jpg" }, { name: 'Hot Buttered Rum', image: "#{ENV['HOST_URL']}/photos/cocktails/Hot-buttered-rum.jpg" }, { name: 'Irish Coffee', image: "#{ENV['HOST_URL']}/photos/cocktails/irish-coffee.jpg" }])

flips_and_nogs = Category.create(name: 'Flips and Nogs',
                                 definition: 'Made with whole eggs, base spirits, cream and/or milk, sweetening agents such as maple syrup or sugar', popular_drinks: [{ name: 'Boston Flip', image: "#{ENV['HOST_URL']}/photos/cocktails/boston-flip.jpeg" }, { name: 'Brandy Flip', image: "#{ENV['HOST_URL']}/photos/cocktails/Brandy-Flip-2.jpg" }])

juleps_and_smashes = Category.create(name: 'Juleps and Smashes',
                                     definition: 'Made of a base spirit, fresh mint, sugar, sometimes with fruits in case of smashes, and a lot of ice', popular_drinks: [{ name: 'Mint Julep', image: "#{ENV['HOST_URL']}/photos/cocktails/Mint_Julep.jpg" }, { name: 'Peach Whiskey Smash', image: "#{ENV['HOST_URL']}/photos/cocktails/grilled-peach-whiskey-smash.webp" }])

punch = Category.create(name: 'Punch',
                        definition: 'Refers to a variety of festive drinks, non-alcoholic or alcoholic, generally containing fruits and fruit juices, spirits and liqueurs if alcoholic, and often topped with sparkling wine or soda. It is usually served at parties in large, wide bowls, known as punch bowls.', popular_drinks: [{ name: 'Gin Punch', image: "#{ENV['HOST_URL']}/photos/cocktails/Gin-punch-epicurious.webp" }, { name: 'Tequila Watermelon Punch', image: "#{ENV['HOST_URL']}/photos/cocktails/Tequila-watermelon-punch.jpg" }])

pousse = Category.create(name: 'Pousse',
                         definition: 'Elaborately composed concoctions made of liqueurs and syrups, layered for a distinctive appearance', popular_drinks: [{ name: 'Pousse Cafe', image: "#{ENV['HOST_URL']}/photos/cocktails/Pousse-cafe.jpg" }, { name: 'B-52', image: "#{ENV['HOST_URL']}/photos/cocktails/B52-Shooter.jpg" }])

tiki = Category.create(name: 'Tiki',
                       definition: 'Single-serving punch-style drinks featuring a base spirit(s), fruit juice and syrups or liqueurs, often deployed in various combinations.', popular_drinks: [{ name: 'Mai Tai', image: "#{ENV['HOST_URL']}/photos/cocktails/MaiTai-Spruce.jpg" }, { name: 'Luau Daiquiri', image: "#{ENV['HOST_URL']}/photos/cocktails/Luau-daiquiri-latitude29.jpg" }, { name: 'Zombie', image: "#{ENV['HOST_URL']}/photos/cocktails/Zombie-Original.jpg" }])

snapper = Category.create(name: 'Snapper',
                          definition: 'Made with a base spirit, tomato juice and a variety of garnishes', popular_drinks: [{ name: 'Bloody Mary', image: "#{ENV['HOST_URL']}/photos/cocktails/bloody-mary.webp" }, { name: 'Red Snapper', image: "#{ENV['HOST_URL']}/photos/cocktails/red-snapper.jpg" }])

Category.create(name: 'Orphan',
                definition: 'Does not fit in any cocktail family, or you are just a renegade. Subjected to be moved to a more appropriate category.', popular_drinks: [{ name: 'Renegade', image: "#{ENV['HOST_URL']}/photos/cocktails/QuestionCocktail.jpg" }])

jamie = User.create(full_name: 'Jamie Pham', username: 'ninjacat', password: '123', location: 'Brooklyn, NY',
                    bartender: true)
toggie = User.create(full_name: 'Toggie Pham', username: 'puglife', password: '123', location: 'Heaven, SK',
                     bartender: true)
jack = User.create(full_name: 'Jack Rose', username: 'jackrose', password: '123', location: 'Queens, NY',
                   bartender: true)
doug = User.create(full_name: 'Douglas Fairbanks', username: 'fairbanks', password: '123', location: 'New York, NY',
                   bartender: true)
User.create(full_name: 'Mia Wallace', username: 'mrswallace', password: '123', location: 'New York, NY',
            bartender: false)

cocktail_data = [
  {
    name: 'Margarita',
    description: 'The Margarita is one of the most popular cocktails in North America—for good reason. Combining the tang of lime and the sweetness of orange liqueur with the distinctive strength of tequila, our classic Margarita strikes all of the right keys.',
    execution: 'Add all ingredients into a shaker with ice and shake. Strain into a rocks glass over fresh ice. Garnish with a lime wheel.',
    ingredients: ['2 oz Tequila', '1 oz Lime Juice', '0.75 oz Orange Liqueur'],
    bartender_id: jamie.id,
    category_id: new_orleans_sour.id,
    image_path: 'Margarita.jpg'
  },
  {
    name: 'Jungle Bird',
    description: 'The Jungle Bird is a modern classic tiki cocktail that was created in 1978 at the Aviary Bar in Kuala Lumpur, Malaysia. Its a tropical, tiki cocktail thats a little bitter, a little sweet, and a little strong.',
    execution: 'Add all ingredients into a shaker with ice and shake. Strain into a rocks glass over fresh ice. Garnish with a lime wheel.',
    ingredients: ['1.5 oz Dark Rum', '0.75 oz Campari', '0.5 oz Lime Juice', '0.5 oz Simple Syrup',
                  '1.5 oz Pineapple Juice'],
    bartender_id: toggie.id,
    category_id: tiki.id,
    image_path: 'Jungle-Bird.jpg'
  },
  {
    name: 'Brooklyn',
    description: "The Brooklyn cocktail is a classic drink made with rye whiskey, dry vermouth, maraschino liqueur, and Amer Picon. It's a boozy, spirit-forward cocktail that's easy to make and a great alternative to a Manhattan.",
    execution: 'Add all ingredients into a mixing glass with ice and stir until well-chilled. Strain into a chilled cocktail glass. Garnish with a cherry.',
    ingredients: ['2 oz Rye Whiskey', '0.75 oz Dry Vermouth', '0.25 oz Maraschino Liqueur', '0.25 oz Amer Picon'],
    bartender_id: jack.id,
    category_id: french_italian.id,
    image_path: 'Brooklyn.jpg'
  },
  {
    name: 'Old Fashioned',
    description: 'The Old Fashioned is a cocktail made by muddling sugar with bitters and water, adding whiskey or, less commonly, brandy, and garnishing with orange slice or zest and a cocktail cherry. It is traditionally served in an old fashioned glass, which predated the cocktail.',
    execution: 'Add sugar cube to old fashioned glass and saturate with bitters, add a dash of plain water. Muddle until dissolved. Fill the glass with ice cubes and add whiskey. Garnish with orange twist, and a cocktail cherry.',
    ingredients: ['2 oz Bourbon or Rye Whiskey', '1 Sugar Cube', '2 Dashes Angostura Bitters',
                  '1 Dash Plain Water'],
    bartender_id: doug.id,
    category_id: ancestral.id,
    image_path: 'old-fashioned.jpg'
  },
  {
    name: 'Daiquiri',
    description: 'The Daiquiri is a classic rum cocktail that is simple, refreshing and timeless. The balance of sweet, sour and spirit is perfectly balanced and the drink can be easily modified to suit your taste.',
    execution: 'Add all ingredients into a shaker with ice and shake. Strain into a chilled cocktail glass, garnish with a lime wheel.',
    ingredients: ['2 oz choiced Rum', '0.75 oz Lime Juice', '0.75 oz Simple Syrup'],
    bartender_id: jamie.id,
    category_id: simple_sour.id,
    image_path: 'daiquiri.webp'
  },
  {
    name: 'Negroni',
    description: 'The Negroni is a popular Italian cocktail, made of one part gin, one part vermouth rosso, and one part Campari, garnished with orange peel. It is considered an apéritif.',
    execution: 'Add all ingredients into mixing glass with ice and stir until well-chilled. Strain into chilled cocktail glass. Garnish with an orange peel.',
    ingredients: ['1 oz Gin', '1 oz Campari', '1 oz Sweet Vermouth'],
    bartender_id: jamie.id,
    category_id: french_italian.id,
    image_path: 'negroni.jpg'
  },
  {
    name: 'Whiskey Sour',
    description: 'The whiskey sour is a mixed drink containing whiskey, lemon juice and simple syrup. It is shaken and served either straight or over ice. The traditional garnish is half an orange slice and a maraschino cherry.',
    execution: 'Add all ingredients into a shaker with ice and shake. Strain into a rocks glass over fresh ice. Garnish with a cherry and an orange slice.',
    ingredients: ['2 oz Bourbon Whiskey', '0.75 oz Lemon Juice', '0.75 oz Simple Syrup'],
    bartender_id: jack.id,
    category_id: simple_sour.id,
    image_path: 'whiskey_sour.jpg'
  },
  {
    name: 'Clover Club',
    description: 'The Clover Club is a cocktail consisting of gin, lemon juice, raspberry syrup, and an egg white. It is traditionally served in a cocktail glass, but may also be served in a Collins glass or an Old Fashioned glass without ice.',
    execution: 'Add all ingredients into a shaker with ice and shake. Strain into a chilled cocktail glass. Garnish with a raspberry.',
    ingredients: ['2 oz Gin', '0.75 oz Lemon Juice', '0.75 oz Raspberry Syrup', '1 Egg White'],
    bartender_id: toggie.id,
    category_id: simple_sour.id,
    image_path: 'Clover-club-cocktail-5.jpg'
  },
  {
    name: 'White Russian',
    description: 'The White Russian is a cocktail made with vodka, coffee liqueur and cream served with ice in an old fashioned glass. Often milk will be used as an alternative to cream.',
    execution: 'Add all ingredients into old fashioned glass filled with ice. Stir gently.',
    ingredients: ['2 oz Vodka', '1 oz Coffee Liqueur', '1 oz Fresh Cream'],
    bartender_id: doug.id,
    category_id: duos_and_trios.id,
    image_path: 'white_russian.jpg'
  },
  {
    name: 'Aviation',
    description: 'The Aviation is a classic cocktail made with gin, maraschino liqueur, crème de violette, and lemon juice. Some recipes omit the crème de violette. It is served straight up, in a cocktail glass.',
    execution: 'Add all ingredients into a shaker with ice and shake. Strain into a chilled cocktail glass. Garnish with a cherry.',
    ingredients: ['2 oz Gin', '0.5 oz Maraschino Liqueur', '0.5 oz Crème de Violette', '0.75 oz Lemon Juice'],
    bartender_id: jamie.id,
    category_id: international_sour.id,
    image_path: 'aviation.jpg'
  },
  {
    name: 'Gun Metal Blue',
    description: 'The Gun Metal Blue is a cocktail made with gin, blue curaçao, lemon juice, and simple syrup. It is served straight up, in a cocktail glass.',
    execution: 'Add all ingredients into a shaker with ice and shake. Strain into a chilled cocktail glass. Garnish with a lemon twist.',
    ingredients: ['2 oz Gin', '0.5 oz Blue Curaçao', '0.75 oz Lemon Juice', '0.75 oz Simple Syrup'],
    bartender_id: toggie.id,
    category_id: new_orleans_sour.id,
    image_path: 'gunmetal_blue.jpg'
  },
  {
    name: 'Blood Mary',
    description: 'The Bloody Mary is a cocktail containing vodka, tomato juice, and other spices and flavorings including Worcestershire sauce, hot sauces, garlic, herbs, horseradish, celery, olives, salt, black pepper, lemon juice, lime juice and celery salt.',
    execution: 'Add all ingredients into highball glass filled with ice. Stir gently. Garnish with celery stalk and lemon wedge.',
    ingredients: ['1.5 oz Vodka', '3 oz Tomato Juice', '0.5 oz Lemon Juice', '1 dash Worcestershire Sauce',
                  '1 dash Tabasco Sauce', '1 pinch Celery Salt', '1 pinch Black Pepper'],
    bartender_id: jack.id,
    category_id: snapper.id,
    image_path: 'bloody-mary.webp'
  },
  {
    name: 'Frozen Pina Colada',
    description: 'The Piña Colada is a sweet cocktail made with rum, coconut cream or coconut milk, and pineapple juice, usually served either blended or shaken with ice.',
    execution: 'Add all ingredients into blender with ice and blend until smooth. Pour into a chilled hurricane glass. Garnish with a pineapple wedge and a cherry.',
    ingredients: ['2 oz White Rum', '3 oz Pineapple Juice', '1 oz Coconut Cream', '1 cup of ice'],
    bartender_id: doug.id,
    category_id: frozen.id,
    image_path: 'Frozen-pina-colada.jpg'
  },
  {
    name: 'Cuba Libre',
    description: 'The Cuba Libre is a highball cocktail consisting of cola, lime, and light rum. This cocktail is often referred to as a Rum and Coke in many countries.',
    execution: "Add all ingredients into highball glass filled with
        ice. Stir gently. Garnish with a lime wedge.",
    ingredients: ['2 oz White Rum', '4 oz Cola', '0.5 oz Lime Juice'],
    bartender_id: jack.id,
    category_id: highball.id,
    image_path: 'Cuba-libre.jpg'
  },
  {
    name: 'Hot Toddy',
    description: 'The hot toddy is a mixed drink made of liquor and water with honey, herbs (such as tea) and spices, and served hot. Hot toddy recipes vary and are traditionally drunk before going to bed or in cold weather.',
    execution: 'Add all ingredients into mug. Stir gently. Garnish with a lemon wedge.',
    ingredients: ['2 oz Whiskey', '1 tbsp Honey', '1 Lemon Wedge', '1 cup Hot Water'],
    bartender_id: doug.id,
    category_id: toddy.id,
    image_path: 'RP-Hot-toddy.jpg'
  },
  {
    name: 'Mint Julep',
    description: 'The mint julep is a mixed alcoholic drink, or cocktail, consisting primarily of bourbon, sugar, water, crushed or shaved ice, and fresh mint. As a bourbon-based cocktail, it is associated with the American South and the cuisine of the Southern United States in general, and the Kentucky Derby in particular.',
    execution: 'Add mint leaves and simple syrup into julep cup. Muddle gently. Fill the cup with crushed ice and add bourbon. Stir gently. Garnish with a mint sprig.',
    ingredients: ['2 oz Bourbon', '1 tbsp Simple Syrup', '8 Mint Leaves'],
    bartender_id: toggie.id,
    category_id: juleps_and_smashes.id,
    image_path: 'Mint_Julep.jpg'
  },
  {
    name: 'Champagne Cocktail',
    description: 'The Champagne Cocktail is a classic drink made with champagne or sparkling wine as the main ingredient with a splash of liqueur and/or fruit juice, or sugar and bitters.',
    execution: 'Add sugar cube to champagne flute. Saturate with bitters. Fill the glass with champagne. Garnish with a lemon twist.',
    ingredients: ['1 Sugar Cube', '2 Dashes Angostura Bitters', '4 oz Champagne'],
    bartender_id: jamie.id,
    category_id: champagne_cocktail.id,
    image_path: 'Champagne_cocktail.jpg'
  },
  {
    name: 'Pousse Cafe',
    description: 'The Pousse Cafe is a layered drink made with liqueurs and syrups. The ingredients are poured into a glass in order of their density.',
    execution: 'Pour ingredients into pousse glass in order of their density. Do not stir.',
    ingredients: ['0.5 oz Grenadine', '0.5 oz Green Chartreuse', '0.5 oz Yellow Chartreuse'],
    bartender_id: jack.id,
    category_id: pousse.id,
    image_path: 'Pousse-cafe.jpg'
  },
  {
    name: 'Mai Tai',
    description: 'The Mai Tai is a cocktail made with rum, lime juice, orgeat syrup, and orange liqueur. It is served over ice in a rocks glass.',
    execution: 'Add all ingredients into shaker with ice and shake. Strain into rocks glass over fresh ice. Garnish with a mint sprig.',
    ingredients: ['2 oz White Rum', '0.75 oz Lime Juice', '0.5 oz Orgeat Syrup', '0.5 oz Orange Liqueur'],
    bartender_id: jamie.id,
    category_id: tiki.id,
    image_path: 'MaiTai-Spruce.jpg'
  },
  {
    name: 'Cosmopolitan',
    description: 'The Cosmopolitan is a cocktail made with vodka, triple sec, cranberry juice, and fresh lime juice. It is served in a cocktail glass.',
    execution: 'Add all ingredients into shaker with ice and shake. Strain into chilled cocktail glass. Garnish with a lime wheel.',
    ingredients: ['1.5 oz Vodka', '0.5 oz Triple Sec', '0.5 oz Lime Juice', '1 oz Cranberry Juice'],
    bartender_id: doug.id,
    category_id: new_orleans_sour.id,
    image_path: 'cosmo.jpg'
  },
  {
    name: 'Corpse Reviver no.2',
    description: 'The Corpse Reviver no.2 is a cocktail made with gin, Cointreau, Lillet Blanc, and absinthe. It is served in a cocktail glass.',
    execution: 'Add all ingredients into shaker with ice and shake. Strain into chilled cocktail glass. Garnish with a lemon twist.',
    ingredients: ['1 oz Gin', '1 oz Cointreau', '1 oz Lillet Blanc', '1 oz Absinthe'],
    bartender_id: toggie.id,
    category_id: enhanced_sour.id,
    image_path: 'corpse_reviver.webp'
  },
  {
    name: 'Vesper Martini',
    description: 'The Vesper Martini is a cocktail made with gin, vodka, and Lillet Blanc. It is served in a cocktail glass.',
    execution: 'Add all ingredients into mixing glass with ice and stir until well-chilled. Strain into chilled cocktail glass. Garnish with a lemon twist.',
    ingredients: ['2 oz Gin', '1 oz Vodka', '0.5 oz Lillet Blanc'],
    bartender_id: jack.id,
    category_id: french_italian.id,
    image_path: 'lillet-vesper-martini.webp'
  },
  {
    name: 'Manhattan',
    description: 'The Manhattan is a cocktail made with rye whiskey, sweet vermouth, and bitters. It is served in a cocktail glass.',
    execution: 'Add all ingredients into mixing glass with ice and stir until well-chilled. Strain into chilled cocktail glass. Garnish with a cherry.',
    ingredients: ['2 oz Rye Whiskey', '1 oz Sweet Vermouth', '2 Dashes Angostura Bitters'],
    bartender_id: doug.id,
    category_id: french_italian.id,
    image_path: 'manhattan.jpg'
  },
  {
    name: 'French 75',
    description: 'The French 75 is a cocktail made with gin, lemon juice, sugar, and champagne. It is served in a champagne flute.',
    execution: 'Add gin, lemon juice, and sugar into shaker with ice and shake. Strain into chilled champagne flute. Top with champagne. Garnish with a lemon twist.',
    ingredients: ['2 oz Gin', '0.5 oz Lemon Juice', '0.5 oz Simple Syrup', '4 oz Champagne'],
    bartender_id: jamie.id,
    category_id: sparkling_sour.id,
    image_path: 'French-75-Sipsmith.jpg'
  },
  {
    name: 'Ramos Gin Fizz',
    description: 'The Ramos Gin Fizz is a cocktail made with gin, lemon juice, lime juice, sugar, cream, egg white, orange flower water, and soda water. It is served in a highball glass.',
    execution: 'Add all ingredients into shaker with ice and shake. Strain into highball glass without ice. Top with soda water. Garnish with a lemon twist.',
    ingredients: ['2 oz Gin', '0.5 oz Lemon Juice', '0.5 oz Lime Juice', '1 oz Simple Syrup', '1 oz Cream',
                  '1 Egg White', '3 drops Orange Flower Water', '1 oz Soda Water'],
    bartender_id: toggie.id,
    category_id: sparkling_sour.id,
    image_path: 'Ramos-Gin-Fizz-Tonique.jpg'
  },
  {
    name: 'Airmail',
    description: 'The Airmail is a cocktail made with rum, lime juice, honey, and champagne. It is served in a champagne flute.',
    execution: 'Add rum, lime juice, and honey into shaker with ice and shake. Strain into chilled champagne flute. Top with champagne. Garnish with a lime wheel.',
    ingredients: ['2 oz White Rum', '0.75 oz Lime Juice', '0.5 oz Honey', '4 oz Champagne'],
    bartender_id: jack.id,
    category_id: sparkling_sour.id,
    image_path: 'Airmail.jpg'
  },
  {
    name: 'Mimosa',
    description: 'The Mimosa is a cocktail made with champagne and orange juice. It is served in a champagne flute.',
    execution: 'Add orange juice into champagne flute. Top with champagne. Garnish with an orange twist.',
    ingredients: ['4 oz Champagne', '2 oz Orange Juice'],
    bartender_id: doug.id,
    category_id: champagne_cocktail.id,
    image_path: 'mimosa.jpg'
  },
  {
    name: 'Tequila Watermelon Jalapenos',
    description: 'The Tequila Watermelon Jalapenos is a cocktail made with tequila, watermelon juice, lime juice, and jalapenos syrup. It is served in a highball glass.',
    execution: 'Add all ingredients into shaker with ice and shake. Strain into highball glass over fresh ice. Garnish with a watermelon slice.',
    ingredients: ['2 oz Tequila', '3 oz Watermelon Juice', '0.5 oz Lime Juice', '0.5 oz jalapenos syrup'],
    bartender_id: toggie.id,
    category_id: simple_sour.id,
    image_path: 'Tequila-watermelon-punch.jpg'
  },
  {
    name: 'Peach Whiskey Smash',
    description: 'The Peach Whiskey Smash is a cocktail made with bourbon, peach, lemon juice, and mint. It is served in a rocks glass.',
    execution: 'Add peach, lemon juice, and mint into shaker and muddle. Add bourbon and ice and shake. Strain into rocks glass over fresh ice. Garnish with a mint sprig.',
    ingredients: ['2 oz Bourbon', '1 Peach', '0.5 oz Lemon Juice', '4 Mint Leaves'],
    bartender_id: jamie.id,
    category_id: juleps_and_smashes.id,
    image_path: 'grilled-peach-whiskey-smash.webp'
  },
  {
    name: 'Boston Flip',
    description: 'The Boston Flip is a cocktail made with rum, port, sugar, egg, and nutmeg. It is served in a rocks glass.',
    execution: 'Add all ingredients into shaker without ice and shake. Add ice and shake again. Strain into rocks glass. Garnish with nutmeg.',
    ingredients: ['2 oz Rum', '0.5 oz Port', '1 tsp Sugar', '1 Egg', '1 pinch Nutmeg'],
    bartender_id: jack.id,
    category_id: flips_and_nogs.id,
    image_path: 'boston-flip.jpeg'
  },
  {
    name: 'Brandy Flip',
    description: 'The Brandy Flip is a cocktail made with brandy, sugar, egg, and nutmeg. It is served in a rocks glass.',
    execution: 'Add all ingredients into shaker without ice and shake. Add ice and shake again. Strain into rocks glass. Garnish with nutmeg.',
    ingredients: ['2 oz Brandy', '1 tsp Sugar', '1 Egg', '1 pinch Nutmeg'],
    bartender_id: doug.id,
    category_id: flips_and_nogs.id,
    image_path: 'Brandy-Flip-2.jpg'
  },
  {
    name: 'Gin Punch',
    description: "The Gin Punch is a adapted recipe from Jerry Thomas's 1862 How to Mix Drinks or the Bon Vivant's Companion, originally a recipe for a single serving. It called for Holland gin—or genever, as we know it today—and was probably a very popular drink. It was the precursor to the Tom Collins. This recipe is adapted from the original, but it's still a very good punch. It's a little tart, a little sweet, and a little strong. It's a great drink for a party.",
    execution: 'Combine all the fruits in a large punch bowl. Add the gin, juice, syrups, crème de framboise, and water. Refrigerate for at least 4 to 5 hours. Just before serving, add the champagne and the decorative ice block',
    ingredients: ['1 (750 ml) bottle Plymouth gin', '1 3/4 cups freshly squeezed lemon juice',
                  '1 1/4 cups simple syrup', '1/2 cup orgeat or almond syrup', '1 cup crème de framboise', '3 cups cold water', '1 (750 ml) bottle Perrier-Jouët Grand Brut champagne', '1 decorative ice block'],
    bartender_id: toggie.id,
    category_id: punch.id,
    image_path: 'Gin-punch-epicurious.webp'
  },
  {
    name: 'B52',
    description: 'The B52 is a cocktail made with Kahlúa, Baileys Irish Cream, and Grand Marnier. It is served in a shot glass.',
    execution: 'Layer ingredients into shot glass in order of their density. Do not stir.',
    ingredients: ['0.5 oz Kahlúa', '0.5 oz Baileys Irish Cream', '0.5 oz Grand Marnier'],
    bartender_id: jamie.id,
    category_id: pousse.id,
    image_path: 'B52-Shooter.jpg'
  },
  {
    name: 'Dark and Stormy',
    description: 'The Dark and Stormy is a cocktail made with dark rum and ginger beer. It is served in a highball glass.',
    execution: 'Add rum and lime juice into highball glass filled with ice. SHort shake. Top with ginger beer. Garnish with a lime wedge.',
    ingredients: ['2 oz Dark Rum', '0.5 oz lime juice', '3 oz Ginger Beer'],
    bartender_id: jack.id,
    category_id: highball.id,
    image_path: 'DarkNStormy.png'
  },
  {
    name: 'Whiskey Highball',
    description: 'The Whiskey Highball is a cocktail made with whiskey and soda water. It is served in a highball glass.',
    execution: 'Add whiskey into highball glass filled with ice. Top with soda water. Garnish with a lemon twist.',
    ingredients: ['2 oz Whiskey', '4 oz Soda Water'],
    bartender_id: doug.id,
    category_id: highball.id,
    image_path: 'Toki-highball.jpg'
  },
  {
    name: 'Hot Buttered Rum',
    description: 'The Hot Buttered Rum is a cocktail made with rum, butter, sugar, and spices. It is served in a mug.',
    execution: 'Add rum, butter, sugar, and spices into mug. Fill with hot water. Stir gently.',
    ingredients: ['2 oz Rum', '1 tbsp Butter', '1 tbsp Sugar', '1 pinch Cinnamon', '1 pinch Nutmeg'],
    bartender_id: jamie.id,
    category_id: toddy.id,
    image_path: 'Hot-buttered-rum.jpg'
  },
  {
    name: 'Irish Coffee',
    description: 'The Irish Coffee is a cocktail made with Irish whiskey, coffee, sugar, and cream. It is served in a mug.',
    execution: 'Add whiskey, coffee, and sugar into mug. Fill with hot water. Stir gently. Float cream on top.',
    ingredients: ['2 oz Irish Whiskey', '1 cup Coffee', '1 tbsp Sugar', '1 tbsp Cream'],
    bartender_id: toggie.id,
    category_id: toddy.id,
    image_path: 'irish-coffee.jpg'
  },
  {
    name: 'Jack Rose',
    description: 'The Jack Rose is a cocktail made with applejack, grenadine, and lime juice. It is served in a cocktail glass.',
    execution: 'Add all ingredients into shaker with ice and shake. Strain into chilled cocktail glass. Garnish with a lime wheel.',
    ingredients: ['2 oz Applejack', '0.5 oz Grenadine', '0.5 oz Lime Juice'],
    bartender_id: jamie.id,
    category_id: new_orleans_sour.id,
    image_path: 'Calvados-Jack-Rose-Cocktail-2.jpg'
  },
  {
    name: 'Hemingway Daiquiri',
    description: 'The Hemingway Daiquiri is a cocktail made with rum, lime juice, grapefruit juice, and maraschino liqueur. It is served in a cocktail glass.',
    execution: 'Add all ingredients into shaker with ice and shake. Strain into chilled cocktail glass. Garnish with a lime wheel.',
    ingredients: ['2 oz White Rum', '0.75 oz Lime Juice', '0.5 oz Grapefruit Juice', '0.5 oz Maraschino Liqueur'],
    bartender_id: toggie.id,
    category_id: international_sour.id,
    image_path: 'hemingway_daiquiri.jpeg'
  },
  {
    name: 'Bronx Cocktail',
    description: 'The Bronx Cocktail is a cocktail made with gin, sweet vermouth, dry vermouth, and orange juice. It is served in a cocktail glass.',
    execution: 'Add all ingredients into shaker with ice and shake. Strain into chilled cocktail glass. Garnish with an orange twist.',
    ingredients: ['2 oz Gin', '0.5 oz Sweet Vermouth', '0.5 oz Dry Vermouth', '0.5 oz Orange Juice'],
    bartender_id: doug.id,
    category_id: french_italian.id,
    image_path: 'bronx_cocktail.jpg'
  },
  {
    name: 'Godfather',
    description: 'The Godfather is a cocktail made with scotch and amaretto. It is served in a rocks glass.',
    execution: 'Add all ingredients into rocks glass filled with ice. Stir gently.',
    ingredients: ['2 oz Scotch', '1 oz Amaretto'],
    bartender_id: jack.id,
    category_id: duos_and_trios.id,
    image_path: 'godfather-cocktail.jpg'
  }
]

cocktail_data.each do |data|
  cocktail = Cocktail.create(data.except(:image_path))
  file_path = Rails.root.join('public', 'photos', 'cocktails', data[:image_path])
  content_type = MIME::Types.type_for(file_path.to_s).first.content_type
  cocktail.image.attach(io: File.open(file_path), filename: data[:image_path], content_type:)
end

puts '🍸🗾🧉✨SEEDED 🧚‍♀️🍹🍾🏝'
