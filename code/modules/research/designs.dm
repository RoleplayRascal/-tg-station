/***************************************************************
**						Design Datums						  **
**	All the data for building stuff and tracking reliability. **
***************************************************************/
/*
For the materials datum, it assumes you need reagents unless specified otherwise. To designate a material that isn't a reagent,
you use one of the material IDs below. These are NOT ids in the usual sense (they aren't defined in the object or part of a datum),
they are simply references used as part of a "has materials?" type proc. They all start with a $ to denote that they aren't reagents.
The currently supporting non-reagent materials. All material amounts are set as the define MINERAL_MATERIAL_AMOUNT, which defaults to 2000
- MAT_METAL (/obj/item/stack/metal).
- MAT_GLASS (/obj/item/stack/glass).
- MAT_PLASMA (/obj/item/stack/plasma).
- MAT_SILVER (/obj/item/stack/silver).
- MAT_GOLD (/obj/item/stack/gold).
- MAT_URANIUM (/obj/item/stack/uranium).
- MAT_DIAMOND (/obj/item/stack/diamond).
- MAT_BANANIUM (/obj/item/stack/bananium)..
(Insert new ones here)

Don't add new keyword/IDs if they are made from an existing one (such as rods which are made from metal). Only add raw materials.

Design Guidlines
- The reliability formula for all R&D built items is reliability (a fixed number) + total tech levels required to make it +
reliability_mod (starts at 0, gets improved through experimentation). Example: PACMAN generator. 79 base reliablity + 6 tech
(3 plasmatech, 3 powerstorage) + 0 (since it's completely new) = 85% reliability. Reliability is the chance it works CORRECTLY.
- When adding new designs, check rdreadme.dm to see what kind of things have already been made and where new stuff is needed.
- A single sheet of anything is 3750 units of material. Materials besides metal/glass require help from other jobs (mining for
other types of metals and chemistry for reagents).
- Add the AUTOLATHE tag to
*/

/datum/design						//Datum for object designs, used in construction
	var/name = "Name"					//Name of the created object.
	var/desc = "Desc"					//Description of the created object.
	var/item_name = null			//An item name before it is modified by various name-modifying procs
	var/id = "id"						//ID of the created object for easy refernece. Alphanumeric, lower-case, no symbols
	var/list/req_tech = list()			//IDs of that techs the object originated from and the minimum level requirements.			//Reliability modifier of the device at it's starting point.
	var/reliability = 100				//Reliability of the device.
	var/build_type = null				//Flag as to what kind machine the design is built in. See defines.
	var/list/materials = list()			//List of materials. Format: "id" = amount.
	var/construction_time				//Amount of time required for building the object
	var/build_path = ""					//The file path of the object that gets created
	var/list/category = null 			//Primarily used for Mech Fabricators, but can be used for anything

/datum/design/New()
	..()
	item_name = name
	AssembleDesignInfo()

//These procs are used in subtypes for assigning names and descriptions dynamically
/datum/design/proc/AssembleDesignInfo()
	AssembleDesignName()
	AssembleDesignDesc()
	return

/datum/design/proc/AssembleDesignName()
	if(!name && build_path)					//Get name from build path if posible
		var/atom/movable/A = build_path
		name = initial(A.name)
		item_name = name
	return

/datum/design/proc/AssembleDesignDesc()
	if(!desc)								//Try to make up a nice description if we don't have one
		desc = "Allows for the construction of \a [item_name]."
	return

//Returns a new instance of the item for this design
//This is to allow additional initialization to be performed, including possibly additional contructor arguments.
/datum/design/proc/Fabricate(var/newloc, var/fabricator)
	return new build_path(newloc)

//A proc to calculate the reliability of a design based on tech levels and innate modifiers.
//Input: A list of /datum/tech; Output: The new reliabilty.
/datum/design/proc/CalcReliability(var/list/temp_techs)
	var/new_reliability
	for(var/datum/tech/T in temp_techs)
		if(T.id in req_tech)
			new_reliability += T.level
	new_reliability = Clamp(new_reliability, reliability, 100)
	reliability = new_reliability
	return


////////////////////////////////////////
//Disks for transporting design datums//
////////////////////////////////////////

