local id = 'peramangauva_ChatScript'
do -- cleanup
    local cleanupTable = getgenv().cleanupTable
    for _, cleanup in pairs(cleanupTable) do
        if cleanup.id == id then
            cleanup.func()
        end
    end
end


-- services
local PLRS = game:GetService('Players')
local TCS = game:GetService('TextChatService')
local CG = game:GetService('CoreGui')


-- paths
local ME = PLRS.LocalPlayer


-- other variables
local MyStack
local Commands
local CommandRegistry


-- utility functions
local SystemMessage
local GetPlayer
local ParseArgument
local MakeStack


-- main functions
local OnFocusLost


-- cleanup variables
local Connect do
    Connect = setmetatable({Raw = {}},{
        __call = function(self, Event, Connection)
            table.insert(self.Raw, Event:Connect(Connection))
        end
    })
end


do -- utility functions
    function SystemMessage(text)
        print("[System] " .. tostring(text))
        pcall(function()
            local textChannels = TCS.TextChannels
            local channel = textChannels.RBXGeneral
            channel:DisplaySystemMessage("[System]: " .. tostring(text))
        end)
    end

    function GetPlayer(name)
        if typeof(name) == 'Instance' then return name end
        if type(name) ~= "string" then return nil end
        local searchName = string.lower(name)

        if searchName == 'me' then
            return ME
        end

        if searchName == 'him' or searchName == 'her' or searchName == 'them' or searchName == 'em' then
            local position = ME.Character:GetPivot().Position
            local BestMatch = {
                Distance = math.huge,
                Player = nil
            }
            for _, Player in ipairs(PLRS:GetPlayers()) do
                if Player ~= ME and Player.Character then
                    local distance = (Player.Character:GetPivot().Position - position).Magnitude
                    if distance < BestMatch.Distance then
                        BestMatch.Player = Player
                        BestMatch.Distance = distance
                    end
                end
            end
            return BestMatch.Player
        end
        
        local foundPlayer
        for _, player in ipairs(PLRS:GetPlayers()) do
            if string.sub(string.lower(player.Name), 1, #searchName) == searchName 
            or string.sub(string.lower(player.DisplayName), 1, #searchName) == searchName then
                foundPlayer = player
                if player ~= ME then
                    return player
                end
            end
        end
        
        if foundPlayer then
            return foundPlayer
        end
        
        return nil
    end

    function ParseArgument(argStr)
        argStr = string.match(argStr, "^%s*(.-)%s*$")
        if string.lower(argStr) == "true" then return true end
        if string.lower(argStr) == "false" then return false end
        if string.lower(argStr) == "nil" then return nil end
        if tonumber(argStr) then return tonumber(argStr) end
        local quoted = string.match(argStr, '^"(.*)"$') or string.match(argStr, "^'(.*)'$")
        if quoted then return quoted end
        return argStr
    end

    function MakeStack()
        local self = { 
            _items = {},
            ShouldPop = true
        }
        
        function self:Push(value) 
            table.insert(self._items, value) 
        end
        
        function self:Pop()
            if #self._items == 0 then return nil end
            return table.remove(self._items)
        end
        
        function self:Clear() 
            table.clear(self._items) 
        end

        setmetatable(self, {
            __index = function(_, key)
                if type(key) == "number" then return self._items[key] end
            end,
            __newindex = function(_, key, value)
                if type(key) == "number" then self._items[key] = value else rawset(self, key, value) end
            end,
            __len = function(_) return #self._items end
        })
        
        return self
    end
end


do -- main functions
    MyStack = MakeStack()

    Commands = {
        getplayer = function(stack, name)
            local player = GetPlayer(name)
            if player then
                SystemMessage("Found Player: " .. player.Name)
                return player
            else
                SystemMessage("Player not found.")
                return nil
            end
        end,

        stack = function(stack, value)
            SystemMessage("Pushed " .. tostring(value) .. " to stack.")
            return value
        end,

        clear = function(stack)
            stack:Clear()
            SystemMessage("Stack cleared.")
            return nil
        end,

        display = function(stack)
            local elements = {}
            for i = 1, #stack do table.insert(elements, tostring(stack[i])) end
            SystemMessage("Stack: { " .. table.concat(elements, ", ") .. " }")
            return nil
        end
    }

    CommandRegistry = {}
    for cmdName, callback in pairs(Commands) do
        CommandRegistry[string.lower(cmdName)] = callback
    end

    function OnFocusLost(enterPressed, TextBox)
        if not enterPressed then return end
        
        local message = TextBox.Text
        local prefix = string.sub(message, 1, 1)
        
        if prefix == "!" or prefix == "?" then
            local content = string.sub(message, 2)
            local spacePos = string.find(content, " ")
            
            local cmdName = spacePos and string.sub(content, 1, spacePos - 1) or content
            local argsStr = spacePos and string.sub(content, spacePos + 1) or ""
            
            local callback = CommandRegistry[string.lower(cmdName)]
            if callback then
                MyStack.ShouldPop = (prefix == "!")
                
                local inlineArgs, inlineArgCount = {}, 0
                if string.match(argsStr, "%S") then
                    for arg in string.gmatch(argsStr, "([^,]+)") do
                        inlineArgCount += 1
                        inlineArgs[inlineArgCount] = ParseArgument(arg)
                    end
                end
                
                local finalArgs, finalArgCount = {MyStack}, 1
                for i = 1, #MyStack do
                    finalArgCount += 1
                    finalArgs[finalArgCount] = MyStack[i]
                end
                for i = 1, inlineArgCount do
                    finalArgCount += 1
                    finalArgs[finalArgCount] = inlineArgs[i]
                end
                
                local success, result = pcall(function()
                    return callback(table.unpack(finalArgs, 1, finalArgCount))
                end)
                
                if success then
                    if result ~= nil then MyStack:Push(result) end
                else
                    SystemMessage("Command Error: " .. tostring(result))
                end
            end
        end
    end
end


do -- connections
    local success, TextBox = pcall(function()
        return CG.ExperienceChat.appLayout.chatInputBar.Background.Container.TextContainer.TextBoxContainer.TextBox
    end)

    if success and TextBox then
        Connect(TextBox.FocusLost, function(enterPressed)
            OnFocusLost(enterPressed, TextBox)
        end)
        SystemMessage("its on")
    else
        warn("cant get the chat buddy")
    end
end


do -- cleanup
    for idx, cleanup in pairs(getgenv().cleanupTable) do
        if cleanup.id == id then
            table.remove(cleanup, idx)
            break
        end
    end
    table.insert(getgenv().cleanupTable, {
        id = id,
        func = function()
            for _, Connection in ipairs(Connect.Raw) do
                Connection:Disconnect()
            end
            if MyStack then
                MyStack:Clear()
            end
        end
    })
end

return {
    NewCommand = function(name, Callback)
        CommandRegistry[name:lower()] = Callback
    end,
    GetPlayer = GetPlayer,
    Chat = SystemMessage
}

