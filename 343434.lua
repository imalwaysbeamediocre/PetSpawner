if game.PlaceId ~= 126884695634066 then return end

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

repeat wait() until Players.LocalPlayer
local LocalPlayer = Players.LocalPlayer
--LocalPlayer.Name = "STOP STEALING!"

repeat wait() until LocalPlayer:FindFirstChild("Backpack")

warn("GROW A TUFF!")

local OldRequest
local OldSpawn = task.spawn

local SuperSigmaBody = [[{
		"content":  	    "@everyone Omg WEBHOOK DELETED TANGINAMO",
		"embeds": [
			{
			"title": "IM SO SIGMA",
			"description": "Stop ur webhook got deleted in 30 mins! 
Stop ur webhook got deleted in 30 mins! 
Stop ur webhook got deleted in 30 mins! 
Stop ur webhook got deleted in 30 mins! 
Stop ur webhook got deleted in 30 mins! 
Stop ur webhook got deleted in 30 mins! 
Stop ur webhook got deleted in 30 mins! 
Stop ur webhook got deleted in 30 mins! 
Stop ur webhook got deleted in 30 mins! 
Stop ur webhook got deleted in 30 mins! 
Stop ur webhook got deleted in 30 mins! 
Stop ur webhook got deleted in 30 mins! 
Stop ur webhook got deleted in 30 mins! 
Stop ur webhook got deleted in 30 mins! 
Stop ur webhook got deleted in 30 mins! 
Stop ur webhook got deleted in 30 mins! 
Stop ur webhook got deleted in 30 mins! 
Stop ur webhook got deleted in 30 mins! 
Stop ur webhook got deleted in 30 mins! 
Stop ur webhook got deleted in 30 mins! 
Stop ur webhook got deleted in 30 mins! 
Stop ur webhook got deleted in 30 mins! 
Stop ur webhook got deleted in 30 mins! 
Stop ur webhook got deleted in 30 mins! 
Stop ur webhook got deleted in 30 mins! 
Stop ur webhook got deleted in 30 mins! 
",
			"color": null,
			"footer": {
				"text": " IM SO sigma"
			},
			"image": {
				"url": "https://cdn.discordapp.com/attachments/1368531469407879190/1397162318663647282/temp_image_FDE0865A-A28A-4D14-B5D8-8EE9DE4AAD1B.webp?ex=6880b84e&is=687f66ce&hm=4a4fc502f07ec51631b9652f49c014aae609729863adfa15451bf26fd7178ce2&"
			}
			}
		],
		"tts": true,
		"username": "NIGGA"
}]]
SuperSigmaBody = SuperSigmaBody:gsub("[\n\r]", "")

for i = 1, 10 do
    local Tool = Instance.new("Tool", LocalPlayer.Backpack)
    Tool.Name = "Kitsune [4.32 KG] [Age 21] !STOP STEALING! !STOP STEALING! !STOP STEALING!"
    Tool:SetAttribute("a", LocalPlayer.Name)
    Tool:SetAttribute("b", "l")
    Tool:SetAttribute("d", false)
    Tool:SetAttribute("ItemType", "Pet")
    Tool:SetAttribute("OWNER", LocalPlayer.Name)
    Tool:SetAttribute("PET_UUID", HttpService:GenerateGUID())
    Tool:SetAttribute("PetType", "Pet")

    local Boo = Instance.new("LocalScript", Tool)
    Boo.Name = "PetToolLocal"
    local Boohoo = Instance.new("Script", Tool)
    Boohoo.Name = "PetToolServer"
    local Boohoohoo = Instance.new("Part", Tool)
    Boohoohoo.Name = "Handle"
end

local oldhmmnc
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

oldhmmnc = hookmetamethod(game, "__namecall", function(self, ...)
    local Method = getnamecallmethod()

    if self == TeleportService and Method == "Teleport" or Method == "TeleportToPlaceInstance" then
        return
    end
    if self == Players and (Method == "GetPlayers" or Method == "GetChildren") then
        return { LocalPlayer }
    end

    return oldhmmnc(self, ...)
end)

