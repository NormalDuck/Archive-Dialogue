"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[67],{34663:t=>{t.exports=JSON.parse('{"functions":[{"name":"AddTriggerSignal","desc":"Sends a signal whenever this Dialogue component has been triggered.\\n```lua\\nlocal Dialogue = require(path.to.dialogue)\\n\\nDialogue.Mount(\\n\\tDialogue.CreateDialogueTemplate(\\n\\t\\tDialogue.CreateMessageTemplate(Dialogue.ConstructMessage():AddTriggerSignal(function(player)\\n\\t\\t\\tprint(`{player} triggered it!`)\\n\\t\\tend))\\n\\t\\t\\t:AddTriggerSignal(function()\\n\\t\\t\\t\\tprint(\\"works for all constructors!\\")\\n\\t\\t\\tend)\\n\\t\\t\\t:AddTriggerSignal(function()\\n\\t\\t\\t\\tprint(\\"You can also chain them!\\")\\n\\t\\t\\tend)\\n\\t\\t\\t:AddTimeoutSignal(2, function()\\n\\t\\t\\t\\tprint(\\"Or mix with the other signal!\\")\\n\\t\\t\\tend),\\n\\t\\tworkspace.Instance\\n\\t)\\n)\\n```","params":[{"name":"fn","desc":"","lua_type":"(player: Player) -> ()"}],"returns":[],"function_type":"method","source":{"line":54,"path":"src/DialogueServer.lua"}},{"name":"AddTimeoutSignal","desc":"Sends a signal whenever it reaches the time and client doesn\'t perform any action to the dialogue component\\n\\n```lua\\nlocal Dialogue = require(path.to.dialogue)\\n\\nDialogue.Mount(\\n\\tDialogue.CreateDialogueTemplate(\\n\\t\\tDialogue.CreateMessageTemplate(Dialogue.ConstructMessage():AddTimeoutSignal(2, function(player)\\n\\t\\t\\tprint(`{player} this prints when client doesn\'t finish your message within 2 seconds!`)\\n\\t\\tend))\\n\\t\\t\\t:AddTimeoutSignal(1, function()\\n\\t\\t\\t\\tprint(\\"The next chain prints at the same time!\\")\\n\\t\\t\\tend)\\n\\t\\t\\t:AddTimeoutSignal(1, function()\\n\\t\\t\\t\\tprint(\\"Chains don\'t yield each other!\\")\\n\\t\\t\\tend)\\n\\t\\t\\t:AddTriggerSignal(2, function()\\n\\t\\t\\t\\tprint(\\"Or mix with the other signal!\\")\\n\\t\\t\\tend),\\n\\t\\tworkspace.Instance\\n\\t)\\n)\\n```","params":[{"name":"Time","desc":"","lua_type":"number"},{"name":"fn","desc":"","lua_type":"(player: Player) -> ()"}],"returns":[],"function_type":"method","source":{"line":84,"path":"src/DialogueServer.lua"}}],"properties":[],"types":[],"name":"ServerSignals","desc":"Listeners are custom methods that are returned when creating components of dialogue.","source":{"line":27,"path":"src/DialogueServer.lua"}}')}}]);