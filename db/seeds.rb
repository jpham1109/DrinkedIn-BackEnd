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



ancestral = Category.create(name: "Ancestral", definition: "Composed of a base spirit lightly adorned with sugar (in Improved versions, the sweetener appears in the form of a dash or two of liqueur such as maraschino or curacao), bitters, and water (usually in its frozen form), and served either straight up or on the rocks.", popular_drinks: [{:name => "Old Fashioned", :image => "https://kitchenswagger.com/wp-content/uploads/2015/11/old-fashioned.jpg"}, {:name => "Sazerac", :image => "https://www.cheersmrforbes.com/wp-content/uploads/2020/11/sazerac-768x768.jpg"}])

duos_and_trios = Category.create(name: "Duos and Trios", definition: "Duos are composed of two ingredients, usually a base spirit and a liqueur, and are normally served in an old-fashioned glass. Trios are duos to which cream or a cream liqueur has been added. Not all duos can be made into trios. Not all trios start out as duos", popular_drinks: [{name: "Godfather", image: "https://media-cdn.tripadvisor.com/media/photo-s/0f/8d/3f/96/godfather-cocktail.jpg"}, {name: "White Russian", image: "https://www.liquor.com/thmb/F4UibVQr8U9E7Y2AkCag0njUC-E=/720x540/smart/filters:no_upscale()/__opt__aboutcom__coeus__resources__content_migration__liquor__2017__12__20073201__white-russian-720x720-article-cbe4b9a832c64f8da0bb09407caefa7f.jpg"}])

french_italian = Category.create(name: "French Italian", definition: "Composed of a base spirit with a modifier of vermouth, or another fortified wine such as sherry, quinquina, or port, often accompanied by other ingredients such as bitters or small doses of liqueurs or syrups.", popular_drinks: [{name: "Vesper Martini", image: "https://robbreport.com/wp-content/uploads/2021/01/lillet-vesper-martini.jpg?w=1000"}, {name: "Negroni", image: "https://www.liquor.com/thmb/FpQjWZNtBBC8PoW8aPfUj7cysYg=/720x720/filters:fill(auto,1)/__opt__aboutcom__coeus__resources__content_migration__liquor__2018__05__08110806__negroni-720x720-recipe-7c1b747a616f4659af4008d025ab55df.jpg"}, {name: "Manhattan", image: "https://www.liquor.com/thmb/zJ7_To3UNS5DNJ0aeyc4dVHUAac=/735x0/__opt__aboutcom__coeus__resources__content_migration__liquor__2018__05__10144903__Manhattan-720x720-recipe-9497922907c14d91898f557cb51f2ea3.jpg"}])

simple_sour = Category.create(name: "Simple Sour", definition: "Contain a base spirit, citrus juice and a non-alcoholic sweetening agent such as simple syrup, grenadine or orgeat syrup (sometimes egg white is added for body and foam)", popular_drinks: [{name: "Daiquiri", image: "https://i2.wp.com/therituals.co/wp-content/uploads/2019/03/Rituals_Cocktails-15_2019.jpg?resize=1600%2C900&ssl=1"}, {name: "Jack Rose", image: "https://nomageddon.com/wp-content/uploads/2018/10/Calvados-Jack-Rose-Cocktail-2.jpg"}, {name: "Whiskey Sour", image: "https://www.simplyrecipes.com/thmb/P92TVlR-1XHEsEt7Lu8_1BIa4Bs=/2000x1333/filters:fill(auto,1)/__opt__aboutcom__coeus__resources__content_migration__simply_recipes__uploads__2019__09__Whiskey-Sour-LEAD-1-a6981aa2e5614f599f23c7b672ca1923.jpg"}])

enhanced_sour = Category.create(name: "Enhanced Sour", definition: "Calls for a spirit, citrus juice, a sweetening agent of any kind , plus vermouth or any other aromatized or fortified wine", popular_drinks: [{name: "Clover Club", image: "https://www.acommunaltable.com/wp-content/uploads/2019/02/Single-clover-club-cocktail-5.jpg"}, {name: "Bronx Cocktail", image: "https://www.liquor.com/thmb/m0uPT_CTULah6AB8izQPF6GUD7I=/720x720/smart/filters:no_upscale()/bronx-720x720-primary-06617fa98d094bd08d97eaec2a3af43f.jpg"}, {name: "Ruby Can't Fail", image: "https://i.pinimg.com/originals/21/b1/08/21b10896c244e6a23e687abf5e17d53f.jpg"}])

new_orleans_sour = Category.create(name: "New Orleans Sour", definition: "Calls for a base spirit, citrus juice, and an orange-flavored liqueur", popular_drinks: [{name: "Cosmopolitan", image: "https://images.food52.com/aJEv48_UtTTPlnWv5m4FoaUKzIU=/fit-in/1200x1200/4af84f60-dc41-4b3e-ae24-068bb2d5bed0--2019-0905_cosmopolitan_3x2_rocky-luten_069.jpg"}, {name: "Margarita", image: "https://selfproclaimedfoodie.com/wp-content/uploads/Margarita-self-proclaimed-foodie-2.jpg"}, {name: "Corpse Reviver no.2", image: "https://preview.redd.it/rznyqpcvhb901.jpg?auto=webp&s=7501142b54001c537acbd68c10f338628c1442c0"}])

