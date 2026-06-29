-- ============================================================================
--  jx_descriptions_ptbr_data.lua
--  Dados de tradução PT-BR para descrições (RECIPE_DESC + DESCRIBE) dos itens
--  do mod JingXi Furniture (workshop-3597024951).
--  Carregado por jx_descriptions_ptbr.lua (Patch 6 do Patch-Warly).
--  NÃO traduz NAMES (nomes dos itens) — apenas descrições.
--
--  Notas sobre bugs corrigidos em relação ao fonte EN (jx_en.lua):
--   * CHESSPIECES_JX (plural, typo do EN) -> aqui usamos a chave singular
--     correta CHESSPIECE_JX, que bate com o prefab real chesspiece_jx.
--   * JX_RUG_TRIANGLE no EN foi acidentalmente escrito como JX_RUG_FOREST
--     (sobrescrevendo a descrição correta de FOREST). Aqui cada chave
--     recebe a tradução correta: FOREST = texto de floresta,
--     TRIANGLE = texto de triângulo/totem.
--   * JX_WATERINGCAN é definido duas vezes no EN (linhas ~85 e ~463).
--     O segundo define sobrescreve o primeiro — usamos o valor final
--     (palace flower tea pot), não o de Aladdin.
--   * Aliases (ex.: JX_SOFA_2 = JX_SOFA_1) são repetidos explicitamente
--     aqui com o mesmo valor PT-BR — sobrescrever a base não atualiza
--     automaticamente o alias capturado pelo EN em tempo de load.
-- ============================================================================

