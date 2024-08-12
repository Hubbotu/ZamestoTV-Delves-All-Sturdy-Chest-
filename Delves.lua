local myname, ns = ...
local L = LibStub("AceLocale-3.0"):GetLocale(myname, false)

local path_meta = {__index = {
    label = "Path to treasure",
    atlas = "map-icon-SuramarDoor.tga",
    path = true,
    scale = 1.1,
}}

ns.map_spellids = {
    -- [2251] = 0, -- The Waterworks / Водокачка +
    -- [2269] = 0, -- Earthcrawl Mines / шахты Землескребов +
    -- [2249] = 0, -- Fungal Folly / Грибных гадостей +
    -- [2310] = 0, -- Skittering Breach / Снующего пролома + 
    -- [2277] = 0, -- Nightfall Sanctum / Святыни Сумерек
    -- [2302] = 0, -- The Dread Pit / Ямы Ужаса + 
	-- [2259] = 0, -- Tak-Rethan Abyss / глубин Так-Ретана (2314) +
    -- [2250] = 0, -- Kriegval's Rest / Покоя Кригвала +
    -- [2312] = 0, -- Mycomancer chestrn / пещеры микомантов +
    -- [2299] = 0, -- The Underkeep / Подоплота
    -- [2313] = 0, -- The Spiral Weave / Сплетенной Спирали (2347) +
    -- [2300] = 0, -- The Sinkhole / Воронки (2301)
}