/obj/item/weapon/disk/design_disk
	name = "Component Design Disk"
	desc = "A disk for storing device design data for construction in lathes."
	icon = 'icons/obj/cloning.dmi'
	icon_state = "datadisk1"
	materials = list(MAT_METAL=30, MAT_GLASS=10)
	var/datum/design/blueprint

/obj/item/weapon/disk/design_disk/New()
	src.pixel_x = rand(-5.0, 5)
	src.pixel_y = rand(-5.0, 5)

///////////////////////////////////
/////Non-Board Computer Stuff//////
///////////////////////////////////

/datum/design/intellicard
	name = "Intellicard AI Transportation System"
	desc = "Allows for the construction of an intellicard."
	id = "intellicard"
	req_tech = list("programming" = 4, "materials" = 4)
	build_type = PROTOLATHE
	materials = list(MAT_GOLD = 1000, MAT_GOLD = 200)
	build_path = /obj/item/device/aicard
	category = list("Electronics")

/datum/design/paicard
	name = "Personal Artificial Intelligence Card"
	desc = "Allows for the construction of a pAI Card."
	id = "paicard"
	req_tech = list("programming" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_GLASS = 500, MAT_METAL = 500)
	build_path = /obj/item/device/paicard
	category = list("Electronics")


////////////////////////////////////////
//////////Disk Construction Disks///////
////////////////////////////////////////
/datum/design/design_disk
	name = "Design Storage Disk"
	desc = "Produce additional disks for storing device designs."
	id = "design_disk"
	req_tech = list("programming" = 1)
	build_type = PROTOLATHE | AUTOLATHE
	materials = list(MAT_METAL = 30, MAT_GLASS = 10)
	build_path = /obj/item/weapon/disk/design_disk
	category = list("Electronics")

/datum/design/tech_disk
	name = "Technology Data Storage Disk"
	desc = "Produce additional disks for storing technology data."
	id = "tech_disk"
	req_tech = list("programming" = 1)
	build_type = PROTOLATHE | AUTOLATHE
	materials = list(MAT_METAL = 30, MAT_GLASS = 10)
	build_path = /obj/item/weapon/disk/tech_disk
	category = list("Electronics")


/////////////////////////////////////////
/////////////////Mining//////////////////
/////////////////////////////////////////

/datum/design/drill
	name = "Mining Drill"
	desc = "Yours is the drill that will pierce through the rock walls."
	id = "drill"
	req_tech = list("materials" = 2, "powerstorage" = 3, "engineering" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 6000, MAT_GLASS = 1000) //expensive, but no need for miners.
	build_path = /obj/item/weapon/pickaxe/drill
	category = list("Mining Designs")

/datum/design/plasmacutter
	name = "Plasma Cutter"
	desc = "You could use it to cut limbs off of xenos! Or, you know, mine stuff."
	id = "plasmacutter"
	req_tech = list("materials" = 2, "plasmatech" = 2, "engineering" = 2, "combat" = 1, "magnets" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 1500, MAT_GLASS = 500, MAT_PLASMA = 400)
	reliability = 79
	build_path = /obj/item/weapon/gun/energy/plasmacutter
	category = list("Mining Designs")

/datum/design/plasmacutter_adv
	name = "Advanced Plasma Cutter"
	desc = "It's an advanced plasma cutter, oh my god."
	id = "plasmacutter_adv"
	req_tech = list("materials" = 4, "plasmatech" = 3, "engineering" = 3, "combat" = 3, "magnets" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 3000, MAT_GLASS = 1000, MAT_PLASMA = 2000, MAT_GOLD = 500)
	reliability = 79
	build_path = /obj/item/weapon/gun/energy/plasmacutter/adv
	category = list("Mining Designs")

/datum/design/jackhammer
	name = "Sonic Jackhammer"
	desc = "Essentially a handheld planet-cracker. Can drill through basic walls as well"
	id = "jackhammer"
	req_tech = list("materials" = 3, "powerstorage" = 2, "engineering" = 3, "magnets" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 8000, MAT_GLASS = 1500, MAT_SILVER = 2000)
	build_path = /obj/item/weapon/pickaxe/drill/jackhammer
	category = list("Mining Designs")

