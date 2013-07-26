
local function get_funcs_and_consts( data )
	local funcs, consts = {}, {}
	for h3 in string.gmatch(data, "<h3>.-</h3>") do
		local code = string.match(h3, "<code>.-</code>")
		if code then
			local code = string.sub(code, 7, -8)
			if string.find(code, "lua") ~= 1 then
				if string.find(code, "%(") then
					code = string.gsub(code, "&middot;", ".")
					table.insert(funcs, code)
				else
					table.insert(consts, code)
				end
			end
		end
	end
	return funcs, consts
end

local function get_content( func )
	local content = func
	local code = string.match(func, "%(.-%)")
	if code then
		code = string.sub(code, 2, -2)
		if string.len(code) > 0 then
			local args = {}
			local n = 1
			for arg in string.gmatch(code, "([%w%.]+)") do
				table.insert(args, string.format("${%d:%s}", n, arg))
				n = n + 1
			end
			content = string.sub(func, 1, string.find(func, "%(") - 2) .. "(".. table.concat(args, ", ") .. ")"
		end
	end
	return "<![CDATA[" .. content .. "]]>"
end

local function get_func_name( func )
	return string.sub(func, 1, string.find(func, "%(") - 2)
end

local function get_description( func )
	return string.match(func, "%(.-%)")
end

local function get_snippet( content, trigger, description )
	local space = string.rep(" ", 4)
	local snippet = string.format("<snippet>\n%s\n%s\n%s\n%s\n</snippet>\n",
		space .. "<content>" .. content .. "</content>",
		space .. "<tabTrigger>" .. trigger .. "</tabTrigger>",
		space .. "<scope>source.lua</scope>",
		space .. "<description>" .. description .. "</description>")
	return snippet
end

local function output_funcs( funcs, dir )
	if string.sub(dir, -1) ~= "/" then
		dir = dir .. "/"
	end
	for _, func in ipairs(funcs) do
		local func_name = get_func_name(func)
		local snippet = get_snippet(get_content(func), func_name, get_description(func))

		local f_name = func_name .. ".sublime-snippet"
		local f = io.open(dir .. f_name, "w")
		f:write(snippet)
		f:close()
	end
end

local function output_consts( consts, dir )
	if string.sub(dir, -1) ~= "/" then
		dir = dir .. "/"
	end
	for _, const in ipairs(consts) do
		local snippet = get_snippet("<![CDATA[" .. const .. "]]>", const, const)

		local f_name = const .. ".sublime-snippet"
		local f = io.open(dir .. f_name, "w")
		f:write(snippet)
		f:close()
	end
end


local f = io.open("manual.html", "r")
local data = f:read("*all")
f:close()

local funcs, consts = get_funcs_and_consts(data)

os.execute("mkdir Lua")

output_funcs(funcs, "Lua")
output_consts(consts, "Lua")

print("all done")