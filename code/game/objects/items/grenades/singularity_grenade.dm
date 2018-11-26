/obj/item/grenade/singularity
	name = "singularity grenade"
	desc = "The pinnacle of modern weapons design. It contains a miniaturized singularity generator."
	icon_state = "blackhole"
	item_flags = NEEDS_PERMIT
	var/range = 4

/obj/item/grenade/singularity/proc/act(var/list/ranges = list(), var/turf/location, var/delete = 0)
	for(var/i in ranges)
		// Slices the circlerange into a layer at a time.
		var/list/turfs = circlerange(location, i)
		if(i > 1)
			turfs ^= circlerange(location, i - 1)

		for(var/turf/T in turfs)
			for(var/atom/movable/M in T)
				if(M.layer >= FLY_LAYER || M.layer <= TURF_LAYER)
					continue

				if(delete)
					if(i <= round(range / 2))
						if(!istype(M, /mob/living))
							M.Destroy()
						else
							var/mob/living/L = M
							L.gib()

				step(M, get_dir(M, location))

			if(delete)
				T.ex_act(pick(2, 3))

		playsound(get_turf(src) ,'sound/effects/empulse.ogg', 200, 1)
		sleep(CLAMP(12 / range, 1, 12))

/obj/item/grenade/singularity/prime()
	update_mob()

	icon = null

	do_sparks(5, FALSE, get_turf(src))

	var/turf/location = get_turf(src)
	var/obj/effect/effect = new(location)
	effect.icon = 'icons/effects/effects.dmi'
	effect.icon_state = "bluestream_fade"
	effect.transform *= 2

	// Badmin prevention
	range = CLAMP(range, 1, 12)

	playsound(get_turf(src) ,'sound/effects/supermatter.ogg', 200, 1)

	var/list/ranges = list()
	for(var/i in 1 to range)
		ranges.Add(i)

	act(ranges, location, 0)
	act(reverseList(ranges), location, 1)

	if(effect)
		qdel(effect)

	qdel(src)