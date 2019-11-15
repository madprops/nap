This is my implementation of an argument parser for nim.

There are already others in existence and being used but I needed one that would meet my requirements.

The way it's made makes it very easy to register and use arguments, while being flexible and letting
the user decide on how to use it.

## Example Usage

Register arguments:
```nim
add_arg(name="foo", kind="flag", help="Foo it")

add_arg(name="bar", kind="value", required=false, help="Heaps Alloy")

add_arg(name="path", kind="argument", required=true, help="Pathfinder Dir")
```

When ready then check arguments:
```nim
parse_args("MyProgram (version 1.2.3)")
```

Now it's ready to use:
```nim
let foo = arg("foo")
echo foo.used

let bar = arg("bar")
if bar.used:
   echo bar.value

# Read parsing section below
# to see what this does
let path = argval_string("path", "/home/me/code")

# Rest of the arguments
let tail = argtail()
for argument in tail:
    echo argument
```

## Properties

`name (string):` The name of the argument. If the name is "bar" then it will be used as "--bar", if the name is "b" then it will be used as "-b". This means there's no need to specify if it's a short or long flag, as this is deduced automatically. In the case of arguments the name will be used in order. For instance if you register two arguments: "path" and "file", the first two arguments provided will fill those.

`kind (string):` Available kinds are "flag", "value", and "argument". Flags are "-a" and "--abc". Values are "-a=x" and "--abc=x". Arguments are any unflagged input "myprogram /some/path"

`required (bool):` Whether the value is required. This only affects "value" and "argument" since there's no point in making a flag that doesn't take value required.

`help (string):` The message shown for the argument when using --help

### Automatic Properties

These are properties that are handled internally, but will still be available to the user.

`used (bool):` If the argument was used at all. For instance if "-b" was provided, used will be true.

`value (string):` The value it has when parsed. For instance in "--foo=200" foo.value = "200". The value will always be a string.

`ikind (string):` This is used internally to differentiate between different kinds of flag and value kinds.

## Methods

`add_arg:` Register an argument to be considered.

`parse_args:` Do the processing. Optional version/info string and parameters list.

`arg:` Get an argument object.

`args:` Get all argument objects.

`argtail:` Get the rest of the arguments.

# Parsing

These functions take 2 arguments, the first one is the name of the argument,
the second is the default value to use if it fails. It returns a value (not the default)
if a) the argument was used and b) the value can be parsed correctly.

`argval_int:` Parse to int

`argval_float:` Parse to float

`argval_bool:` Parse to bool

`argval_string:` Return value unchanged

## Help

Using --help will show a summary of all available arguments. As well as print the version at the top.

## Version

Using --version will show a string that is left to the user to define completely. This is defined when
using `parse_args`, for instance `parse_args("My Program (version 1.2.3)"). If no version is provided
then it will use a default "No version information." string. So it's advised to always fill this.