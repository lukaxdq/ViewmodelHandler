--!strict
--[[
    A configurable logging utility that can be used across multiple scripts.

    Example usage:
    ```lua
    local ReplicatedStorage = game:GetService("ReplicatedStorage")

    local Logger = require(ReplicatedStorage.Source.Utility.Logger)

    local logger = Logger.new({
        Debug = false, -- When true, will print debug messages, when false only warnings/errors
        Prefix = "ScriptName" -- Prefixes [ScriptName] before the logger message
    })

    -- Calling the logger message:
    logger.log(`This is a debug message and wil only print if Debug is true`)
    logger.log(`This is an error and will print a warnign in output no matter what`, true)
    -- The second one is marked as an error with the `true` value after the message
    ```
]]

export type LoggerConfig = {
    Debug: boolean,
    Prefix: string?, -- Optional prefix for log messages
}

export type Logger = {
    log: (message: string, isError: boolean?) -> (),
    setConfig: (newConfig: LoggerConfig) -> (),
    getConfig: () -> LoggerConfig,
}

-- Creates a new logger instance with default configuration.
local function new(initialConfig: LoggerConfig?): Logger
    local config: LoggerConfig = initialConfig or {
        Debug = false,
        Prefix = nil,
    }

    -- Used in lew of a metatable to keep things simple.
    local logger = {}

    -- Log a message
    function logger.log(message: string, isError: boolean?)
        local prefix = if config.Prefix then (`[{config.Prefix}] `) else ""

        if isError then
            warn(`{prefix}{debug.info(2, "n")}():{debug.info(2, "l")} {message}`)
        elseif config.Debug then
            print(`{prefix}{debug.info(2, "n")}():{debug.info(2, "l")} {message}`)
        end
    end

    -- Used to update Logger configuration anytime after creation.
    function logger.setConfig(newConfig: LoggerConfig)
        config.Debug = newConfig.Debug
        config.Prefix = newConfig.Prefix
    end

    -- Used to get the current Logger configuration.
    function logger.getConfig()
        return table.clone(config)
    end

    return logger
end

return {
    new = new
}