international_sour = Category.create(name: "International Sour", definition: "Contains a spirit, citrus juice and a liqueur as sweetening agent", popular_drinks: [{name: "Hemingway Daiquiri", image: "https://storage.googleapis.com/gen-atmedia/3/2014/06/4db452b6ce8adf37c19f523950318ecf59d00514.jpeg"}, {name: "Aviation", image: "https://www.sidewalkshoes.com/wp-content/uploads/2017/10/20171024-featured-cocktail.jpg"}, {name: "Gun Metal Blue", image: "https://static.onecms.io/wp-content/uploads/sites/9/2015/02/original-201502-HD-porchlight-gun-metal-blue-cocktail.jpg"}])

sparkling_sour = Category.create(name: "Sparkling Sour", definition: "Contains a spirit, citrus juice, a sweetening agent of any kind and some bubbles either non-alcoholic or alcoholic", popular_drinks: [{name: "French 75", image: "https://cookieandkate.com/images/2017/12/french-75-recipe-2-3.jpg"}, {name: "Ramos Gin Fizz", image: "https://assets.punchdrink.com/wp-content/uploads/2017/02/Article-Recipe-How-to-Make-Ramos-Gin-Fizz-Cocktail-Recipe-NOLA-Bar-Tonqiue.jpg"}, {name: "Airmail", image: "http://blog.umamimart.com/wp-content/uploads/2012/06/Airmail1.jpg"}])

champagne_cocktail = Category.create(name: "Champagne Cocktail", definition: "Made with champagne or sparkling wine as the main ingredient with a splash of liqueur and/or fruit juice, or sugar and bitters", popular_drinks: [{name: "Champagne cocktail", image: "https://res.cloudinary.com/hksqkdlah/image/upload/SFS_champagne_cocktail_150_d2wzhn.jpg"}, {name: "Mimosa", image: "https://www.foodiecrush.com/wp-content/uploads/2019/04/Mimosa-foodiecrush.com-013.jpg"}])

frozen = Category.create(name: "Frozen", definition: "Cocktails that are blended with ice, perfect for hot summer days", popular_drinks: [{name: "Frozen pina colada", image: "https://www.thelittleepicurean.com/wp-content/uploads/2016/07/Frozen-pina-colada.jpg"}, {name: "Frozen Strawberry Daiquiri", image: "https://www.recipetineats.com/wp-content/uploads/2019/09/Frozen-Strawberry-Daiquiri_1.jpg"}])

highball = Category.create(name: "Highball", definition: "Made with a base spirit leavened with ice and a lengthener such as club soda, ginger ale or cola", popular_drinks: [{name: "Cuba Libre", image: "https://www.thespruceeats.com/thmb/CTxyO_vAgYqO9u9IflFPf8Dr57k=/1912x1568/filters:fill(auto,1)/cuba-libre-362f4afbd5df49eda398ba825895eef7.jpg"}, {name: "Dark and Stormy", image: "https://hips.hearstapps.com/hmg-prod.s3.amazonaws.com/images/lede-1550781637.png?resize=480:*"}, {name: "Whiskey Highball", image: "https://www.oliversmarket.com/wp-content/uploads/2019/04/CPG_TOKI_LAUNCH_054-1440x960.jpg"}])

toddy = Category.create(name: "Toddy", definition: "Old-fashioned style of cocktail with distilled spirit, sweetener and hot water, and other spices", popular_drinks: [{name: "Hot Toddy", image: "https://static01.nyt.com/images/2019/12/04/dining/rp-hot-toddy/rp-hot-toddy-articleLarge.jpg"}, {name: "Hot Buttered Rum", image: "https://hips.hearstapps.com/hmg-prod/images/delish-190904-hot-buttered-rum-0462-landscape-pf-1568846593.jpg"}, {name: "Irish Coffee", image: "https://www.liquor.com/thmb/GZYit8B1jTZwM6bqyA80nRkkj1A=/450x0/filters:no_upscale():max_bytes(150000):strip_icc()/__opt__aboutcom__coeus__resources__content_migration__liquor__2013__04__Dead-Rabbit-Irish-Coffee-0492c99a5f2444028069e22c745b7608.jpg"}])

