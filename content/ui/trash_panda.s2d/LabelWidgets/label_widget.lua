--
-- IMPORTANT: This script resource may be attached to all Label widgets created by the Widget Creator panel.
--            If modifications are required, then first copy this file to a unique path and fix all necessary
--            script components' resource paths.
--
-- EXAMPLE:
--
---- (In another script component attached to the same actor)
--
-- local comp = scaleform.Actor.component_by_name(thisActor, "WidgetBase");
-- local widgetScript = scaleform.ScriptComponent.script_results(comp);
-- widgetScript.setEnabled(false);
--

local thisActor = ...;

local exports = {

    -- Helper function to get the label text of the button. 
    --  local labelText = getText();
    getText = function()
        local container = scaleform.Actor.container(thisActor);
        local labelActor = scaleform.ContainerComponent.actor_by_name(container, "label");
        if labelActor ~= nil then
            return scaleform.TextComponent.text(scaleform.Actor.component_by_index(labelActor, 1));
        end
    end

     -- Helper function to set the label widget enabled or not. 
    ,setEnabled = function(enabled)
        local container = scaleform.Actor.container(thisActor);

        local frame;
        if enabled then
            frame = "enabled";
        else
            frame = "disabled";
        end

        scaleform.AnimationComponent.play_label(container, frame);
    end

}

return exports;