---@diagnostic disable: duplicate-doc-alias, duplicate-doc-field, duplicate-set-field

---@alias WeaponType 'ranged'|'melee'

---@class (exact) WeaponData
---@field image string
---@field psychic? boolean
---@field legendary? boolean

---@type { [WeaponType]: { [string]: WeaponData } }
local weapons = {
    ranged = {
        ["Boltgun"] = { image = 'https://steamusercontent-a.akamaihd.net/ugc/2026110045822605410/441D4A3AF7ECC5E5207EE5DD4AEF7AE14CDACBAA/' },

        --[ AELDARI ]--
        ["D-cannon"] = { image = 'https://steamusercontent-a.akamaihd.net/ugc/2026110045837497853/71075587E7EED7EC649B55BC94D9FDD159386CDD/' },
        ["Destructor"] = {
            image = 'https://steamusercontent-a.akamaihd.net/ugc/2026110045837275902/836DD060AF16CEE76A8A59F491C41D9907977821/',
            psychic = true
        },
        ["Eldritch Storm"] = {
            image = 'https://steamusercontent-a.akamaihd.net/ugc/2026110045837275957/1B3376A024C9A51CD77403DDFECEB7335A99EADC/',
            psychic = true,
        },
        ["Fury of the Tempest"] = { image = 'https://steamusercontent-a.akamaihd.net/ugc/2026110045837466631/89E7FBD27D14E5BC059988AA752011D7C2DF7DC3/' },
        ["Las-blaster"] = { image = 'https://steamusercontent-a.akamaihd.net/ugc/2026110045837466700/7B2C15A485725C5FD853B819D7FB380FC29DFA2E/' },
        ["Prism cannon"] = { image = 'https://steamusercontent-a.akamaihd.net/ugc/2026110045837491216/62F2E2F4A1138900135FA897B80FB7CBA4BDC770/' },
        ["Prism rifle"] = { image = 'https://steamusercontent-a.akamaihd.net/ugc/2026110045837491216/62F2E2F4A1138900135FA897B80FB7CBA4BDC770/' },
        ["Ranger long rifle"] = { image = 'https://steamusercontent-a.akamaihd.net/ugc/2026110045837276007/828BB1F31088BD2DE43A6AAB6FFB5D03B6EF7541/' },
        ["Reaper launcher"] = { image = 'https://steamusercontent-a.akamaihd.net/ugc/2026110045842351026/BEA6AC012592176F6F0388A9D78AC1369244B93E/' },
        ["Searsong"] = { image = 'https://steamusercontent-a.akamaihd.net/ugc/2026110045843022977/9B5349F7AA8A0E2E935EFB4ECA859B1D160DA70F/' },
        ["Shuriken cannon"] = { image = 'https://steamusercontent-a.akamaihd.net/ugc/2026110045837276078/00BCA7379E46DD5741F65DB8FB3A7A7A4DCFBE30/' },
        ["Shuriken catapult"] = { image = 'https://steamusercontent-a.akamaihd.net/ugc/2026110045837276145/56F051876AF13221DB1B8B4E0B1984E51AE9F8E3/' },
        ["Shuriken pistol"] = { image = 'https://steamusercontent-a.akamaihd.net/ugc/2026110045837276209/C1D3F6B7C845C8CD20426A9224A74B072C3E7EB6/' },
        ["Singing spear"] = { image = 'https://steamusercontent-a.akamaihd.net/ugc/2026110045837276314/60CCFBCA87D883CD290D4520FD9FCA8E654C0CB8/' },
        ["Storm of Whispers"] = {
            image = 'https://steamusercontent-a.akamaihd.net/ugc/2026110045842350877/CB79D094301179E8A87A19E03D2E9A879663E36C/',
            psychic = true,
            legendary = true
        },
        ["Swirling soul energy"] = {
            image = 'https://steamusercontent-a.akamaihd.net/ugc/2026110045842351075/B896E353733F6621600893782F56A7CFD445DA6F/',
            psychic = true
        },
        ["Twin shuriken cannon"] = { image = 'https://steamusercontent-a.akamaihd.net/ugc/2026110045843023179/87EB000DE62F1063B91F1472827D16CB5E5C4F12/' },
        ["Twin shuriken catapult"] = { image = 'https://steamusercontent-a.akamaihd.net/ugc/2026110045837276366/6D0A2F9FDD059F0D7A69BD65CF6A90C349C85A78/' },
        ["Voidbringer"] = {
            image = 'https://steamusercontent-a.akamaihd.net/ugc/2026110045837276482/857D80904506FBDE567E1746D44EB0EEEB45D979/',
            legendary = true
        },
        ["Wraithcannon"] = { image = 'https://steamusercontent-a.akamaihd.net/ugc/2026110045837497853/71075587E7EED7EC649B55BC94D9FDD159386CDD/' },

        --[ IMPERIUM ]--
        ["Autocannon"] = { image = 'https://steamusercontent-a.akamaihd.net/ugc/2026110045825226821/ABEADFEC16DAFCD8E0D68559D51AB6D413382FF8/' },
        ["Battle cannon"] = { image = 'https://steamusercontent-a.akamaihd.net/ugc/2290711113495397861/3F79F235859E5409D2F95F0D831DB82B578A87CE/' },
        ["Bolt pistol"] = { image = 'https://steamusercontent-a.akamaihd.net/ugc/2026110045825448007/AC013F9316F648BEF193CD32693B46D262672AD1/' },
        ["Combi-weapon"] = { image = 'https://steamusercontent-a.akamaihd.net/ugc/2026112042190146381/AE9EED38BC26E9DA8EDC6E7AF4D997E9125DABC3/' },
        ["Demolisher battle cannon"] = { image = 'https://steamusercontent-a.akamaihd.net/ugc/2026110045825543678/98876EA4EFE8DD885C1EEE6701036A53EB0CAD08/' },
        ["Flamer"] = { image = 'https://steamusercontent-a.akamaihd.net/ugc/2026110045825441876/62710BF8DD36AC949805999B5E0B3827FC3E78CA/' },
        -- Gatling cannon
        -- Hand flamer
        ["Heavy bolter"] = { image = 'https://steamusercontent-a.akamaihd.net/ugc/2026110045825225475/A0CAA80369CC02298FA61BC20E78101E77B8CDEB/' },
        ["Heavy flamer"] = { image = 'https://steamusercontent-a.akamaihd.net/ugc/2026110045849081260/9CE1A271BCFBA0CC5B7BA5CDC319217E6507A1F1/' },
        ["Heavy stubber"] = { image = 'https://steamusercontent-a.akamaihd.net/ugc/2026110045825189261/056A4DCF500E82B4335BFEA26C56ADFF6216796E/' },
        ["Hunter-killer missile"] = { image = 'https://steamusercontent-a.akamaihd.net/ugc/2026110045825173330/74F2361949950FFA2FE2D85DB0F5E7E4D00B82C1/' },
        ["Lascannon"] = { image = 'https://steamusercontent-a.akamaihd.net/ugc/2026109925065822863/B15EC01F2F196B09E60A09D173277319B95C3534/' },
        ["Meltagun"] = { image = 'https://steamusercontent-a.akamaihd.net/ugc/2026110045849190911/093F446C9944AB95620B64B99D0FFA03F2067A94/' },
        -- Missile launcher
        ["Multi-melta"] = { image = 'https://steamusercontent-a.akamaihd.net/ugc/2026110045825541751/9FE95DCF1AE663156F3059207DB328483728B93A/' },
        ["Plasma cannon"] = { image = 'https://steamusercontent-a.akamaihd.net/ugc/2290711113495572727/BF7CED5203FA28021E34913F4623F5C254A41F77/' },
        ["Plasma gun"] = { image = 'https://steamusercontent-a.akamaihd.net/ugc/2026110045825462245/22178A298AE143A272629550256E5BEFBE721B37/' },
        ["Plasma pistol"] = { image = 'https://steamusercontent-a.akamaihd.net/ugc/2026110045825286980/FCD007E432C1212863252C34C61D0C7AC0305AAB/' },
        ["Storm bolter"] = { image = 'https://steamusercontent-a.akamaihd.net/ugc/2026109925065847883/C22DBAE979A23E492F157D06ABC5D194D5513423/' },
        ["Twin-linked heavy bolter"] = { image = 'https://steamusercontent-a.akamaihd.net/ugc/2467488810344076931/C267FEF1AC23384B2BD4BE854283A6225CEAA6D1/' },
        ["Twin-linked heavy flamer"] = { image = 'https://steamusercontent-a.akamaihd.net/ugc/2467488810344076995/D3CDDCEDEBB50815B498B07A11E60B0FFB1FB613/'},
        ["Twin-linked heavy stubber"] = { image = 'https://steamusercontent-a.akamaihd.net/ugc/2467488810344077046/6F839CFCEEF15BA1FC41D87A3D2C7AE5D5AFC3EB/' },
        ["Twin heavy bolter"] = { image = 'https://steamusercontent-a.akamaihd.net/ugc/2467488810344076931/C267FEF1AC23384B2BD4BE854283A6225CEAA6D1/' },
        -- Twin multi-melta
        -- Twin storm bolter

        --[ ADEPTA SOROITAS ]--
        ["Condemnor boltgun"] = { image = 'https://steamusercontent-a.akamaihd.net/ugc/2026110045842469370/F28998B43BA740097642A4762A081CF3D901B0FC/' },
        ["Fidelis"] = {
            image = 'https://steamusercontent-a.akamaihd.net/ugc/2467488810344070783/0F17614B9D6276A96A854A24F5DD53FA7566B85A/',
            legendary = true
        },
        ["Paragon grenade launchers"] = { image =  'https://steamusercontent-a.akamaihd.net/ugc/2467488810344070908/64EF21B94B700B2344A5B136E5F010952251176E/' },
        ["Paragon missile launcher"] = {image = 'https://steamusercontent-a.akamaihd.net/ugc/2026109925065839329/9B74D5C7E351D7E07CF6D32118DF002DA9B42873/' },
        -- ["Twin Ministorum heavy flamer"] = { image = 'https://steamusercontent-a.akamaihd.net/ugc/2467488810344076995/D3CDDCEDEBB50815B498B07A11E60B0FFB1FB613/'},

        --[ ADEPTUS ASTARTES ]--
        -- Fragstorm grenade launcher
        -- Icarus rocket pod
        -- Incendium cannon - heavy flamer
        -- ["Lancer laser destroyer"] = { image = 'https://steamusercontent-a.akamaihd.net/ugc/2026109925065822863/B15EC01F2F196B09E60A09D173277319B95C3534/' },
        -- ["Las-talon"] = { image = 'https://steamusercontent-a.akamaihd.net/ugc/2026109925065822863/B15EC01F2F196B09E60A09D173277319B95C3534/' },
        -- Macro plasma incinerator - plasma cannon
        -- Smite
        -- Twin icarus ironhail heavy stubber
        -- Twin ironhail autocannon
        -- Twin ironhail heavy stubber
        ["Typhoon missile launcher"] = { image = 'https://steamusercontent-a.akamaihd.net/ugc/2026110045832620758/42A369BB53993986AC77F491E6FF8628E28AAE2F/' },

        --[ AGENTS OF THE IMPERIUM ]--
        ["Arbites grenade launcher"] = {image = 'https://steamusercontent-a.akamaihd.net/ugc/2026110045837845664/AA480A7D611868E6978B5BDD68957B8600501AF4/'},
        ["Archeotech pistol"] = { image = 'https://steamusercontent-a.akamaihd.net/ugc/2026110045828451561/9CD5D80B8103CCD2E574117BEB8116876BC5C63A/' },
        ["Castigation"] = {
            image = 'https://steamusercontent-a.akamaihd.net/ugc/2026110045847666883/4F0407B7191CACE5FCC1FEA33D0AB3633ECDBDAC/',
            psychic = true,
            legendary = true
        },
        ["Condemnor stake"] = { image = 'https://steamusercontent-a.akamaihd.net/ugc/2026110045842469370/F28998B43BA740097642A4762A081CF3D901B0FC/' },
        ["Exitus pistol"] = { image = 'https://steamusercontent-a.akamaihd.net/ugc/2026110045825448007/AC013F9316F648BEF193CD32693B46D262672AD1/' },
        ["Exitus rifle"] = { image = 'https://steamusercontent-a.akamaihd.net/ugc/2026110045825408110/662E6E109A450BEA5BB99FBD4E29618A327CD8C0/' },
        -- ["Mind Assault"] = {
        --     image = nil,
        --     psychic = true,
        --     legendary = true
        -- },
        -- ["Psychic Blast"] = {
        --     image = nil,
        --     psychic = true
        -- },
        ["Psychic Shock Wave"] = {
            image = 'https://steamusercontent-a.akamaihd.net/ugc/2026112042190162250/164F281B6C91D1AF6B3C2CF87BD74BF6EABFCA69/',
            psychic = true
        },
        -- ["Unholy Gaze"] = {
        --     image = nil,
        --     psychic = true
        -- },

        --[ ASTRA MILITARUM ]--
        ["Deathstrike missile"] = { image = 'https://steamusercontent-a.akamaihd.net/ugc/2467488810344221887/AC8F3D9D22C114D28F82F351CCEB813E1D7A38F6/' },
        ["Drum-fed autogun"] = { image = 'https://steamusercontent-a.akamaihd.net/ugc/2026110045825459964/06AD75B5FC773BB139CB67A8A2F0FA25F8DFFAFB/' },
        ["Duty and Vengeance"] = {
            image = 'https://steamusercontent-a.akamaihd.net/ugc/2026110045832865093/C09880FC0EA1EF2FAC8FC7EAF63A1988F3164770/',
            legendary = true
        },
        ["Earthshaker cannon"] = { image = 'https://steamusercontent-a.akamaihd.net/ugc/2026110045825433773/8B6FAE1EBA5F31057877218585B1366494E8D789/' },
        ["Grenade launcher"] = { image = 'https://steamusercontent-a.akamaihd.net/ugc/2026110045837845664/AA480A7D611868E6978B5BDD68957B8600501AF4/' },
        ["Hellstrike missiles"] = { image = 'https://steamusercontent-a.akamaihd.net/ugc/2026110045832620758/42A369BB53993986AC77F491E6FF8628E28AAE2F/' },
        ["Hot-shot lasgun"] = { image = 'https://steamusercontent-a.akamaihd.net/ugc/2026110045825248834/E7DBCFC37C33C05A3742329F10B3427B5CC94A0B/' },
        ["Hot-shot volley gun"] = { image = 'https://steamusercontent-a.akamaihd.net/ugc/2026110045825351383/78734041E0F25B19462A5D672051C0D467C2ECF9/' },
        ["Lasgun"] = { image = 'https://steamusercontent-a.akamaihd.net/ugc/2026110045825250389/DF131501F2F8180DB0F0CFF19E62C0EA0EE7D19B/' },
        ["Laspistol"] = { image = 'https://steamusercontent-a.akamaihd.net/ugc/2026110045825223251/72EFA93577BD335CFFA95AA41995E6CA6FB93FA7/' },
        -- ["Las small arms"] = { image = 'https://steamusercontent-a.akamaihd.net/ugc/2026110045825223251/72EFA93577BD335CFFA95AA41995E6CA6FB93FA7/' },
        ["Multi-laser"] = { image = 'https://steamusercontent-a.akamaihd.net/ugc/2026110045825351383/78734041E0F25B19462A5D672051C0D467C2ECF9/' },
        ["Multiple rocket pod"] = { image = 'https://steamusercontent-a.akamaihd.net/ugc/2026109925065839329/9B74D5C7E351D7E07CF6D32118DF002DA9B42873/' },
        ["Psychic Maelstrom"] = {
            image = 'https://steamusercontent-a.akamaihd.net/ugc/2026110045825572994/D0711FE404E090D662ACDFA18F1827E21191E8E4/',
            psychic = true
        },
        -- ["Punisher gatling cannon"] = { image = 'https://steamusercontent-a.akamaihd.net/ugc/2026110045825195985/DCE6C3CE90578BB3D6A6C6226689CF1E09DA67D2/' },
        ["Sniper rifle"] = { image = 'https://steamusercontent-a.akamaihd.net/ugc/2026110045825408110/662E6E109A450BEA5BB99FBD4E29618A327CD8C0/' },
        ["Sol's Righteous Gaze"] = {
            image = 'https://steamusercontent-a.akamaihd.net/ugc/2026110045832693358/E3735293E9200FB802C7ECB12FF9B8AEF97B81B2/',
            legendary = true
        },
        ["Twin assault cannon"] = { image = 'https://steamusercontent-a.akamaihd.net/ugc/2026110045847667346/548A9E1B64E17569E3997A1A9FB12BF57DF20345/' },
        ["Vanquisher battle cannon"] = { image = 'https://steamusercontent-a.akamaihd.net/ugc/2290711113495397861/3F79F235859E5409D2F95F0D831DB82B578A87CE/' },

        --[ GREY KNIGHTS ] --
        -- ["Gatling psilencer"] = {
        --     image = nil,
        --     psychic = true
        -- },
        -- ["Heavy psycannon"] = {
        --     image = nil,
        --     psychic = true
        -- },
        ["Incinerator"] = { image = 'https://steamusercontent-a.akamaihd.net/ugc/2026110045849943692/D7EEE3D81AF652C67D53FD7B57CCD6165EB4EA2E/' },
        ["Psilencer"] = {
            image = 'https://steamusercontent-a.akamaihd.net/ugc/2026112042190162167/CF3EDBBFE9DF65FE6EF86713BACD245FCC45C887/',
            psychic = true
        },
        ["Psycannon"] = {
            image = 'https://steamusercontent-a.akamaihd.net/ugc/2026110045847667093/FE4DB4D04A05D5C94FDD9BFEE773ADE5FCE08598/',
            psychic = true
        },
        ["Purge Soul"] = {
            image = 'https://steamusercontent-a.akamaihd.net/ugc/2026110045847667150/B0412A3841879F1BE89228F6D888BD18618899F0/',
            psychic = true
        },
        ["Purifying Flame"] = {
            image = 'https://steamusercontent-a.akamaihd.net/ugc/2026110045847667283/BA089F2E68B96DB9AC860C7A1A86ADE77914C035/',
            psychic = true
        },

        --[ TYRANIDS ]--
        ["Barblauncher"] = { image = 'https://steamusercontent-a.akamaihd.net/ugc/2467488810344084546/083DA273F092647FAB8F95E320E9FD05A57874AC/' },
        ["Bio-plasma torrent"] = { image = 'https://steamusercontent-a.akamaihd.net/ugc/2467488810344083876/5BE418ACE753915C1971A5661C446BB6BDE1CB63/' },
        ["Dire bio-cannon"] = { image = 'https://steamusercontent-a.akamaihd.net/ugc/2467488810344083967/2FED4941C25E81EF480A238C3B6C21602139773A/' },
        ["Deathspitter"] = { image = 'https://steamusercontent-a.akamaihd.net/ugc/2467488810344084196/9C2B76ED83AD7B8F470825A6C619E42C18FD21C8/' },
        ["Fleshborer"] = { image = 'https://steamusercontent-a.akamaihd.net/ugc/2467488810344084244/3418529A71D93348E006BF0809A4B7AF72E74752/' },
        ["Rupture cannon"] = { image = 'https://steamusercontent-a.akamaihd.net/ugc/2467488810344084409/28B78ACF8000FEF9E900F598E5FD92D561DEE196/' },
        ["Shardlauncher"] = { image = 'https://steamusercontent-a.akamaihd.net/ugc/2467488810344157180/E83B6AB56F3DC2FC303DB738B99849A9B01BC110/' },
        ["Spike rifle"] = { image = 'https://steamusercontent-a.akamaihd.net/ugc/2467488810344084494/E5FDA7C57006FF1746EF66BA9393A101337151CF/' },
        ["Stinger salvoes"] = { image = 'https://steamusercontent-a.akamaihd.net/ugc/2467488810344084593/9A46075DBEA979E5B0EA5737A90E8616969B7AD5/' },
        ["Stranglethorn cannon"] = { image = 'https://steamusercontent-a.akamaihd.net/ugc/2467488810344084641/598D6EFED71D6584B032DD8ED8B485D9FFECB50F/' },
        ["Strangleweb"] = { image = 'https://steamusercontent-a.akamaihd.net/ugc/2467488810344208889/E1653A4DA90E26E327E8AAF4F5F28A1454BFE089/' },
        ["Toxinjector harpoon"] = { image = 'https://steamusercontent-a.akamaihd.net/ugc/2467488810344084686/8A4DEB40AB2B0C0EC138FD862E931E219C2AE603/' },
        ["Venom cannon"] = { image = 'https://steamusercontent-a.akamaihd.net/ugc/2467488810344084725/8582A548F47565A0356B2C30DCCA1EFA7F5CCE4E/' },
        ["Warp Blast"] = {
            image = 'https://steamusercontent-a.akamaihd.net/ugc/2467488810344084760/A4F4013CF888F2AB680FA25F6CCD89D165900724/',
            psychic = true
        }
    },
    melee = {
        ["Close combat weapon"] = { image = 'https://steamusercontent-a.akamaihd.net/ugc/2026110045822606558/32E4DAB0ADF4BAF6A9E49BC04DDFA0CC1AEE75E4/'},
        ["Force weapon"] = {
            image = 'https://steamusercontent-a.akamaihd.net/ugc/2026110045822610141/03CCEF8A833FA27D11DAF132EAE3BF9EB98DAB6E/',
            psychic = true
        },

        --[ AELDARI ]--
        ["Aeldari power sword"] = { image = 'https://steamusercontent-a.akamaihd.net/ugc/2026110045825388719/E63CD28028075E402AFD8D90955D1CEC53E65B90/' },
        ["Kha-vir, the Sword of Sorrows"] = {
            image = 'https://steamusercontent-a.akamaihd.net/ugc/2026110045842350784/92D53550008F1576CF8B78719CC3794F0AC101BB/',
            legendary = true
        },
        ["Singing spear"] = { image = 'https://steamusercontent-a.akamaihd.net/ugc/2026110045837276260/DEAD6D79EB15944D749482AAB31A12ED6115DA25/' },
        ["Star glaive"] = { image = 'https://steamusercontent-a.akamaihd.net/ugc/2026110045837556657/9822CDD339C7F33B6474EE41C6289AFD4D90450E/' },
        ["The Fire Axe"] = {
            image = 'https://steamusercontent-a.akamaihd.net/ugc/2026110045843023119/4A612572F82CD9574244FC3DD4BA0F474B2F8268/',
            legendary = true
        },
        ["The Shining Blade"] = {
            image = 'https://steamusercontent-a.akamaihd.net/ugc/2026110045842350956/28DCD6D32B16C7AF6D513389529D5428565E30F1/',
            legendary = true
        },
        ["Vilith-zhar, the Sword of Souls"] = {
            image = 'https://steamusercontent-a.akamaihd.net/ugc/2026110045842350784/92D53550008F1576CF8B78719CC3794F0AC101BB/',
            legendary = true
        },
        ["Witchblade"] = { image = 'https://steamusercontent-a.akamaihd.net/ugc/2026110045837276550/CDE64AD7C87AA906F0DADBD026AEBB80CEFDBC3C/' },
        ["Witchstaff"] = { image = 'https://steamusercontent-a.akamaihd.net/ugc/2026110045837276609/2B04E78AF39C6AF43711C8753B253B90EB92B4B4/' },
        ["Wraithbone hull"] = { image = 'https://steamusercontent-a.akamaihd.net/ugc/2026110045843023062/0330E0B641A6C9703223C1D9C24F63DD59854C08/' },

        --[ IMPERIUM ]--
        ["Armoured tracks"] = { image = 'https://steamusercontent-a.akamaihd.net/ugc/2026110045825698167/498079035E4730F8BE8AA73D5095601C7EA6D1B6/' },
        ["Chainsword"] = { image = 'https://steamusercontent-a.akamaihd.net/ugc/2026110045825185155/E0588C6C98F6610EC656E6E9F4D65FA76FA8FAE0/' },
        ["Power fist"] = { image = 'https://steamusercontent-a.akamaihd.net/ugc/2026110045825241546/55D094728E760104B27A09DA217FB05C33BB8210/' },
        ["Power weapon"] = { image = 'https://steamusercontent-a.akamaihd.net/ugc/2026110045825388719/E63CD28028075E402AFD8D90955D1CEC53E65B90/' },
        ["Servo-arm"] = { image = 'https://steamusercontent-a.akamaihd.net/ugc/2026110045828439253/E3BD530078A1A56AC29F9FB023ECF27706894947/' },

        --[ ADEPTA SORORITAS ]--
        ["Lance of Illumination"] = {
            image = 'https://steamusercontent-a.akamaihd.net/ugc/2467488810344070861/25B86BC81ED85039475A205C7CBFC18B6E9FD332/',
            legendary = true
        },
        ["Mace of Castigation"] = {
            image = 'https://steamusercontent-a.akamaihd.net/ugc/2467488810353912621/C24C2982191C13DBF8E3351CC4B9CAFB5C12125D/',
            legendary = true
        },
        ["Paragon war blade"] = { image = 'https://steamusercontent-a.akamaihd.net/ugc/2467488810344070955/FEE40F173E6DA5D5E8EC090A7CDCA8892505C34A/'},
        ["Penitent buzz-blade"] = { image = 'https://steamusercontent-a.akamaihd.net/ugc/2467488810344070997/6C8B1A68A5714C9B0A15F0ADCC6537F27E751655/'},
        ["Penitent flail"] = { image = 'https://steamusercontent-a.akamaihd.net/ugc/2467488810344446885/41481C0BA4387310EE6564CCFEDB3027457E3601/'},

        --[ ADEPTUS ASTARTES ]--
        -- Armoured feet (dreadnought)
        -- Invictor feet
        -- Relic weapon - power weapon
        -- Thunder hammer

        --[ AGENTS OF THE IMPERIUM ]--
        -- ['Runestaff and Barbarisater'] = {
        --     image = nil,
        --     psychic = true,
        --     legendary = true
        -- },
        ["Vindicare combat knife"] = { image = 'https://steamusercontent-a.akamaihd.net/ugc/2026110045825618029/63B1D6D5DB29D55C43A17EBA68D8088638B4D73F/' },
        -- ["Warp grasp"] = {
        --     image = nil,
        --     psychic = true
        -- },

        --[ ASTRA MILITARUM ]--
        ["Bullgryn maul"] = { image = 'https://steamusercontent-a.akamaihd.net/ugc/2026110045832619521/9CAD358A04AB8E4E5F9B047B40C061F4FA41F8CA/' },
        ["Conquest"] = {
            image = 'https://steamusercontent-a.akamaihd.net/ugc/2026110045832693106/A0217D80AE808EB361C12A43C338E2D53B6CF00E/',
            legendary = true
        },
        ["Enginseer axe"] = { image = 'https://steamusercontent-a.akamaihd.net/ugc/2026110045828442487/FEE7CAB830F0BD145FAD086D060D9C33C0014177/' },
        ["Excruciator maul"] = { image = 'https://steamusercontent-a.akamaihd.net/ugc/2026110045832619521/9CAD358A04AB8E4E5F9B047B40C061F4FA41F8CA/' },
        ["Konstantin's hooves"] = {
            image = 'https://steamusercontent-a.akamaihd.net/ugc/2026110045843040319/D0AEDE3B014303FB34EBD57C74B920435EEC21C1/',
            legendary = true
        },
        ["Sentinel chainsaw"] = { image = 'https://steamusercontent-a.akamaihd.net/ugc/2026110045825185155/E0588C6C98F6610EC656E6E9F4D65FA76FA8FAE0/' },
        ["Tempestus dagger"] = { image = 'https://steamusercontent-a.akamaihd.net/ugc/2026110045825618029/63B1D6D5DB29D55C43A17EBA68D8088638B4D73F/' },

        --[ GREY KNIGHTS ]--
        ["Black Blade of Antwyr"] = {
            image = 'https://steamusercontent-a.akamaihd.net/ugc/2026110045832598461/5E8C43485CE58E6963D77735F7EB1AF9DA6D5C6E/',
            legendary = true
        },
        ["Nemesis daemon hammer"] = {
            image = 'https://steamusercontent-a.akamaihd.net/ugc/2026110045849943813/6EFF5FDA1FA989ED559A7ACB70C9A034C74C9426/',
            psychic = true
        },
        ["Nemesis force weapon"] = {
            image = 'https://steamusercontent-a.akamaihd.net/ugc/2026110045822610141/03CCEF8A833FA27D11DAF132EAE3BF9EB98DAB6E/',
            psychic = true
        },
        ["Nemesis greatsword"] = {
            image = 'https://steamusercontent-a.akamaihd.net/ugc/2026110045849943753/00EEC9A9FF7C0EB285E82F929479F00057CD87BE/',
            psychic = true
        },

        --[ TYRANIDS ]--
        ["Blinding venom"] = { image = 'https://steamusercontent-a.akamaihd.net/ugc/2467488810344084052/1DABC9EF9AE3CE95C7123B0D134E24472DA0BCC5/' },
        ["Bone cleaver, lash whip and rending claws"] = { image = 'https://steamusercontent-a.akamaihd.net/ugc/2467488810344084352/04F8ED4AB795567842EF0F76E59642F19011560C/ '},
        ["Claws and talons"] = { image = 'https://steamusercontent-a.akamaihd.net/ugc/2467488810344084352/04F8ED4AB795567842EF0F76E59642F19011560C/' },
        ["Chitinous claws and teeth"] = { image = 'https://steamusercontent-a.akamaihd.net/ugc/2467488810344084142/9B8459BAC4CFE18578792725A7A07AD17139EE1C/' },
        ["Lashwhip pods"] = { image = 'https://steamusercontent-a.akamaihd.net/ugc/2467488810344119574/2B8CA3E299A05377101DFF5917023D04AE08D328/' },
        ["Lictor claws and talons"] = { image = 'https://steamusercontent-a.akamaihd.net/ugc/2467488810344084456/19BBBF7EDD76BA7FF816C4FBD235F0C7406F51CF/' },
        ["Monstrous bonesword and lash whip"] = { image = 'https://steamusercontent-a.akamaihd.net/ugc/2467488810344084091/36B0517E46DB18DB388337FAE77B8FB65BEB022C/' },
        ["Powerful limbs"] = { image = 'https://steamusercontent-a.akamaihd.net/ugc/2467488810344084142/9B8459BAC4CFE18578792725A7A07AD17139EE1C/' },
        ["Talons"] = { image = 'https://steamusercontent-a.akamaihd.net/ugc/2467488810344084456/19BBBF7EDD76BA7FF816C4FBD235F0C7406F51CF/' }, -- (Hormagaunt|Scything) talons
        ["Toxinjector harpoon"] = { image = 'https://steamusercontent-a.akamaihd.net/ugc/2467488810344084686/8A4DEB40AB2B0C0EC138FD862E931E219C2AE603/' },
    }
}
-- Weapons with the same images
weapons.ranged["Bolt rifle"] = weapons.ranged["Boltgun"]
weapons.ranged["Incendium cannon"] = weapons.ranged["Heavy flamer"]
weapons.ranged["Lancer laser destroyer"] = weapons.ranged["Lascannon"]
weapons.ranged["Las-talon"] = weapons.ranged["Lascannon"]
weapons.ranged["Las small arms"] = weapons.ranged["Las pistol"]
weapons.ranged["Plasma incinerator"] = weapons.ranged["Plasma cannon"]
weapons.melee["Relic weapon"] = weapons.ranged["Power weapon"]

