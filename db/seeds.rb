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



ancestral = Category.create(name: "Ancestral", definition: "Composed of a base spirit lightly adorned with sugar (in Improved versions, the sweetener appears in the form of a dash or two of liqueur such as maraschino or curacao), bitters, and water (usually in its frozen form), and served either straight up or on the rocks.", popular_drinks: [{:name => "Old Fashioned", :image => "/public/photos/cocktails/old-fashioned.jpg"}, {:name => "Sazerac", :image => "DrinkedIn_BackEnd/public/photos/cocktails/sazerac-768x768.jpg"}])

duos_and_trios = Category.create(name: "Duos and Trios", definition: "Duos are composed of two ingredients, usually a base spirit and a liqueur, and are normally served in an old-fashioned glass. Trios are duos to which cream or a cream liqueur has been added. Not all duos can be made into trios. Not all trios start out as duos", popular_drinks: [{name: "Godfather", image: "DrinkedIn_BackEnd/public/photos/cocktails/godfather-cocktail.jpg"}, {name: "White Russian", image: "DrinkedIn_BackEnd/public/photos/cocktails/white_russian.jpg"}])

french_italian = Category.create(name: "French Italian", definition: "Composed of a base spirit with a modifier of vermouth, or another fortified wine such as sherry, quinquina, or port, often accompanied by other ingredients such as bitters or small doses of liqueurs or syrups.", popular_drinks: [{name: "Vesper Martini", image: "DrinkedIn_BackEnd/public/photos/cocktails/lillet-vesper-martini.webp"}, {name: "Negroni", image: "DrinkedIn_BackEnd/public/photos/cocktails/negroni.jpg"}, {name: "Manhattan", image: "DrinkedIn_BackEnd/public/photos/cocktails/manhattan.jpg"}])

simple_sour = Category.create(name: "Simple Sour", definition: "Contain a base spirit, citrus juice and a non-alcoholic sweetening agent such as simple syrup, grenadine or orgeat syrup (sometimes egg white is added for body and foam)", popular_drinks: [{name: "Daiquiri", image: "DrinkedIn_BackEnd/public/photos/cocktails/daiquiri.webp"}, {name: "Jack Rose", image: "DrinkedIn_BackEnd/public/photos/cocktails/Calvados-Jack-Rose-Cocktail-2.jpg"}, {name: "Whiskey Sour", image: "DrinkedIn_BackEnd/public/photos/cocktails/whiskey_sour.jpg"}])

enhanced_sour = Category.create(name: "Enhanced Sour", definition: "Calls for a spirit, citrus juice, a sweetening agent of any kind , plus vermouth or any other aromatized or fortified wine", popular_drinks: [{name: "Clover Club", image: "DrinkedIn_BackEnd/public/photos/cocktails/Clover-club-cocktail-5.jpg"}, {name: "Bronx Cocktail", image: "DrinkedIn_BackEnd/public/photos/cocktails/bronx_cocktail.jpg"}, {name: "Ruby", image: "DrinkedIn_BackEnd/public/photos/cocktails/Ruby_cocktail.jpg"}])

new_orleans_sour = Category.create(name: "New Orleans Sour", definition: "Calls for a base spirit, citrus juice, and an orange-flavored liqueur", popular_drinks: [{name: "Cosmopolitan", image: "DrinkedIn_BackEnd/public/photos/cocktails/cosmo.jpg"}, {name: "Margarita", image: "DrinkedIn_BackEnd/public/photos/cocktails/Margarita.jpg"}, {name: "Corpse Reviver no.2", image: "DrinkedIn_BackEnd/public/photos/cocktails/corpse_reviver.webp"}])

international_sour = Category.create(name: "International Sour", definition: "Contains a spirit, citrus juice and a liqueur as sweetening agent", popular_drinks: [{name: "Hemingway Daiquiri", image: "DrinkedIn_BackEnd/public/photos/cocktails/hemingway_daiquiri.jpeg"}, {name: "Aviation", image: "DrinkedIn_BackEnd/public/photos/cocktails/aviation.jpg"}, {name: "Gun Metal Blue", image: "DrinkedIn_BackEnd/public/photos/cocktails/gunmetal_blue.jpg"}])

sparkling_sour = Category.create(name: "Sparkling Sour", definition: "Contains a spirit, citrus juice, a sweetening agent of any kind and some bubbles either non-alcoholic or alcoholic", popular_drinks: [{name: "French 75", image: "DrinkedIn_BackEnd/public/photos/cocktails/French-75-Sipsmith.jpg"}, {name: "Ramos Gin Fizz", image: "DrinkedIn_BackEnd/public/photos/cocktails/Ramos-Gin-Fizz-Tonique.jpg"}, {name: "Airmail", image: "DrinkedIn_BackEnd/public/photos/cocktails/Airmail.jpg"}])

champagne_cocktail = Category.create(name: "Champagne Cocktail", definition: "Made with champagne or sparkling wine as the main ingredient with a splash of liqueur and/or fruit juice, or sugar and bitters", popular_drinks: [{name: "Champagne cocktail", image: "DrinkedIn_BackEnd/public/photos/cocktails/Champagne_cocktail.jpg"}, {name: "Mimosa", image: "DrinkedIn_BackEnd/public/photos/cocktails/mimosa.jpg"}])

frozen = Category.create(name: "Frozen", definition: "Cocktails that are blended with ice, perfect for hot summer days", popular_drinks: [{name: "Frozen pina colada", image: "DrinkedIn_BackEnd/public/photos/cocktails/Frozen-pina-colada.jpg"}, {name: "Frozen Strawberry Daiquiri", image: "DrinkedIn_BackEnd/public/photos/cocktails/Frozen-Strawberry-Daiquiri.webp"}])

