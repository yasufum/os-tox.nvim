# os-tox

An OpenStack tox helper for nvim.

## Setup

```lua
-- $HOME/.config/nvim/lua/plugins/user.lua

return {
...
{
    "yasufum/os-tox.nvim",
    event = "VeryLazy",
    config = function()
      require("os-tox").setup()
    end
  },
}
```