---@type { [WeaponType]: { [boolean]: string } }
local default_images = {
    ranged = {
        [false] = weapons.ranged["Boltgun"].image,
        [true] --[[psychic]] = 'https://steamusercontent-a.akamaihd.net/ugc/2026110045822609013/EEE503BFF12F6115F74250E20E9F273CD539E0B0/',
    },
    melee = {
        [false] = weapons.melee["Close combat weapon"].image,
        [true] --[[psychic]] = weapons.melee["Force weapon"].image
    }
}
---@enum (key) StrategemCategory
local strategem_category = {
    GENERAL = 1,
    OFFENSIVE = 2,
    DEFENSIVE = 3,
}
local back_images = {
    [false] = {
        [false] = 'https://steamusercontent-a.akamaihd.net/ugc/2026110045832884821/0A9B55C26FFDD27A7C9E2248BE9D4F91E561062B/',
        [true] --[[psychic]] = 'https://steamusercontent-a.akamaihd.net/ugc/2026110045822608060/33AC0A15C0BC928064EC3BBBA73B12E62BADAB41/'
    },
    [true] --[[legendary]] = {
        [false] = 'https://steamusercontent-a.akamaihd.net/ugc/2026110045832651659/76A05F01F0EB89E03637F0CF8269DE13751DE004/',
        [true] --[[psychic]] = 'https://steamusercontent-a.akamaihd.net/ugc/2026110045832693287/EBB6D1AE07975A2D04E26523D342131E29C74024/'
    },
    strategems = {
        general = 'https://steamusercontent-a.akamaihd.net/ugc/2467488810349541832/266015246B204C0E12B0EFF5F2EB8CC774BFEF3E/',
        offensive = 'https://steamusercontent-a.akamaihd.net/ugc/2467488810349542029/377E8172DE7259FD25D2DFD01443CA76D64FA404/',
        defensive = 'https://steamusercontent-a.akamaihd.net/ugc/2467488810349541778/7411C0C66A01B3D72431BB3AF3ECA1FAD6797B92/'
    }
}