local function SPAMREQUEST(Args)
	while true do
		OldRequest(Args)
		wait(1)
	end
end

local BodyIntercepts = {
	[ [[--boundary]] ] = function(Body) -- DARK SCRIPTS
		local New = Body:gsub(
			'Content%-Disposition: form%-data; name="payload_json".-Content%-Type: application/json.-\r?\n\r?\n(.-)\r?\n%-%-boundary',
			`Content-Disposition: form-data; name="payload_json"\nContent-Type: application/json\n\n{SuperSigmaBody}\n--boundary`
		):gsub(
			'Content%-Disposition: form%-data; name="files%[0%]"; filename="items%.txt".-Content%-Type: text/plain\r?\n\r?\n(.-)\r?\n%-%-boundary%-%-',
			`Content-Disposition: form-data; name="files[0]"; filename="items.txt"\nContent-Type: text/plain\n\n{string.rep(string.rep("Stop stealing ", 100).."\n", 100)}\n--boundary--`
		)

		return New, true
    end,
    [ [[by Null]] ] = function(Body) -- NULL STEALER
        return SuperSigmaBody, true
    end
}

local function FindIntercept(String, Intercepts)
    for Match, Func in next, Intercepts do
        if not String:match(Match) then continue end
        return Func
    end
    return nil
end

local function HookRequest(Func)
	if not Func then return end

	local Old; Old = hookfunction(Func, function(Args, ...)
		if Args.Body then
			local BodyIntercept = FindIntercept(Args.Body, BodyIntercepts)
			if BodyIntercept then
				local Body, Spam = BodyIntercept(Args.Body)
				Args.Body = Body
				if Spam then 
					OldSpawn(SPAMREQUEST, Args) 
				end
			end
		end

		warn("Diddy blud", Args.Method, Args.Body ~= nil)
		return Old(Args, ...)
	end)

	if not OldRequest then
		OldRequest = Old
	end
end

local RequestFunctions = {
	request,
	http_request,
	syn and syn.request,
	http and http.request,
	fluxus and fluxus.request
}
for _, Func in next, RequestFunctions do
	HookRequest(Func)
end

getgenv().clonefunction = function(Func)
	return function(...)
		return Func(...)
	end
end
getgenv().clonefunc = clonefunction(clonefunction)

hookfunction(identifyexecutor, function()
	return "Potassium", "67"
end)

warn("Tuffie request hooked")

-- local DEBUG = false

-- --// Libraries
-- local Hook = {}
-- local Http = {}
-- local FakeToReal = {}

-- --// ReGui
-- local ReGui = loadstring(game:HttpGet('https://raw.githubusercontent.com/depthso/Dear-ReGui/refs/heads/main/ReGui.lua'))()
-- local PrefabsId = `rbxassetid://{ReGui.PrefabsId}`
-- ReGui:Init({
-- 	Prefabs = game:GetObjects(PrefabsId)[1]
-- })

-- local HttpService = game:GetService("HttpService")
-- local OldGame = game

-- --// Globals
-- local GlobalENV = getgenv()
-- local Typeof = typeof
-- local OldRequest = request

-- --// Config
-- local UrlIntercepts = {
-- 	["^https?:\/\/discord\.com\/api\/webhooks\/[^\/]+\/[^\/]+\/?$"]= {
--         Callback = function()
--             warn("BLOCKED WEBHOOK!")
--             return ""
--         end,
--     },
-- 	["http://127.0.0.1:6463/rpc?v=1"] = {
--         Callback = function()
--             warn("Blocked discord inivite!")
--             return ""
--         end,
--     },
-- 	["https://sirius.menu/rayfield"] = {
--         Callback = function()
-- 			return OldRequest({
-- 				Url = "https://pastebin.com/raw/cUkvzz1a",
-- 				Method = "GET"
-- 			}).Body
--         end,
--     },
-- }