/datum/design/drill_diamond
	name = "Diamond-Tipped Mining Drill"
	desc = "Yours is the drill that will pierce the heavens!"
	id = "drill_diamond"
	req_tech = list("materials" = 6, "powerstorage" = 4, "engineering" = 4)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 6000, MAT_GLASS = 1000, MAT_DIAMOND = 3750) //Yes, a whole diamond is needed.
	reliability = 79
	build_path = /obj/item/weapon/pickaxe/drill/diamonddrill
	category = list("Mining Designs")



/////////////////////////////////////////
//////////////Blue Space/////////////////
/////////////////////////////////////////

/datum/design/beacon
	name = "Tracking Beacon"
	desc = "A blue space tracking beacon."
	id = "beacon"
	req_tech = list("bluespace" = 1)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 20, MAT_GLASS = 10)
	build_path = /obj/item/device/beacon
	category = list("Bluespace Designs")

/datum/design/bag_holding
	name = "Bag of Holding"
	desc = "A backpack that opens into a localized pocket of Blue Space."
	id = "bag_holding"
	req_tech = list("bluespace" = 4, "materials" = 6)
	build_type = PROTOLATHE
	materials = list(MAT_GOLD = 3000, MAT_DIAMOND = 1500, MAT_URANIUM = 250)
	reliability = 80
	build_path = /obj/item/weapon/storage/backpack/holding
	category = list("Bluespace Designs")

/datum/design/bluespace_crystal
	name = "Artificial Bluespace Crystal"
	desc = "A small blue crystal with mystical properties."
	id = "bluespace_crystal"
	req_tech = list("bluespace" = 4, "materials" = 6)
	build_type = PROTOLATHE
	materials = list(MAT_DIAMOND = 1500, MAT_PLASMA = 1500)
	reliability = 100
	build_path = /obj/item/bluespace_crystal/artificial
	category = list("Bluespace Designs")

/datum/design/bluespace_crystal2
	name = "Improved Bluespace Crystal"
	desc = "A higher quality bluespace crystal designed for advanced research purposes."
	id = "bluespace_crystal2"
	req_tech = list("bluespace" = 6, "materials" = 6)
	build_type = PROTOLATHE
	materials = list(MAT_DIAMOND = 2000, MAT_PLASMA = 1000)
	reliability = 100
	build_path = /obj/item/bluespace_crystal
	category = list("Bluespace Designs")

/datum/design/telesci_gps
	name = "GPS Device"
	desc = "Little thingie that can track its position at all times."
	id = "telesci_gps"
	req_tech = list("materials" = 2, "magnets" = 3, "bluespace" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 500, MAT_GLASS = 1000)
	build_path = /obj/item/device/gps
	category = list("Bluespace Designs")

/datum/design/miningsatchel_holding
	name = "Mining Satchel of Holding"
	desc = "A mining satchel that can hold an infinite amount of ores."
	id = "minerbag_holding"
	req_tech = list("bluespace" = 3, "materials" = 4)
	build_type = PROTOLATHE
	materials = list(MAT_GOLD = 250, MAT_URANIUM = 500) //quite cheap, for more convenience
	reliability = 100
	build_path = /obj/item/weapon/storage/bag/ore/holding
	category = list("Bluespace Designs")


/////////////////////////////////////////
/////////////////HUDs////////////////////
/////////////////////////////////////////

/datum/design/health_hud
	name = "Health Scanner HUD"
	desc = "A heads-up display that scans the humans in view and provides accurate data about their health status."
	id = "health_hud"
	req_tech = list("biotech" = 2, "magnets" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 50, MAT_GLASS = 50)
	build_path = /obj/item/clothing/glasses/hud/health
	category = list("Equipment")

/datum/design/health_hud_night
	name = "Night Vision Health Scanner HUD"
	desc = "An advanced medical head-up display that allows doctors to find patients in complete darkness."
	id = "health_hud_night"
	req_tech = list("biotech" = 4, "magnets" = 5)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 200, MAT_GLASS = 200, MAT_URANIUM = 1000, MAT_SILVER = 250)
	build_path = /obj/item/clothing/glasses/hud/health/night
	category = list("Equipment")

/datum/design/security_hud
	name = "Security HUD"
	desc = "A heads-up display that scans the humans in view and provides accurate data about their ID status."
	id = "security_hud"
	req_tech = list("magnets" = 3, "combat" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 50, MAT_GLASS = 50)
	build_path = /obj/item/clothing/glasses/hud/security
	category = list("Equipment")