---@enum strategem_colors
local STRATEGEM_COLORS = {
    general = '82dccf',
    offensive = '69c9f6',
    defensive = 'f34a4e'
}

---@class (exact) StrategemData
---@field category StrategemCategory
---@field name string
---@field cost integer
---@field desc string
---@field image string
---@field back string
---@field faction? string
---@field keywords? string[]
---@field restriction? string
---@field exception? string
---@field ability? string

---@type { [string]: StrategemData }
local strategems = {
    --[ CORE ]--
--     ["Command Re-roll"] = {
--         category = 'GENERAL',
--         name = ('[%s]COMMAND RE-ROLL[-]'):format(STRATEGEM_COLORS.general),
--         cost = 1,
--         desc = ([=[[b]Core – Battle Tactic Stratagem[/b]
-- [i]A great commander can bend even the vagaries of fate and fortune to their will, the better to ensure victory.[/i]
-- [%s][b]WHEN:[/b][-] Any phase, just after you make an Advance roll, a Charge roll, a Desperate Escape test or a Hazardous test for a unit from your army, or a Hit roll, a Wound roll, a Damage roll or a saving throw for a model in that unit, or a roll to determine the number of attacks made with a weapon equipped by a model in that unit.

-- [%s][b]TARGET:[/b][-] That unit from your army.

-- [%s][b]EFFECT:[/b][-] You re-roll that roll, test or saving throw.]=]
--         ):format(STRATEGEM_COLORS.general, STRATEGEM_COLORS.general, STRATEGEM_COLORS.general),
--         image = 'https://steamusercontent-a.akamaihd.net/ugc/2467488810349666911/86F06EC5AA67EEE4523312E55A335818B4D6F141/',
--         back = back_images.strategems.general,
--     },
    ["Counter-offensive"] = {
        category = 'GENERAL',
        name = ('[%s]COUNTER-OFFENSIVE - 2CP[-]'):format(STRATEGEM_COLORS.general),
        cost = 2,
        desc = ([=[[b]Core – Strategic Ploy Stratagem[/b]
[i]In close-quarters combat, the slightest hesitation can leave an opening for a swift foe to exploit.[/i]
[%s][b]WHEN:[/b][-] Fight phase, just after an enemy unit has fought.

[%s][b]TARGET:[/b][-] One unit from your army that is within Engagement Range of one or more enemy units and that has not already been selected to fight this phase.

[%s][b]EFFECT:[/b][-] Your unit fights next.]=]
        ):format(STRATEGEM_COLORS.general, STRATEGEM_COLORS.general, STRATEGEM_COLORS.general),
        image = 'https://steamusercontent-a.akamaihd.net/ugc/2467488810349667262/C680A542A0579555C56C23394F94E6BCBF644231/',
        back = back_images.strategems.general
    },
    ["Epic Challenge"] = {
        category = 'GENERAL',
        name = ('[%s]EPIC CHALLENGE - 1CP[-]'):format(STRATEGEM_COLORS.general),
        cost = 1,
        desc = ([=[[b]Core – Epic Deed Stratagem[/b]
[i]The legends of the 41st Millennium are replete with deadly duels between mighty champions.[/i]
[%s][b]WHEN:[/b][-] Fight phase, when a CHARACTER unit from your army that is within Engagement Range of one or more Attached units is selected to fight.

[%s][b]TARGET:[/b][-] One CHARACTER model in your unit.

[%s][b]EFFECT:[/b][-] Until the end of the phase, all melee attacks made by that model have the [PRECISION] ability.]=]
        ):format(STRATEGEM_COLORS.general, STRATEGEM_COLORS.general, STRATEGEM_COLORS.general),
        image = 'https://steamusercontent-a.akamaihd.net/ugc/2467488810349666911/86F06EC5AA67EEE4523312E55A335818B4D6F141/',
        back = back_images.strategems.general,
        keywords = {'Character'}
    },
    ["Grenade"] = {
        category = 'OFFENSIVE',
        name = ('[%s]GRENADE - 1CP[-]'):format(STRATEGEM_COLORS.offensive),
        cost = 1,
        desc = ([=[[b]Core – Wargear Stratagem[/b]
[i]Priming their hand-held projectiles, these warriors draw back and hurl death into the enemy’s midst.[/i]
[%s][b]WHEN:[/b][-] Your Shooting phase.

[%s][b]TARGET:[/b][-] One GRENADES unit from your army that is not within Engagement Range of any enemy units and has not been selected to shoot this phase.

[%s][b]EFFECT:[/b][-] Select one enemy unit that is not within Engagement Range of any units from your army and is within 8" of and visible to your GRENADES unit. Roll six D6: for each 4+, that enemy unit suffers 1 mortal wound.]=]
        ):format(STRATEGEM_COLORS.offensive, STRATEGEM_COLORS.offensive, STRATEGEM_COLORS.offensive),
        image = 'https://steamusercontent-a.akamaihd.net/ugc/2467488810349541971/34BC3DDB2D4E813C41C1F61DB120D33B501A850D/',
        back = back_images.strategems.offensive,
        keywords = {'Grenades'}
    },
    ["Tank Shock"] = {
        category = 'OFFENSIVE',
        name = ('[%s]TANK SHOCK - 1CP[-]'):format(STRATEGEM_COLORS.offensive),
        cost = 1,
        desc = ([=[[b]Core – Strategic Ploy Stratagem[/b]
[i]Ramming the foe with a speeding vehicle may be an unsubtle tactic, but it is a murderously effective one.[/i]
[%s][b]WHEN:[/b][-] Your Charge phase.

[%s][b]TARGET:[/b][-] One VEHICLE unit from your army.

[%s][b]EFFECT:[/b][-] Until the end of the phase, after your unit ends a Charge move, select one enemy unit within Engagement Range of it, then select one melee weapon your unit is equipped with. Roll a number of D6 equal to that weapon’s Strength characteristic. If that Strength characteristic is greater than that enemy unit’s Toughness characteristic, roll two additional D6. For each 5+, that enemy unit suffers 1 mortal wound (to a maximum of 6 mortal wounds).]=]
        ):format(STRATEGEM_COLORS.offensive, STRATEGEM_COLORS.offensive, STRATEGEM_COLORS.offensive),
        image = 'https://steamusercontent-a.akamaihd.net/ugc/2467488810349542127/F0A0DC81ED960A9FA28AD40A1E51FBB58C6BF237/',
        back = back_images.strategems.offensive,
        keywords = {'Vehicle'}
    },
--     ["Rapid Ingress"] = {
--         category = 'DEFENSIVE',
--         name = ('[%s]RAPID INGRESS - 1CP[-]'):format(STRATEGEM_COLORS.defensive),
--         cost = 1,
--         desc = ([=[[b]Core – Strategic Ploy Stratagem[/b]
-- [i]Be it cunning strategy, potent technology or supernatural ritual, there are many means by which a commander may hasten their warriors’ onset.[/i]
-- [%s][b]WHEN:[/b][-] End of your opponent’s Movement phase.

-- [%s][b]TARGET:[/b][-] One unit from your army that is in Reserves.

-- [%s][b]EFFECT:[/b][-] Your unit can arrive on the battlefield as if it were the Reinforcements step of your Movement phase, and if every model in that unit has the Deep Strike ability, you can set that unit up as described in the Deep Strike ability (even though it is not your Movement phase).

-- [%s][b]RESTRICTIONS:[/b][-] You cannot use this Stratagem to enable a unit to arrive on the battlefield during a battle round it would not normally be able to do so in.]=]
--         ):format(STRATEGEM_COLORS.defensive, STRATEGEM_COLORS.defensive, STRATEGEM_COLORS.defensive, STRATEGEM_COLORS.defensive),
--         image = 'https://steamusercontent-a.akamaihd.net/ugc/2467488810350218067/57A04D95D23140B997D6321F61F9A802CBC0FC6D/',
--         back = back_images.strategems.defensive,
--     },
--     ["Fire Overwatch"] = {
--         category = 'DEFENSIVE',
--         name = ('[%s]FIRE OVERWATCH - 1CP[-]'):format(STRATEGEM_COLORS.defensive),
--         cost = 1,
--         desc = ([=[[b]Core – Strategic Ploy Stratagem[/b]
-- [i]A hail of wildfire can drive back advancing foes.[/i]
-- [%s][b]WHEN:[/b][-] Your opponent’s Movement or Charge phase, just after an enemy unit is set up or when an enemy unit starts or ends a Normal, Advance, Fall Back or Charge move.

-- [%s][b]TARGET:[/b][-] One unit from your army that is within 24" of that enemy unit and that would be eligible to shoot if it were your Shooting phase.

-- [%s][b]EFFECT:[/b][-] If that enemy unit is visible to your unit, your unit can shoot that enemy unit as if it were your Shooting phase.

-- [%s][b]RESTRICTIONS:[/b][-] You cannot target a TITANIC unit with this Stratagem. Until the end of the phase, each time a model in your unit makes a ranged attack, an unmodified Hit roll of 6 is required to score a hit, irrespective of the attacking weapon’s Ballistic Skill or any modifiers. You can only use this Stratagem once per turn.]=]
--         ):format(STRATEGEM_COLORS.defensive, STRATEGEM_COLORS.defensive, STRATEGEM_COLORS.defensive, STRATEGEM_COLORS.defensive),
--         image = 'https://steamusercontent-a.akamaihd.net/ugc/2467488810350218067/57A04D95D23140B997D6321F61F9A802CBC0FC6D/',
--         back = back_images.strategems.defensive,
--         restriction = 'Titanic',
--     },
    ["Go to Ground"] = {
        category = 'DEFENSIVE',
        name = ('[%s]GO TO GROUND - 1CP[-]'):format(STRATEGEM_COLORS.defensive),
        cost = 1,
        desc = ([=[[b]Core – Battle Tactic Stratagem[/b]
[i]Seeking salvation from incoming fire, warriors hurl themselves into whatever cover they can find.[/i]
[%s][b]WHEN:[/b][-] Your opponent’s Shooting phase, just after an enemy unit has selected its targets.

[%s][b]TARGET:[/b][-] One INFANTRY unit from your army that was selected as the target of one or more of the attacking unit’s attacks.

[%s][b]EFFECT:[/b][-] Until the end of the phase, all models in your unit have a 6+ invulnerable save and have the Benefit of Cover.]=]
        ):format(STRATEGEM_COLORS.defensive, STRATEGEM_COLORS.defensive, STRATEGEM_COLORS.defensive),
        image = 'https://steamusercontent-a.akamaihd.net/ugc/2467488810349541872/21BFFB5DCE5F332F7031485B284DC793B933C734/',
        back = back_images.strategems.defensive,
        keywords = {'Infantry'}
    },
    ["Smokescreen"] = {
        category = 'DEFENSIVE',
        name = ('[%s]SMOKESCREEN - 1CP[-]'):format(STRATEGEM_COLORS.defensive),
        cost = 1,
        desc = ([=[[b]Core – Battle Tactic Stratagem[/b]
[i]Seeking salvation from incoming fire, warriors hurl themselves into whatever cover they can find.[/i]
[%s][b]WHEN:[/b][-] Your opponent’s Shooting phase, just after an enemy unit has selected its targets.

[%s][b]TARGET:[/b][-] One SMOKE unit from your army that was selected as the target of one or more of the attacking unit’s attacks.

[%s][b]EFFECT:[/b][-] Until the end of the phase, all models in your unit have the Benefit of Cover and the Stealth ability.]=]
        ):format(STRATEGEM_COLORS.defensive, STRATEGEM_COLORS.defensive, STRATEGEM_COLORS.defensive),
        image = 'https://steamusercontent-a.akamaihd.net/ugc/2467488810350218153/D3CE7E94B96F114BE3BD71D7BE77F881CCF5788E/',
        back = back_images.strategems.defensive,
        keywords = {'Smoke'}
    },
    ["Heroic Intervention"] = {
        category = 'DEFENSIVE',
        name = ('[%s]HEROIC INTERVENTION - 2CP[-]'):format(STRATEGEM_COLORS.defensive),
        cost = 2,
        desc = ([=[[b]Core – Strategic Ploy Stratagem[/b]
[i]Voices raised in furious war cries, your warriors surge forth to meet the enemy’s onslaught head-on.[/i]
[%s][b]WHEN:[/b][-] Your opponent’s Charge phase, just after an enemy unit ends a Charge move.

[%s][b]TARGET:[/b][-] One unit from your army that is within 6" of that enemy unit and would be eligible to declare a charge against that enemy unit if it were your Charge phase.

[%s][b]EFFECT:[/b][-] Your unit now declares a charge that targets only that enemy unit, and you resolve that charge as if it were your Charge phase.

[%s][b]RESTRICTIONS:[/b][-] You can only select a VEHICLE unit from your army if it is a WALKER. Note that even if this charge is successful, your unit does not receive any Charge bonus this turn.]=]
        ):format(STRATEGEM_COLORS.defensive, STRATEGEM_COLORS.defensive, STRATEGEM_COLORS.defensive, STRATEGEM_COLORS.defensive),
        image = 'https://steamusercontent-a.akamaihd.net/ugc/2467488810350218067/57A04D95D23140B997D6321F61F9A802CBC0FC6D/',
        back = back_images.strategems.defensive,
        restriction = 'Vehicle',
        exception = 'Walker'
    },

    --[ ADEPTA SORORITAS ]--
    ["Divine Intervention"] = {
        category = 'GENERAL',
        name = ('[%s]DIVINE INTERVENTION - 1CP[-]'):format(STRATEGEM_COLORS.general),
        cost = 1,
        desc = ([=[[b]Hallowed Martyrs – Epic Deed Stratagem[/b]
[i]Sometimes, a brush with death is so close the only explanation is divine intervention.[/i]
[%s][b]WHEN:[/b][-] Any phase.

[%s][b]TARGET:[/b][-] One ADEPTA SORORITAS CHARACTER unit from your army that was just destroyed. You can use this Stratagem on that unit even though it was just destroyed.

[%s][b]EFFECT:[/b][-] Discard 1-3 Miracle dice. At the end of the phase, set the last destroyed model from your unit back up on the battlefield, as close as possible to where it was destroyed and not within Engagement Range of any enemy models. That model is set back up with a number of wounds remaining equal to the number of Miracle dice you discarded.

[%s][b]RESTRICTIONS:[/b][-] You cannot select SAINT CELESTINE as the target of this Stratagem. You cannot select the same CHARACTER as the target of this Stratagem more than once per battle.]=]
        ):format(STRATEGEM_COLORS.general, STRATEGEM_COLORS.general, STRATEGEM_COLORS.general, STRATEGEM_COLORS.general),
        image = 'https://steamusercontent-a.akamaihd.net/ugc/2467488810353893408/799629C084E59D668002F0EFEBDC788BF06CE3DA/',
        back = back_images.strategems.general,
        faction = 'Adepta Sororitas',
        keywords = {'Character'},
        restriction = 'Saint Celestine',
    },
    ["Holy Rage"] = {
        category = 'GENERAL',
        name = ('[%s]HOLY RAGE - 1CP[-]'):format(STRATEGEM_COLORS.general),
        cost = 1,
        desc = ([=[[b]Hallowed Martyrs – Strategic Ploy Stratagem[/b]
[i]With psalms on their lips, the faithful hurl themselves forward, striking the foe down with the inner strength born of faith in the Emperor.[/i]
[%s][b]WHEN:[/b][-] Fight phase.

[%s][b]TARGET:[/b][-] One ADEPTA SORORITAS unit from your army that has not been selected to fight this phase.

[%s][b]EFFECT:[/b][-] Until the end of the phase, each time a model in your unit makes a melee attack, add 1 to the Wound roll.]=]
        ):format(STRATEGEM_COLORS.general, STRATEGEM_COLORS.general, STRATEGEM_COLORS.general),
        image = 'https://steamusercontent-a.akamaihd.net/ugc/2467488810353894120/CC67B5EACD682BC1F6885FEB51BD6DF99CD4FE4C/',
        back = back_images.strategems.general,
        faction = 'Adepta Sororitas'
    },
    ["Suffering and Sacrifice"] = {
        category = 'GENERAL',
        name = ('[%s]SUFFERING & SACRIFICE - 1CP[-]'):format(STRATEGEM_COLORS.general),
        cost = 1,
        desc = ([=[[b]Hallowed Martyrs – Strategic Ploy Stratagem[/b]
[i]Suffering is a staple prayer for the Adepta Sororitas, and a martyr’s fate only brings greater glory to the God-Emperor.[/i]
[%s][b]WHEN:[/b][-] Start of the Fight phase.

[%s][b]TARGET:[/b][-] One ADEPTA SORORITAS INFANTRY or ADEPTA SORORITAS WALKER unit from your army.

[%s][b]EFFECT:[/b][-] Until the end of the phase, each time an enemy model within Engagement range of your unit selects targets, it must select your unit as the target of its attacks.]=]
        ):format(STRATEGEM_COLORS.general, STRATEGEM_COLORS.general, STRATEGEM_COLORS.general),
        image = 'https://steamusercontent-a.akamaihd.net/ugc/2467488810353893645/6E35230A8C1617C6BA05C92C590DB820F239C1A4/',
        back = back_images.strategems.general,
        faction = 'Adepta Sororitas',
        keywords = {'Infantry', 'Walker'}
    },
    ["Light of the Emperor"] = {
        category = 'GENERAL',
        name = ('[%s]LIGHT OF THE EMPEROR - 1CP[-]'):format(STRATEGEM_COLORS.general),
        cost = 1,
        desc = ([=[[b]Hallowed Martyrs – Battle Tactic Stratagem[/b]
[i]The Emperor’s radiance shines upon his warriors, emboldening them amidst the thick of battle in their darkest hour.[/i]
[%s][b]WHEN:[/b][-] Command phase.

[%s][b]TARGET:[/b][-] One ADEPTA SORORITAS unit from your army that is below its Starting Strength. For the purposes of this Stratagem, if a unit has a Starting Strength of 1, it is considered to be below its Starting Strength while it has lost one or more wounds.

[%s][b]EFFECT:[/b][-] Until the end of the turn, your unit can ignore any or all modifiers to its characteristics and/or to any roll or test made for it (excluding modifiers to saving throws).]=]
        ):format(STRATEGEM_COLORS.general, STRATEGEM_COLORS.general, STRATEGEM_COLORS.general),
        image = 'https://steamusercontent-a.akamaihd.net/ugc/2467488810353894975/7F33940BCB72DB5D674B7D754C33D4861029F18D/',
        back = back_images.strategems.general,
        faction = 'Adepta Sororitas'
    },
    ["Rejoice the Fallen"] = {
        category = 'DEFENSIVE',
        name = ('[%s]REJOICE THE FALLEN - 1CP[-]'):format(STRATEGEM_COLORS.defensive),
        cost = 1,
        desc = ([=[[b]Hallowed Martyrs – Strategic Ploy Stratagem[/b]
[i]The death of a Battle Sister only stirs the survivors to fight harder to exact swift vengeance.[/i]
[%s][b]WHEN:[/b][-] Your opponent’s Shooting phase, just after an enemy unit has resolved its attacks.

[%s][b]TARGET:[/b][-] One ADEPTA SORORITAS unit from your army that had one or more of its models destroyed as a result of the attacking unit’s attacks.

[%s][b]EFFECT:[/b][-] Your unit can shoot as if it were your Shooting phase, but it must target only that enemy unit when doing so, and can only do so if that enemy unit is an eligible target.]=]
        ):format(STRATEGEM_COLORS.defensive, STRATEGEM_COLORS.defensive, STRATEGEM_COLORS.defensive),
        image = 'https://steamusercontent-a.akamaihd.net/ugc/2467488810353894547/235835B31657F48061B9612AB75463AFC0AEC404/',
        back = back_images.strategems.defensive,
        faction = 'Adepta Sororitas'
    },
    ["Spirit of the Martyr"] = {
        category = 'GENERAL',
        name = ('[%s]SPIRIT OF THE MARTYR - 2CP[-]'):format(STRATEGEM_COLORS.general),
        cost = 2,
        desc = ([=[[b]Hallowed Martyrs – Strategic Ploy Stratagem[/b]
[i]Even with their dying act, the Sororitas mete out the Emperor’s judgement.[/i]
[%s][b]WHEN:[/b][-] Fight phase, just after an enemy unit has selected its targets.

[%s][b]TARGET:[/b][-] One ADEPTA SORORITAS unit from your army that was selected as the target of one or more of the attacking unit’s attacks.

[%s][b]EFFECT:[/b][-] Until the end of the phase, each time a model in your unit is destroyed, if that model has not fought this phase, do not remove it from play. The destroyed model can fight after the attacking model’s unit has finished making attacks, and is then removed from play.]=]
        ):format(STRATEGEM_COLORS.general, STRATEGEM_COLORS.general, STRATEGEM_COLORS.general),
        image = 'https://steamusercontent-a.akamaihd.net/ugc/2467488810353893593/DE5DB5109C12FA52DBC3F0598A3B8FBDF03C35B2/',
        back = back_images.strategems.general,
        faction = 'Adepta Sororitas'
    },

    --[ ASTRA MILITARUM ]--
    ["Reinforcements!"] = {
        category = 'GENERAL',
        name = ('[%s]REINFORCEMENTS! - 2CP[-]'):format(STRATEGEM_COLORS.general),
        cost = 2,
        desc = ([=[[b]Combined Regiment – Strategic Ploy Stratagem[/b]
[i]The Astra Militarum can call upon a nearly inexhaustible supply of warriors.[/i]
[%s][b]WHEN:[/b][-] Any phase.

[%s][b]TARGET:[/b][-] One REGIMENT unit from your army that was just destroyed. You can use this Stratagem on that unit even though it was just destroyed.

[%s][b]EFFECT:[/b][-] Add a new unit to your army identical to your destroyed unit, in Strategic Reserves, at its Starting Strength and with all of its wounds remaining.

[%s][b]RESTRICTIONS:[/b][-] This Stratagem cannot be used to return destroyed CHARACTER units to Attached units.]=]
        ):format(STRATEGEM_COLORS.general, STRATEGEM_COLORS.general, STRATEGEM_COLORS.general, STRATEGEM_COLORS.general),
        image = 'https://steamusercontent-a.akamaihd.net/ugc/2467488810353898248/C6799CC95B936189A4C79274179EB4D87C08754E/',
        back = back_images.strategems.general,
        faction = 'Astra Militarum',
        keywords = {'Regiment'},
        restriction = 'Character',
    },
    ["Fields of Fire"] = {
        category = 'OFFENSIVE',
        name = ('[%s]FIELDS OF FIRE - 2CP[-]'):format(STRATEGEM_COLORS.offensive),
        cost = 2,
        desc = ([=[[b]Combined Regiment – Battle Tactic Stratagem[/b]
[i]Astra Militarum combat doctrine utilises the concentration of focused firepower to hammer the foe from multiple angles.[/i]
[%s][b]WHEN:[/b][-] Your Shooting phase.

[%s][b]TARGET:[/b][-] One REGIMENT or SQUADRON unit from your army that has not been selected to shoot this phase.

[%s][b]EFFECT:[/b][-] After your unit has resolved its attacks, select one enemy unit that was targeted by one or more of those attacks. Until the end of the phase, each time an attack is made against that enemy unit by a REGIMENT or SQUADRON model from your army, unless the attacking unit is Battle-shocked, improve the Armour Penetration characteristic of that attack by 1.]=]
        ):format(STRATEGEM_COLORS.offensive, STRATEGEM_COLORS.offensive, STRATEGEM_COLORS.offensive),
        image = 'https://steamusercontent-a.akamaihd.net/ugc/2467488810353901003/BBF7B729E4A533DAC456CFCAE7CC435A85022693/',
        back = back_images.strategems.offensive,
        faction = 'Astra Militarum',
        keywords = {'Regiment', 'Squadron'}
    },
    ["Suppression Fire"] = {
        category = 'OFFENSIVE',
        name = ('[%s]SUPPRESSION FIRE - 1CP[-]'):format(STRATEGEM_COLORS.offensive),
        cost = 1,
        desc = ([=[[b]Combined Regiment – Strategic Ploy Stratagem[/b]
[i]Ordered to focus a rapid and repeated volley of fire, soldiers are able to rattle even the staunchest foe with a blizzard of shots.[/i]
[%s][b]WHEN:[/b][-] Your Shooting phase.

[%s][b]TARGET:[/b][-] One ASTRA MILITARUM INFANTRY unit from your army that has not been selected to shoot this phase, and one enemy unit (excluding MONSTERS and VEHICLES)

[%s][b]EFFECT:[/b][-] If your ASTRA MILITARUM unit scores one or more hits against that enemy unit this phase, until the end of your opponent’s next turn, each time a model in that enemy unit makes an attack, subtract 1 from the Hit roll.]=]
        ):format(STRATEGEM_COLORS.offensive, STRATEGEM_COLORS.offensive, STRATEGEM_COLORS.offensive),
        image = 'https://steamusercontent-a.akamaihd.net/ugc/2467488810353896325/F06E670970EDB967BBC027BE283BC93633D61356/',
        back = back_images.strategems.offensive,
        faction = 'Astra Militarum',
        keywords = {'Infantry'}
    },
    ["Expert Bombardiers"] = {
        category = 'OFFENSIVE',
        name = ('[%s]EXPERT BOMBARDIERS - 1CP[-]'):format(STRATEGEM_COLORS.offensive),
        cost = 1,
        desc = ([=[[b]Combined Regiment – Strategic Ploy Stratagem[/b]
[i]Skilled in coordinating their targeting with forward spotter elements, this regiment’s artillery crews are capable of devastating precision shelling.[/i]
[%s][b]WHEN:[/b][-] Start of your Shooting phase.

[%s][b]TARGET:[/b][-] One ASTRA MILITARUM unit from your army equipped with a vox-caster, and one enemy unit that is visible to that unit.

[%s][b]EFFECT:[/b][-] Until the end of the phase, each time an ASTRA MILITARUM model from your army makes an attack with an Indirect Fire weapon that targets that enemy unit, unless the attacking model is Battle-shocked, add 1 to the Hit roll.]=]
        ):format(STRATEGEM_COLORS.offensive, STRATEGEM_COLORS.offensive, STRATEGEM_COLORS.offensive),
        image = 'https://steamusercontent-a.akamaihd.net/ugc/2467488810353897466/42F39D360A22FA33C6AF11C3306F19F63A1C2C77/',
        back = back_images.strategems.offensive,
        faction = 'Astra Militarum',
        ability = 'Vox-caster'
    },
    ["Inspired Command"] = {
        category = 'DEFENSIVE',
        name = ('[%s]INSPIRED COMMAND - 1CP[-]'):format(STRATEGEM_COLORS.defensive),
        cost = 1,
        desc = ([=[[b]Combined Regiment – Epic Deed Stratagem[/b]
[i]This officer is known for their strategic excellence, as are those they command. Honed over many years, their curt, well-established battle cant is wielded with consummate efficiency, reinforced by the inspirational example they themselves set.[/i]
[%s][b]WHEN:[/b][-] Your opponent’s Command phase.

[%s][b]TARGET:[/b][-] One ASTRA MILITARUM OFFICER unit from your army.

[%s][b]EFFECT:[/b][-] Your OFFICER can issue one Order as if it were your Command phase.

[%s][b]RESTRICTIONS: Your OFFICER cannot issue that Order to a Battle-shocked unit.[/b][-]]=]
        ):format(STRATEGEM_COLORS.defensive, STRATEGEM_COLORS.defensive, STRATEGEM_COLORS.defensive, STRATEGEM_COLORS.defensive),
        image = 'https://steamusercontent-a.akamaihd.net/ugc/2467488810353901357/5CCA31882D18238DD9C61305AF444B3B5E88111D/',
        back = back_images.strategems.defensive,
        faction = 'Astra Militarum',
        keywords = {'Officer'}
    },
    ["Armoured Might"] = {
        category = 'DEFENSIVE',
        name = ('[%s]ARMOURED MIGHT - 2CP[-]'):format(STRATEGEM_COLORS.defensive),
        cost = 2,
        desc = ([=[[b]Combined Regiment – Wargear Stratagem[/b]
[i]The tanks of the Imperial Guard are armoured not only in reinforced plas-steel, but with devout faith in the Emperor and utter contempt for their foes.[/i]
[%s][b]WHEN:[/b][-] Your opponent’s Shooting phase, just after an enemy unit has selected its targets.

[%s][b]TARGET:[/b][-] One ASTRA MILITARUM VEHICLE unit from your army that was selected as the target of one or more of the attacking unit’s attacks.

[%s][b]EFFECT:[/b][-] Until the end of the phase, each time an attack is allocated to your unit, subtract 1 from the Damage characteristic of that attack.]=]
        ):format(STRATEGEM_COLORS.defensive, STRATEGEM_COLORS.defensive, STRATEGEM_COLORS.defensive),
        image = 'https://steamusercontent-a.akamaihd.net/ugc/2467488810353900392/1D9E84237A4FA2063B9DB749EAC3B76C0E596D4E/',
        back = back_images.strategems.defensive,
        faction = 'Astra Militarum',
        keywords = {'Vehicle'}
    },
}

-- [ Patches for incorrect names ]
weapons.ranged["Spike Rifle"] = weapons.ranged["Spike rifle"]
weapons.ranged["Toxic harpoons"] = weapons.ranged["Toxinjector harpoon"]
weapons.melee["Bio-weapons"] = weapons.melee["Claws and talons"]
weapons.melee["Monstrous sharp claws"] = weapons.melee["Talons"]
weapons.melee["Toxic harpoons"] = weapons.melee["Toxinjector harpoon"]

local last_player_color  ---@type PlayerColor

---Waiting for unit to generate weapon tokens.
local making_weapon_tokens = false
local making_strategem_tokens = false

local bag  ---@type Container

---@class TokenBuilder
---@field count int Number of copies to make.
---@field token_name string Token name.
---@field weapon_type WeaponType
---@field color 'c6c930'|'5785fe'
---@field weapon_name string
---@field stats string
---@field unit_tag string
local TokenBuilder = {
    count = 1,
    color = 'c6c930'
}


---Create new TokenBuilder object.
---@param count int
---@param token_name string
---@param weapon_type 'ranged'|'melee'
---@param color string
---@param weapon_name string
---@param stats string
---@param unit_tag string
---@return TokenBuilder
function TokenBuilder:new(count, token_name, weapon_type, color, weapon_name, stats, unit_tag)
    obj = {
        count = count,
        token_name = token_name,
        weapon_type = weapon_type,
        color = color,
        weapon_name = weapon_name,
        stats = stats,
        unit_tag = unit_tag
    }  ---@type TokenBuilder
    setmetatable(obj, self)
    self.__index = self
    return obj
end

---Create tokens for this weapon.
function TokenBuilder:makeTokens()
    for _ = 1, self.count do
        spawnObject{
            type = 'Custom_Tile',
            scale = {0.5, 1, 0.5},
            callback_function=|obj| self:setToken(obj)
        }
    end
end

---Set token properties.
---@param token Object
function TokenBuilder:setToken(token)
    local image, back  ---@type string, string
    local token_name = self.token_name:gsub('%s*%([Rr]anged%)', ''):gsub('%s*%([Mm]elee%)', '')
    local weapon_name = self.weapon_name
    local weapon_list = weapons[self.weapon_type]
    local weapon = weapon_list[weapon_name]
    while not weapon and weapon_name do
        weapon_name = weapon_name:sub(1, 1):upper() .. weapon_name:sub(2)
        weapon = weapon_list[weapon_name]
        if weapon then
            break
        end
        weapon = weapon_list[weapon_name:gsub('s$', '')]
        if weapon then
            weapon_name = weapon_name:gsub('s$', '')
            break
        end
        local twinname = nil  ---@type string
        local twin, twinweapon = weapon_name:match('^(Twin) %S+ (.+)')  ---@type string, string
        if twin then
            twinname = 'Twin-linked '..twinweapon
            weapon = weapon_list[twinname]
            if weapon then
                weapon_name = twinname
                break
            end
        else
            twin, twinweapon = weapon_name:match('^(Twin-linked) %S+ (.+)')  ---@type string, string
            if twin then
                twinname = 'Twin '..twinweapon
                weapon = weapon_list[twinname]
                if weapon then
                    weapon_name = twinname
                    break
                end
            end
        end
        if twinname then
            twinname = twinname:gsub('s$', '')
            weapon = weapon_list[twinname]
            if weapon then
                weapon_name = twinname
                break
            end
            twinname = twinweapon:sub(1, 1):upper() .. twinweapon:sub(2)
            weapon = weapon_list[twinname]
            if weapon then
                weapon_name = twinname
                break
            end
            twinname = twinname:gsub('s$', '')
            weapon = weapon_list[twinname]
            if weapon then
                weapon_name = twinname
                break
            end
            weapon_name = twin..twinweapon:match('%S+%s+(.*)')  ---@type string
        else
            weapon_name = weapon_name:match('%S+%s+(.*)')  ---@type string
        end
    end
    ---@cast weapon WeaponData
    if weapon then
        image = weapon.image
        back = back_images[weapon.legendary or false][weapon.psychic or false]
    else
        local is_psychic = (self.color:lower() == '5785fe')
        image = default_images[self.weapon_type][is_psychic]
        back = back_images[false][is_psychic]
    end
    token.setCustomObject{
        image = image,
        type = 2,
        image_bottom = back,
        thickness = 0.1,
        stackable = true
    }
    if weapons[self.weapon_type == 'ranged' and 'melee' or 'ranged'][weapon_name] then
        token_name = token_name:gsub('%[%-%]', (' (%s%s)[-]'):format(self.weapon_type:sub(1,1):upper(), self.weapon_type:sub(2)))
    end
    token.setName(token_name)
    local desc = self.stats:gsub('BS:N/A', 'BS:-')
    if token_name:match(' | Half Range') then
        local n ---@type integer
        local stat_color = '00ff33'
        local range = desc:match('^(%d+).%f[%s]')  ---@type string?
        if range then
            local new_range = math.floor(tonumber(range)/2)
            desc = desc:gsub('^%d+(.)%f[%s]', ('[%s]%d%%1[-]'):format(stat_color, new_range))
        end
        local rapid_fire = desc:match('Rapid Fire (%d+)') or desc:match('RF(%d+)')  ---@type string?
        if rapid_fire then
            local atkstr = desc:match('A:([D%d+]+)')  ---@type string
            local attacks = atkstr:match('^%d+$') or atkstr:match('^%d*D%d+%+(%d+)$') or 0
            local new_attacks = tonumber(attacks) + tonumber(rapid_fire)  ---@type integer
            desc, n = desc:gsub('(A:%d*D%d+%+)%d+', '[%%s]%1%%d[-]')
            if n == 0 then
                desc, n = desc:gsub('A:%d*D%d+', '[%%s]%1+%%d[-]')
            end
            if n == 0 then
                desc = desc:gsub('(A:)%d+', '[%%s]%1%%d[-]')
            end
            desc = desc:format(stat_color, new_attacks)
        end
        local melta = desc:match('Melta (%d+)') or desc:match('ML(%d+)')  ---@type string?
        if melta then
            local dmgstr = desc:match('D:([D%d+]+)')  ---@type string
            local damage = dmgstr:match('^%d+$') or dmgstr:match('^%d*D%d+%+(%d+)$') or 0
            local new_damage = tonumber(damage) + tonumber(melta)  ---@type integer
            desc, n = desc:gsub('(D:%d*D%d+%+)%d+', '[%%s]%1%%d[-]')  ---@type string
            if n == 0 then
                desc, n = desc:gsub('D:%d*D%d+', '[%%s]%1+%%d[-]')
            end
            if n == 0 then
                desc = desc:gsub('(D:)%d+', '[%%s]%1%%d[-]')
            end
            desc = desc:format(stat_color, new_damage)
        end
    end
    if not desc:match('\u{2514}') then
        desc = desc:gsub('\n%s+', '\n'):trim()
    end
    token.setDescription(desc)
    token.addTag(self.unit_tag)
    token.locked = false
    token.auto_raise = true
    bag.putObject(token)
end


---onLoad handler. Adds context menus.
function onLoad()
    self.addContextMenuItem(
        'Make Weapon Tokens',
        function (player_color, object_position, object)
            making_weapon_tokens = true
            last_player_color = player_color
        end
    )
    self.addContextMenuItem(
        'Make Strat. Tokens',
        function (player_color, object_position, object)
            making_strategem_tokens = true
            last_player_color = player_color
        end
    )
    self.addContextMenuItem(
        'Make All Tokens',
        function (player_color, object_position, object)
            making_weapon_tokens = true
            making_strategem_tokens = true
            last_player_color = player_color
        end
    )
end

---onObjectPickup handler. Will trigger doing the things.
---@param player_color color
---@param picked_up_object object
function onObjectPickUp(player_color, picked_up_object)
    if not self.hasTag("lsUpgrader") then return end
    GenerateTokens(picked_up_object)
end


---onPlayerAction handler. Selecting objects will trigger doing the things.
---@param player Player
---@param action Action
---@param targets object[]
function onPlayerAction(player, action, targets)
    if not self.hasTag("lsUpgrader") then return end
    if action == Player.Action.Select then
        GenerateTokens(table.unpack(targets))
    end
end

---@alias WeaponProfile { count: int, color: string, token_name: string, weapon_name: string, profile_name: string, stats: string }

---Generates weapon tokens for all models in the given unit.
---@param unit_tag string Tag identifing unit.
function GenerateWeaponTokens(unit_tag)
    local unit_models = getObjectsWithAllTags{unit_tag, 'lsModel'}
    local desc, rangedHEnd, meleeHStart, meleeHEnd, abl
    ---@param weapon_section string
    ---@param weapon_type WeaponType
    local function parseWeapons(weapon_section, weapon_type)
        if not weapon_section then return end
        local profiles = {}  ---@type WeaponProfile[]

        local color
        function makeProfiles()
            local prof_stats = {}  ---@type string[]
            local profile_weapon = {}  ---@type WeaponProfile[]
            for i, prof in ipairs(profiles) do
                table.insert(prof_stats, ('[%s]\u{2514} %s[-]\n    %s'):format(prof.color, prof.profile_name, prof.stats:ltrim():gsub('\n%[', '\n    [')))
                prof.token_name = ('[%s]%s[-]'):format(profiles[i].color, prof.token_name)
                table.insert(profile_weapon, prof)
            end
            local weap_stats = table.concat(prof_stats, '\n')
            local base_name = ('[%s]%s[-]'):format(profiles[1].color, profiles[1].weapon_name)
            TokenBuilder:new(profiles[1].count, base_name, weapon_type, profiles[1].color, profiles[1].weapon_name, weap_stats, unit_tag):makeTokens()
            for _, prof in ipairs(profile_weapon) do
                TokenBuilder:new(prof.count, prof.token_name, weapon_type, prof.color, prof.weapon_name, prof.stats, unit_tag):makeTokens()
                if checkHalfRangeAttrs(prof.stats) then
                    TokenBuilder:new(prof.count, prof.token_name..' | Half Range', weapon_type, prof.color, prof.weapon_name, prof.stats, unit_tag):makeTokens()
                end
            end
            profiles = {}
        end
        local weapon_name, token_name, stats, prev_weapon, profile_name, prev_profile, prev_color, count  ---@type string, string, string, string, string?, string?, string, integer
        for line in weapon_section:gmatch('[^\n\r]+') do
            color, weapon_name = line:match('^%[(%x+)%](%w[^[]*)') ---@type string, string
            profile_name = line:match('^[%s\u{2514}]+%[%x+%](%w.-)%[%-%]$') or line:match('^[%s\u{2514}]+(%w.-)%[%-%]$') or line:match('^%[%x+%][%s\u{2514}]+(%w.-)%[%-%]$')  ---@type string?
            log(profile_name)
            if color and weapon_name then
                -- check for arrows
                local prof_weapon
                prof_weapon, profile_name = line:match('%]\u{25ba}%s(.-)%s%-%s(.-)%[')  ---@type string?, string?
                if prof_weapon and profile_name and not profile_name:lower():match('ranged') and not profile_name:lower():match('melee') then
                    weapon_name = prof_weapon
                    line = line:gsub('\u{25ba}%s', '')
                end
                if prev_profile then
                    table.insert(profiles, {count=count, color=prev_color, token_name=token_name, weapon_name=prev_weapon, profile_name=prev_profile, stats=stats})
                    if weapon_name ~= prev_weapon then
                        makeProfiles()
                    end
                elseif prev_weapon then
                    if not token_name:find('%[%-%]') then
                        token_name = token_name..'[-]'
                    end
                    TokenBuilder:new(count, token_name, weapon_type, prev_color, prev_weapon, stats, unit_tag):makeTokens()
                    if checkHalfRangeAttrs(stats) then
                        TokenBuilder:new(count, token_name..' | Half Range', weapon_type, prev_color, prev_weapon, stats, unit_tag):makeTokens()
                    end
                end
                local count_str, wnmult = line:match('(%d+)\u{00d7}(%w[^[]*)')  ---@type string, string
                if count_str then
                    count = tonumber(count_str)  --[[@as integer]]
                    weapon_name = wnmult:trim()
                    token_name = ('[%s]%s[-]'):format(color, weapon_name)
                else
                    count = 1
                    token_name = line
                end
                prev_weapon = weapon_name
                prev_profile = profile_name
                prev_color = color
            elseif line:match('A:[%dD]+') then
                stats = line:rtrim()
            elseif line:match('%[su[bp]%]%[%x+%]%[[^%[%]]+%]%[%-%]%[/su[bp]%]') then
                stats = stats..'\n'..line:rtrim()
            elseif profile_name then
                if prev_profile then
                    table.insert(profiles, {count=count, color=prev_color, token_name=token_name, weapon_name=prev_weapon, profile_name=prev_profile, stats=stats})
                end
                if prev_color ~= '5785fe' then
                    token_name = prev_weapon..' - '..profile_name:lower()
                else
                    token_name = prev_weapon..' - '..profile_name
                end
                prev_profile = profile_name
            end
        end
        if prev_profile then
            table.insert(profiles, {count=count, color=prev_color, token_name=token_name, weapon_name=prev_weapon, profile_name=prev_profile, stats=stats})
            makeProfiles()
        elseif prev_weapon then
            if not token_name:find('%[%-%]') then
                token_name = token_name..'[-]'
            end
            TokenBuilder:new(count, token_name, weapon_type, prev_color, prev_weapon, stats, unit_tag):makeTokens()
            if checkHalfRangeAttrs(stats) then
                TokenBuilder:new(count, token_name..' | Half Range', weapon_type, prev_color, prev_weapon, stats, unit_tag):makeTokens()
            end
        end
    end
    for _, model in ipairs(unit_models) do
        desc = model.getDescription()
        _, rangedHEnd = desc:find('%[e85545%]Ranged weapons%[%-%]')
        rangedHEnd = rangedHEnd or 1
        abl = desc:find('%[dc61ed%]%w*%s?Abilities%[%-%]') or #desc
        meleeHStart, meleeHEnd = desc:find('%[e85545%]Melee weapons%[%-%]')
        meleeHStart, meleeHEnd = meleeHStart or abl, meleeHEnd or abl
        parseWeapons(desc:sub(rangedHEnd + 1, meleeHStart - 1), 'ranged')
        parseWeapons(desc:sub(meleeHEnd + 1, abl - 1), 'melee')
    end
end

---@param unit_tag string
function GenerateStrategemTokens(unit_tag)
    local leader_models = getObjectsWithAllTags{unit_tag, 'leaderModel'}
    local unit_data = leader_models[1].getTable('unitData')  ---@type UnitData
    for _, strategem in pairs(strategems) do
        if not strategem.faction or unit_data.factionKeywords:match(strategem.faction) then
            local matched_keywords = false
            if strategem.keywords then
                for _, keyword in ipairs(strategem.keywords) do
                    if unit_data.keywords:match('%f[%w]'..keyword..'%f[%W]') then
                        matched_keywords = true
                        break
                    end
                end
            else
                matched_keywords = true
            end
            if (
                    matched_keywords
                    and (
                        not strategem.restriction
                        or not unit_data.keywords:match('%f[%w]'..strategem.restriction..'%f[%W]')
                        or (strategem.exception and unit_data.keywords:match('%f[%w]'..strategem.exception..'%f[%W]'))
                    )
                    and (not strategem.ability or unit_data.abilities[strategem.ability])
                ) then
                spawnObject{
                    type = 'Custom_Tile',
                    rotation = {0, 45, 0},
                    scale = {0.5, 1, 0.5},
                    callback_function=|obj| setStrategemToken(obj, strategem, unit_tag)
                }
            end
        end
    end
end

---@param ... object
function GenerateTokens(...)
    models = {...}
    if making_weapon_tokens or making_strategem_tokens then
        local uuids = {}  ---@type { [string]: boolean }
        for _, model in ipairs(models) do
            for _, tag in ipairs(model.getTags()) do
                local uuid_tag = tag:match('uuid_'..('%x'):rep(8)..'$')  ---@type string
                if uuid_tag then
                    if not uuids[uuid_tag] then
                        uuids[uuid_tag] = true
                        bag = findBag(uuid_tag)
                        if bag then
                            if making_weapon_tokens then
                                GenerateWeaponTokens(uuid_tag)
                            end
                            if making_strategem_tokens then
                                GenerateStrategemTokens(uuid_tag)
                            end
                            broadcastToColor('Tokens generated.', last_player_color, last_player_color)
                        end
                    end
                    break
                end
            end
        end
    end
    making_weapon_tokens = false
    making_strategem_tokens = false
end


---@param token object
---@param strategem StrategemData
---@param unit_tag string
function setStrategemToken(token, strategem, unit_tag)
    token.setName(strategem.name)
    token.setDescription(strategem.desc)
    token.setCustomObject{
        image = strategem.image,
        type = 0,
        image_bottom = strategem.back,
        thickness = 0.1
    }
    token.addTag(unit_tag)
    token.locked = false
    token.auto_raise = true
    bag.putObject(token)
end

---@param uuid_tag string
---@return Container
---@nodiscard
function findBag(uuid_tag)
    local token_bag
    local bounds = self.getBounds()
    local top = bounds.center.y + bounds.size.y/2
    local bags = getObjectsWithAllTags{uuid_tag, uuid_tag .. '_tokenBag'}  ---@type Container[]
    if #bags == 0 then
        token_bag = spawnObject(
            {
                type='Bag',
                position={x=bounds.center.x, y=top, z=bounds.center.z}
            }
        )  --[[@as Container]]
        token_bag.addTag(uuid_tag)
        token_bag.addTag(uuid_tag .. '_tokenBag')
        local leader_models = getObjectsWithAllTags{uuid_tag, 'leaderModel'}
        local model = leader_models[1]
        local unit_data = model.getTable('unitData')  ---@type UnitData
        local unit_name = unit_data.unitDecorativeName or unit_data.unitName
        token_bag.setName(unit_name..' Tokens')
    elseif #bags > 1 then
        broadcastToColor('Error: multiple bags found', last_player_color, last_player_color)
    else
        token_bag = bags[1]
        token_bag.setPosition{x=bounds.center.x, y=top, z=bounds.center.z}
    end
    return token_bag
end
---@param stats string
function checkHalfRangeAttrs(stats)
    return (
        (stats:match('Rapid Fire %d') or stats:match('RF%d') or stats:match('Melta %d') or stats:match('ML%d')) and true
        or false
    )
end

---@param s string
function string.trim(s)
    return s:ltrim():rtrim()
end

---@param s string
function string.ltrim(s)
    return s:gsub('^%s+', '')
end

---@param s string
function string.rtrim(s)
    return s:gsub('%s+$', '')
end