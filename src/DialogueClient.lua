--!native
--!nocheck

--[=[
	@class DialogueClient
	@client
]=]
local DialogueClient = {}

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local TableUtil = require(ReplicatedStorage.Packages.TableUtil)
local LemonSignal = require(ReplicatedStorage.Packages.LemonSignal)
local Packet = require(script.Parent:WaitForChild("packet"))
local PublicTypes = require(script.Parent:WaitForChild("PublicTypes"))

--[=[
	@type CloseDialogue RBXScriptSignal
	@within DialogueClient
	whenever the dialogue is closed by the server (clients cannot close dialogue by themselves)
]=]
DialogueClient.CloseDialgoue = LemonSignal.new()

--[=[
	@type OpenDialogue RBXScriptSignal
	@within DialogueClient
	whenever the client triggers a proximity prompt that is dialogue related
]=]
DialogueClient.OpenDialogue = LemonSignal.new()

--[=[
	@type ChoiceChosen RBXScriptSignal
	@within DialogueClient
	whenever the client has selected any choice in choice state
]=]
DialogueClient.ChoiceChosen = LemonSignal.new()

--[=[
	@type SwitchToChoice RBXScriptSignal
	@within DialogueClient
	Whenever the client has finished the messages switched into choice state
]=]
DialogueClient.SwitchToChoice = LemonSignal.new()

--[=[
	@type NextMessage RBXScriptSignal
	@within DialogueClient
	whenever the server exposes a message to the client
]=]
DialogueClient.NextMessage = LemonSignal.new()

local New = Fusion.New
local Children = Fusion.Children
local Value = Fusion.Value
local Computed = Fusion.Computed
local OnEvent = Fusion.OnEvent

--States--
local DialogueState = Value("Closed")
local Head = Value("")
local Body = Value("")
local ChoiceMessage = Value("")
local Choices = Value(nil)

--BYTENET EVENT LISTENERS--
Packet.ExposeMessage.listen(function(Message)
	ProximityPromptService.Enabled = false
	DialogueState:set("Message")
	Head:set(Message.Head)
	Body:set(Message.Body)
	DialogueClient.NextMessage:Fire()
end)

Packet.ExposeChoice.listen(function(ChoiceData)
	Choices:set(ChoiceData.Choices)
	ChoiceMessage:set(ChoiceData.ChoiceMessage)
	DialogueState:set("Choice")
	DialogueClient.SwitchToChoice:Fire()
end)

Packet.CloseDialogue.listen(function()
	DialogueState:set(false)
	ProximityPromptService.Enabled = true
	DialogueClient.CloseDialgoue:Fire()
end)
--BYTENET EVENT LISTENERS END--

ProximityPromptService.PromptTriggered:Connect(function(prompt)
	if CollectionService:HasTag(prompt, "Dialogue") then
		ProximityPromptService.Enabled = false
		DialogueClient.OpenDialogue:Fire()
	end
end)

local StyleProps = {
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundTransparency = 0.3,
	BackgroundColor3 = Color3.new(0, 0, 0),
	TextColor3 = Color3.new(1, 1, 1),
	TextScaled = true,
	Font = Enum.Font.BuilderSans,
}

--[=[
	@return "Message" | "Choice" | "Closed"
	returns the choices
]=]
function DialogueClient.GetDialogueState(): "Message" | "Choice" | "Closed"
	return DialogueState:get()
end

--[=[
	@return {Head: string | nil, Body: string | nil}
]=]
function DialogueClient.GetMessage()
	return { Head = Head:get(), Body = Body:get() }
end

--[=[
	@return {Choice} | nil
	although it returns choice, but the client **cannot read** the response nor the listeners for safety reasons.
]=]
function DialogueClient.GetChoices()
	return Choices:get()
end

New("ScreenGui")({
	Parent = Players.LocalPlayer.PlayerGui,
	Enabled = Computed(function()
		return DialogueState:get() ~= false
	end),
	[Children] = {
		New("ImageButton")({
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 0.3,
			BackgroundColor3 = Color3.new(0, 0, 0),
			Size = UDim2.fromOffset(275, 100),
			Position = UDim2.fromScale(0.5, 0.75),
			[OnEvent("Activated")] = function()
				if DialogueState:get() == "Message" then
					Packet.FinishedMessage.send()
				end
			end,
			[Children] = {
				New("UIAspectRatioConstraint")({
					AspectRatio = 2.854,
				}),
				New("UICorner")({
					CornerRadius = UDim.new(0.05),
				}),
				--Head
				New("TextLabel")(TableUtil.Reconcile({
					Size = UDim2.fromScale(1, 0.3),
					Position = UDim2.fromScale(0.5, 0.15),
					BackgroundTransparency = 1,
					Text = Computed(function()
						if DialogueState:get() == "Message" then
							return Head:get()
						elseif DialogueState:get() == "Choice" then
							return ChoiceMessage:get()
						else
							return ""
						end
					end),
					Visible = Computed(function()
						return DialogueState:get()
					end),
				}, StyleProps)),
				--Body
				New("TextLabel")(TableUtil.Reconcile({
					Size = UDim2.fromScale(1, 0.7),
					Position = UDim2.fromScale(0.5, 0.65),
					BackgroundTransparency = 1,
					Text = Computed(function()
						return Body:get()
					end),
					Visible = Computed(function()
						return DialogueState:get() == "Message"
					end),
				}, StyleProps)),
				New("ScrollingFrame")({
					Visible = Computed(function()
						return DialogueState:get() == "Choice"
					end),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Size = UDim2.fromScale(1, 0.7),
					Position = UDim2.fromScale(0.5, 0.65),
					AutomaticCanvasSize = Enum.AutomaticSize.Y,
					ScrollBarThickness = 0.01,
					BackgroundTransparency = 1,
					CanvasSize = UDim2.fromScale(0, 0),
					[Children] = Computed(function()
						if DialogueState:get() == "Choice" then
							local ChoicesInstance = {}
							for _, Choice: { ChoiceName: string, UUID: string } in ipairs(Choices:get()) do
								table.insert(
									ChoicesInstance,
									New("TextButton")(TableUtil.Reconcile({
										Size = UDim2.fromScale(1, 0.35),
										Text = Choice.ChoiceName,
										BackgroundColor3 = Color3.new(0, 0, 0),
										[OnEvent("Activated")] = function()
											Packet.ChoiceChosen.send({ UUID = Choice.UUID })
											DialogueClient.ChoiceChosen:Fire()
										end,
									}, StyleProps))
								)
							end
							table.insert(ChoicesInstance, New("UIListLayout")({ Padding = UDim.new(0.05) }))
							return ChoicesInstance
						else
							return nil
						end
					end),
				}),
			},
		}),
	},
})

return DialogueClient :: PublicTypes.DialogueClient
