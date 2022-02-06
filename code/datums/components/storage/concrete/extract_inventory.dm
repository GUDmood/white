/datum/component/storage/concrete/extract_inventory
	max_combined_w_class = WEIGHT_CLASS_TINY * 3
	max_items = 3
	insert_preposition = "в"
//These need to be false in order for the extract's food to be unextractable
//from the inventory
	attack_hand_interact = FALSE
	quickdraw = FALSE
	can_transfer = FALSE
	drop_all_on_deconstruct = FALSE
	locked = TRUE //True in order to prevent messing with the inventory in any way other than the specified ways on reproductive.dm
	rustle_sound = FALSE
	silent = TRUE
	var/obj/item/slimecross/reproductive/parentSlimeExtract


/datum/component/storage/concrete/extract_inventory/Initialize()
	. = ..()
	set_holdable(/obj/item/food/monkeycube)
	if(!istype(parent, /obj/item/slimecross/reproductive))
		return COMPONENT_INCOMPATIBLE
	parentSlimeExtract = parent


/datum/component/storage/concrete/extract_inventory/proc/processCubes(obj/item/slimecross/reproductive/parentSlimeExtract, mob/user)

	if(length(parentSlimeExtract.contents) >= max_items)
		QDEL_LIST(parentSlimeExtract.contents)
		createExtracts(parentSlimeExtract,user)

/datum/component/storage/concrete/extract_inventory/proc/createExtracts(obj/item/slimecross/reproductive/parentSlimeExtract, mob/user)
	playsound(parentSlimeExtract, 'sound/effects/splat.ogg', 40, TRUE)
	parentSlimeExtract.last_produce = world.time
	to_chat(user, "<span class='notice'>[parentSlimeExtract] briefly swells to a massive size, and expels a baby slime!</span>")
	new /mob/living/simple_animal/slime(parentSlimeExtract.drop_location(), parentSlimeExtract.colour)
