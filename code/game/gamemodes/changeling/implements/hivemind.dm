/mob/abstract/hivemind
	name = "internal hivemind"
	see_in_dark = 2
	see_invisible = SEE_INVISIBLE_LIVING

	var/mob/living/carbon/human/changeling_mob // the head honcho

/mob/abstract/hivemind/Destroy()
	changeling_mob = null
	return ..()

/mob/abstract/hivemind/verb/ghost()
	set category = "OOC"
	set name = "Ghost"
	set desc = "Relinquish your life and enter the land of the dead."

	world << "[src] begins ghost"
	announce_ghost_joinleave(ghostize(1, 0))
	world << "[src] has ghosted"
	changeling_mob.mind.changeling.hivemind_members -= src
	to_chat(changeling_mob, SPAN_NOTICE("[src] has left our hivemind to join the living dead."))
	for(var/H in changeling_mob.mind.changeling.hivemind_members) // tell the others in the hivemind
		to_chat(changeling_mob.mind.changeling.hivemind_members[H], SPAN_NOTICE("[src] has left our hivemind to join the living dead."))

/mob/abstract/hivemind/proc/add_to_hivemind(var/mob/original_body, var/mob/living/carbon/human/ling)
	world << "Called add to hivemind [src]"
	name = original_body.real_name
	languages = original_body.languages
	for(var/language in ling.languages)
		add_language(language)
	remove_language(LANGUAGE_CHANGELING) // no actual changeling speak for you, buddy
	if(original_body.ckey)
		ckey = original_body.ckey
	changeling_mob = ling
	if(changeling_mob)
		changeling_mob.mind.changeling.hivemind_members[name] = src
		world << "Adding to hivemind and showing intro"
		introduction(changeling_mob)

/mob/abstract/hivemind/proc/introduction(var/mob/living/carbon/human/ling)
	to_chat(src, SPAN_DANGER(FONT_LARGE("You are a member of a Changeling's Hivemind!")))
	to_chat(src, SPAN_DANGER("You have been absorbed by [ling]! Do not fret."))
	to_chat(src, SPAN_DANGER("You are now a part of their hivemind."))
	to_chat(src, SPAN_DANGER("You can use 'say' to speak with them and the rest of the hivemind."))
	to_chat(src, SPAN_DANGER("What you say can only be heard by [ling] and the other members of the hivemind."))

/mob/abstract/hivemind/say(message)
	message = sanitize_text(message)

	if(!message)
		return

	log_say("[changeling_mob] Hivemind/[src.key] : [message]", ckey=key_name(src))

	if(src.client?.prefs.muted & (MUTE_DEADCHAT|MUTE_IC))
		to_chat(src, SPAN_WARNING("You cannot talk. (Admin Muted)"))
		return

	to_chat(changeling_mob, message_process(message)) // tell the changeling
	for(var/H in changeling_mob.mind.changeling.hivemind_members) // tell the others in the hivemind
		var/mob/M = changeling_mob.mind.changeling.hivemind_members[H]
		to_chat(M, message_process(message))
		world << "To_chat sent to [M]"

/mob/abstract/hivemind/proc/message_process(var/message)
	return "<font color=[COLOR_LING_I_HIVEMIND]>[src] says, \"[message]\"</font>"

/mob/abstract/hivemind/emote()
	to_chat(src, SPAN_WARNING("You cannot emote."))
	return