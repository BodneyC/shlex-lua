# ShLex Lua

First off, __a disclaimer__, this is not supposed to be a full Lua implementation of the Python [shlex](https://docs.python.org/3/library/shlex.html) module. It is a simplified version to fit my purposes.

## Usage

This is not a [rock](https://luarocks.org/), it's not worthy of a rock really. It's more a couple files you can drop into your project (or even your Neovim config (which is why I wrote it)) if you need to parse a shell command.

```lua
local shlex = require 'shlex'

local parts = shlex.split('some command/with/parts')

print(require('inspect')(parts))
-- {'some', 'command/with/parts'}

local cmd = shlex.join(parts)

print(cmd)
-- "'some' 'command/with/parts'"
```

## Differences from the Python Module

- No file sources, it takes a string and a string alone
- Comments are enabled by default (I'm not really sure why this is disabled by default in shlex)

## Run the Tests

Simple set of tests, easy to add your own if you want to know if this file will work for you.

```bash
$ lua shlex-tests.lua
Test: Simple command
  cmd: cat /some/file
  exp: { "cat", "/some/file" }
  res: success

Test: Quoted argument
  cmd: cat '/some/file'
  exp: { "cat", "/some/file" }
  res: success

...
```
