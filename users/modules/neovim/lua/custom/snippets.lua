require'snippets'.use_suggested_mappings()
local snippets = require 'snippets'
local U = require'snippets.utils'

snippets.snippets = {
    _global =  {
        copyright = U.force_comment [[Copyright (C) Philipp Herzog ${=os.date("%Y")}]];
    };
    lua = {
        req = [[local ${2:${1|S.v:match"([^.()]+)[()]*$"}} = require '$1']];
        func = [[function${1|vim.trim(S.v):gsub("^%S"," %0")}(${2|vim.trim(S.v)})$0 end]];
        ["local"] = [[local ${2:${1|S.v:match"([^.()]+)[()]*$"}} = ${1}]];
        ["for"] = U.match_indentation [[
        for ${1:i}, ${2:v} in ipairs(${3:t}) do
            $0
        end]];
    };
}
