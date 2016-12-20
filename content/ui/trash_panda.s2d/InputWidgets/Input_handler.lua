-- NOTE: This handler object is auto-generated. Feel free to modify the contents of this file.
--
-- IMPORTANT: This script resource must be attached to a script component named WidgetHandler to work
--            with the input widget's base script.
--

GameState = GameState or {}

local thisActor = ...;
local actorName = scaleform.Actor.name(thisActor);

-- The handler object expected by the base widget script
-- If any of the handler methods are not defined, then the base widget will not attempt to invoke them.
local handler = {

    -- Invoked when the input receives a key down event
    -- Param KeyCode : Number
    -- Param KeyState : Number
    keyDown = function(KeyCode, KeysState)
        print(actorName .. " input new key down event: [Code:" .. KeyCode .. "]");

        if KeyCode == scaleform.Keys.Return then
            --TODO click go button
        end
        

        -- The code below gives an example of how to dispatch a custom event from this event handler function.
        --[[
        local evt = { eventId = scaleform.EventTypes.Custom,
                      name = actorName .. "_keyDown",
                      data = { keyCode = KeyCode, keysState = KeysState } }
        scaleform.Stage.dispatch_event(evt)
        --]]
    end

    -- Invoked when the input focus change
    -- Param focus : boolean
    ,hasFocus = function(focus)
        print(actorName .. " input has focus:" .. tostring(focus));
    end

}

return handler;