/datum/design/security_hud_night
	name = "Night Vision Security HUD"
	desc = "A heads-up display which provides id data and vision in complete darkness."
	id = "security_hud_night"
	req_tech = list("magnets" = 5, "combat" = 4)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 200, MAT_GLASS = 200, MAT_URANIUM = 1000, MAT_GOLD = 350)
	build_path = /obj/item/clothing/glasses/hud/security/night
	category = list("Equipment")

/////////////////////////////////////////
//////////////////Test///////////////////
/////////////////////////////////////////

	/*	test
			name = "Test Design"
			desc = "A design to test the new protolathe."
			id = "protolathe_test"
			build_type = PROTOLATHE
			req_tech = list("materials" = 1)
			materials = list(MAT_GOLD = 3000, "iron" = 15, "copper" = 10, MAT_SILVER = 2500)
			build_path = /obj/item/weapon/banhammer"
			category = list("Weapons") */

/////////////////////////////////////////
//////////////////Misc///////////////////
/////////////////////////////////////////

/datum/design/welding_mask
	name = "Welding Gas Mask"
	desc = "A gas mask with built in welding goggles and face shield. Looks like a skull, clearly designed by a nerd."
	id = "weldingmask"
	req_tech = list("materials" = 2, "engineering" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 4000, MAT_GLASS = 1000)
	build_path = /obj/item/clothing/mask/gas/welding
	category = list("Equipment")

/datum/design/air_horn
	name = "Air Horn"
	desc = "Damn son, where'd you find this?"
	id = "air_horn"
	req_tech = list("materials" = 2, "engineering" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 4000, "$bananium" = 1000)
	build_path = /obj/item/weapon/bikehorn/airhorn
	category = list("Equipment")

/datum/design/mesons
	name = "Optical Meson Scanners"
	desc = "Used by engineering and mining staff to see basic structural and terrain layouts through walls, regardless of lighting condition."
	id = "mesons"
	req_tech = list("materials" = 3, "magnets" = 3, "engineering" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 200, MAT_GLASS = 300, MAT_PLASMA = 100)
	build_path = /obj/item/clothing/glasses/meson
	category = list("Equipment")

/datum/design/engine_goggles
	name = "Engineering Scanner Goggles"
	desc = "Goggles used by engineers. The Meson Scanner mode lets you see basic structural and terrain layouts through walls, regardless of lighting condition. The T-ray Scanner mode lets you see underfloor objects such as cables and pipes."
	id = "engine_goggles"
	req_tech = list("materials" = 4, "magnets" = 3, "engineering" = 4)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 200, MAT_GLASS = 300, MAT_PLASMA = 100)
	build_path = /obj/item/clothing/glasses/meson/engine
	category = list("Equipment")

/datum/design/nvgmesons
	name = "Night Vision Optical Meson Scanners"
	desc = "Prototype meson scanners fitted with an extra sensor which amplifies the visible light spectrum and overlays it to the UHD display."
	id = "nvgmesons"
	req_tech = list("materials" = 5, "magnets" = 5, "engineering" = 4)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 300, MAT_GLASS = 400, MAT_PLASMA = 250, MAT_URANIUM = 1000)
	build_path = /obj/item/clothing/glasses/meson/night
	category = list("Equipment")

/datum/design/night_vision_goggles
	name = "Night Vision Goggles"
	desc = "Goggles that let you see through darkness unhindered."
	id = "night_visision_goggles"
	req_tech = list("magnets" = 4)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 100, MAT_GLASS = 100, MAT_URANIUM = 1000)
	build_path = /obj/item/clothing/glasses/night
	category = list("Equipment")

/datum/design/magboots
	name = "Magnetic Boots"
	desc = "Magnetic boots, often used during extravehicular activity to ensure the user remains safely attached to the vehicle."
	id = "magboots"
	req_tech = list("materials" = 4, "magnets" = 4, "engineering" = 5)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 4500, MAT_SILVER = 1500, MAT_GOLD = 2500)
	build_path = /obj/item/clothing/shoes/magboots
	category = list("Equipment")

