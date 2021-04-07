loadstring(game:HttpGet("https://raw.githubusercontent.com/Kinlei/js.lua/main/js.lua"))()(false);

-- ^^ js.lua ^^

local GlobalSpace = getgenv();

function ShortUpper(n)
	if (typeof(n) == "string") then
		local u = Wrap({});
		for i = 1, #n do
			local c = n[i];
			if (c == c.toUpperCase) then
				table.insert(u, c);
			end;
		end;
		return u.join("");
	end;
	return n;
end;

function GetShortProperties(i)
    local Properties = getproperties(i);
    local PropTable = Wrap({});
    for PropN, PropV in next, Properties do
    	if (typeof(PropN) == "number") then
    		PropN = PropV;
    	end;
	    PropV = pcall(function() 
			return i[PropN] 
		end);
		if (PropV) then
			local CheckIndex = ShortUpper(PropN);
			if (not PropTable[CheckIndex]) then
				 PropTable[CheckIndex] = i[PropN];
			end;
		end;
    end;
    return PropTable;
end;

GlobalSpace.dynamic = function(n)
	local d = n[1];
	local f = n[2];
	local e = n[3];
	local r = (typeof(f) == "function") and f();
	GlobalSpace[d] = r;
	r.Changed:Connect(function()
		GlobalSpace[d] = (typeof(f) == "function") and f();
	end);
	if (e) then
		e:Connect(function()
			GlobalSpace[d] = (typeof(f) == "function") and f();
		end);
	end;
end;

GlobalSpace.props = function(n)
    local e = n[1];
    local props = getproperties(e);
    local sprops = GetShortProperties(e);
    table.foreach(sprops, function(k, v)
        props[k] = v;
    end);
    return Wrap(props);
end;

GlobalSpace.let = function(n)
    local d = n[1];
    local v = n[2];
    GlobalSpace[d] = v;
end;

GlobalSpace.temp = function(n)
    local d = n[1];
    local v = n[2];
    setrawmetatable(v, {
        __call = function()
            GlobalSpace[d] = nil;
        end;
    })
    GlobalSpace[d] = v;
end;

GlobalSpace.class = function(n)
    local d = n[1];
    GlobalSpace[d] = {};
    return function(s)
        table.foreach(s, function(k, v)
            GlobalSpace[d][k] = v;
        end);
    end;
end;

GlobalSpace.get = function(n)
    local s = table.remove(n, 1);
    repeat
        s = s:WaitForChild(table.remove(n, 1));
    until table.remove(n, 1) == nil;
    return s;
end;

local LoadedServices = {};

GlobalSpace.serve = function(n)
	local f = n[1];
	local CheckLoaded = LoadedServices[f];
	if (CheckLoaded) then
		return CheckLoaded;
	end;
    local s = game:GetService(f);
    if (s) then
        local mt = getrawmetatable(s);
        local oni = mt.__newindex;
        local oi = mt.__index;
        local p = Wrap({});
        mt.__index = function(t, k)
            if (checkcaller()) then
                local tp = rawget(p, k);
                if (tp) then
                    return tp;
                end;
            end;
            return oi(t, k);
        end;
        mt.__newindex = function(t, k, v)
            if (checkcaller()) then
                rawset(p, k, v);
            end;
            return oni(t, k, v);
        end;
        local sp = GetShortProperties(s);
        table.foreach(sp, function(pn, pv)
            p[pn] = pv;
        end);
    end;
    LoadedServices[f] = s;
    return s;
end;
