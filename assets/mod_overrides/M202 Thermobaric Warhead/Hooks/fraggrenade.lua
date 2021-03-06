function FragGrenade:_spawn_environment_fire(normal, unit)
	local grenade_entry = self._tweak_projectile_entry or "frag"
	local tweak_entry = tweak_data.projectiles[grenade_entry]
	if tweak_entry.incendiary_fire_arbiter then
		local position = self._unit:position()
		local rotation = self._unit:rotation()
		local data = tweak_entry.incendiary_fire_arbiter
		EnvironmentFire.spawn(position, rotation, data, normal, self._thrower_unit, 0, 1)
		if unit:base()._fake_fire then
			local _fire = World:spawn_unit(Idstring("units/pd2_dlc_bbq/weapons/molotov_cocktail/wpn_molotov_third"), unit:position(), unit:rotation())
			_fire:base():_detonate(normal)
		end
	end
end

function FragGrenade:_detonate(tag, unit, body, other_unit, other_body, position, normal, collision_velocity, velocity, other_velocity, new_velocity, direction, damage, ...)
	local pos = self._unit:position()
	local normal = math.UP
	local range = self._range
	local slot_mask = managers.slot:get_mask("explosion_targets")
	managers.explosion:give_local_player_dmg(pos, range, self._player_damage)
	managers.explosion:play_sound_and_effects(pos, normal, range, self._custom_params)
	local hit_units, splinters = managers.explosion:detect_and_give_dmg({
		player_damage = 0,
		hit_pos = pos,
		range = range,
		collision_slotmask = slot_mask,
		curve_pow = self._curve_pow,
		damage = self._damage,
		ignore_unit = self._unit,
		alert_radius = self._alert_radius,
		user = self:thrower_unit() or self._unit,
		owner = self._unit
	})
	self:_spawn_environment_fire(normal, unit)
	managers.network:session():send_to_peers_synched("sync_unit_event_id_16", self._unit, "base", GrenadeBase.EVENT_IDS.detonate)
	self._unit:set_slot(0)
end