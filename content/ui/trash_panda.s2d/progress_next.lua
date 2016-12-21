thisActor = ...;

-- This basically just waits until the game mode changes to round_explanation,
-- so that it can change the frame to round-start.
local enterFrameEventListener = scaleform.EventListener.create(function(e)
    local scene = scaleform.Actor.scene(thisActor);
    GameState = GameState or {}
    if GameState.game_mode == GameModes.round_explanation then
        local scene = scaleform.Actor.scene(thisActor);
        local animation = scaleform.Actor.component_by_name(scene, "Animation")
        scaleform.AnimationComponent.goto_label(animation, "round-start")
    end
end )

scaleform.EventListener.connect(enterFrameEventListener,thisActor,scaleform.EventTypes.EnterFrame)