flips_and_nogs = Category.create(name: "Flips and Nogs", definition: "Made with whole eggs, base spirits, cream and/or milk, sweetening agents such as maple syrup or sugar", popular_drinks: [{name: "Boston Flip", image: "https://images.squarespace-cdn.com/content/v1/588d3b862e69cf76b75442ed/1485655195933-9VMVN22FZC0QWFZ1IR02/ke17ZwdGBToddI8pDm48kLkXF2pIyv_F2eUT9F60jBl7gQa3H78H3Y0txjaiv_0fDoOvxcdMmMKkDsyUqMSsMWxHk725yiiHCCLfrh8O1z4YTzHvnKhyp6Da-NYroOW3ZGjoBKy3azqku80C789l0iyqMbMesKd95J-X4EagrgU9L3Sa3U8cogeb0tjXbfawd0urKshkc5MgdBeJmALQKw/image-asset.jpeg?format=2500w"}, {name: "Brandy Flip", image: "https://assets.punchdrink.com/wp-content/uploads/2016/03/Brandy-Flip-2-Cocktail-Ale-Sherry-Brandy-Drinks-History-Recipe-Elephant-Flip-Pouring-Ribbons-Franklin-Bar-Philadelphia-NYC.jpg"}])

juleps_and_smashes = Category.create(name: "Juleps and Smashes", definition: "Made of a base spirit, fresh mint, sugar, sometimes with fruits in case of smashes, and a lot of ice", popular_drinks: [{name: "Mint Julep", image: "https://upload.wikimedia.org/wikipedia/commons/5/55/Mint_Julep_im_Silberbecher.jpg"}, {name: "Peach Whiskey Smash", image: "https://i2.wp.com/completelydelicious.com/wp-content/uploads/2018/07/grilled-peach-whiskey-smash-5.jpg"}])

punch = Category.create(name: "Punch", definition: "Refers to a variety of festive drinks, non-alcoholic or alcoholic, generally containing fruits and fruit juices, spirits and liqueurs if alcoholic, and often topped with sparkling wine or soda. It is usually served at parties in large, wide bowls, known as punch bowls.", popular_drinks: [{name: "Watermelon Rum Punch", image: "https://www.rachaelraymag.com/.image/t_share/MTYzNzc5NTc4ODAyNzQzMDA5/watermelon-rum-punch-fecfd321.jpg"}, {name: "Summer Punch", image: "https://images.immediate.co.uk/production/volatile/sites/30/2020/08/wilhelminas-punch-e0a68df.jpg?quality=90&resize=768,574"}])

pousse = Category.create(name: "Pousse", definition: "Elaborately composed concoctions made of liqueurs and syrups, layered for a distinctive appearance", popular_drinks: [{name: "Pousse Cafe", image: "https://assets.epicurious.com/photos/55fc76d9393f29a26aca918a/1:1/w_600%2Ch_600/51167400_the-pousse-cafe-no-1.jpg"}, {name: "B-52", image: "https://s3.amazonaws.com/img.kh-labs.com/N7snPD60206de6f32817.28564981"}])

tiki = Category.create(name: "Tiki", definition: "Single-serving punch-style drinks featuring a base spirit(s), fruit juice and syrups or liqueurs, often deployed in various combinations.", popular_drinks: [{name: "Mai Tai", image: "https://www.thespruceeats.com/thmb/_EQvuPU4f1tbh8UFcYYKrtb_fog=/4000x3000/smart/filters:no_upscale()/its-tiki-time-mai-tai-cocktail-759316-8-5b4900dfc9e77c0037fad180.jpg"}, {name: "Luau Daiquiri", image: "https://www.drinkmagazine.asia/wp-content/uploads/2019/04/beachbum.jpg"}, {name: "Zombie", image: "https://www.wine-liquor.store/wp-content/uploads/cocktail-zombie-1934-recipe-e1589396013394-1200x1200.jpeg"}])

snapper = Category.create(name: "Snapper", definition: "Made with a base spirit, tomato juice and a variety of garnishes", popular_drinks: [{name: "Bloody Mary", image: "https://i0.wp.com/www.crowdedkitchen.com/wp-content/uploads/2020/08/bloody-mary-bar.jpg"}, {name: "Red Snapper", image: "https://d32miag6ta013h.cloudfront.net/master_cocktails/3423/en-gl/large/f2a84a~1.jpg"}])

orphan = Category.create(name: "Orphan", definition: "Does not fit in any cocktail family, subjected to be moved to a more appropriate category by DrinkedIn admins.", popular_drinks: [{name: "?", image: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSarsfAX0xOW1TnX1Dggc9rFh_wvqjGyGJtGA&usqp=CAU"}])


# jamie = User.create(full_name: "Jamie Pham", username: "ninjacat", password: "911", location: "Brooklyn, NY", bartender: true, instagram_account: "lilliputik")

# thirds = Bar.create(name: "Rule of thirds")


# barry = User.create(full_name: "Barry Wright", username: "baaarry", password: "123", location: "Brooklyn, NY", bartender: true, instagram_account: "baaaaaarry")

# gitano = Bar.create(name: "Gitano")

# ash = User.create(full_name: "Ash Lafayette", username: "ashlee", password: "123", location: "Brooklyn, NY", bartender: true, instagram_account: "ash_n_salt")

# yu = User.create(full_name: "Yu Shi", username: "yushi", password: "123", location: "New York, NY", bartender: true, instagram_account: "yushi.95")

# caitlin = User.create(full_name: "Caitlin Seager", username: "caitlin", password: "123", location: "New York, NY", bartender: true, instagram_account: "caitseager")


puts "???????????????SEEDED ?????????????????????????"