// remove shit below later

/////////////////////////////////////////
////////////Janitor Designs//////////////
/////////////////////////////////////////

/datum/design/buffer
	name = "Floor Buffer Upgrade"
	desc = "A floor buffer that can be attached to vehicular janicarts."
	id = "buffer"
	req_tech = list("materials" = 5, "engineering" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 3000, MAT_GLASS = 200)
	build_path = /obj/item/janiupgrade
	category = list("Equipment")

/datum/design/holosign
	name = "Holographic Sign Projector"
	desc = "A holograpic projector used to project various warning signs."
	id = "holosign"
	req_tech = list("magnets" = 3, "powerstorage" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 2000, MAT_GLASS = 1000)
	build_path = /obj/item/weapon/holosign_creator
	category = list("Equipment")


/////////////////////////////////////////
////////////Tools////////////////////////
/////////////////////////////////////////

/datum/design/exwelder
	name = "Experimental Welding Tool"
	desc = "An experimental welder capable of self-fuel generation."
	id = "exwelder"
	req_tech = list("materials" = 4, "engineering" = 4, "bluespace" = 3, "plasmatech" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 1000, MAT_GLASS = 500, MAT_PLASMA = 1500, MAT_URANIUM = 200)
	build_path = /obj/item/weapon/weldingtool/experimental
	category = list("Equipment")  //fuck you tg


/////////////////////////////////////////
//////Integrated Circuits////////////////
/////////////////////////////////////////

/datum/design/item/wirer
	name = "Custom wirer tool"
	id = "wirer"
	req_tech = list(TECH_MATERIAL = 2, TECH_ENGINEERING = 2)
	materials = list(DEFAULT_WALL_MATERIAL = 5000, "glass" = 2500)
	build_type = PROTOLATHE
	build_path = /obj/item/device/integrated_electronics/wirer
	category = list("Electronics")

/datum/design/item/debugger
	name = "Custom circuit debugger tool"
	id = "debugger"
	req_tech = list(TECH_MATERIAL = 2, TECH_ENGINEERING = 2)
	materials = list(DEFAULT_WALL_MATERIAL = 5000, "glass" = 2500)
	build_path = /obj/item/device/integrated_electronics/debugger


/datum/design/item/custom_circuit_assembly
	name = "Small custom assembly"
	desc = "An customizable assembly for simple, small devices."
	id = "assembly-small"
	build_type = PROTOLATHE
	req_tech = list(TECH_MATERIAL = 3, TECH_ENGINEERING = 2, TECH_POWER = 2)
	materials = list(DEFAULT_WALL_MATERIAL = 10000)
	build_path = /obj/item/device/electronic_assembly
	category = list("Electronics")

/datum/design/item/custom_circuit_assembly/medium
	name = "Medium custom assembly"
	desc = "An customizable assembly suited for more ambitious mechanisms."
	id = "assembly-medium"
	req_tech = list(TECH_MATERIAL = 4, TECH_ENGINEERING = 3, TECH_POWER = 3)
	materials = list(DEFAULT_WALL_MATERIAL = 20000)
	build_path = /obj/item/device/electronic_assembly/medium

/datum/design/item/custom_circuit_assembly/large
	name = "Large custom assembly"
	desc = "An customizable assembly for large machines."
	id = "assembly-large"
	req_tech = list(TECH_MATERIAL = 5, TECH_ENGINEERING = 4, TECH_POWER = 4)
	materials = list(DEFAULT_WALL_MATERIAL = 40000)
	build_path = /obj/item/device/electronic_assembly/large

/datum/design/circuit/integrated_circuit
	req_tech = list(TECH_ENGINEERING = 2, TECH_DATA = 2)
	category = list("Electronics")

/datum/design/circuit/integrated_circuit/AssembleDesignName()
	..()
	name = "Custom circuitry ([item_name])"

/datum/design/circuit/integrated_circuit/AssembleDesignDesc()
	if(!desc)
		desc = "Allows for the construction of \a [name] custom circuit."

/datum/design/circuit/integrated_circuit/arithmetic/AssembleDesignName()
	..()
	name = "Custom circuitry \[Arithmetic\] ([item_name])"

/datum/design/circuit/integrated_circuit/arithmetic/addition
	id = "cc-addition"
	build_path = /obj/item/integrated_circuit/arithmetic/addition