JX_DESC_PTBR = {
    RECIPE_DESC = {
        -- =====================================================================
        -- Plantas em vaso / decoração floral
        -- =====================================================================
        ["JX_POTTED"] = "Decore a casa com um vaso de pau-brasil.",
        ["JX_POTTED_SUNFLOWER"] = "Decore a casa com girassóis.",
        ["JX_POTTED_CHERRY"] = "Cheio de oxalis de flor de cerejeira.",
        ["JX_POTTED_ROSE"] = "Amor puro entre rosas e lírios.",
        ["JX_POTTED_CACTUS"] = "Decore a casa com um cacto em vaso.",
        ["JX_POTTED_ANTHURIUM"] = "Decore a casa com uma planta de antúrio em vaso.",
        ["JX_POTTED_SNAKEPLANT"] = "Decore a casa com uma espada-de-são-jorge em vaso.",
        ["JX_POTTED_NARCISSUS"] = "Decore a casa com uma planta de narciso em vaso.",
        ["JX_ROSE_BIG_POTTED"] = "Decore a casa com uma elegante planta de rosas.",
        ["JX_CHLOROPHYTUM_COMOSUM_POTTED"] = "Decore a casa com clorofito (chlorophytum comosum).",
        ["JX_XUNCAT"] = "Criar um lindo gatinho laranja em casa.",
        ["JX_RED_ROSE_POTTED"] = "Decore a casa com um vaso de rosas.",
        ["JX_GREEN_PALM"] = "Decore a casa com uma planta de peperômia (Douban) em vaso.",
        ["JX_POTTED_GARDENIA"] = "Decore a casa com flores de gardênia em vaso.",
        ["JX_POTTED_MONSTERA"] = "Decore a casa com plantas de monstera em vaso.",
        ["JX_PERFUME_POTTED"] = "Decore a casa com uma planta de lírio perfumado em vaso.",
        ["JX_PRINCESS_POTTED"] = "Decore a casa com a Princesa Verde Dourada em vaso.",
        ["JX_POTTED_BERRY"] = "Decore o pátio com bagas em vaso.",
        ["JX_POTTED_MEXICO"] = "Plantas verdes ornamentais resistentes à seca.",
        ["JX_COLCHICUM"] = "Arranjo floral decorativo.",

        -- =====================================================================
        -- Eletrodomésticos e cozinha
        -- =====================================================================
        ["JX_COOKPOT"] = "Você pode cozinhar comida melhor com ela.",
        ["JX_COOKPOT_2"] = "Use-a para cozinhar comida deliciosa mais rápido.",
        ["JX_ICEBOX"] = "Uma geladeira grande cheia de vibe vintage.",
        ["JX_ICEBOX_2"] = "Uma geladeira fofa com paleta de cores creme.",
        ["JX_ICEBOX_BIG"] = "Armários refrigerados ociosos.",
        ["JX_OVEN"] = "Usado para grelhar e cozinhar vários ingredientes.",
        ["JX_TOASTER"] = "Aqueça suas mãos, como a Pedra Térmica.",
        ["JX_BASKET"] = "Um cesto de piquenique usado para guardar ingredientes.",
        ["JX_ICEMAKER"] = "Faça gelo com pedras e esta máquina de gelo.",
        ["JX_CHARCOAL_STOVE"] = "Converta madeira em carvão.",
        ["JX_CANNER"] = "Método secreto de conservação de alimentos.",
        ["JX_PICKLING_BARREL"] = "Usado para colocar alimentos em conserva.",
        ["JX_HONEY_BOX"] = "Mel doce recém-preservado.",
        ["JX_BAGUETTE"] = "Um pão tradicional.",
        ["JX_KEBAB"] = "Comida essencial para reuniões.",
        ["JX_CAN0"] = "Salgado e salgado, com gosto de sal do mar.",
        ["JX_CAN1"] = "Vamos jantar!",
        ["JX_CAN2"] = "Peixe seco delicioso!",
        -- JX_DRINK_COFFEE, JX_DRINK_COLA, JX_DRINK_TEA não são fabricáveis no EN: omitidos do RECIPE_DESC.

        -- =====================================================================
        -- Móveis: baús, armários, mesas, cadeiras, camas
        -- =====================================================================
        ["JX_CHEST"] = "Baú de madeira europeu de alto padrão.",
        ["JX_CHEST_2"] = "Um baú de tesouro precioso.",
        ["JX_TENT"] = "Cama abobadada europeia luxuosa, mais durável que tendas.",
        ["JX_TV"] = "Uma TV retrô com console de videogame embutido.",
        ["JX_FISH_TANK"] = "Um armário antigo que pode guardar itens e é cheio de valor artístico.",
        ["JX_PHONOGRAPH"] = "A discagem por pulso traz a alma de volta ao corpo.",
        ["JX_TAPEPLAYER"] = "Venha ouvir a música no antigo toca-fitas.",
        ["JX_WATERINGCAN"] = "Chaleiras de chá de flores também podem ser usadas para regar plantas.",
        ["JX_SOFA_1"] = "Você vai se apaixonar por este sofá de couro luxuoso.",
        ["JX_SOFA_2"] = "Você vai se apaixonar por este sofá de couro luxuoso.", -- alias de JX_SOFA_1
        ["JX_SOFA_3"] = "Sofá de couro vermelho rosa esculpido em madeira maciça.",
        ["JX_TABLE"] = "Você vai se apaixonar por esta mesa luxuosa.",
        ["JX_TABLE_2"] = "Coloque pratos favoritos sobre a mesa.",
        ["JX_TABLE_3"] = "Mesa quadrada de tecido xadrez elegante.",
        ["JX_TABLE_4"] = "Mesa de jantar de madeira maciça esculpida em vermelho rosa.",
        ["JX_TABLE_5"] = "Coloque uma tocador delicada e luxuosa no quarto.",
        ["JX_TABLE_6"] = "Exponha seus itens favoritos para apreciação.",
        ["JX_TABLE_7"] = "Acessórios decorativos para banheiro.",
        ["JX_TABLE_8"] = "Aquecimento e decoração.",
        ["JX_TABLE_9"] = "Armário de pia de lavar louça de cozinha.",
        ["JX_CHAIR_1"] = "Descanse no pequeno banco de couro.",
        ["JX_CHAIR_2"] = "Cadeira de madeira maciça com tecido xadrez elegante.",
        ["JX_CHAIR_3"] = "Sentado em uma cadeira de balanço, desfrutando de uma tarde preguiçosa.",
        ["JX_CHAIR_4"] = "Louça sanitária decorativa clássica.",
        ["JX_WARDROBE"] = "Usado para guardar várias roupas.",
        ["JX_SEWINGMACHINE"] = "Use uma máquina de costura para consertar roupas danificadas.",
        ["JX_BOOKCASE"] = "Um armário clássico sem janelas usado para exposição e armazenamento.",
        ["JX_CABINET"] = "Exponha a coleção do aventureiro.",
        ["JX_BATHTUB"] = "Tome um banho para regular corpo e mente.",
        ["JX_HANGING_BED"] = "Rede de pendurar de estilo étnico.",
        ["JX_STORAGE_BASKET"] = "Cesto tecido de vime rústico.",
        ["JX_PACK"] = "Bolsa bento em formato de urso que só pode guardar comida.",
        ["JX_HANDCART"] = "Coloque os ramos amarrados aqui.",
        ["JX_WOOD_BIN"] = "Usado para armazenar madeira.",
        ["JX_ROCK_BIN"] = "Armazene Pedras e Pedras Cortadas.",
        ["JX_HAY_CART"] = "Usado para armazenar grama e corda.",
        ["JX_CELLAR"] = "Usado para armazenar materiais preciosos.",
        ["JX_TRASH_CAN"] = "Uma lata de lixo de ferro azul.",
        ["JX_VENDING_MACHINE"] = "Compre algumas bebidas.",
        ["JX_FARM_TOOLS_CONTAINER"] = "Um suporte de madeira para armazenar ferramentas agrícolas.",
        ["JX_DISASSEMBLER"] = "Use esta máquina para decompor itens.",
        ["JX_BANKATM"] = "Deposite e troque Moedas de Gato.",

        -- =====================================================================
        -- Iluminação
        -- =====================================================================
        ["JX_MUSHROOM_LIGHT"] = "Ilumine seu pátio com postes palacianos.",
        ["JX_MUSHROOM_LIGHT_2"] = "Luz interna premium de madeira maciça vermelho rosa.",
        ["JX_LAMP"] = "Um abajur de mesa palaciano europeu clássico e requintado.",
        ["JX_LAMP_2"] = "Ornamentos de iluminação decorativa clássica.",
        ["JX_LANTERN"] = "Design de lanterna requintado e bonito.",
        ["JX_LANTERN_2"] = "Lanterna elegante e retrô.",
        ["JX_LANTERN_3"] = "Luminárias noturnas góticas.",
        ["JX_FURNACE"] = "Construa um forno de ferro para você.",
        ["JX_FLASHLIGHT"] = "Ferramenta de iluminação portátil e prática.",
        ["JX_BATTERY1"] = "Bateria tipo D antiquada.",
        ["JX_BATTERY2"] = "Bateria tipo D antiquada.", -- alias de JX_BATTERY1
        ["JX_PARTS_LIGHT"] = "Faróis modificados ilegalmente. Não há polícia aqui.",

        -- =====================================================================
        -- Tapetes / carpetes / pisos
        -- =====================================================================
        ["JX_RUG_OVAL"] = "Estenda um tapete de veludo premium em casa.",
        ["JX_RUG_OVAL_ITEM"] = "Estenda um tapete de veludo premium em casa.", -- alias de JX_RUG_OVAL
        ["JX_RUG_FOREST"] = "Estenda uma manta de tecido com atmosfera de floresta.",
        ["JX_RUG_FOREST_ITEM"] = "Estenda uma manta de tecido com atmosfera de floresta.", -- alias de JX_RUG_FOREST
        ["JX_RUG_AUBUSSON"] = "Estenda uma manta de seda em casa.",
        ["JX_RUG_AUBUSSON_ITEM"] = "Estenda uma manta de seda em casa.", -- alias de JX_RUG_AUBUSSON
        ["JX_RUG_TRADITION"] = "Estenda um tapete quadriculado em casa.",
        ["JX_RUG_TRADITION_ITEM"] = "Estenda um tapete quadriculado em casa.", -- alias de JX_RUG_TRADITION
        ["JX_RUG_SAVANNAH"] = "Estendendo tapetes de corte artesanais em casa.",
        ["JX_RUG_SAVANNAH_ITEM"] = "Estendendo tapetes de corte artesanais em casa.", -- alias de JX_RUG_SAVANNAH
        ["JX_RUG_TRIANGLE"] = "Estenda um tapete triangular com estilo étnico em casa.",
        ["JX_RUG_TRIANGLE_ITEM"] = "Estenda um tapete triangular com estilo étnico em casa.", -- alias de JX_RUG_TRIANGLE
        ["JX_RUG_PLATONI"] = "Um tapete decorativo.",
        ["JX_RUG_PLATONI_ITEM"] = "Um tapete decorativo.", -- alias de JX_RUG_PLATONI
        ["TURF_GRANITE"] = "Azulejos de granito são decorações premium para casa.",
        ["TURF_REDDISH_BROWN"] = "Estenda tapetes vermelhos no quarto.",
        ["TURF_CORRIDOR"] = "Tapete retrô com pilha de tecido fino.",
        ["TURF_BATH"] = "Substitua os azulejos do seu banheiro por novos.",
        ["TURF_JX_WOOD"] = "Piso de madeira composto de precisão.",
        ["TURF_JX_COURTYARD"] = "Tijolos de cimento montados e limpos.",

        -- =====================================================================
        -- Mochilas / bolsas
        -- =====================================================================
        ["JX_BACKPACK"] = "Obrigado por se inscrever!",
        ["JX_BACKPACK_2"] = "Obrigado por se inscrever!",
        ["JX_BACKPACK_3"] = "Bolsa de boneca de festa do chá de gato tricolor retrô.",
        ["JX_BACKPACK_4"] = "Uma mochila que pode manter a comida fresca.",
        ["JX_BACKPACK_5"] = "Uma mochila que pode piar.",
        ["JX_RUG_BAG"] = "Usada para guardar terreno e tapetes.",

        -- =====================================================================
        -- Chapéus / capacetes
        -- =====================================================================
        ["JX_HAT_IRON_PAN"] = "Uma panela velha só pode ser usada como capacete.",
        ["JX_HAT_SUNFLOWER"] = "Um chapéu de palha tecido à mão adequado para acampamentos.",
        ["JX_HAT_WHITE_ROSE"] = "Um chapéu redondo de couro nobre clássico cor de vinho.",
        ["JX_HAT_MEXICO"] = "Um chapéu de palha elegante com charme exótico.",
        ["JX_HAT_REINDEER"] = "Chapéu invernal quente e brincalhão.",
        ["JX_HAT_NOODLES"] = "Mal posso esperar.",
        ["JX_HAT_MOTORCYCLE"] = "Capacete primeiro.",
        ["JX_HAT_SIGURD"] = "Capacete do Herói Nórdico Matador de Dragões.",
        ["JX_HAT_HEPBURN"] = "Chapéu de sol de aba pequena.",
        ["JX_FROG_RAINCOAT"] = "É fofo e à prova de chuva.",

        -- =====================================================================
        -- Armas / ferramentas
        -- =====================================================================
        ["JX_PAN"] = "O chef disse que pode ser usada como arma, temporariamente.",
        ["JX_WEAPON_1"] = "Garfo ocidental aristocrático elegante.",
        ["JX_WEAPON_2"] = "Uma faca estilo ocidental aristocrática elegante.",
        ["JX_WEAPON_3"] = "Uma colher ocidental aristocrática elegante.",
        ["JX_WEAPON_4"] = "Sem um saca-rolhas, pode servir temporariamente como arma.",
        ["JX_WEAPON_5"] = "A espátula usada pelo chef real.",
        ["JX_FAN"] = "Abra as pás do ventilador para se refrescar.",
        ["JX_WELL"] = "Poço de pedra clássico prático de extração de água.",
        ["JX_WASHER"] = "Use esta máquina de lavar para limpar e secar suas roupas.",
        ["JX_TOILET_SUCTION"] = "Pode ser usado para sugar tapetes.",
        ["JX_HOLY_SWORD"] = "Espada nórdica de matar dragões Gram.",
        ["JX_WAR_HOE"] = "A determinação dos fazendeiros.",
        -- JX_WATERINGCAN_EMPTY não é fabricável no EN: omitido do RECIPE_DESC.

        -- =====================================================================
        -- Construções / paredes / cercas / exteriores
        -- =====================================================================
        ["JX_MAILBOX"] = "Coloque uma caixa de correio na entrada da sua villa.",
        ["WALL_JX_STONE"] = "Villa retrô com paredes e colunas de pedra.",
        ["WALL_JX_STONE_ITEM"] = "Villa retrô com paredes e colunas de pedra.", -- alias de WALL_JX_STONE
        ["WALL_JX_STONE_2"] = "As paredes de pedra esculpidas comumente usadas em palácios.",
        ["WALL_JX_STONE_2_ITEM"] = "As paredes de pedra esculpidas comumente usadas em palácios.", -- alias de WALL_JX_STONE_2
        ["WALL_JX_STONE_3"] = "Parede esculpida com estilo sombrio.",
        ["WALL_JX_STONE_3_ITEM"] = "Parede esculpida com estilo sombrio.", -- alias de WALL_JX_STONE_3
        ["WALL_JX_STRAW_1"] = "Cercado de plantas verdes para jardim.",
        ["WALL_JX_STRAW_1_ITEM"] = "Cercado de plantas verdes para jardim.", -- alias de WALL_JX_STRAW_1
        ["JX_FENCE"] = "Uma balaustrada que combina com a parede de pedra.",
        ["JX_FENCE_ITEM"] = "Uma balaustrada que combina com a parede de pedra.", -- alias de JX_FENCE
        ["JX_FENCE_2"] = "Uma cerca que complementa as paredes de pedra esculpidas do palácio.",
        ["JX_FENCE_2_ITEM"] = "Uma cerca que complementa as paredes de pedra esculpidas do palácio.", -- alias de JX_FENCE_2
        ["JX_FOUNTAIN"] = "Paisagem de água corrente no pátio.",
        ["JX_FIREPLUG"] = "Hidrante novinho em folha.",
        ["JX_PORTABLETENT"] = "Crie uma atmosfera de acampamento.",
        ["JX_PORTABLETENT_ITEM"] = "Crie uma atmosfera de acampamento.", -- alias de JX_PORTABLETENT
        ["JX_CHESTER_HOUSE"] = "Abrigo do Chester.",
        ["JX_GLOMMER_HOUSE"] = "Abrigo do Glommer.",
        ["JX_CAT_TREE"] = "Momentos aconchegantes para gatos.",

        -- =====================================================================
        -- Carrinho / Beetle / peças de carro
        -- =====================================================================
        ["JX_CAR"] = "Você pode colocar sua bagagem no porta-malas do carro.",
        ["JX_GASOLINE"] = "Combustível de 95 octanas projetado especificamente para carros Fusca.",
        ["JX_CAR_KEY"] = "Prove sua identidade como dono do carro.",
        ["JX_PARTS_COLOUR"] = "É hora de se preparar para a nova temporada.",
        ["JX_PARTS_MUSIC"] = "Viajar nunca é solitário.",
        ["JX_PARTS_ENGINE"] = "Experimente um poder mais forte.",
        ["JX_PARTS_WHEEL"] = "Segure W e o Mouse, então siga seu coração.",
        ["JX_PARTS_CAMERA_1"] = "Câmera fixa do motorista.\n Espero que ninguém fique com enjoo de carro.",
        ["JX_PARTS_CAMERA_2"] = "Ainda um pouco tonto.",

        -- =====================================================================
        -- Instrumentos musicais / decoração
        -- =====================================================================
        ["JX_PIANO"] = "Instrumentos musicais decorativos luxuosos de madeira maciça.",
        ["JX_SAXOPHONE"] = "Ornamentos de instrumentos musicais tradicionais.",
        ["JX_CELLO"] = "Ornamentos de instrumentos musicais tradicionais.",
        ["JX_HARP"] = "Ornamentos de instrumentos musicais tradicionais.",
        ["JX_DRESS_FORM_M"] = "Manequim de exibição de vestidos elegante e luxuoso.",
        ["JX_DRESS_FORM_W"] = "Manequim de exibição para vestidos Lolita requintados.",

        -- =====================================================================
        -- Miscelânea / estátuas / livros / relógios / moedas
        -- =====================================================================
        ["CHESSPIECE_JX"] = "Faça uma escultura da empregada, Srta. Jingxi.", -- bug fix: CHESSPIECES_JX -> CHESSPIECE_JX (singular)
        ["JX_WIKI_BOOK"] = "Livro tutorial, mas atualmente disponível apenas em chinês.",
        ["JX_MANTEL_CLOCK"] = "Talvez possa servir como decoração de sala.",
        ["JX_PORTABLE_COOK_POT"] = "Ferramentas de cozinha ao ar livre para piquenique.",
        ["JX_PORTABLE_COOK_POT_ITEM"] = "Ferramentas de cozinha ao ar livre para piquenique.", -- alias de JX_PORTABLE_COOK_POT
        ["JX_PORTABLE_COOK_POT_2"] = "Ferramentas de cozinha ao ar livre para piquenique.",
        ["JX_PORTABLE_COOK_POT_2_ITEM"] = "Ferramentas de cozinha ao ar livre para piquenique.", -- alias de JX_PORTABLE_COOK_POT_2

        -- Itens sem RECIPE_DESC no fonte EN (não fabricáveis): omitidos
        -- JX_BAGUETTE_EDIBLE, JX_CATCOIN, JX_DRINK_COFFEE, JX_DRINK_COLA,
        -- JX_DRINK_TEA, JX_WATERINGCAN_EMPTY
    },

    DESCRIBE = {
        -- =====================================================================
        -- Plantas em vaso / decoração floral
        -- =====================================================================
        ["JX_POTTED"] = "Uma planta de pau-brasil em vaso que traz a vibe \nda floresta tropical e adiciona um toque de verde à casa.",
        ["JX_POTTED_SUNFLOWER"] = "O girassol no cesto de bambu transbordando luz solar é \ntão atraente que até Chester não consegue evitar se inclinar para cheirá-lo.",
        ["JX_POTTED_CHERRY"] = "A pequena e delicada oxalis de flor de cerejeira em vaso \ndá flores minúsculas de rosa suave.",
        ["JX_POTTED_ROSE"] = "A pureza das rosas brancas \ne a elegância dos lírios simbolizam o amor puro.",
        ["JX_POTTED_CACTUS"] = "Uma planta em vaso fofa com flores pequenas e brilhantes \nque contrastam fortemente com as esferas verdes.",
        ["JX_POTTED_ANTHURIUM"] = "Planta decorativa em vaso de antúrio \nnativa das florestas tropicais da Colômbia.",
        ["JX_POTTED_SNAKEPLANT"] = "As folhas são eretas e bem moldadas, \ncom padrões únicos, combinando textura minimalista com charme natural selvagem.",
        ["JX_POTTED_NARCISSUS"] = "O narciso é uma planta ornamental comum, \namada por muitos entusiastas de flores.",
        ["JX_ROSE_BIG_POTTED"] = "Vaso europeu de pé alto, com corpo de porcelana branca adornado por douração,\nexibindo rosas vermelhas, uma peça de arte floral decorativa retrô e luxuosa.",
        ["JX_CHLOROPHYTUM_COMOSUM_POTTED"] = "Elegante arranjo floral decorativo para interiores.",
        ["JX_XUNCAT"] = "Um gato laranja está tirando uma soneca, \nnão a~c~o~r~d~e o gato.",
        ["JX_RED_ROSE_POTTED"] = "Pode decorar bem o cômodo, \ntornando o ambiente interno mais bonito.",
        ["JX_GREEN_PALM"] = "O 'purificador de ar' do escritório entende as necessidades \nrespiratórias dos moradores urbanos melhor do que uma jiboia.",
        ["JX_POTTED_GARDENIA"] = "A gardênia simboliza pureza, beleza e amor eterno.",
        ["JX_POTTED_MONSTERA"] = "As folhas têm formato único e cor verde perene, \nsendo uma ótima planta de vaso para interiores.",
        ["JX_PERFUME_POTTED"] = "Decoração de casa com plantas verdes frescas e ornamentos.",
        ["JX_PRINCESS_POTTED"] = "Purificação do ar interno e decoração com plantas verdes.",
        ["JX_POTTED_BERRY"] = "Plantas de baga em vaso cuidadosamente aparadas.",
        ["JX_POTTED_MEXICO"] = "O cacto multi-braços de estilo exótico traz \num charme selvagem mexicano para a residência.",
        ["JX_COLCHICUM"] = "O cesto tecido está cheio de açafroa-de-outono roxo claro.",

        -- =====================================================================
        -- Eletrodomésticos e cozinha
        -- =====================================================================
        ["JX_COOKPOT"] = "Uma panela elétrica de cozinha vermelha retrô, \ncom vapor enrolando entre a panela de cobre e o fogão.",
        ["JX_COOKPOT_2"] = "Uma panela de pressão elétrica clássica cor de carvalho,\numa panela de cozinha multifuncional comumente usada em cozinhas domésticas.",
        ["JX_ICEBOX"] = "A geladeira azul com forte vibe vintage \nadiciona um toque retrô à cozinha.",
        ["JX_ICEBOX_2"] = "A adorável geladeira em formato de urso é um sucesso entre as meninas.",
        ["JX_ICEBOX_BIG"] = "Geladeiras de armazenamento de alimentos de grau comercial com paleta de cores laranja e branco.",
        ["JX_OVEN"] = "Forno retrô e requintado, \nusado para grelhar e cozinhar ingredientes favoritos.",
        ["JX_TOASTER"] = "A forma arredondada da torradeira, \ncombinada com paletas de cores retrô, \ndá às pessoas um sentimento nostálgico.",
        ["JX_BASKET"] = "Cestos de vegetais tecidos à mão.",
        ["JX_ICEMAKER"] = "Use esta máquina de precisão para fabricar cubos de gelo.",
        ["JX_CHARCOAL_STOVE"] = "Refinando lenha em chamas.",
        ["JX_CANNER"] = "Em meio ao rugido do vapor e das engrenagens,\nproduza em massa vários tipos de latas.",
        ["JX_PICKLING_BARREL"] = "Barris de carvalho vedados e conservantes usados para marinhar ingredientes",
        ["JX_HONEY_BOX"] = "O prédio exala uma doce fragrância âmbar\ne exala o charme de uma propriedade rural.",
        ["JX_BAGUETTE"] = "Talvez eu deva passar um pouco de manteiga ou geleia primeiro,\ndo contrário não conseguirei mastigá-lo.",
        ["JX_BAGUETTE_EDIBLE"] = "Está muito mais macio agora.",
        ["JX_KEBAB"] = "Um espeto de carne com gordura e magra alternadas, envolto em especiarias",
        ["JX_CAN0"] = "Salgado e salgado, com gosto de sal do mar.",
        ["JX_CAN1"] = "Vamos jantar!",
        ["JX_CAN2"] = "Peixe seco delicioso!",
        ["JX_DRINK_COFFEE"] = "Um pouco amargo.",
        ["JX_DRINK_COLA"] = "Refrigerante delicioso!",
        ["JX_DRINK_TEA"] = "Ajuda a reviver minha mente.",

        -- =====================================================================
        -- Móveis: baús, armários, mesas, cadeiras, camas
        -- =====================================================================
        ["JX_CHEST"] = "As nervuras de folha de bordô marcadas na tampa da caixa \nainda guardam os suspiros da floresta do último outono.",
        ["JX_CHEST_2"] = "Guarde os tesouros reais e as raridades no reino secreto.",
        ["JX_TENT"] = "Nas sombras das cortinas de cama cor de tangerina, \num grande sonho da era vitoriana repousa adormecido.",
        ["JX_TV"] = "A TV retrô equipada com um Console Vermelho e Branco (Famicom/NES) \npode transformar pixels em realidade no momento em que você aperta o botão de energia.",
        ["JX_FISH_TANK"] = "O fedor salgado de navios mercantes naufragados do século XVII \nestá preso nos padrões esculpidos de ondas na moldura de carvalho vermelho do armário.",
        ["JX_PHONOGRAPH"] = "O clique do disco giratório reproduziu o \ntom de ocupado de um certo século no fone vazio.",
        ["JX_TAPEPLAYER"] = "Um gravador de fita cassete retrô carrega as impressões sonoras do tempo.",
        ["JX_WATERINGCAN"] = "Uma chaleira de chá de flores palaciana de alto padrão com \ncorpo de porcelana branco leitoso e renda laranja.",
        ["JX_SOFA_1"] = "Sofá de couro premium com renda de Bologne.",
        ["JX_SOFA_2"] = "Sofá de couro premium com renda de Bologne.", -- alias de JX_SOFA_1
        ["JX_SOFA_3"] = "Flores esculpidas retrô combinadas com vermelho rosa, \ncom textura de couro genuíno adequada para sofás de alto padrão em mansões.",
        ["JX_TABLE"] = "Mesa premium com renda de Bologne.",
        ["JX_TABLE_2"] = "Originária da capital literária da Itália, \ntem um feeling narrativo retrô e romântico.",
        ["JX_TABLE_3"] = "Uma mesa quadrada de madeira maciça com estilo artístico europeu, \ncoberta com uma toalha de mesa xadrez luxuosa.",
        ["JX_TABLE_4"] = "Mesa de jantar de madeira maciça esculpida em vermelho rosa, \na primeira escolha para refeições elegantes e sofisticadas.",
        ["JX_TABLE_5"] = "As flores esculpidas douradas refletem a luz do espelho, \ne o tecido de veludo clássico complementa os itens \nde toucador luxuosos e elegantes.",
        ["JX_TABLE_6"] = "Uma mesa de exposição esculpida retrô europeu com uma toalha de estilo natalino.",
        ["JX_TABLE_7"] = "A pia montada em coluna estilo europeu,\nadornada com padrões decorativos dourados e\num armário com espelho, tem um design retrô e luxuoso.",
        ["JX_TABLE_8"] = "Lareira de pedra estilo europeu.",
        ["JX_TABLE_9"] = "Armário de pia de lavar louça de madeira maciça.",
        ["JX_CHAIR_1"] = "Banco de couro pequeno no estilo artístico de Florence.",
        ["JX_CHAIR_2"] = "Cadeiras de madeira maciça com estilo artístico europeu.",
        ["JX_CHAIR_3"] = "As cadeiras que balançam para frente e para trás através da base curva \nsão feitas de couro vermelho rosa, o que parece muito elegante.",
        ["JX_CHAIR_4"] = "O vaso sanitário em estilo retrô europeu tem um corpo branco leve\ncom acabamento dourado e um design clássico de tampa com dobradiça.",
        ["JX_WARDROBE"] = "Um guarda-roupa de madeira maciça neoclássico, \num diálogo entre esculturas de rosas douradas e madeira de nogueira ao longo do tempo.",
        ["JX_SEWINGMACHINE"] = "Uma máquina de costura preta fosca com linhas douradas, \num tesouro de colecionador com a marca do tempo.",
        ["JX_BOOKCASE"] = "Originária da estética de móveis da dinastia Windsor, \nas linhas são elegantes e solenes, combinando textura clássica com armazenamento prático.",
        ["JX_CABINET"] = "Um armário de exposição esculpido antigo branco leitoso com design de porta de vidro única.",
        ["JX_BATHTUB"] = "Uma banheira de porcelana branca que se conforma à estética complexa do estilo Baroque.",
        ["JX_HANGING_BED"] = "Uma rede de pendurar com franjas projetada com padrões étnicos boêmios.",
        ["JX_STORAGE_BASKET"] = "Flores amarelas decoram cestos rústicos de vime.",
        ["JX_PACK"] = "Uma bolsa bento de urso de pelúcia de alto padrão, uma companheira de armazenamento para refeições durante viagens, \nou um item decorativo que realça o estilo da decoração de casa.",
        ["JX_HANDCART"] = "É um veículo de madeira de tempos antigos.",
        ["JX_WOOD_BIN"] = "Armazenamento ordenado de lenha para a lareira.",
        ["JX_ROCK_BIN"] = "Organize e armazene materiais de pedra de construção de forma ordenada.",
        ["JX_HAY_CART"] = "Carregado de feno dourado, incorpora plenamente a atmosfera serena do campo.",
        ["JX_CELLAR"] = "Projetado especialmente para envelhecer vinhos finos e armazenar materiais preciosos.",
        ["JX_TRASH_CAN"] = "Limpar é importante.",
        ["JX_VENDING_MACHINE"] = "Parece um pouco enferrujada.",
        ["JX_FARM_TOOLS_CONTAINER"] = "Parece um pouco instável.",
        ["JX_DISASSEMBLER"] = "Ajuda a decompor e reciclar materiais, mas leva tempo.",
        ["JX_BANKATM"] = "Guarde nossas economias.",
        ["JX_CATCOIN"] = "Dourado, tão bonito.",

        -- =====================================================================
        -- Iluminação
        -- =====================================================================
        ["JX_MUSHROOM_LIGHT"] = "Colunas ornamentadas de ferro fundido, \nLuz quente através de vitral, \nProjetada nas paredes desgastadas do palácio.",
        ["JX_MUSHROOM_LIGHT_2"] = "Luminárias de madeira maciça vermelho rosa, \nintrincadamente trabalhadas com textura e luz suave, \ncapturando os momentos elegantes da decoração de casa.",
        ["JX_LAMP"] = "Vinhas douradas emitem brilho quente, a elegância francesa reina.",
        ["JX_LAMP_2"] = "O design de três braços, combinado com uma base decorativa, exala uma elegância retrô.",
        ["JX_LANTERN"] = "A luminária noturna criativa em formato de rosa combina decoração \ne praticidade, criando uma atmosfera romântica para o espaço.",
        ["JX_LANTERN_2"] = "A luz fraca brilha como as estrelas no céu noturno.",
        ["JX_LANTERN_3"] = "A luz fraca pisca suavemente,\ncarregando uma aura misteriosa e sinistra.",
        ["JX_FURNACE"] = "Aquecedor de querosene Neuburg retrô.",
        ["JX_FLASHLIGHT"] = "Uma lanterna portátil e prática com corpo\nverde fresco, adequada para uso diário.",
        ["JX_BATTERY1"] = "Fornece suporte de energia.",
        ["JX_BATTERY2"] = "Fornece suporte de energia.", -- alias de JX_BATTERY1
        ["JX_PARTS_LIGHT"] = "Nos encontraremos novamente esta noite?",

        -- =====================================================================
        -- Tapetes / carpetes / pisos
        -- =====================================================================
        ["JX_RUG_OVAL"] = "Combinando o temperamento elegante de Vienna com o toque aveludado \ne a textura luxuosa do tapete oval.",
        ["JX_RUG_OVAL_ITEM"] = "Combinando o temperamento elegante de Vienna com o toque aveludado \ne a textura luxuosa do tapete oval.", -- alias de JX_RUG_OVAL
        ["JX_RUG_FOREST"] = "Uma manta quadrada de tecido que traz a \nfrescura e tranquilidade da natureza para a vida doméstica.",
        ["JX_RUG_FOREST_ITEM"] = "Uma manta quadrada de tecido que traz a \nfrescura e tranquilidade da natureza para a vida doméstica.", -- alias de JX_RUG_FOREST
        ["JX_RUG_AUBUSSON"] = "Padrões requintados e cores vibrantes.",
        ["JX_RUG_AUBUSSON_ITEM"] = "Padrões requintados e cores vibrantes.", -- alias de JX_RUG_AUBUSSON
        ["JX_RUG_TRADITION"] = "Resistente ao desgaste e liso.",
        ["JX_RUG_TRADITION_ITEM"] = "Resistente ao desgaste e liso.", -- alias de JX_RUG_TRADITION
        ["JX_RUG_SAVANNAH"] = "Artesanato clássico europeu.",
        ["JX_RUG_SAVANNAH_ITEM"] = "Artesanato clássico europeu.", -- alias de JX_RUG_SAVANNAH
        ["JX_RUG_TRIANGLE"] = "Integrando clássicos elementos de totem tribal dos nativos americanos, \npadrões geométricos colidem com cores étnicas para criar um charme único.",
        ["JX_RUG_TRIANGLE_ITEM"] = "Integrando clássicos elementos de totem tribal dos nativos americanos, \npadrões geométricos colidem com cores étnicas para criar um charme único.", -- alias de JX_RUG_TRIANGLE
        ["JX_RUG_PLATONI"] = "O padrão requintado e suave traz conforto e calor.",
        ["JX_RUG_PLATONI_ITEM"] = "O padrão requintado e suave traz conforto e calor.", -- alias de JX_RUG_PLATONI
        ["TURF_GRANITE"] = "Sejam os padrões delicados do mármore ou a textura granular do granito, \neles podem restaurar com precisão o estilo sofisticado da pedra natural.",
        ["TURF_REDDISH_BROWN"] = "Tecido decorativo em estilo clássico europeu.",
        ["TURF_CORRIDOR"] = "Tapete decorativo antiderrapante para sala e quarto.",
        ["TURF_BATH"] = "Talvez eu possa usá-lo para cobrir o piso do banheiro.",
        ["TURF_JX_WOOD"] = "Piso laminado de madeira maciça com estilo palaciano.",
        ["TURF_JX_COURTYARD"] = "Materiais de pavimentação quadrados projetados para pátios externos,\nterraços, passarelas e jardins.",

        -- =====================================================================
        -- Mochilas / bolsas
        -- =====================================================================
        ["JX_BACKPACK"] = "Uma mochila de coelhinho de piquenique fofa estilo Lolita \nde edição limitada que pode guardar muitas coisas.",
        ["JX_BACKPACK_2"] = "Mochila de coelho com orelhas caídas Bonnet fofa de edição limitada.",
        ["JX_BACKPACK_3"] = "Uma mochila prática com um design retrô \nde boneca de gato de três cores como núcleo.",
        ["JX_BACKPACK_4"] = "Mochila de boneca fofa em formato de pequeno guaxinim.",
        ["JX_BACKPACK_5"] = "Uma mochila de pintinho adequada para roupas divertidas infantis.",
        ["JX_RUG_BAG"] = "A governanta nos deixou bolsas de couro cilíndricas para que as pequenas empregadas recolham tapetes.",

        -- =====================================================================
        -- Chapéus / capacetes
        -- =====================================================================
        ["JX_HAT_IRON_PAN"] = "Uma panela velha, o furo no fundo da panela foi consertado, \nmas só pode ser usada como capacete.",
        ["JX_HAT_SUNFLOWER"] = "Chapéu de palha de girassol em estilo rural.",
        ["JX_HAT_WHITE_ROSE"] = "Elegante ornamento de cabeça nobre de rosa branca com estilo palaciano retrô.",
        ["JX_HAT_MEXICO"] = "Um chapéu de palha exótico originário do estilo mexicano.",
        ["JX_HAT_REINDEER"] = "Um chapéu com padrão de veado manchado com chifres de veado e pelúcia de proteção para as orelhas.",
        ["JX_HAT_NOODLES"] = "Parece delicioso.",
        ["JX_HAT_MOTORCYCLE"] = "Tenho o pressentimento de que vai ser útil.",
        ["JX_HAT_SIGURD"] = "Capacete do Herói Nórdico Matador de Dragões.",
        ["JX_HAT_HEPBURN"] = "Um chapéu elegante de aba larga xadrez preto e branco\nadornado com rosas pretas e penas.",
        ["JX_FROG_RAINCOAT"] = "Um conjunto impermeável em formato de sapo.",

        -- =====================================================================
        -- Armas / ferramentas
        -- =====================================================================
        ["JX_PAN"] = "A frigideira francesa enferrujada já não pode cozinhar.",
        ["JX_WEAPON_1"] = "Um garfo comumente usado na culinária ocidental, \ncombinado com uma faca estilo ocidental.",
        ["JX_WEAPON_2"] = "As facas comumente usadas na culinária ocidental são muito afiadas.",
        ["JX_WEAPON_3"] = "A colher comumente usada na culinária ocidental tem muita textura.",
        ["JX_WEAPON_4"] = "Dizem ser o vinho favorito da Senhora Charles.",
        ["JX_WEAPON_5"] = "Muito prático.",
        ["JX_FAN"] = "Considerações práticas e decorativas.",
        ["JX_WELL"] = "Padrões requintados, destacando nobreza.",
        ["JX_WASHER"] = "Uma máquina de lavar com textura de borda metálica totalmente esticada \ne prática em termos de cuidado inteligente e aparência.",
        ["JX_TOILET_SUCTION"] = "Pode ser usado para sugar tapetes.",
        ["JX_HOLY_SWORD"] = "Uma espada sem igual, capaz de matar dragões e\nvencer demônios, carregando o destino e a glória dos heróis.",
        ["JX_WAR_HOE"] = "A enxada divina empunhada por Enlil, o deus sumério do vento",

        -- =====================================================================
        -- Construções / paredes / cercas / exteriores
        -- =====================================================================
        ["JX_MAILBOX"] = "Uma villa de alto padrão com uma caixa de correio de ferro retrô na placa da porta.",
        ["WALL_JX_STONE"] = "Colunas de parede de pedra retrô europeias,\ndecoradas com anéis de pedra redonda no topo,\ncom corpo principal de tijolo e base esculpida.",
        ["WALL_JX_STONE_ITEM"] = "Colunas de parede de pedra retrô europeias,\ndecoradas com anéis de pedra redonda no topo,\ncom corpo principal de tijolo e base esculpida.", -- alias de WALL_JX_STONE
        ["WALL_JX_STONE_2"] = "Adornado com flores e vinhas intrincadas, \nincorpora plenamente uma estética clássica e romântica.",
        ["WALL_JX_STONE_2_ITEM"] = "Adornado com flores e vinhas intrincadas, \nincorpora plenamente uma estética clássica e romântica.", -- alias de WALL_JX_STONE_2
        ["WALL_JX_STONE_3"] = "Design de escultura de totem, decoração arquitetônica de pátio em estilo sombrio.",
        ["WALL_JX_STONE_3_ITEM"] = "Design de escultura de totem, decoração arquitetônica de pátio em estilo sombrio.", -- alias de WALL_JX_STONE_3
        ["WALL_JX_STRAW_1"] = "Cerca viva perene de propriedade em estilo europeu,\nplantas de decoração de paisagem de villa.",
        ["WALL_JX_STRAW_1_ITEM"] = "Cerca viva perene de propriedade em estilo europeu,\nplantas de decoração de paisagem de villa.", -- alias de WALL_JX_STRAW_1
        ["JX_FENCE"] = "As balaustradas quadradas de pedra parecem muito resistentes.",
        ["JX_FENCE_ITEM"] = "As balaustradas quadradas de pedra parecem muito resistentes.", -- alias de JX_FENCE
        ["JX_FENCE_2"] = "Enlaçada com flores rosa e vinhas verdes, \ncomplementa lindamente a coluna floral.",
        ["JX_FENCE_2_ITEM"] = "Enlaçada com flores rosa e vinhas verdes, \ncomplementa lindamente a coluna floral.", -- alias de JX_FENCE_2
        ["JX_FOUNTAIN"] = "Ornamentos decorativos de arte em escultura de pedra ao ar livre.",
        ["JX_FIREPLUG"] = "Decore as instalações de combate a incêndio na paisagem urbana.",
        ["JX_PORTABLETENT"] = "A primeira escolha para atmosfera de acampamento ao ar livre",
        ["JX_PORTABLETENT_ITEM"] = "A primeira escolha para atmosfera de acampamento ao ar livre", -- alias de JX_PORTABLETENT
        ["JX_CHESTER_HOUSE"] = "Ofereça um lugar quente de descanso para parceiros leais.",
        ["JX_GLOMMER_HOUSE"] = "Eu costumava criar um canário aqui, mas agora é o habitat do Glommer.",
        ["JX_CAT_TREE"] = "Ofereça um lugar para gatos descansarem e explorarem.",

        -- =====================================================================
        -- Carrinho / Beetle / peças de carro
        -- =====================================================================
        ["JX_CAR"] = "Sedan pequeno clássico, com design arredondado retrô.",
        ["JX_GASOLINE"] = "Alta octanagem, excelente resistência à detonação, \nlimpo e com baixo teor de enxofre.",
        ["JX_CAR_KEY"] = "Aperte o cinto. Estamos prontos para partir agora.",
        ["JX_PARTS_COLOUR"] = "Busque mais individualidade.",
        ["JX_PARTS_MUSIC"] = "Acredito que a maioria das pessoas dá grande importância à música no carro.",
        ["JX_PARTS_ENGINE"] = "É incrivelmente desafiador inventar \ntal estrutura mecânica na selva.",
        ["JX_PARTS_WHEEL"] = "Segurando-a, sinto a magia fluindo pela minha palma.",
        ["JX_PARTS_CAMERA_1"] = "Talvez fosse melhor se eu dirigisse mais devagar.",
        ["JX_PARTS_CAMERA_2"] = "Máquinas com um pouco de inteligência,\npodem ser úteis em competições de derrapagem.",

        -- =====================================================================
        -- Instrumentos musicais / decoração
        -- =====================================================================
        ["JX_PIANO"] = "Um piano de alto padrão retrô estilo europeu projetado para uso real.",
        ["JX_SAXOPHONE"] = "Adicione um ambiente romântico a bailes palacianos e tavernas noturnas.",
        ["JX_CELLO"] = "Toque a melodia melancólica das profundezas do antigo castelo.",
        ["JX_HARP"] = "Tocando uma peça musical onírica reminiscente de um reino mágico medieval.",
        ["JX_DRESS_FORM_M"] = "Estilo de roupa de cavalheiro adornado com combinação de cores preto e dourado.",
        ["JX_DRESS_FORM_W"] = "Saia preta com acabamento branco e decoração de laço.",

        -- =====================================================================
        -- Miscelânea / estátuas / livros / relógios / panelas portáteis
        -- =====================================================================
        ["CHESSPIECE_JX"] = "Fiz uma escultura da empregada, Srta. Jingxi.", -- bug fix: CHESSPIECES_JX -> CHESSPIECE_JX (singular)
        ["JX_WIKI_BOOK"] = "Este livro redirecionará para um site wiki chinês,\nentão, por favor, seja paciente e aguarde atualizações..",
        ["JX_MANTEL_CLOCK"] = "O relógio antes favorito da Srta. Wanda parou de tic-tac.",
        ["JX_PORTABLE_COOK_POT"] = "Uma panela de ensopado resistente e confiável para exploração ao ar livre e acampamentos.",
        ["JX_PORTABLE_COOK_POT_ITEM"] = "Uma panela de ensopado resistente e confiável para exploração ao ar livre e acampamentos.", -- alias de JX_PORTABLE_COOK_POT
        ["JX_PORTABLE_COOK_POT_2"] = "Uma panela de barro de fogo de carvão com\numa pega em formato de rabo de um gato guaxinim.",
        ["JX_PORTABLE_COOK_POT_2_ITEM"] = "Uma panela de barro de fogo de carvão com\numa pega em formato de rabo de um gato guaxinim.", -- alias de JX_PORTABLE_COOK_POT_2
    },
}
