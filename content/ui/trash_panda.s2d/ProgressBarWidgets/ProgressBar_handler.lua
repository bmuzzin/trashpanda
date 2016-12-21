-- NOTE: This handler object is auto-generated. Feel free to modify the contents of this file.
--
-- IMPORTANT: This script resource must be attached to a script component named WidgetHandler to work
--            with the progress bar widget's base script.
--
-- HOWTO:     Progress bar widgets are slightly different from other widgets because users have to control their progression,
--            not only process output events.
--            That's why those 3 methods are available to control each progress bar widget:
--                incrementProgress() -- increment the progress percentage by 1
--                resetProgress()     -- reset the progress percentage
--                setProgress(progressPercentage) -- set the progress percentage to progressPercentage
--
--                Example of using them, for a progress bar called "myProgressBar" defined in Scene0
--                            local actorProgressBar = scaleform.Stage.actor_by_name_path("Scene0.myProgressBar");
--                            actorProgressBar.resetProgress(); -- myProgressBar progression is reset to 0.
--

local thisActor = ...;
local actorName = scaleform.Actor.name(thisActor);

-- The handler object expected by the base widget script
-- If any of the handler methods are not defined, then the base widget will not attempt to invoke them.
local handler = {

    -- Invoked when the progress bar starts
    started = function()
        print(actorName .. " progress bar has started")

        -- The code below gives an example of how to dispatch a custom event from this event handler function.
        --[[
        local evt = { eventId = scaleform.EventTypes.Custom,
                      name = actorName .. "_started",
                      data = {} }
        scaleform.Stage.dispatch_event(evt)
        --]]

    end

    ,complete = function()
        print(actorName .. " progress bar is complete")
    end

    -- Invoked when progress has changed
    -- Param progress : number
    --[[
    ,onProgress = function(progress)
        print(actorName .. " is complete " .. progress .. "%")
    end
    --]]
}

return handler;