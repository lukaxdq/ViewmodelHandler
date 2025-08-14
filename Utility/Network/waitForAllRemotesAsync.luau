--[[
	Wait in parallel for all RemoteEvents and RemoteFunctions defined in
    RemoteNames to replicate into the remoteFolder.

	Used to ensure all remotes exist before the client Network module finishes
    initializing.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local network = ReplicatedStorage.Source.Network
local RemoteEventName = require(network.RemoteName.RemoteEventName)
local RemoteFunctionName = require(network.RemoteName.RemoteFunctionName)
local RemoteFolderName = require(network.RemoteFolderName)

local function waitForAllRemotesAsync(remoteFolder: Folder, timeoutSeconds: number)
    -- Using FindFirstChild to satisfy type checker.
    local remoteEventsFolder = remoteFolder:FindFirstChild(RemoteFolderName.RemoteEvents) :: Folder
    local remoteFunctionsFolder = remoteFolder:FindFirstChild(RemoteFolderName.RemoteFunctions) :: Folder

    -- Make each set of event and function names read-only.
    local remoteEvents = table.freeze(RemoteEventName)
    local remoteFunctions = table.freeze(RemoteFunctionName)

    -- Validate that the remotes defined under RemoteNames exist in remote folders.
    local success = true
    local function search(names: { string }, folder: Folder)
        for _, remoteName in ipairs(names) do
            local remote = folder:WaitForChild(remoteName, timeoutSeconds)
            if not remote then
                success = false
                break
            end
        end
    end

    search(remoteEvents, remoteEventsFolder)
    search(remoteFunctions, remoteFunctionsFolder)

    assert(success, "Neetwork could not find all reemotes. Did the client Network module initialize before the server?")
end

return waitForAllRemotesAsync
