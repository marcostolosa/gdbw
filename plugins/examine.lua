examine = {
    iscommand=true;
    alias={"examine", "x"};
    help="usage: examine [address] [-f format] [-c count]";
    valid_formats={};
}

function examine:parseargs(args)
    local parser = ArgumentParser;
    parser:init("examine", "display memory contents at a given address", false)
    parser:AddArgument("address", "address of memory content", true, "store", Evaluate)
    parser:AddArgument({"-f", "--format"}, "format to display data [word/dword/qword/cstring]", false, "store", nil)
    parser:AddArgument({"-c", "--count"}, "number of items to display (e.g. 10)", false, "store", math.tointeger)
    return parser:ParseArgs(args)
end

function examine:command(args)
    local namespace = examine:parseargs(args)
    if namespace == nil then return end

    examine.valid_formats["word"] = examine.word;
    examine.valid_formats["dword"] = examine.dword;
    examine.valid_formats["qword"] = examine.qword;
    examine.valid_formats["cstring"] = examine.cstring;

    ---@type integer
    local address = namespace["address"]
    if address == nil then
        print("usage: examine <address> [--format format] [--count count]")
        return
    end

    ---@type integer
    local count = 1
    if namespace["--count"] ~= nil then count = namespace["--count"] end

    -- Set format, defaults to pointer size, otherwise user format
    ---@type string
    local format
    if Is64BitTarget() then format = "qword" else format = "dword" end
    for valid_format, func in pairs(examine.valid_formats) do
        if namespace["--format"] == valid_format then
            format = namespace["--format"]
            goto format_processed
        end
    end
    ::format_processed::

    local to_print = ""
    local base_addr = address
    local last_size = 0
    for i = 0, count-1 do
        local data
        data, last_size = examine.valid_formats[format](self, address)
        if data == nil then
            printf("Failed to read data at address %s", address2hex(address))
            goto output
        end
        to_print = to_print .. string.format("%02x:%04x| %s%s%s : ", i, address - base_addr, colour.LIGHTBLUE, address2hex(address), colour.DEFAULT)
        to_print = to_print .. data .. string.char(10)

        address = address + last_size
    end
    ::output::
    print(to_print)
end

---Read a qword at address, returns string representation of data & size
---@param address integer
---@return string|nil, integer
function examine:qword(address)
    local data, size = memory:readqword(address)
    if data == nil then return nil, size end
    return string.format("0x%016x", data), size
end

---Read a dword at address, returns string representation of data & size
---@param address integer
---@return string|nil, integer
function examine:dword(address)
    local data, size = memory:readdword(address)
    if data == nil then return nil, size end
    return string.format("0x%08x", data), size
end

---Read a word at address, returns string representation of data & size
---@param address integer
---@return string|nil, integer
function examine:word(address)
    local data, size = memory:readword(address)
    if data == nil then return nil, size end
    return string.format("0x%02x", data), size
end

---Read a cstring at an address, returns string representation of data & size 
---@param address integer
---@return string|nil, integer
function examine:cstring(address)
    local read_byte
    local size = 0
    local data = ""
    repeat
        read_byte = memory:readbyte(address)
        if read_byte == nil then return nil, size end
        if read_byte > 0x1f and read_byte < 0x7f then
            data = data .. string.char(read_byte)
        else 
            data = data .. string.format("\\x%02x", read_byte)
        end
        size = size + 1
        address = address + 1
    until read_byte == 0x00
    return data, size
end