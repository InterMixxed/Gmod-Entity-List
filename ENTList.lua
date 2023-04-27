local function openEntityList()
    local entitiesByName = {}

    for _, e in ipairs(ents.GetAll()) do
        local className = e:GetClass()
        entitiesByName[className] = entitiesByName[className] or {}
        table.insert(entitiesByName[className], e)
        e:SetNWBool("IsESPOff", true)
    end

    local frame = vgui.Create("DFrame")
    frame:SetSize(400, 500)
    frame:SetTitle("Entity List By Mixxed")
    frame:Center()
    frame:MakePopup()

    local listView = vgui.Create("DListView", frame)
    listView:Dock(FILL)
    listView:AddColumn("Entity Name")

    local searchBox = vgui.Create("DTextEntry", frame)
    searchBox:Dock(TOP)
    searchBox:SetHeight(20)
    searchBox:SetPlaceholderText("Search for an entity...")

    local function updateListView(searchText)
        if not IsValid(listView) then return end

        listView:Clear()

        for className, entities in pairs(entitiesByName) do
            if not searchText or string.find(string.lower(className), string.lower(searchText), 1, true) then
                local line = listView:AddLine(className)

                local function toggleESPOptions()
                    local isESPOff = entities[1]:GetNWBool("IsESPOff")
                    for _, e in ipairs(entities) do
                        if IsValid(e) then
                            e:SetNWBool("IsESPOff", not isESPOff)
                        end
                    end
                end

                local espToggleBtn = vgui.Create("DButton", line)
                espToggleBtn:SetSize(80, 20)
                espToggleBtn:SetText(entities[1]:GetNWBool("IsESPOff") and "ESP" or "ESP")
                espToggleBtn:Dock(RIGHT)
                espToggleBtn.DoClick = toggleESPOptions
            end
        end
    end

    updateListView()

    searchBox.OnValueChange = function()
        updateListView(searchBox:GetValue())
    end

    local function drawESP()
        for _, entities in pairs(entitiesByName) do
            if not entities[1]:GetNWBool("IsESPOff") then
                for _, e in ipairs(entities) do
                    if IsValid(e) then
                        local pos = e:GetPos():ToScreen()
                        draw.DrawText(e:GetClass(), "Default", pos.x, pos.y, Color(255, 255, 255), TEXT_ALIGN_CENTER)
                    end
                end
            end
        end
    end

    hook.Add("HUDPaint", "MarkedEntitiesESP", drawESP)
end

concommand.Add("open_entity_list", openEntityList)
