/datum/component/soundplayer
	dupe_mode = COMPONENT_DUPE_ALLOWED
	var/atom/soundsource

	var/sound/cursound
	var/active = FALSE
	var/playing_range = 12
	var/list/listeners = list()

	var/environmental = FALSE
	var/env_id = 12
	var/repeating = TRUE
	var/playing_volume = 100
	var/playing_falloff = 4
	var/playing_channel = 0

/datum/component/soundplayer/Initialize()
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE
	soundsource = parent
	playing_channel = open_sound_channel()
	set_sound(sound('code/shitcode/baldenysh/sounds/hardbass_loop.ogg'))
	START_PROCESSING(SSprocessing, src)
	. = ..()

/datum/component/soundplayer/Destroy()
	STOP_PROCESSING(SSprocessing, src)
	stop_sounds()
	. = ..()

/datum/component/soundplayer/process()
	if(!active || !cursound)
		return

	for(var/client/C)
		if(!C.GetComponent(/datum/component/soundplayer_listener))
			client_preload_cursound(C)
			C.

/datum/component/soundplayer/proc/client_preload_cursound(var/client/C)
	SEND_SOUND(C, cursound)

/datum/component/soundplayer/proc/client_stop_cursound(var/client/C)
	SEND_SOUND(C, sound(null, repeat = 0, wait = 0, channel = playing_channel))

/datum/component/soundplayer/proc/update_sounds()

/datum/component/soundplayer/proc/stop_sounds()
	active = FALSE
	/*
	for(var/client/C)
		if(!client_get_cursound(C))
			continue
		client_stop_cursound(C)
		*/

/datum/component/soundplayer/proc/set_sound(var/sound/newsound)
	if(!cursound)
		return
	cursound = newsound
	cursound.repeat = repeating
	cursound.falloff = playing_falloff
	cursound.channel = playing_channel
	cursound.environment = env_id
	cursound.volume = 0
	cursound.status = 0
	cursound.wait = 0
	cursound.x = 0
	cursound.z = 1
	cursound.y = 1
	update_sounds()

////////////////////////////////////////////////

/datum/component/soundplayer_listener
	dupe_mode = COMPONENT_DUPE_ALLOWED
	var/datum/component/soundplayer/myplayer
	var/client/listener

/datum/component/soundplayer_listener/Initialize(var/datum/component/soundplayer/player)
	if(!isclient(parent) || !player)
		return COMPONENT_INCOMPATIBLE
	listener = parent
	myplayer = player

/datum/component/soundplayer_listener/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, .proc/update_sound)

/datum/component/soundplayer_listener/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_MOVABLE_MOVED)

/datum/component/soundplayer_listener/proc/get_player_sound()
	for(var/sound/S in listener.client.SoundQuery())
		if(S.file == myplayer.cursound.file)
			return S
	return FALSE
/datum/component/soundplayer_listener/proc/update_sound()
	var/sound/S = get_player_sound()
	if(!S)
		return
	var/turf/TT = get_turf(listener)
	var/turf/MT = get_turf(myplayer.soundsource)
	var/dist = get_dist(TT, MT)
	S.status = SOUND_UPDATE
	if(dist <= myplayer.playing_range)
		S.volume = myplayer.playing_volume
		S.volume -= max(dist - world.view, 0) * 2
		S.falloff = myplayer.playing_falloff
		S.environment = myplayer.env_id
		if(environmental)
			var/dx = MT.x - TT.x
			S.x = dx
			var/dy = MT.y - TT.y
			S.z = dy
		else
			S.x = 0
			S.z = 1
	else
		S.volume = 0
	SEND_SOUND(listener, S)