highball = Category.create(name: "Highball", definition: "Made with a base spirit leavened with ice and a lengthener such as club soda, ginger ale or cola", popular_drinks: [{name: "Cuba Libre", image: "DrinkedIn_BackEnd/public/photos/cocktails/Cuba-libre.jpg"}, {name: "Dark and Stormy", image: "DrinkedIn_BackEnd/public/photos/cocktails/DarkNStormy.png"}, {name: "Whiskey Highball", image: "DrinkedIn_BackEnd/public/photos/cocktails/Toki-highball.jpg"}])

toddy = Category.create(name: "Toddy", definition: "Old-fashioned style of cocktail with distilled spirit, sweetener and hot water, and other spices", popular_drinks: [{name: "Hot Toddy", image: "DrinkedIn_BackEnd/public/photos/cocktails/RP-Hot-toddy.jpg"}, {name: "Hot Buttered Rum", image: "DrinkedIn_BackEnd/public/photos/cocktails/Hot-buttered-rum.jpg"}, {name: "Irish Coffee", image: "DrinkedIn_BackEnd/public/photos/cocktails/irish-coffee.jpg"}])

flips_and_nogs = Category.create(name: "Flips and Nogs", definition: "Made with whole eggs, base spirits, cream and/or milk, sweetening agents such as maple syrup or sugar", popular_drinks: [{name: "Boston Flip", image: "DrinkedIn_BackEnd/public/photos/cocktails/boston-flip.jpeg"}, {name: "Brandy Flip", image: "DrinkedIn_BackEnd/public/photos/cocktails/Brandy-Flip-2.jpg"}])

juleps_and_smashes = Category.create(name: "Juleps and Smashes", definition: "Made of a base spirit, fresh mint, sugar, sometimes with fruits in case of smashes, and a lot of ice", popular_drinks: [{name: "Mint Julep", image: "DrinkedIn_BackEnd/public/photos/cocktails/Mint_Julep.jpg"}, {name: "Peach Whiskey Smash", image: "DrinkedIn_BackEnd/public/photos/cocktails/grilled-peach-whiskey-smash.webp"}])

punch = Category.create(name: "Punch", definition: "Refers to a variety of festive drinks, non-alcoholic or alcoholic, generally containing fruits and fruit juices, spirits and liqueurs if alcoholic, and often topped with sparkling wine or soda. It is usually served at parties in large, wide bowls, known as punch bowls.", popular_drinks: [{name: "Gin Punch", image: "DrinkedIn_BackEnd/public/photos/cocktails/Gin-punch-epicurious.webp"}, {name: "Tequila Watermelon Punch", image: "DrinkedIn_BackEnd/public/photos/cocktails/Tequila-watermelon-punch.jpg"}])

pousse = Category.create(name: "Pousse", definition: "Elaborately composed concoctions made of liqueurs and syrups, layered for a distinctive appearance", popular_drinks: [{name: "Pousse Cafe", image: "DrinkedIn_BackEnd/public/photos/cocktails/Pousse-cafe.jpg"}, {name: "B-52", image: "DrinkedIn_BackEnd/public/photos/cocktails/B52-Shooter.jpg"}])

tiki = Category.create(name: "Tiki", definition: "Single-serving punch-style drinks featuring a base spirit(s), fruit juice and syrups or liqueurs, often deployed in various combinations.", popular_drinks: [{name: "Mai Tai", image: "DrinkedIn_BackEnd/public/photos/cocktails/MaiTai-Spruce.jpg"}, {name: "Luau Daiquiri", image: "DrinkedIn_BackEnd/public/photos/cocktails/Luau-daiquiri-latitude29.jpg"}, {name: "Zombie", image: "DrinkedIn_BackEnd/public/photos/cocktails/Zombie-Original.jpg"}])

snapper = Category.create(name: "Snapper", definition: "Made with a base spirit, tomato juice and a variety of garnishes", popular_drinks: [{name: "Bloody Mary", image: "DrinkedIn_BackEnd/public/photos/cocktails/bloody-mary.webp"}, {name: "Red Snapper", image: "DrinkedIn_BackEnd/public/photos/cocktails/red-snapper.jpg"}])

orphan = Category.create(name: "Miscellaneous", definition: "Does not fit in any cocktail family, or you are just a renegade. Subjected to be moved to a more appropriate category.", popular_drinks: [{name: "Renegade", image: "DrinkedIn_BackEnd/public/photos/cocktails/QuestionCocktail.jpg"}])


# jamie = User.create(full_name: "Jamie Pham", username: "ninjacat", password: "911", location: "Brooklyn, NY", bartender: true, instagram_account: "lilliputik")

# thirds = Bar.create(name: "Rule of thirds")


# barry = User.create(full_name: "Barry Wright", username: "baaarry", password: "123", location: "Brooklyn, NY", bartender: true, instagram_account: "baaaaaarry")

# gitano = Bar.create(name: "Gitano")

# ash = User.create(full_name: "Ash Lafayette", username: "ashlee", password: "123", location: "Brooklyn, NY", bartender: true, instagram_account: "ash_n_salt")

# yu = User.create(full_name: "Yu Shi", username: "yushi", password: "123", location: "New York, NY", bartender: true, instagram_account: "yushi.95")

# caitlin = User.create(full_name: "Caitlin Seager", username: "caitlin", password: "123", location: "New York, NY", bartender: true, instagram_account: "caitseager")


puts "🍸🗾🧉✨SEEDED 🧚‍♀️🍹🍾🏝"
