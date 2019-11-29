This is my implementation of an argument parser for nim.

There are already others in existence and being used but I needed one that would meet my requirements.

The way it's made makes it very easy to register and use arguments, while being flexible and letting
the user decide on how to use it.

## Example Usage

Register arguments:
```nim
add_arg(name="foo", kind="flag", help="Foo it")
add_arg(name="path", kind="argument", required=true, help="Pathfinder Dir")

# Adding a `-b` alt to the `--bar` value flag
# This will work with `--bar=x` and `-b=x`
add_arg(name="bar", kind="value", required=false, help="Heaps Alloy", alt="b")

# Same as add_arg but receives a reference
let c = use_arg(name="catnip" kind="value" value="cosmic")

# Make a value flag that accepts multiple values
# For instance myprogram --name=Joe --name=Bill
# Default values can be sent as a list
let name = use_arg(name="name", kind="value", multiple=true, values=["jaja", "jojo"], alt="n")

# Examples are shown at the top of --help. 
# Content is a string that can have multiple lines
# If a line starts with # it is treated as a comment
add_example(title="Cook the food", content="cook -mbv pizza\n#This makes the pizza\n#Very cool")

# Information at the top
add_header("MyProgram")
add_header("Version 1.2.3")

# Notes at the bottom
add_note("Licensed under the FreeBeer public license")
add_note("Made with industrial boots")
```

When ready start the argument parser.
```nim
parse_args()
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

# Iterate through the multiple --name values
for n in name:
  echo n

# This will either print "cosmic" 
# or a user submitted value
echo c.value
```

## Properties

`name (string):` The name of the argument. If the name is "bar" then it will be used as "--bar", if the name is "b" then it will be used as "-b". This means there's no need to specify if it's a short or long flag, as this is deduced automatically. In the case of arguments the name will be used in order. For instance if you register two arguments: "path" and "file", the first two arguments provided will fill those.

`kind (string):` Available kinds are "flag", "value", and "argument". Flags are "-a" and "--abc". Values are "-a=x" and "--abc=x". Arguments are any unflagged input "myprogram /some/path"

`required (bool):` Whether the value is required. This only affects "value" and "argument" since there's no point in making a flag that doesn't take value required.

`help (string):` The message shown for the argument when using --help

`value (string):` A default value that is set initially on the object. Defaults to an empty string.

`alt (string):` This is used to make alts in flag and values. For instance -a and --acorn.

`multiple (bool):` Whether a value flag should add provided values to the values list instead of the value property.

`values (seq[string]):` When multiple is true add values to this list. When adding an arg it is received as an openarray[string] so it's easy to send values like ["aa", "bb"].

### Automatic Properties

These are properties that are handled internally, but will still be available to the user.

`used (bool):` If the argument was used at all. For instance if "-b" was provided, used will be true.

`value (string):` The value it has when parsed. For instance in "--foo=200" foo.value = "200". The value will always be a string. You can use `val` as a shortcut.

`ikind (string):` This is used internally to differentiate between different kinds of flag and value kinds.

`aikind (string):` This is used internally to differentiate between different kinds of flag and value kinds in alts.

## Methods

`add_arg:` Register an argument to be considered.

`use_arg:` Same as add_arg but it returns the argument object.

`parse_args:` Do the processing. Optional parameters list can be sent, else it uses the default one.

`arg:` Get an argument object.

`args:` Get all argument objects.

`argtail:` Get the rest of the arguments.

`add_header:` Include a line that will appear at the top.

`add_note:` Include a line that will appear in the notes at the bottom.

`add_example:` Add an example to show in the help. Receives title and content. Content can have multiple lines.
If a line starts with # it is treated as a comment.

`print_help:` Prints the help.

`print_version:` Prints the version.

# Parsing

These functions take 2 arguments.

The first one is the name of the argument.

The second is the default value to use if it fails. 

It returns a value (not the default) if:

a) The argument was used

b) The value is not empty

c) The value can be parsed correctly

`argval_int:` Parse to int.

`argval_float:` Parse to float.

`argval_bool:` Parse to bool.

`argval_string:` Return value unchanged.

## Examples

```nim
# Either supplied age int or 30
let n = argval_int("age", 30)

# Either supplied country string or "Sealand"
let c = argval_string("country", "Sealand")
```

## Help

Using --help will show a summary of all available arguments, headers, examples, and notes.

## Version

Using --version will show all the headers.