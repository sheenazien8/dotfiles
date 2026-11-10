--- @since 25.5.31

local function quote(s)
	return "'" .. s:gsub("'", "'\\''") .. "'"
end

local function extract_cmd(url, name)
	local n = name:lower()
	local q = quote(url)
	if n:match("%.zip$") then
		return "unzip -q " .. q
	elseif n:match("%.tar%.gz$") or n:match("%.tgz$") then
		return "tar -xzf " .. q
	elseif n:match("%.tar%.bz2$") then
		return "tar -xjf " .. q
	elseif n:match("%.tar%.xz$") then
		return "tar -xJf " .. q
	elseif n:match("%.tar$") then
		return "tar -xf " .. q
	elseif n:match("%.7z$") or n:match("%.rar$") then
		return "7z x " .. q
	elseif n:match("%.gz$") then
		return "gunzip -k " .. q
	elseif n:match("%.xz$") then
		return "unxz -k " .. q
	elseif n:match("%.bz2$") then
		return "bunzip2 -k " .. q
	else
		return "7z x " .. q .. " 2>/dev/null || unzip -q " .. q .. " 2>/dev/null || tar -xf " .. q
	end
end

local get_hovered = ya.sync(function()
	local h = cx.active.current.hovered
	if not h then
		return nil
	end
	return {
		url = tostring(h.url),
		name = h.name,
		is_dir = h.cha.is_dir,
	}
end)

local IMAGE = { png = true, jpg = true, jpeg = true, gif = true, webp = true, bmp = true, svg = true, avif = true, jxl = true, heic = true, tiff = true, ico = true }
local TEXT = { txt = true, md = true, json = true, jsonc = true, js = true, ts = true, jsx = true, tsx = true, php = true, py = true, rb = true, go = true, rs = true, c = true, cpp = true, h = true, hpp = true, java = true, kt = true, lua = true, yml = true, yaml = true, toml = true, ini = true, conf = true, cfg = true, env = true, sh = true, bash = true, zsh = true, fish = true, css = true, scss = true, html = true, xml = true, sql = true, csv = true, log = true }

