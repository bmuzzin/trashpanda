--
-- IMPORTANT: This script resource may be attached to all input widgets created by the Widget Creator panel.
--            If modifications are required, then first copy this file to a unique path and fix all necessary
--            script components' resource paths.
--

local thisActor = ...;

-- init at first creation.
if not isTextEditFocused then
    isTextEditFocused = false;
end

-- Helper function to set input text. 
--  setText("new input text");
local setText = function(text)
    local container = scaleform.Actor.container(thisActor);
    local labelActor = scaleform.ContainerComponent.actor_by_name(container, "label");
    if labelActor ~= nil then
        scaleform.TextComponent.set_text(scaleform.Actor.component_by_index(labelActor, 1) , text);
    end
end

-- Helper function to get the current dropdown text. 
-- ex:   local inputText = getText();
local getText = function()
    local container = scaleform.Actor.container(thisActor);
    local labelActor = scaleform.ContainerComponent.actor_by_name(container, "label");
    if labelActor ~= nil then
        return scaleform.TextComponent.text(scaleform.Actor.component_by_index(labelActor, 1));
    end
end

-- Helper function to get wether the widget is focused or not 
local isFocused = function()
    return isTextEditFocused;
end

local emitEvent = function(func, param1, param2)
    local comp = scaleform.Actor.component_by_name(thisActor, "WidgetHandler");
    if comp ~= nil then
        local handlerObject = scaleform.ScriptComponent.script_results(comp);
        if handlerObject ~= nil then
            if handlerObject[func] ~= nil then
                if (param2) then
                    handlerObject[func](param1, param2);
                else
                    handlerObject[func](param1);
                end
            end
        end
    end
end



-- Event Handlers
keyDownEventListener = scaleform.EventListener.create(keyDownEventListener, function(e)
    if isTextEditFocused then
        emitEvent("keyDown", e.keyCode, e.keysState);
    end
end )

stageMouseDownEventListener = scaleform.EventListener.create(stageMouseDownEventListener, function(e)
    if e.buttonId == 0 then
        local container = scaleform.Actor.container(thisActor);
        local previousFocus = isTextEditFocused;
        isTextEditFocused = e.target == scaleform.ContainerComponent.actor_by_name(container, "label");
        if previousFocus ~= isTextEditFocused then
            emitEvent("hasFocus", isTextEditFocused);
            if isTextEditFocused then
                scaleform.AnimationComponent.play_label(container, "selected");
            else
                scaleform.AnimationComponent.play_label(container, "normal");
            end
        end
    end
end )

local removedFromStageListener = scaleform.EventListener.create(removedFromStageListener, function(e)
    scaleform.EventListener.disconnect(stageMouseDownEventListener)
    scaleform.EventListener.disconnect(keyDownEventListener)
end )

scaleform.EventListener.connect(removedFromStageListener, thisActor, scaleform.EventTypes.RemovedFromStage)
scaleform.EventListener.connect(stageMouseDownEventListener, scaleform.EventTypes.MouseDown);
scaleform.EventListener.connect(keyDownEventListener, scaleform.EventTypes.KeyDown);

-- Save the method below in this script component to use it from elsewhere
local exports = {
    setText = setText;
    getText = getText;
    isFocused = isFocused;
}
return exports;