/datum/design/circuit/integrated_circuit/arithmetic/subtraction
	id = "cc-subtraction"
	build_path = /obj/item/integrated_circuit/arithmetic/subtraction

/datum/design/circuit/integrated_circuit/arithmetic/multiplication
	id = "cc-multiplication"
	build_path = /obj/item/integrated_circuit/arithmetic/multiplication

/datum/design/circuit/integrated_circuit/arithmetic/division
	id = "cc-division"
	build_path = /obj/item/integrated_circuit/arithmetic/division

/datum/design/circuit/integrated_circuit/arithmetic/absolute
	id = "cc-absolute"
	build_path = /obj/item/integrated_circuit/arithmetic/absolute

/datum/design/circuit/integrated_circuit/arithmetic/average
	id = "cc-average"
	build_path = /obj/item/integrated_circuit/arithmetic/average

/datum/design/circuit/integrated_circuit/arithmetic/pi
	id = "cc-pi"
	build_path = /obj/item/integrated_circuit/arithmetic/pi

/datum/design/circuit/integrated_circuit/arithmetic/random
	id = "cc-random"
	build_path = /obj/item/integrated_circuit/arithmetic/random



/datum/design/circuit/integrated_circuit/converter/AssembleDesignName()
	..()
	name = "Custom circuitry \[Conversion\] ([item_name])"

/datum/design/circuit/integrated_circuit/converter/num2text
	id = "cc-num2text"
	build_path = /obj/item/integrated_circuit/converter/num2text

/datum/design/circuit/integrated_circuit/converter/text2num
	id = "cc-text2num"
	build_path = /obj/item/integrated_circuit/converter/text2num

/datum/design/circuit/integrated_circuit/converter/ref2text
	id = "cc-ref2text"
	build_path = /obj/item/integrated_circuit/converter/ref2text

/datum/design/circuit/integrated_circuit/converter/lowercase
	id = "cc-lowercase"
	build_path = /obj/item/integrated_circuit/converter/lowercase

/datum/design/circuit/integrated_circuit/converter/uppercase
	id = "cc-uppercase"
	build_path = /obj/item/integrated_circuit/converter/uppercase

/datum/design/circuit/integrated_circuit/converter/concatenatior
	id = "cc-concatenatior"
	build_path = /obj/item/integrated_circuit/converter/concatenatior



/datum/design/circuit/integrated_circuit/coordinate/AssembleDesignName()
	..()
	name = "Custom circuitry \[Coordinate\] ([item_name])"

/datum/design/circuit/integrated_circuit/coordinate/gps
	id = "cc-gps"
	build_path = /obj/item/integrated_circuit/gps

/datum/design/circuit/integrated_circuit/coordinate/abs_to_rel_coords
	id = "cc-abs_to_rel_coords"
	build_path = /obj/item/integrated_circuit/abs_to_rel_coords



/datum/design/circuit/integrated_circuit/transfer/AssembleDesignName()
	..()
	name = "Custom circuitry \[Transfer\] ([item_name])"

/datum/design/circuit/integrated_circuit/transfer/splitter
	id = "cc-splitter"
	build_path = /obj/item/integrated_circuit/transfer/splitter

/datum/design/circuit/integrated_circuit/transfer/splitter4
	id = "cc-splitter4"
	build_path = /obj/item/integrated_circuit/transfer/splitter/medium

/datum/design/circuit/integrated_circuit/transfer/splitter8
	id = "cc-splitter8"
	build_path = /obj/item/integrated_circuit/transfer/splitter/large

/datum/design/circuit/integrated_circuit/transfer/activator_splitter
	id = "cc-activator_splitter"
	build_path = /obj/item/integrated_circuit/transfer/activator_splitter

/datum/design/circuit/integrated_circuit/transfer/activator_splitter4
	id = "cc-activator_splitter4"
	build_path = /obj/item/integrated_circuit/transfer/activator_splitter/medium

/datum/design/circuit/integrated_circuit/transfer/activator_splitter8
	id = "cc-activator_splitter8"
	build_path = /obj/item/integrated_circuit/transfer/activator_splitter/large



