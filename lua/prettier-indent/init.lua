local M = {}

-- Locate a prettier config file upward in the directory tree
local function find_prettier_config(start_dir)
  local config_files = {
    ".prettierrc",
    ".prettierrc.json",
    ".prettierrc.js",
    "prettier.config.js",
    ".prettierrc.cjs",
  }

  local uv = vim.loop
  local function is_file(path)
    local stat = uv.fs_stat(path)
    return stat and stat.type == "file"
  end

  local function join(...)
    return table.concat({ ... }, "/")
  end

  local function search_up(dir)
    for _, name in ipairs(config_files) do
      local candidate = join(dir, name)
      if is_file(candidate) then
        return candidate
      end
    end
    local parent = uv.fs_realpath(join(dir, ".."))
    if parent and parent ~= dir then
      return search_up(parent)
    end
  end

  return search_up(uv.fs_realpath(start_dir))
end

-- Parse the Prettier config via Node.js
local function parse_prettier_config(path)
  local json = vim.fn.system({
    "node",
    "-e",
    string.format(
      [[
        const fs = require("fs");
        const path = "%s";
        const config = require(path);
        console.log(JSON.stringify({ tabWidth: config.tabWidth, useTabs: config.useTabs }));
      ]],
      path:gsub("\\", "\\\\") -- escape for Windows
    ),
  })

  local ok, parsed = pcall(vim.fn.json_decode, json)
  if ok and parsed then
    return parsed
  end
end

-- Apply shiftwidth/tabstop/expandtab based on Prettier config
function M.apply()
  local filepath = vim.api.nvim_buf_get_name(0)
  if filepath == "" then return end
  local config_path = find_prettier_config(vim.fn.fnamemodify(filepath, ":p:h"))
  if not config_path then return end

  local config = parse_prettier_config(config_path)
  if not config then return end

  vim.bo.shiftwidth = config.tabWidth or 2
  vim.bo.tabstop = config.tabWidth or 2
  vim.bo.expandtab = not config.useTabs
end

function M.setup()
  vim.api.nvim_create_autocmd("BufReadPost", {
    pattern = "*",
    callback = M.apply,
    group = vim.api.nvim_create_augroup("PrettierIndent", { clear = true }),
  })
end

return M
