/// All active /datum/atom_hud/alternate_appearance/basic/see_no_evil instances
GLOBAL_LIST_EMPTY_TYPED(see_no_evil_huds, /datum/atom_hud/alternate_appearance/basic/see_no_evil)

/// An alternate appearance that will only show if you have the antag datum
/datum/atom_hud/alternate_appearance/basic/see_no_evil
	var/pref_level = 0

/datum/atom_hud/alternate_appearance/basic/see_no_evil/New(key, image/I, pref_level)
	if(pref_level)
		src.pref_level = pref_level
	GLOB.see_no_evil_huds += src
	return ..(key, I, NONE)

/datum/atom_hud/alternate_appearance/basic/see_no_evil/Destroy()
	GLOB.see_no_evil_huds -= src
	return ..()

/datum/atom_hud/alternate_appearance/basic/see_no_evil/mobShouldSee(mob/M)
	if(add_ghost_version && isobserver(M))
		return FALSE // use the ghost version instead

/// An alternate appearance that will show all the antagonists this mob has
/datum/atom_hud/alternate_appearance/basic/see_no_evil
	var/list/evil_hud_images = list()
	var/index = 1

	var/datum/mind/mind

/datum/atom_hud/alternate_appearance/basic/see_no_evil/New(key, datum/mind/mind)
	src.mind = mind

	evil_hud_images = get_evil_hud_images(mind)

	var/image/first_antagonist = get_evil_image(1) || image(icon('icons/blanks/32x32.dmi', "nothing"), mind.current)

	RegisterSignals(
		mind,
		list(COMSIG_ANTAGONIST_GAINED, COMSIG_ANTAGONIST_REMOVED),
		PROC_REF(update_evil_hud_images)
	)

	check_processing()

	return ..(key, first_antagonist, NONE)

/datum/atom_hud/alternate_appearance/basic/see_no_evil/Destroy()
	QDEL_LIST(evil_hud_images)
	STOP_PROCESSING(SSantag_hud, src)
	mind.antag_hud = null
	mind = null

	return ..()

/datum/atom_hud/alternate_appearance/basic/see_no_evil/mobShouldSee(mob/mob)
	return (mob.client?.combo_hud_enabled && !isnull(mob.client?.holder))

/datum/atom_hud/alternate_appearance/basic/see_no_evil/process(seconds_per_tick)
	index += 1
	update_icon()

/datum/atom_hud/alternate_appearance/basic/see_no_evil/proc/check_processing()
	if (evil_hud_images.len > 1 && !(DF_ISPROCESSING in datum_flags))
		START_PROCESSING(SSantag_hud, src)
	else if (evil_hud_images.len <= 1)
		STOP_PROCESSING(SSantag_hud, src)

/datum/atom_hud/alternate_appearance/basic/see_no_evil/proc/get_evil_image(index)
	RETURN_TYPE(/image)
	if (evil_hud_images.len)
		return evil_hud_images[(index % evil_hud_images.len) + 1]

/datum/atom_hud/alternate_appearance/basic/see_no_evil/proc/get_evil_hud_images(datum/mind/mind)
	var/list/final_evil_hud_images = list()

	for (var/datum/antagonist/antagonist as anything in mind?.antag_datums)
		if (isnull(antagonist.antag_hud_name))
			continue
		final_evil_hud_images += antagonist.hud_image_on(mind.current)

	return final_evil_hud_images

/datum/atom_hud/alternate_appearance/basic/see_no_evil/proc/update_icon()
	if (evil_hud_images.len == 0)
		image.icon = icon('icons/blanks/32x32.dmi', "nothing")
	else
		image.icon = icon(get_evil_image(index).icon, get_evil_image(index).icon_state)

/datum/atom_hud/alternate_appearance/basic/see_no_evil/proc/update_evil_hud_images(datum/mind/source)
	SIGNAL_HANDLER

	evil_hud_images = get_evil_hud_images(source)
	index = clamp(index, 1, evil_hud_images.len)
	update_icon()
	check_processing()

/// Hud used for people to see body parts of a sensitive nature
/datum/atom_hud/alternate_appearance/basic/see_no_evil/special_eyes
	pref_level = 1
	add_ghost_version = TRUE
/datum/atom_hud/alternate_appearance/basic/see_no_evil/special_eyes
	pref_level = 1
	add_ghost_version = TRUE
