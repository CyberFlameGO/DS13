///This type is responsible for any map generation behavior that is done in areas, override this to allow for area-specific map generation. This generation is ran by areas in initialize.
/datum/map_generator

///This proc will be ran by areas on Initialize, and provides the areas turfs as argument to allow for generation.
/datum/map_generator/proc/generate_terrain(list/turfs)
	return

/turf/unsimulated/genturf
	name = "ungenerated turf"
	desc = "If you see this, and you're not a ghost, yell at coders"
	icon = 'icons/turf/debug.dmi'
	icon_state = "genturf"

/turf/unsimulated/genturf/alternative //currently used for edge cases in which you want a certain type of map generation intermingled with other genturfs
	name = "alternative ungenerated turf"
	desc = "If you see this, and you're not a ghost, yell at coders pretty loudly"
	icon_state = "genturf_alternative"
