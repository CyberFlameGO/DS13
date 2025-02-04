/obj/item/tool/multitool/hacktool
	var/is_hacking = 0
	var/max_known_targets

	var/in_hack_mode = 0
	var/list/known_targets
	var/list/supported_types
	var/datum/topic_state/default/must_hack/hack_state

/obj/item/tool/multitool/hacktool/New()
	..()
	known_targets = list()
	max_known_targets = 5 + rand(1,3)
	supported_types = list(/obj/machinery/door/airlock)
	hack_state = new(src)

/obj/item/tool/multitool/hacktool/Destroy()
	known_targets.Cut()
	qdel(hack_state)
	hack_state = null
	return ..()

/obj/item/tool/multitool/hacktool/attackby(var/obj/W, var/mob/user)
	if(isScrewdriver(W))
		in_hack_mode = !in_hack_mode
		playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
	else
		..()

/obj/item/tool/multitool/hacktool/resolve_attackby(atom/A, mob/user)
	sanity_check()

	if(!in_hack_mode || !attempt_hack(user, A)) //will still show the unable to hack message, oh well
		return ..()

	A.ui_interact(user, state = hack_state)
	return 1

/obj/item/tool/multitool/hacktool/proc/attempt_hack(var/mob/user, var/atom/target)
	if(is_hacking)
		to_chat(user, "<span class='warning'>You are already hacking!</span>")
		return 1
	if(!is_type_in_list(target, supported_types))
		to_chat(user, "\icon[src] <span class='warning'>Unable to hack this target.</span>")
		return 0
	var/found = known_targets.Find(target)
	if(found)
		known_targets.Swap(1, found)	// Move the last hacked item first
		return 1

	to_chat(user, "<span class='notice'>You begin hacking \the [target]...</span>")
	is_hacking = 1
	// Hackin takes roughly 15-25 seconds. Fairly small random span to avoid people simply aborting and trying again.
	var/hack_result = do_after(user, (15 SECONDS + rand(0, 5 SECONDS) + rand(0, 5 SECONDS)), target)
	is_hacking = 0

	if(hack_result && in_hack_mode)
		to_chat(user, "<span class='notice'>Your hacking attempt was succesful!</span>")
		user.playsound_local(get_turf(src), 'sound/piano/A#6.ogg', 50)
		known_targets.Insert(1, target)	// Insert the newly hacked target first,
		RegisterSignal(target, COMSIG_PARENT_QDELETING, .proc/on_target_destroy)
	else
		to_chat(user, "<span class='warning'>Your hacking attempt failed!</span>")
	return 1

/obj/item/tool/multitool/hacktool/proc/sanity_check()
	if(max_known_targets < 1) max_known_targets = 1
	// Cut away the oldest items if the capacity has been reached
	if(known_targets.len > max_known_targets)
		for(var/i = (max_known_targets + 1) to known_targets.len)
			var/atom/A = known_targets[i]
			UnregisterSignal(A, COMSIG_PARENT_QDELETING)
		known_targets.Cut(max_known_targets + 1)

/obj/item/tool/multitool/hacktool/proc/on_target_destroy(var/target)
	SIGNAL_HANDLER
	known_targets -= target

/datum/topic_state/default/must_hack
	var/obj/item/tool/multitool/hacktool/hacktool

/datum/topic_state/default/must_hack/New(var/hacktool)
	src.hacktool = hacktool
	..()

/datum/topic_state/default/must_hack/Destroy()
	hacktool = null
	return ..()

/datum/topic_state/default/must_hack/can_use_topic(var/src_object, var/mob/user)
	if(!hacktool || !hacktool.in_hack_mode || !(src_object in hacktool.known_targets))
		return STATUS_CLOSE
	return ..()
