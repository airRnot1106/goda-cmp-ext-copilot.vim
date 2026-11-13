-- Tests of copilot.lua with a fake copilot.lua. Run with `nvim -l`, from anywhere.
local script = debug.getinfo(1, "S").source:sub(2)
local copilot = dofile(vim.fn.fnamemodify(script, ":p:h:h") .. "/copilot.lua")

local callbacks = {}
package.loaded["copilot.client"] = {
    get = function()
        if not vim.g.no_client then
            return {}
        end
    end,
}
package.loaded["copilot.util"] = { get_doc_params = function() return {} end }
package.loaded["copilot.api"] = {
    get_completions = function(_, _, callback)
        table.insert(callbacks, callback)
    end,
}

-- Insert mode allows the cursor after the last character, and the test stays in normal mode.
vim.o.virtualedit = "onemore"

local failures = 0

local function test(name, fn)
    vim.cmd "enew!"
    callbacks = {}
    vim.g.no_client = false
    local ok, err = xpcall(fn, debug.traceback)
    if ok then
        print("ok    " .. name)
    else
        failures = failures + 1
        print("FAIL  " .. name .. "\n" .. err)
    end
end

local function eq(got, want)
    if not vim.deep_equal(got, want) then
        error(("got %s, want %s"):format(vim.inspect(got), vim.inspect(want)), 2)
    end
end

test("the answer of a request is pending until copilot.lua calls back", function()
    copilot.request(1)
    eq(copilot.poll(1), nil)
    callbacks[1](nil, { completions = { { text = "foo" }, { text = "bar" } } })
    eq(copilot.poll(1), { "foo", "bar" })
end)

test("a newer request drops the answer of an older one", function()
    copilot.request(1)
    copilot.request(2)
    callbacks[1](nil, { completions = { { text = "old" } } })
    eq(copilot.poll(1), {})
    eq(copilot.poll(2), nil)
    callbacks[2](nil, { completions = { { text = "new" } } })
    eq(copilot.poll(2), { "new" })
end)

test("an error of copilot.lua answers no completions", function()
    copilot.request(1)
    callbacks[1]({ message = "e" }, nil)
    eq(copilot.poll(1), {})
end)

test("without a copilot client the answer has no completions", function()
    vim.g.no_client = true
    copilot.request(1)
    eq(copilot.poll(1), {})
end)

test("accepting replaces the placeholder word with the lines", function()
    vim.api.nvim_buf_set_lines(0, 0, -1, true, { "  if x {??y()?}" })
    vim.api.nvim_win_set_cursor(0, { 1, 15 })
    copilot.accept("if x {??y()?}", { "if x {", "\ty()", "}" })
    eq(vim.api.nvim_buf_get_lines(0, 0, -1, true), { "  if x {", "\ty()", "}" })
    eq(vim.api.nvim_win_get_cursor(0), { 3, 1 })
end)

test("accepting leaves the buffer alone when the word is not before the cursor", function()
    vim.api.nvim_buf_set_lines(0, 0, -1, true, { "other" })
    vim.api.nvim_win_set_cursor(0, { 1, 5 })
    copilot.accept("foo?bar", { "foo", "bar" })
    eq(vim.api.nvim_buf_get_lines(0, 0, -1, true), { "other" })
end)

if failures > 0 then
    print(failures .. " failed")
    os.exit(1)
end