/datum/design/circuit/integrated_circuit/input_output/AssembleDesignName()
	..()
	name = "Custom circuitry \[Input/Output\] ([item_name])"

/datum/design/circuit/integrated_circuit/input_output/button
	id = "cc-button"
	build_path = /obj/item/integrated_circuit/input/button

/datum/design/circuit/integrated_circuit/input_output/numberpad
	id = "cc-numberpad"
	build_path = /obj/item/integrated_circuit/input/numberpad

/datum/design/circuit/integrated_circuit/input_output/textpad
	id = "cc-textpad"
	build_path = /obj/item/integrated_circuit/input/textpad

/datum/design/circuit/integrated_circuit/input_output/screen
	id = "cc-screen"
	build_path = /obj/item/integrated_circuit/output/screen

/datum/design/circuit/integrated_circuit/input_output/med_scanner
	id = "cc-medscanner"
	build_path = /obj/item/integrated_circuit/input/med_scanner
	req_tech = list(TECH_MATERIAL = 2, TECH_MAGNETS = 2, TECH_BIOMED = 2)

/datum/design/circuit/integrated_circuit/input_output/adv_med_scanner
	id = "cc-advmedscanner"
	build_path = /obj/item/integrated_circuit/input/adv_med_scanner
	req_tech = list(TECH_MATERIAL = 2, TECH_MAGNETS = 3, TECH_BIOMED = 4)

/datum/design/circuit/integrated_circuit/input_output/local_locator
	id = "cc-locallocator"
	build_path = /obj/item/integrated_circuit/input/local_locator

/datum/design/circuit/integrated_circuit/input_output/signaler
	id = "cc-signaler"
	build_path = /obj/item/integrated_circuit/input/signaler

/datum/design/circuit/integrated_circuit/input_output/light
	id = "cc-light"
	build_path = /obj/item/integrated_circuit/output/light

/datum/design/circuit/integrated_circuit/input_output/adv_light
	id = "cc-adv_light"
	build_path = /obj/item/integrated_circuit/output/light/advanced

/datum/design/circuit/integrated_circuit/input_output/beeper
	id = "cc-sound_beeper"
	build_path = /obj/item/integrated_circuit/output/sound/beeper

/datum/design/circuit/integrated_circuit/input_output/beepsky_sound
	id = "cc-sound_beepsky"
	build_path = /obj/item/integrated_circuit/output/sound/beepsky
	req_tech = list(TECH_ENGINEERING = 2, TECH_DATA = 2, TECH_ILLEGAL = 1)

/datum/design/circuit/integrated_circuit/input_output/EPv2
	id = "cc-epv2"
	build_path = /obj/item/integrated_circuit/input/EPv2
	req_tech = list(TECH_ENGINEERING = 2, TECH_DATA = 2, TECH_MAGNETS = 2, TECH_BLUESPACE = 2)

/datum/design/circuit/integrated_circuit/logic/AssembleDesignName()
	..()
	name = "Custom circuitry \[Logic\] ([item_name])"

/datum/design/circuit/integrated_circuit/logic/equals
	id = "cc-equals"
	build_path = /obj/item/integrated_circuit/logic/equals

/datum/design/circuit/integrated_circuit/logic/not
	id = "cc-not"
	build_path = /obj/item/integrated_circuit/logic/not

/datum/design/circuit/integrated_circuit/logic/and
	id = "cc-and"
	build_path = /obj/item/integrated_circuit/logic/and

/datum/design/circuit/integrated_circuit/logic/or
	id = "cc-or"
	build_path = /obj/item/integrated_circuit/logic/or

/datum/design/circuit/integrated_circuit/logic/less_than
	id = "cc-less_than"
	build_path = /obj/item/integrated_circuit/logic/less_than

/datum/design/circuit/integrated_circuit/logic/less_than_or_equal
	id = "cc-less_than_or_equal"
	build_path = /obj/item/integrated_circuit/logic/less_than_or_equal

/datum/design/circuit/integrated_circuit/logic/greater_than
	id = "cc-greater_than"
	build_path = /obj/item/integrated_circuit/logic/greater_than

/datum/design/circuit/integrated_circuit/logic/greater_than_or_equal
	id = "cc-greater_than_or_equal"
	build_path = /obj/item/integrated_circuit/logic/greater_than_or_equal



