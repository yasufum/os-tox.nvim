# os-tox

An OpenStack tox helper for nvim.

## Setup

It's expected to be used with `Astronvim` using `lazy.nvim` as a
package manager. So, it's recommended to setup your custom plugins
as explained in Astronvim's
[Custom Plugins](https://astronvim.com/recipes/custom_plugins).

Configuration of `os-tox` plugin is defined in 
`$HOME/.config/nvim/lua/plugins/user.lua` in this case.

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

## Usage

[TODO] Update usage below.

### Run tox

Open a file in which unittests are defined, go to a function of unittest
and run it in command line mode for running it from command line mode.

```
:OsRunTest
```

If you want to debug the code from the point you put
`import pdb; pdb.set_trace()`, run `:OsRunDebug` in the command line mode.
You can run debug without importing pdb by yourself by running
`:OsRunDebugI` which is insert the importing pdb at current position before
running.

```
" Run debug
:OsRunDebug

" Insert `import pdb; pdb.set_trace()` and run debug
:OsRunDebugI
```

It is configurable if you run `:OsRunTox` with an argument for giving an
environment. For example, it is equal to run tox in `py38`.

```
:OsRunTox py38
```

If your cursor is on a test class, but outside of a method, it runs
whole of methods defined in the class. Furthermore, it runs whole of
tests in a file if cursor is outside of a class.

### Open definition

You may usually open a file of unittest by referring a test path such as
`tacker.tests.unit.vnfm.test_plugin.TestVNFMPlugin.test_create_vnf_with_config_option`.
In this case, you will open `tacker/tests/unit/vnfm/test_plugin.py` and find the method
`test_create_vnf_with_config_option` in `TestVNFMPlugin` class.

This plugin provide a feature to jump to the definition from the test path.

Open a method, class or file of the test path on the cursor.

```
:OsOpenDefinition
```

Or, you can give a test path explicitly.

```
" Open test method
:OsOpenDefinition tacker.tests.unit.vnfm.test_plugin.TestVNFMPlugin.test_create_vnf_with_config_option

" Open class
:OsOpenDefinition tacker.tests.unit.vnfm.test_plugin.TestVNFMPlugin

" Open file
:OsOpenDefinition tacker.tests.unit.vnfm.test_plugin

" Open directory 
:OsOpenDefinition tacker.tests.unit.vnfm
```

## License

MIT