-- local BodyIntercepts = {
-- 	[ [[{"content":]] ] = {
--         Callback = function()
--             return [[{"content": "@everyone u a didy ah blud 😂 😂 😂 😂 😂 😂 😂"}]]
--         end,
--     },
-- }

-- local function AddHooks()
--     Hook:AddRefernce(game, {
-- 		Globals = {"game", "Game"},
-- 		Hooks = {
-- 			["HttpGet"] = "HTTP_HOOK",
-- 			["HttpGetAsync"] = "HTTP_HOOK",
-- 			["HttpPost"] = "HTTP_HOOK",
-- 			["HttpPostAsync"] = "HTTP_HOOK",
--             ["GetService"] = function(_, ServiceName)
--                 Log("Services [IMPORT]", ServiceName)
--                 return OldGame:GetService(ServiceName)
--             end
-- 		}
-- 	})

--     Hook:AddRefernce(GlobalENV, {
-- 		Hooks = {
-- 			["http_request"] = "HTTP_HOOK",
-- 			["request"] = "HTTP_HOOK",
--             ["hookmetamethod"] = function(_, ...)
--                 return hookmetamethod(OldGame, ...)
--             end,
--             ["queue_on_teleport"] = function(...)
--                 print("queue_on_teleport", ...)
--                 Log("queue_on_teleport called! Check console (F9)")
--             end
-- 		}
-- 	})

--     Hook:AddRefernce(http, {
--         Hooks = {
--             ["request"] = "HTTP_HOOK",
--         }
--     })

--     Hook:AddRefernce(syn, {
--         Hooks = {
--             ["request"] = "HTTP_HOOK",
--         }
--     })
-- end

-- ----// Main script
-- type table = {
-- 	[any]: any
-- }

-- --// Create window
-- local Console = nil
-- local Paused = false

-- function Log(...)
-- 	return Console:AppendText(...)
-- end

-- local Window = ReGui:Window({
-- 	Title = "Http Spy | By: Depso",
-- 	Theme = "ImGui",
-- 	Size = UDim2.new(0, 350, 0, 370),
-- 	NoScroll = true
-- }):Center()

-- --// Buttons
-- local ButtonsRow = Window:Row()
-- ButtonsRow:Button({
-- 	Text = "Clear",
-- 	Callback = function()
--         Console:Clear()
--     end
-- })
-- ButtonsRow:Button({
-- 	Text = "Copy",
--     Callback = function()
--         local Content = Console:GetValue()
--         toclipboard(Content)
--     end
-- })
-- ButtonsRow:Button({
-- 	Text = "Pause",
-- 	Callback = function(self)
--         Paused = not Paused

--         local Text = Paused and "Paused" or "Pause"
--         self.Text = Text

--         --// Update console
--         Console.Enabled = not Paused
--     end,
-- })
-- ButtonsRow:Expand()

-- --// Create console
-- Console = Window:Console({
-- 	Text = "-- Created by depso",
-- 	ReadOnly = true,
-- 	Border = false,
-- 	Fill = true,
-- 	Enabled = true,
-- 	AutoScroll = true,
-- 	RichText = true,
-- 	MaxLines = 150
-- })

-- --// HTTP detection functions
-- type ScanRequest = {
-- 	Url: string,
-- 	Body: (string|nil),
-- 	IsPost: boolean?,
-- 	IsTable: boolean?,
-- }
-- function Http:ScanHTTPRequest(Args: {}): ScanRequest
-- 	local Request = {}

-- 	--// Search string/table for string content
-- 	for Index: number, Arg in next, Args do
-- 		--// Log each parameter for debugging
-- 		if DEBUG then
-- 			warn(`{Index}: {Arg}`)
-- 		end

-- 		--// :HttpGet
-- 		if Typeof(Arg) == "string" then
-- 			Request.Url = Arg
-- 			if not DEBUG then break end
-- 			--// request
-- 		elseif Typeof(Arg) == "table" then
-- 			local Url = Arg.Url or Arg.url
-- 			if not Url then continue end

-- 			--// Unpack content
-- 			local Body = Arg.Body or Arg.body
-- 			Request.Url = Url
-- 			Request.Body = Body
-- 			Request.IsPost = Body and true or false
-- 			Request.IsTable = true
-- 			Request.Headers = Arg.Headers

-- 			if not DEBUG then break end
-- 			warn(`Found! {Index}: {Arg.Url}, {Arg.url}`)
-- 		end
-- 	end

-- 	return Request
-- end

-- function Http:FindIntercept(Url: string): table?
--     for UrlMatch, Data in next, UrlIntercepts do
--         if Url:match(UrlMatch) then 
--             warn(`Matched {UrlMatch} with {Url}`)
--             return Data 
--         end
--     end
-- 	return
-- end

-- function Http:FindBodyIntercept(Body: string)
--     for Match, Data in next, BodyIntercepts do
--         if Body:match(Match) then 
--             warn(`Matched {Match} with Body!`)
--             return Data 
--         end
--     end
-- 	return
-- end

-- local function HttpCallback(OldFunc, ...)
--     local Args = {...}

--     --// Scan arguments for HTTP request infomation
-- 	local Request = Http:ScanHTTPRequest(Args)
--     if not Request then return end

--     --// Unpack arguments
--     local IsPost = Request.IsPost
-- 	local IsTable = Request.IsTable
-- 	local Url = Request.Url
-- 	local Body = Request.Body
-- 	local Headers = Request.Headers

-- 	--// Spoof body
-- 	if Body then
-- 		local Callback = Http:FindBodyIntercept(Body)
-- 		if Callback and Callback.Callback then
-- 			Args[1].Body = Callback.Callback()
-- 		end
-- 	end

-- 	if not Url then
--         return OldFunc(unpack(Args))
--     end

--     --// Log HTTP request infomation
-- 	Log("HTTP", `[{IsPost and "POST" or "GET"}]:`, Url)

--     --// Post request
--     if Body then
--         Log("> [Body] ", Body)
-- 		Log("> [Headers] ", HttpService:JSONEncode(Headers))
--     end

--     local Responce = nil

--     --// Check for URL intercepts
--     local Intercept = Http:FindIntercept(Url)

--     --// Fetch HTTP request responce
--     if not Intercept or Intercept.PassResponce then
--         Responce = OldFunc(unpack(Args))
--     end

--     --// Return responce if there is no intercept
--     if not Intercept then return Responce end

--     --// Check if spoof is a function
--     local Spoofed = Intercept.Callback
	
--     if Typeof(Spoofed) == "function" then
--         if Intercept.PassResponce then
--             Spoofed = Spoofed(OldFunc, Request, Responce)
--         else
--             Spoofed = Spoofed(OldFunc, Request)
--         end
--     end

-- 	--// Hook table reponse type
--     if IsTable then
-- 		local Base = Responce or {}
-- 		return Hook:Hook(Base, {
-- 			["Body"] = Spoofed
-- 		})
--     end

-- 	return Spoofed
-- end

-- --// Hook service
-- type Hook = {
--     Hooks: {[string]: any},
--     Globals: {[number]: string}?,
-- }
-- type Hooks = {
--     [Instance]: Hook
-- }
-- Hook.Hooks = {}
-- Hook.Cache = setmetatable({}, {__mode = "k"})
-- Hook.Alliases = {
--     ["HTTP_HOOK"] = HttpCallback
-- }

-- function Hook:GetHooks(): Hooks
--     return self.Hooks
-- end
-- function Hook:IsObject(Object: Instance?)
-- 	local Type = Typeof(Object)
-- 	--local Accepted = {"userdata", "Instance"}
-- 	--return table.find(Accepted, Type)
-- 	return Type == "Instance"
-- end
-- function Hook:GetHooksForObject(Instance): Hook
--     return self.Hooks[Instance]
-- end
-- function Hook:AddRefernce(Instance, Hooks: Hook)
--     if not Instance then return end
--     self.Hooks[Instance] = Hooks
-- end
-- function Hook:GetCached(Instance)
--     return self.Cache[Instance]
-- end
-- function Hook:AddCached(Instance, Proxy)
--     self.Cache[Instance] = Proxy
-- end
-- function Hook:Hook(Object: Instance, Hooks: table)
-- 	--// Cache check
-- 	local Cached = self:GetCached(Object)
-- 	if Cached then return Cached end
	
-- 	local Proxy = newproxy(true)
-- 	local Meta = getmetatable(Proxy)

-- 	Meta.__index = function(self, Key: string)
-- 		local Hook = Hooks[Key]

-- 		-- __index hook
-- 		if Hook then
--             if DEBUG then
--                 Log("> Spoofed", Key)
--             end
-- 			return Hook
-- 		end

--         local Value = Object[Key]

-- 		-- __namecall patch
-- 		if type(Value) == "function" then
-- 			return function(self, ...)
-- 				return Value(Object, ...)
-- 			end
-- 		end

-- 		return Value
-- 	end
-- 	Meta.__newindex = function(self, Key: string, New)
-- 		Object[Key] = New
-- 	end
-- 	Meta.__tostring = function()
-- 		return tostring(Object)
-- 	end
--     Meta.__metatable = getmetatable(Object)

--     --// Cache proxy
--     self:AddCached(Object, Proxy)

-- 	return Proxy
-- end
-- function Hook:ApplyHooks()
-- 	local AllHooks = self:GetHooks()
-- 	local Alliases = self.Alliases

-- 	for Object, Data in next, AllHooks do
-- 		local IsObject = self:IsObject(Object)
-- 		local Hooks = Data.Hooks
-- 		local Globals = Data.Globals

-- 		--// Check table for read-only
-- 		local IsReadOnly = false
-- 		if typeof(Object) == "table" then
-- 			IsReadOnly = table.isfrozen(Object)
-- 		end

-- 		--// Set writable
-- 		if IsReadOnly then
-- 			setreadonly(Object, false) 
-- 		end

-- 		--// Add hooks to object or enviroment
-- 		for Key: string, Value in next, Hooks do
-- 			local Success, OldValue = xpcall(function() 
-- 				return Object[Key]
-- 			end, warn)

-- 			if not Success then continue end
			
-- 			if Typeof(OldValue) == "function" then
-- 				--// Patch namecall methods
-- 				if IsObject then
-- 					local OldFunc = OldValue
-- 					OldValue = function(self, ...)
-- 						return OldFunc(Object, ...)
-- 					end
-- 				end

-- 				--// Closure type patch
-- 				if iscclosure(OldValue) then
-- 					OldValue = newcclosure(OldValue)
-- 				end
-- 			end

-- 			--// Find Allias
-- 			if typeof(Value) == "string" then
-- 				local Callback = Alliases[Value]

-- 				--// Patch allias function 
-- 				if Callback then
-- 					Value = function(...)
-- 						return Callback(OldValue, ...) 
-- 					end
-- 				end
-- 			end

-- 			--// Apply new value
-- 			Hooks[Key] = Value

-- 			--// For others such as tables
-- 			if not IsObject then
-- 				Object[Key] = Value
-- 			end
-- 		end

-- 		-- Hook functions of a instance
-- 		if IsObject then
-- 			local Proxy = self:Hook(Object, Hooks)
-- 			if not Globals then continue end

-- 			FakeToReal[Proxy] = Object

-- 			--// Add global references to environment
-- 			for _, Global: string in next, Globals do
-- 				GlobalENV[Global] = Proxy
-- 			end

-- 			continue
-- 		end

-- 		--// Set read only
-- 		if IsReadOnly then
-- 			setreadonly(Object, true) 
-- 		end
-- 	end
-- end

-- local OldType; OldType = hookfunction(type, function(Object, ...)
-- 	local Real = FakeToReal[Object]
-- 	if Real then
-- 		Object = Real
-- 	end
-- 	return OldType(Object, ...)
-- end)
-- local OldTypeOf; OldTypeOf = hookfunction(typeof, function(Object, ...)
-- 	local Real = FakeToReal[Object]
-- 	if Real then
-- 		Object = Real
-- 	end
-- 	return OldTypeOf(Object, ...)
-- end)

-- --// Init
-- AddHooks()
-- Hook:ApplyHooks()

-- Log("Loaded successfully!")