/datum/design/circuit/integrated_circuit/manipulation/AssembleDesignName()
	..()
	name = "Custom circuitry \[Manipulation\] ([item_name])"

/datum/design/circuit/integrated_circuit/manipulation/weapon_firing
	id = "cc-weapon_firing"
	build_path = /obj/item/integrated_circuit/manipulation/weapon_firing
	req_tech = list(TECH_ENGINEERING = 3, TECH_DATA = 3, TECH_COMBAT = 4)

/datum/design/circuit/integrated_circuit/manipulation/smoke
	id = "cc-smoke"
	build_path = /obj/item/integrated_circuit/manipulation/smoke
	req_tech = list(TECH_ENGINEERING = 3, TECH_DATA = 3, TECH_BIO = 4)

/datum/design/circuit/integrated_circuit/manipulation/locomotion
	name = "locomotion"
	id = "cc-locomotion"
	build_path = /obj/item/integrated_circuit/manipulation/locomotion
	req_tech = list(TECH_ENGINEERING = 3, TECH_DATA = 3)


/datum/design/circuit/integrated_circuit/memory/AssembleDesignName()
	..()
	name = "Custom circuitry \[Memory\] ([item_name])"

/datum/design/circuit/integrated_circuit/memory
	id = "cc-memory"
	build_path = /obj/item/integrated_circuit/memory

/datum/design/circuit/integrated_circuit/memory/medium
	id = "cc-memory4"
	build_path = /obj/item/integrated_circuit/memory/medium

/datum/design/circuit/integrated_circuit/memory/large
	id = "cc-memory8"
	build_path = /obj/item/integrated_circuit/memory/large

/datum/design/circuit/integrated_circuit/memory/huge
	id = "cc-memory16"
	build_path = /obj/item/integrated_circuit/memory/huge

/datum/design/circuit/integrated_circuit/memory/constant
	id = "cc-constant"
	build_path = /obj/item/integrated_circuit/memory/constant

/datum/design/circuit/integrated_circuit/time/AssembleDesignName()
	..()
	name = "Custom circuitry \[Time\] ([item_name])"

/datum/design/circuit/integrated_circuit/time/delay
	id = "cc-delay"
	build_path = /obj/item/integrated_circuit/time/delay

/datum/design/circuit/integrated_circuit/time/delay/five_sec
	id = "cc-five_sec_delay"
	build_path = /obj/item/integrated_circuit/time/delay/five_sec

/datum/design/circuit/integrated_circuit/time/delay/one_sec
	id = "cc-one_sec_delay"
	build_path = /obj/item/integrated_circuit/time/delay/one_sec

/datum/design/circuit/integrated_circuit/time/delay/half_sec
	id = "cc-half_sec_delay"
	build_path = /obj/item/integrated_circuit/time/delay/half_sec

/datum/design/circuit/integrated_circuit/time/delay/tenth_sec
	id = "cc-tenth_sec_delay"
	build_path = /obj/item/integrated_circuit/time/delay/tenth_sec

/datum/design/circuit/integrated_circuit/time/delay/custom
	id = "cc-custom_delay"
	build_path = /obj/item/integrated_circuit/time/delay/custom

/datum/design/circuit/integrated_circuit/time/ticker
	id = "cc-ticker"
	build_path = /obj/item/integrated_circuit/time/ticker

/datum/design/circuit/integrated_circuit/time/ticker/slow
	id = "cc-ticker_slow"
	build_path = /obj/item/integrated_circuit/time/ticker/slow

/datum/design/circuit/integrated_circuit/time/ticker/fast
	id = "cc-ticker_fast"
	build_path = /obj/item/integrated_circuit/time/ticker/fast
	req_tech = list(TECH_ENGINEERING = 4, TECH_DATA = 4)

/datum/design/circuit/integrated_circuit/time/clock
	id = "cc-clock"
	build_path = /obj/item/integrated_circuit/time/clock


/datum/design/circuit/tcom/exonet_node
	name = "exonet node"
	id = "tcom-exonet_node"
	req_tech = list(TECH_DATA = 5, TECH_ENGINEERING = 5, TECH_BLUESPACE = 4)
	build_path = /obj/item/weapon/circuitboard/telecomms/exonet_node