ns.points = {
    [2277] = { -- Nightfall Sanctum / Святыни Сумерек
        [70584444] = ({
            label = L["Sturdy Chest 2"],
            cont = true,
            Zamro = true,
            note = L["Sturdy Chest 2 Note"],
            pathto = "Interface\\Addons\\"..myname.."\\Icons\\chest.tga",
        }),
        [51905539] = ({
            label = L["Sturdy Chest"],
            cont = true,
            Zamro = true,
            note = L["Sturdy Chest Note"],
            pathto = "Interface\\Addons\\"..myname.."\\Icons\\chest.tga",
        }),
		[38887406] = ({
            label = L["Sturdy Chest"],
            cont = true,
            Zamro = true,
            note = L["Sturdy Chest Note"],
            pathto = "Interface\\Addons\\"..myname.."\\Icons\\chest.tga",
        }),
		[40203704] = ({
            label = L["Sturdy Chest 3"],
            cont = true,
            Zamro = true,
            note = L["Sturdy Chest 3 Note"],
            pathto = "Interface\\Addons\\"..myname.."\\Icons\\chest.tga",
        }),
    },
	[2269] = { -- Earthcrawl Mines / шахты Землескребов
        [45251473] = ({
            label = L["Sturdy Chest"],
            cont = true,
            Zamro = true,
            achievement = {id = 40815, criteria = 167540}, 			
            note = L["Sturdy Chest Note"],
            pathto = "Interface\\Addons\\"..myname.."\\Icons\\chest.tga",
        }),
        [43502690] = ({
            label = L["Sturdy Chest"],
            cont = true,
            Zamro = true,
            achievement = {id = 40815, criteria = 167540}, 			
            note = L["Sturdy Chest Note"],
            pathto = "Interface\\Addons\\"..myname.."\\Icons\\chest.tga",
        }),
        [32844006] = ({
            label = L["Sturdy Chest"],
            cont = true,
            Zamro = true,
            achievement = {id = 40815, criteria = 167540}, 			
            note = L["Sturdy Chest Note"],
            pathto = "Interface\\Addons\\"..myname.."\\Icons\\chest.tga",
        }),		
        [36283324] = ({
            label = L["Sturdy Chest 1"],
            cont = true,
            Zamro = true,
            achievement = {id = 40815, criteria = 167540}, 			
            note = L["Sturdy Chest 1 Note"],
            pathto = "Interface\\Addons\\"..myname.."\\Icons\\chest.tga",
        }),		
        [53168205] = ({
            label = L["Sturdy Chest"],
            cont = true,
            Zamro = true,
            achievement = {id = 40815, criteria = 167540}, 			
            note = L["Sturdy Chest Note"],
            pathto = "Interface\\Addons\\"..myname.."\\Icons\\chest.tga",
        }),		
    },
    [2259] = { -- Tak-Rethan Abyss / глубин Так-Ретана (2314)
        [65235280] = ({
            label = L["Sturdy Chest"],
            cont = true,		
            Zamro = true,
            note = L["Sturdy Chest Note"],
            pathto = "Interface\\Addons\\"..myname.."\\Icons\\chest.tga",
        }),
	    [44925025] = ({
            label = L["Sturdy Chest"],
            cont = true,
            Zamro = true,
            note = L["Sturdy Chest Note"],
            pathto = "Interface\\Addons\\"..myname.."\\Icons\\chest.tga",
	    }),
	    [35195852] = ({
            label = L["Sturdy Chest"],
            cont = true,
            Zamro = true,
            note = L["Sturdy Chest Note"],
            pathto = "Interface\\Addons\\"..myname.."\\Icons\\chest.tga",
	    }),
	    [41517503] = ({
            label = L["Sturdy Chest"],
            cont = true,
            Zamro = true,
            note = L["Sturdy Chest Note"],
            pathto = "Interface\\Addons\\"..myname.."\\Icons\\chest.tga",
	    }),		
    },
    [2313] = { -- The Spiral Weave / Сплетенной Спирали
        [50024579] = ({
            label = L["Sturdy Chest"],
            cont = true,
            Zamro = true,
            note = L["Sturdy Chest Note"],
            pathto = "Interface\\Addons\\"..myname.."\\Icons\\chest.tga",
        }),
	    [36441121] = ({
            label = L["Sturdy Chest 4"],
            cont = true,
            Zamro = true,
            note = L["Sturdy Chest 4 Note"],
            pathto = "Interface\\Addons\\"..myname.."\\Icons\\chest.tga",
	    }),	
	    [46074624] = ({
            label = L["Sturdy Chest 5"],
            cont = true,
            Zamro = true,
            note = L["Sturdy Chest 5 Note"],
            pathto = "Interface\\Addons\\"..myname.."\\Icons\\chest.tga",
	    }),	
	    [42584775] = ({
            label = L["Sturdy Chest 6"],
            cont = true,
            Zamro = true,
            note = L["Sturdy Chest 6 Note"],
            pathto = "Interface\\Addons\\"..myname.."\\Icons\\chest.tga",
	    }),			
    },
	[2312] = { -- Mycomancer chestrn / пещеры микомантов
        [49662186] = ({
            label = L["Sturdy Chest"],
            cont = true,
            Zamro = true,
            note = L["Sturdy Chest Note"],
            pathto = "Interface\\Addons\\"..myname.."\\Icons\\chest.tga",
        }),
	    [62814517] = ({
            label = L["Sturdy Chest"],
            cont = true,
            Zamro = true,
            note = L["Sturdy Chest Note"],
            pathto = "Interface\\Addons\\"..myname.."\\Icons\\chest.tga",
	    }),	
	    [68754046] = ({
            label = L["Sturdy Chest"],
            cont = true,
            Zamro = true,
            note = L["Sturdy Chest Note"],
            pathto = "Interface\\Addons\\"..myname.."\\Icons\\chest.tga",
	    }),	
	    [40746165] = ({
            label = L["Sturdy Chest 7"],
            cont = true,
            Zamro = true,
            note = L["Sturdy Chest 7 Note"],
            pathto = "Interface\\Addons\\"..myname.."\\Icons\\chest.tga",
	    }),	
    },
	[2310] = { -- Skittering Breach / Снующего пролома
        [51216529] = ({
            label = L["Sturdy Chest"],
            cont = true,
            Zamro = true,
            note = L["Sturdy Chest Note"],
            pathto = "Interface\\Addons\\"..myname.."\\Icons\\chest.tga",
        }),
	    [26982640] = ({
            label = L["Sturdy Chest"],
            cont = true,
            Zamro = true,
            note = L["Sturdy Chest Note"],
            pathto = "Interface\\Addons\\"..myname.."\\Icons\\chest.tga",
        }),
	    [55592415] = ({
            label = L["Sturdy Chest"],
            cont = true,
            Zamro = true,
            note = L["Sturdy Chest Note"],
            pathto = "Interface\\Addons\\"..myname.."\\Icons\\chest.tga",
        }),
	    [66591485] = ({
            label = L["Sturdy Chest 8"],
            cont = true,
            Zamro = true,
            note = L["Sturdy Chest 8 Note"],
            pathto = "Interface\\Addons\\"..myname.."\\Icons\\chest.tga",
        }),			
    },
    [2249] = { -- Fungal Folly / Грибных гадостей
        [58514703] = ({
           label = L["Sturdy Chest"],
           cont = true,
           quest = 83702,		   
           Zamro = true,
           note = L["Sturdy Chest Note"],
           pathto = "Interface\\Addons\\"..myname.."\\Icons\\chest.tga",
        }),
	    [49453589] = ({
            label = L["Sturdy Chest 9"],
            cont = true,
            quest = 83452,			
            Zamro = true,
            note = L["Sturdy Chest 9 Note"],
            pathto = "Interface\\Addons\\"..myname.."\\Icons\\chest.tga",
        }),
	    [34546550] = ({
            label = L["Sturdy Chest"],
            cont = true,
            quest = 83689,			
            Zamro = true,
            note = L["Sturdy Chest Note"],
            pathto = "Interface\\Addons\\"..myname.."\\Icons\\chest.tga",
        }),
	    [32907432] = ({
            label = L["Sturdy Chest"],
            cont = true,
            quest = 83671,				
            Zamro = true,
            note = L["Sturdy Chest Note"],
            pathto = "Interface\\Addons\\"..myname.."\\Icons\\chest.tga",
        }),	
	    [41937961] = ({
            label = L["Wrapped Spool 1"],
            cont = true,
            quest = 83671,				
            Zamro = true,
            note = L["Wrapped Spool 1 Note"],
            pathto = "Interface\\Addons\\"..myname.."\\Icons\\tokens.tga",
        }),		
	    [55804514] = ({
            label = L["Sturdy Chest 10"],
            cont = true,
            quest = 83690,				
            Zamro = true,
            note = L["Sturdy Chest 10 Note"],
            pathto = "Interface\\Addons\\"..myname.."\\Icons\\tokens.tga",
        }),		
	    [53314164] = ({
            label = L["Sturdy Chest"],
            cont = true,
            quest = 83690,				
            Zamro = true,
            note = L["Sturdy Chest Note"],
            pathto = "Interface\\Addons\\"..myname.."\\Icons\\chest.tga",
        }),			
    },
    [2302] = { -- The Dread Pit / Ямы Ужаса
        [41104548] = ({
           label = L["Sturdy Chest"],
           cont = true,
           quest = 83677,
           Zamro = true,
           note = L["Sturdy Chest Note"],
           pathto = "Interface\\Addons\\"..myname.."\\Icons\\chest.tga",
        }),
	    [57415613] = ({
            label = L["Sturdy Chest"],
            cont = true,
            quest = 83658,			
            Zamro = true,
            note = L["Sturdy Chest Note"],
            pathto = "Interface\\Addons\\"..myname.."\\Icons\\chest.tga",
        }),
	    [57852766] = ({
            label = L["Sturdy Chest"],
            cont = true,
            quest = 83678,				
            Zamro = true,
            note = L["Sturdy Chest Note"],
            pathto = "Interface\\Addons\\"..myname.."\\Icons\\chest.tga",
        }),
	    [41637871] = ({
            label = L["Wrapped Spool"],
            cont = true,				
            Zamro = true,
            note = L["Wrapped Spool Note"],
            pathto = "Interface\\Addons\\"..myname.."\\Icons\\tokens.tga",
        }),		
	    [36231662] = ({
            label = L["Sturdy Chest"],
            cont = true,
            quest = 83659,			
            Zamro = true,
            note = L["Sturdy Chest Note"],
            pathto = "Interface\\Addons\\"..myname.."\\Icons\\chest.tga",
        }),	
    },	
    [2250] = { -- Kriegval's Rest / Покоя Кригвала
        [46281955] = ({
           label = L["Sturdy Chest"],
           cont = true,
           Zamro = true,
           note = L["Sturdy Chest Note"],
           pathto = "Interface\\Addons\\"..myname.."\\Icons\\chest.tga",
        }),
	    [62225299] = ({
            label = L["Sturdy Chest 11"],
            cont = true,
            quest = 83698,			
            Zamro = true,
            note = L["Sturdy Chest 11 Note"],
            pathto = "Interface\\Addons\\"..myname.."\\Icons\\chest.tga",
        }),
	    [69818519] = ({
            label = L["Sturdy Chest"],
            cont = true,			
            Zamro = true,
            note = L["Sturdy Chest Note"],
            pathto = "Interface\\Addons\\"..myname.."\\Icons\\chest.tga",
        }),	
	    [74397009] = ({
            label = L["Sturdy Chest"],
            cont = true,		
            Zamro = true,
            note = L["Sturdy Chest Note"],
            pathto = "Interface\\Addons\\"..myname.."\\Icons\\chest.tga",
        }),	
    },		
}
