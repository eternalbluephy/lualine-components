local highlight = require("lualine.highlight")
local lnp = require("lualine.component"):extend()

lnp.default = {
	colors = {
		location = "#CCC",
		progress = "#CCC",
		spinner = "#FF8800"
	},
	spinner_symbols = { "▁", "▂", "▃", "▄", "▅", "▆", "▇", "█" },
}

lnp.init = function(self, options)
	lnp.super.init(self, options)

	self.options.colors = vim.tbl_extend("force", lnp.default.colors, self.options.colors or {})
	self.options.spinner_symbols = vim.tbl_extend("force", lnp.default.spinner_symbols, self.options.spinner_symbols or {})
	
	self.highlights.location = highlight.create_component_highlight_group({ fg = self.options.colors.location }, "lnp_location", self.options)
	self.highlights.progress = highlight.create_component_highlight_group({ fg = self.options.colors.progress }, "lnp_progress", self.options)
	self.highlights.spinner = highlight.create_component_highlight_group({ fg = self.options.colors.spinner }, "lnp_spinner", self.options)
end

lnp.update_status = function(self)
	self._line = vim.fn.line(".")
	self._col = vim.fn.col(".")
	self._total = vim.fn.line("$")
	self._location = highlight.component_format_highlight(self.highlights.location) .. string.format("%3d:%-2d", self._line, self._col)

	self._progress = ""
	if self._line == 1 then self._progress = "Top"
	elseif self._line == self._total then self._progress = "Bot"
	else self._progress = string.format("%2d%%%%", math.floor(self._line / self._total * 100)) end
	self._progress = highlight.component_format_highlight(self.highlights.progress) .. self._progress

	self:update_spinner()
	self._spinner_symbol = highlight.component_format_highlight(self.highlights.spinner) .. self._spinner_symbol
	return self._location .. " " .. self._progress .. " " .. self._spinner_symbol
end

lnp.update_spinner = function(self)
	self._spinner_symbol = ""
	if #self.options.spinner_symbols == 0 then
		return
	end
	local progress = math.floor(self._line / self._total * 100)
	local unit = math.floor(100 / #self.options.spinner_symbols)
	for i, symbol in ipairs(self.options.spinner_symbols) do
		if (progress >= (i - 1) * unit) then
			self._spinner_symbol = symbol
		else
			break
		end
	end
end

return lnp
