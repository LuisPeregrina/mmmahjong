# Lua 5.1 Quick Reference

**Lutro runs Lua 5.1.** This ref covers only what Lutro devs need: types, syntax, operators, and standard library APIs. C API sections omitted.

Sources for the full manual: http://www.lua.org/manual/5.1/

---

## 1. Types & Values

8 types: `nil`, `boolean`, `number`, `string`, `function`, `userdata`, `thread`, `table`

- **nil**: "no value". Makes condition false.
- **boolean**: `false` and `true`. Only `false`/`nil` = false; everything else = true.
- **number**: double-precision float.
- **string**: 8-bit clean, immutable, can contain `\0`.
- **table**: associative arrays. Indexed by any value except nil. Records via `t.field` = `t["field"]`.
- **function**: first-class values, closures.
- **thread**: coroutines.
- **userdata**: raw C data (not creatable from Lua alone).

Coercion: strings ↔ numbers automatic in arithmetic (string→number) and string contexts (number→string).

---

## 2. Syntax Summary

```
chunk       ::= {stat [`;´]} [laststat [`;´]]
block       ::= chunk

stat        ::= varlist `=´ explist
              | functioncall
              | do block end
              | while exp do block end
              | repeat block until exp
              | if exp then block {elseif exp then block} [else block] end
              | for Name `=´ exp `,´ exp [`,´ exp] do block end
              | for namelist in explist do block end
              | function funcname funcbody
              | local function Name funcbody
              | local namelist [`=´ explist]

laststat    ::= return [explist] | break
funcname    ::= Name {`.´ Name} [`:´ Name]
varlist     ::= var {`,´ var}
var         ::= Name | prefixexp `[´ exp `]´ | prefixexp `.´ Name
namelist    ::= Name {`,´ Name}
explist     ::= {exp `,´} exp
exp         ::= nil | false | true | Number | String | `...´ | function
              | prefixexp | tableconstructor | exp binop exp | unop exp
prefixexp   ::= var | functioncall | `(´ exp `)´
functioncall::= prefixexp args | prefixexp `:´ Name args
args        ::= `(´ [explist] `)´ | tableconstructor | String
function    ::= function funcbody
funcbody    ::= `(´ [parlist] `)´ block end
parlist     ::= namelist [`,´ `...´] | `...´
tableconstructor ::= `{´ [fieldlist] `}´
fieldlist   ::= field {fieldsep field} [fieldsep]
field       ::= `[´ exp `]´ `=´ exp | Name `=´ exp | exp
fieldsep    ::= `,´ | `;´
```

Reserved keywords: `and break do else elseif end false for function if in local nil not or repeat return then true until while`

---

## 3. Operators (precedence, highest to lowest)

```
^               exponentiation (right-associative)
not  #  -       unary: logical not, length, arithmetic negation
*  /  %         multiplication, division, modulus
+  -            addition, subtraction
..              concatenation (right-associative)
<  >  <=  >=  ~=  ==     relational (~= = not equal)
and             logical AND
or              logical OR
```

---

## 4. Metatables & Metamethods

Every table/udata can have a metatable. Key metamethods:

`__add`, `__sub`, `__mul`, `__div`, `__mod`, `__pow`, `__unm`, `__concat`, `__len`, `__eq`, `__lt`, `__le`, `__index`, `__newindex`, `__call`, `__tostring`, `__metatable`, `__gc` (udata only), `__mode` (weak tables).

`a[b]` → `__index` if `a[b]` nil. `a[b] = v` → `__newindex`.

---

## 5. Standard Libraries

### 5.1 Basic Functions

```
assert(v [, message])           -> v or error
collectgarbage([opt [, arg]])   -> varies (opt: "stop","restart","collect","count","step","setpause","setstepmul")
dofile([filename])              -> chunk results
error(message [, level])        -> never returns
_G                              -> global env table
getfenv([f])                    -> env table of function f
getmetatable(object)            -> metatable or nil
ipairs(t)                       -> iterator (1..first nil)
load(func [, chunkname])        -> chunk (function) or nil+err
loadfile([filename])            -> chunk or nil+err
loadstring(string [, chunkname]) -> chunk or nil+err
next(table [, index])           -> next key-value pair
pairs(t)                        -> iterator over all pairs
pcall(f, ...)                   -> true, results | false, err
print(...)                      -> to stdout
rawequal(v1, v2)                -> bool
rawget(table, index)            -> value (no metamethods)
rawset(table, index, value)     -> table (no metamethods)
select(index, ...)              -> nth arg or count of args (#)
setfenv(f, table)               -> function f
setmetatable(table, metatable)  -> table
tonumber(e [, base])            -> number or nil
tostring(e)                     -> string
type(v)                         -> string type name
unpack(list [, i [, j]])        -> elements (⚠️ see Gotcha below)
_VERSION                        -> "Lua 5.1"
xpcall(f, err)                  -> true, results | false, err
```

### 5.2 Coroutines

```
coroutine.create(f)             -> thread (co)
coroutine.resume(co, ...)       -> true, results | false, err
coroutine.running()             -> thread or nil
coroutine.status(co)            -> "running","suspended","normal","dead"
coroutine.wrap(f)               -> function (resumes internally)
coroutine.yield(...)            -> values passed to resume
```

### 5.3 Modules

```
module(name [, ...])            -> create module table
require(modname)                -> loaded module value
package.cpath                   -> C loader search path
package.loaded                  -> table of loaded modules
package.loaders                 -> list of searcher functions
package.loadlib(lib, func)      -> C function from shared lib
package.path                    -> Lua loader search path
package.preload                 -> table of preloaded loaders
package.seeall(module)          -> set __index = _G
```

### 5.4 String Library

```
string.byte(s [, i [, j]])      -> char codes
string.char(...)                -> string from codes
string.dump(function)           -> binary chunk string
string.find(s, pattern [, init [, plain]])  -> start, end (or nil)
string.format(formatstring, ...)            -> formatted string
string.gmatch(s, pattern)                  -> iterator (captures)
string.gsub(s, pattern, repl [, n])         -> result, count
string.len(s)                   -> length
string.lower(s)                 -> lowercase
string.match(s, pattern [, init])           -> captures (or nil)
string.rep(s, n)                -> repeated string
string.reverse(s)               -> reversed string
string.sub(s, i [, j])          -> substring
string.upper(s)                 -> uppercase
```

#### Patterns (similar to POSIX but limited):

**Character class**: `%a` (letter), `%c` (control), `%d` (digit), `%l` (lower), `%p` (punct), `%s` (space), `%u` (upper), `%w` (alnum), `%x` (hex), `%z` (NUL). Uppercase = complement. `.` = any char. `%` = escapes magic chars `( ) . % + - * ? [ ] ^ $`.

**Pattern item**: single class, `class*` (0+ greedy), `class+` (1+ greedy), `class-` (0+ non-greedy), `class?` (0/1).

**Pattern**: `^` (anchor start), `$` (anchor end), `[...]` (set, `^`=complement).

**Captures**: `(pattern)` captures substring. `%1`-`%9` back-references. Empty capture `()` = position.

### 5.5 Table Library

```
table.concat(table [, sep [, i [, j]]])     -> concatenated string
table.insert(table, [pos,] value)           -> grows table
table.maxn(table)                           -> largest positive numeric key
table.remove(table [, pos])                 -> removed value (shrinks)
table.sort(table [, comp])                  -> in-place sort
```

### 5.6 Math Library

```
math.abs(x)         math.acos(x)        math.asin(x)
math.atan(x)        math.atan2(y, x)    math.ceil(x)
math.cos(x)         math.cosh(x)        math.deg(x)
math.exp(x)         math.floor(x)       math.fmod(x, y)
math.frexp(x)       math.huge           math.ldexp(m, e)
math.log(x)         math.log10(x)       math.max(x, ...)
math.min(x, ...)    math.modf(x)        math.pi
math.pow(x, y)      math.rad(x)         math.random([m [, n]])
math.randomseed(x)  math.sin(x)         math.sinh(x)
math.sqrt(x)        math.tan(x)         math.tanh(x)
```

`math.random()` → [0,1). `math.random(n)` → 1..n int. `math.random(m,n)` → m..n int.

### 5.7 I/O Library

```
io.close([file])             -> true or nil+err
io.flush()                   -> true or nil+err
io.input([file])             -> current input file
io.lines([filename])         -> iterator (line w/o EOL)
io.open(filename [, mode])   -> file handle or nil+err
io.output([file])            -> current output file
io.popen(prog [, mode])      -> file handle or nil (POSIX only)
io.read(...)                 -> read from input
io.tmpfile()                 -> temporary file handle
io.type(obj)                 -> "file" or "closed file" or nil
io.write(...)                -> write to output

file:close()                 -> true or nil+err
file:flush()                 -> true or nil+err
file:lines()                 -> iterator
file:read(...)               -> result(s)
file:seek([whence] [, offset]) -> current position (whence: "set","cur","end")
file:setvbuf(mode [, size])  -> true or nil+err (mode: "full","line","no")
file:write(...)              -> true or nil+err
```

Read formats: `"*all"` (entire), `"*line"` (line w/o EOL), `"*number"` (number), `n` (n-byte string).

### 5.8 OS Library

```
os.clock()                   -> CPU time in seconds
os.date([format [, time]])   -> formatted string or table
os.difftime(t2, t1)          -> seconds difference
os.execute([command])        -> status code
os.exit([code])              -> never returns
os.getenv(varname)           -> value or nil
os.remove(filename)          -> true or nil+err
os.rename(old, new)          -> true or nil+err
os.setlocale(locale [, cat]) -> string or nil
os.time([table])             -> timestamp
os.tmpname()                 -> temp filename string
```

### 5.9 Debug Library

```
debug.debug()                              -> interactive prompt
debug.getfenv(o)                           -> env table
debug.gethook([thread])                    -> hook, mask, count
debug.getinfo([thread,] f [, what])        -> table of info
debug.getlocal([thread,] level, local)     -> name, value
debug.getmetatable(object)                 -> metatable
debug.getregistry()                        -> registry table
debug.getupvalue(func, up)                 -> name, value
debug.setfenv(object, table)               -> object
debug.sethook([thread,] hook, mask [, count])  -> nil
debug.setlocal([thread,] level, local, value)  -> name or nil
debug.setmetatable(object, table)          -> object
debug.setupvalue(func, up, value)          -> name or nil
debug.traceback([thread,] [message [,level]])  -> trace string
```

## 6. Lua 5.1 Gotchas

### `unpack` trims in non-tail position

When `unpack(t)` is NOT the last item in an expression list, Lua trims its multi-return to **1 value** (the first element). The rest are silently discarded.

```lua
-- BAD: unpack is not in tail position
function f(a, b, c, d, e) end
f(unpack({1, 2, 3}), 4, 5)  -- f gets: (1, 4, 5)  -- 2 and 3 lost!

-- GOOD: unpack is the only expression - all values pass
f(unpack({1, 2, 3}))        -- f gets: (1, 2, 3)

-- ALSO GOOD: pass table directly and unpack inside the function
function darken_color(color, pct)
  return math.floor(color[1] * pct), math.floor(color[2] * pct), math.floor(color[3] * pct), color[4] or 255
end
darken_color({255, 255, 255}, 0.5)  -- works correctly

-- ALSO GOOD: multi-return in tail position passes through
love.graphics.setColor(darken_color({255, 255, 255}, 0.5))
-- darken_color returns (127, 127, 127, 255), setColor receives all 4
```