return {
	entry = function()
		local info = get_hovered()
		if not info then
			ya.notify({ title = "Context Menu", content = "No file hovered", timeout = 3 })
			return
		end

		local url = info.url
		local name = info.name
		local lower = name:lower()
		local ext = lower:match("%.([^.]+)$") or ""
		local is_dir = info.is_dir
		local q = quote(url)

		local actions = {}
		local cands = {}

		local function add(key, desc, fn)
			actions[#actions + 1] = fn
			cands[#cands + 1] = { on = key, desc = desc }
		end

		add("o", "Open", function() ya.emit("open", {}) end)
		add("O", "Open With...", function() ya.emit("open", { "--interactive" }) end)
		add("r", "Reveal", function() ya.emit("open", { "--reveal" }) end)

		if is_dir then
			add("e", "Enter Directory", function() ya.emit("enter", {}) end)
			add("t", "Open Terminal Here", function()
				local term = os.getenv("TERMINAL") or "xterm"
				local shell = os.getenv("SHELL") or "bash"
				ya.emit("shell", { term .. " -e " .. shell, block = true })
			end)
			add("z", "Zip Directory", function()
				local zip = (name:gsub("/+$", "")) .. ".zip"
				ya.emit("shell", { "zip -r " .. quote(zip) .. " " .. q, block = true })
				ya.notify({ title = "Zip", content = "Created " .. zip, timeout = 3 })
			end)
		else
			local is_archive = lower:match("%.zip$") or lower:match("%.tar") or lower:match("%.tgz$") or lower:match("%.7z$") or lower:match("%.rar$") or lower:match("%.gz$") or lower:match("%.xz$") or lower:match("%.bz2$") or lower:match("%.zst$")
			local is_image = IMAGE[ext] or false
			local is_text = TEXT[ext] or false

			if is_archive then
				add("x", "Extract Here", function()
					ya.emit("shell", { extract_cmd(url, name), block = true })
				end)
				add("X", "Extract To...", function()
					ya.emit("shell", {
						"read -rp 'Extract to: ' dest; mkdir -p \"$dest\"; cd \"$dest\" && " .. extract_cmd(url, name),
						block = true, interactive = true,
					})
				end)
			end

			if is_image then
				add("w", "Set as Wallpaper", function()
					local cmd = "feh --bg-scale " .. q .. " 2>/dev/null || nitrogen --set-zoom-fill " .. q .. " 2>/dev/null || swww img " .. q .. " 2>/dev/null"
					ya.emit("shell", { cmd, block = true })
				end)
			end

			if is_text then
				add("e", "Edit", function()
					ya.emit("shell", { "${EDITOR:-vi} " .. q, block = true })
				end)
			end

			if ext == "deb" then
				add("i", "Install .deb", function()
					ya.emit("shell", { "sudo dpkg -i " .. q, block = true })
				end)
			end

			if ext == "rpm" then
				add("i", "Install .rpm", function()
					ya.emit("shell", { "sudo rpm -i " .. q, block = true })
				end)
			end

			if lower:match("%.flatpak$") or lower:match("%.flatpakref$") or lower:match("%.flatpakrepo$") then
				add("i", "Install Flatpak", function()
					ya.emit("shell", { "flatpak install --user -y " .. q, block = true })
				end)
			end

			if lower:match("%.appimage$") then
				add("I", "Install AppImage", function()
					local env = {}
					local fields = {
						{ key = "AI_NAME", title = "Name:", value = name:gsub("%.appimage$", "") },
						{ key = "AI_ICON", title = "Icon path (empty = auto):", value = "" },
						{ key = "AI_CATEGORIES", title = "Categories:", value = "Utility;" },
						{ key = "AI_EXEC_ARGS", title = "Exec args:", value = "%U" },
					}
					for _, f in ipairs(fields) do
						local v = ya.input({ pos = { "top-center", y = 3, w = 50 }, title = f.title, value = f.value })
						if v and v ~= "" then
							env[#env + 1] = f.key .. "=" .. quote(v)
						end
					end
					ya.emit("shell", {
						(#env > 0 and table.concat(env, " ") .. " " or "") .. "~/.config/yazi/install-appimage.sh " .. q,
						block = true,
					})
				end)
				add("m", "Make Executable", function()
					ya.emit("shell", { "chmod +x " .. q })
				end)
			end

			if ext == "sh" or ext == "bash" or ext == "zsh" or ext == "fish" then
				add("M", "Make Executable + Run", function()
					ya.emit("shell", { "chmod +x " .. q .. " && " .. q, block = true })
				end)
			end

			add("c", "Copy Absolute Path", function() ya.emit("copy", { "path" }) end)
			add("n", "Copy Filename", function() ya.emit("copy", { "filename" }) end)
			add("y", "Yank (Copy)", function() ya.emit("yank", {}) end)
			add("Y", "Cut", function() ya.emit("yank", { "--cut" }) end)
			add("d", "Trash", function() ya.emit("remove", {}) end)
			add("D", "Delete Permanently", function() ya.emit("remove", { "--permanently" }) end)
			add("z", "Zip File", function()
				local zip = name .. ".zip"
				ya.emit("shell", { "zip " .. quote(zip) .. " " .. q, block = true })
				ya.notify({ title = "Zip", content = "Created " .. zip, timeout = 3 })
			end)
			add("+", "Chmod +x", function()
				ya.emit("shell", { "chmod +x " .. q })
			end)
			add("R", "Rename", function() ya.emit("rename", { "--cursor=before_ext" }) end)
		end

		local idx = ya.which({ cands = cands, silent = false })
		if idx then
			actions[idx]()
		end
	end,
}
