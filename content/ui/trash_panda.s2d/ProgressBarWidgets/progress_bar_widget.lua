--
-- IMPORTANT: This script resource may be attached to all progress bar widgets created by the Widget Creator panel.
--            If modifications are required, then first copy this file to a unique path and fix all necessary
--            script components' resource paths.
--

local thisActor = ...;
local currentProgressBarPercentage = 0;
scaleform.Actor.set_mouse_enabled_for_children(thisActor, false);

local emitEvent = function(func, param)
    local comp = scaleform.Actor.component_by_name(thisActor, "WidgetHandler");
    if comp ~= nil then
        local handlerObject = scaleform.ScriptComponent.script_results(comp);
        if handlerObject ~= nil then
            if handlerObject[func] ~= nil then
                if (param) then
                    handlerObject[func](param);
                else
                    handlerObject[func]();
                end
            end
        end
    end
end

-- Helper function to set the current progress of the widget (0 to 100)
local setProgress = function(progressPercentage)

    if (progressPercentage < 0) then progressPercentage = 0; end
    if (progressPercentage > 100) then progressPercentage = 100; end

    local mainContainer = scaleform.Actor.container(thisActor);
    
    -- Process only if progression has changed.
    if (currentProgressBarPercentage ~= progressPercentage) then

        currentProgressBarPercentage = progressPercentage;
        
        if (currentProgressBarPercentage > 0) then
            if (currentProgressBarPercentage == 1) then
                emitEvent("started");
            end
            scaleform.AnimationComponent.goto_label(mainContainer, "started");
        else
            scaleform.AnimationComponent.goto_label(mainContainer, "normal");
        end

        if (currentProgressBarPercentage > 0) then
            local bitmap = scaleform.ContainerComponent.actor_by_name(mainContainer, "bitmap");
            if (bitmap) then
                scaleform.Actor.set_local_scale( bitmap, {x=currentProgressBarPercentage/100, y=1.} ) ;
                emitEvent("onProgress", currentProgressBarPercentage);
            end
        end

        if (currentProgressBarPercentage == 100) then
            emitEvent("complete");
        end
    end
end

-- Helper function to increment the current progress of the widget (0 to 100)
local incrementProgress = function()
    if (currentProgressBarPercentage < 100) then
        setProgress(currentProgressBarPercentage+1);
    end
end

-- Helper function to reset the current progress of the widget.
local resetProgress = function()
    setProgress(0);
end

-- Helper function to get  the current progress of the widget.
local getProgress = function()
    return currentProgressBarPercentage;
end

-- Save the methods below in this script component to use them from elsewhere
local exports = {
    incrementProgress = incrementProgress;
    setProgress = setProgress;
    resetProgress = resetProgress;
    getProgress = getProgress;
}
return exports;
