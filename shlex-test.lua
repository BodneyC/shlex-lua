local shlex = require 'shlex'
local inspect = require 'inspect'

shlex.shlex.debug = 0

local colors = {
  red = '\27[31m',
  green = '\27[32m',
  yellow = '\27[33m',
  blue = '\27[34m',
  reset = '\27[0m',
}

local function list_equal(exp, act)
  if type(exp) ~= 'table' then
    return false, 'expected value not table'
  end
  if type(act) ~= 'table' then
    return false, 'actual value not table'
  end
  if #exp ~= #act then
    return false, 'lengths differ (' .. #exp .. ', ' .. #act .. ')'
  end
  for idx, vexp in ipairs(exp) do
    local vact = act[idx]
    if vexp ~= vact then
      return false,
        'value@' .. idx .. ' differs (' .. vexp .. ', ' .. vact .. ')'
    end
  end
  return true
end

-- If you're after that "easy to add" bit I was talking about then ignore this
--  abomination and head below
local function shlex_tests(tests)
  local total = 0
  local passed = 0
  for name, tests_in_type in pairs(tests) do
    total = total + #tests_in_type
    local passed_in_type = 0
    print('-------- Tests for \'' .. name .. '\' --------')
    print()
    for _, t in ipairs(tests_in_type) do
      print('Test: ' .. colors.yellow .. t.name .. colors.reset)
      print('  input: ' .. colors.blue .. inspect(t.input) .. colors.reset)
      print('  exp: ' .. colors.blue .. inspect(t.exp) .. colors.reset)
      local succ, mess, actual
      if name == 'split' then
        actual = shlex.split(t.input)
        succ, mess = list_equal(t.exp, actual)
      elseif name == 'quote' then
        actual = shlex.quote(t.input)
        succ, mess = t.exp == actual, ''
      elseif name == 'join' then
        actual = shlex.join(t.input)
        succ, mess = t.exp == actual, ''
      else
        error('unknown test type (' .. name .. ')')
      end
      if succ then
        print('  res: ' .. colors.green .. 'success' .. colors.reset)
      else
        print('  act: ' .. colors.red .. inspect(actual) .. colors.reset)
        print('  res: ' .. colors.red .. mess .. colors.reset)
      end
      print()
      passed_in_type = passed_in_type + (succ and 1 or 0)
    end
    passed = passed + passed_in_type
    local color = colors.red
    if passed_in_type == #tests_in_type then
      color = colors.green
    end
    print(' ' .. name .. ': ' .. color .. passed_in_type .. '/' ..
            #tests_in_type .. ' passed' .. colors.reset)
    print()
  end
  local color = colors.red
  if passed == total then
    color = colors.green
  end
  print('Total ' .. color .. passed .. '/' .. total .. ' passed' .. colors.reset)
end

shlex_tests({
  split = {
    {
      name = 'Simple command',
      input = [[cat /some/file]],
      exp = {'cat', '/some/file'},
    },
    {
      name = 'Quoted argument',
      input = [[cat '/some/file']],
      exp = {'cat', '/some/file'},
    },
    {
      name = 'Quote-wrapped argument',
      input = [[cat "'"/some/file"'"]],
      exp = {'cat', [['/some/file']]},
    },
    {
      name = 'With a space in quotes',
      input = [[cat "/some/ file"]],
      exp = {'cat', '/some/ file'},
    },
    {
      name = 'With a space out of quotes',
      input = [[cat /some/ file]],
      exp = {'cat', '/some/', 'file'},
    },
    {
      name = 'With a comment',
      input = [[cat /some/file # This is a comment]],
      exp = {'cat', '/some/file'},
    },
    {
      name = 'Comment in quotes',
      input = [[echo '/some/file # not a comment']],
      exp = {'echo', '/some/file # not a comment'},
    },
    {
      name = 'Multiline simple',
      input = [[echo /some/file \
         | cat ]],
      exp = {'echo', '/some/file', '|', 'cat'},
    },
  },
  join = {
    {
      name = 'Join command and argument',
      input = {'cat', '/some/file'},
      exp = [['cat' '/some/file']],
    },
    {
      name = 'With quoted file',
      input = {'cat', [['/some/file']]},
      exp = [['cat' ''"'"'/some/file'"'"'']],
    },
  },
  quote = {
    {
      name = 'No need to quote spaces',
      input = '       ',
      exp = '       ',
    },
    {
      name = 'Quote word',
      input = 'simplestring',
      exp = [['simplestring']],
    },
    {
      name = 'Quote with an @',
      input = 'simple@string',
      exp = [['simple@string']],
    },
    {
      name = 'Match at start covers whole word',
      input = [[@simplestring]],
      exp = [['@simplestring']],
    },
    {
      name = 'Single quote match on word',
      input = [[simple'string]],
      exp = [['simple'"'"'string']],
    },
  },
})
