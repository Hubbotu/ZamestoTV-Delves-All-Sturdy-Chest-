local codec = {}

local function EnsureSavedVars(savedVars)
    local vars = savedVars
    if type(vars) ~= "table" then
        vars = {}
    end

    if vars.framesVisible == nil then
        vars.framesVisible = true
    end
    if type(vars.positions) ~= "table" then
        vars.positions = {}
    end

    return vars
end

local function EscapeProfileValue(value)
    value = tostring(value or "")
    value = value:gsub("%%", "%%25")
    value = value:gsub(";", "%%3B")
    value = value:gsub(":", "%%3A")
    value = value:gsub("/", "%%2F")
    value = value:gsub("|", "%%7C")
    value = value:gsub(",", "%%2C")
    return value
end

local function UnescapeProfileValue(value)
    value = tostring(value or "")
    value = value:gsub("%%2C", ",")
    value = value:gsub("%%7C", "|")
    value = value:gsub("%%2F", "/")
    value = value:gsub("%%3A", ":")
    value = value:gsub("%%3B", ";")
    value = value:gsub("%%25", "%%")
    return value
end

local function ClampScaleForProfile(value)
    local scale = tonumber(value)
    if not scale then
        return nil
    end
    if scale < 0.7 then
        return 0.7
    end
    if scale > 2.0 then
        return 2.0
    end
    return scale
end

local function ParseXY(value)
    local xStr, yStr = tostring(value or ""):match("^([^,/]+)[,/]([^,/]+)$")
    local x = tonumber(xStr)
    local y = tonumber(yStr)
    if not x or not y then
        return nil
    end
    return x, y
end

function codec.EnsureSavedVars(savedVars)
    return EnsureSavedVars(savedVars)
end

function codec.BuildProfileString(savedVars)
    local vars = EnsureSavedVars(savedVars)
    local positions = vars.positions or {}
    local defaults = {
        tracks = { x = 30, y = -28 },
        raid = { x = 30, y = -74 },
        mythicPlus = { x = 30, y = -190 },
        delve = { x = 30, y = -245 },
    }

    local function getXY(key)
        local p = positions[key]
        local x = (p and type(p.x) == "number") and p.x or defaults[key].x
        local y = (p and type(p.y) == "number") and p.y or defaults[key].y
        return string.format("%.2f/%.2f", x, y)
    end

    local scale = ClampScaleForProfile(vars.uiScale) or 1
    local parts = {
        "GWA2",
        "fv:" .. tostring(vars.framesVisible and 1 or 0),
        "scale:" .. string.format("%.2f", scale),
        "fsize:" .. tostring(vars.fontSize or ""),
        "fpath:" .. EscapeProfileValue(vars.fontPath or ""),
        "tracks:" .. getXY("tracks"),
        "raid:" .. getXY("raid"),
        "mythicPlus:" .. getXY("mythicPlus"),
        "delve:" .. getXY("delve"),
    }
    return table.concat(parts, ";")
end

function codec.ImportProfileString(data, savedVars, malformedSuffix)
    if type(data) ~= "string" or data == "" then
        return false, "Empty profile string."
    end

    local trimmed = data:match("^%s*(.-)%s*$")
    trimmed = trimmed:gsub("[\r\n]", "")
    trimmed = trimmed:gsub("^<", ""):gsub(">$", "")

    local isV1 = trimmed:find("^GWA1|", 1, false) ~= nil
    local isV2 = trimmed:find("^GWA2;", 1, false) ~= nil
    if not isV1 and not isV2 then
        return false, "Invalid profile header."
    end

    local fields = {}
    local fieldCount = 0
    local tokenPattern = isV2 and "[^;]+" or "[^|]+"
    for token in trimmed:gmatch(tokenPattern) do
        if token ~= "GWA1" and token ~= "GWA2" then
            local k, v
            if isV2 then
                k, v = token:match("^([^:]+):(.*)$")
            else
                k, v = token:match("^([^=]+)=(.*)$")
            end
            if k then
                fields[k] = v
                fieldCount = fieldCount + 1
            end
        end
    end

    local suffix = malformedSuffix or ""
    local requiredKeys = {"tracks", "raid", "mythicPlus", "delve", "scale", "fv"}
    for _, key in ipairs(requiredKeys) do
        if fields[key] == nil then
            return false, "Malformed profile string (missing " .. key .. ")." .. suffix
        end
    end
    if fieldCount < 8 then
        return false, "Malformed profile string." .. suffix
    end

    local vars = EnsureSavedVars(savedVars)
    local keys = {"tracks", "raid", "mythicPlus", "delve"}
    for _, key in ipairs(keys) do
        if fields[key] then
            local x, y = ParseXY(fields[key])
            if x and y then
                vars.positions[key] = {
                    point = "TOPLEFT",
                    relativePoint = "TOPLEFT",
                    x = x,
                    y = y,
                }
            end
        end
    end

    if fields.fv == "1" then
        vars.framesVisible = true
    elseif fields.fv == "0" then
        vars.framesVisible = false
    end

    if fields.scale ~= nil then
        local scale = tonumber(fields.scale)
        if scale and scale >= 0.7 and scale <= 2.0 then
            vars.uiScale = scale
        elseif fields.scale == "" then
            vars.uiScale = nil
        end
    end

    if fields.fsize ~= nil then
        local fsize = tonumber(fields.fsize)
        if fsize and fsize >= 6 and fsize <= 24 then
            vars.fontSize = math.floor(fsize + 0.5)
        elseif fields.fsize == "" then
            vars.fontSize = nil
        end
    end

    if fields.fpath ~= nil then
        local path = UnescapeProfileValue(fields.fpath)
        if path == "" then
            vars.fontPath = nil
        elseif path:find("=", 1, true) or path:find(",", 1, true) then
            return false, "Malformed font path in profile."
        else
            vars.fontPath = path
        end
    end

    return true
end

_G.GWA_ProfileCodec = codec