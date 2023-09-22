desktop_entity = data.get("desktop_entity")
speaker_entity = data.get("speaker_entity")
home_zone_name = data.get("home_zone_name", "home")

logger.info("running sound sync script")
if desktop_entity is not None and speaker_entity is not None:
    data = { 'entity_id': speaker_entity }

    if hass.states.is_state(desktop_entity, home_zone_name):
        hass.services.call('switch', 'turn_on', data, False)
    else:
        hass.services.call('switch', 'turn_off', data, False)
