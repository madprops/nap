This is my implementation of an argument parser for nim.

There are already others in existence and being used but I needed one that would meet my requirements.

The way it's made makes it very easy to register and use arguments, while being flexible and letting
the user decide on how to use it.

## Example Usage

Register arguments:
>add_arg(name="foo", kind="flag", required="true", help="Foo it")

>add_arg(name="bar", kind="value", required="false", help="Heaps Alloy")

>add_arg(name="path", kind="argument", required="true", help="Pathfinder Dir")

When ready then check arguments:
>parse_args("MyProgram (version 1.2.3)")

Now it's ready to use:
```
let foo = arg("foo")
echo foo.used

let bar = arg("bar")
if bar.used:
   echo bar.value

let path = arg("path")
   echo path.value
```

## Properties

`name:` The name of the argument. If the name is "bar" then it will be used as "--bar", if the name is "b" then it will be used as "-b". This means there's no need to specify if it's a short or long flag, as this is deduced automatically. In the case of arguments the name will be used in order. For instance if you register two arguments: "path" and "file", the first two arguments provided will fill those.

`kind:` Available kinds are "flag", "value", and "argument". Flags are "-a" and "--abc". Values are "-a=x" and "--abc=x". Arguments are any unflagged input "myprogram /some/path"

`required:` Whether the value is required. This only affects "value" and "argument" since there's no point in making a flag that doesn't take value required.

`help:` The message shown for the argument when using --help

### Automatic Properties

These are properties that are handled internally. But will still be available for the user.

`used:` If the argument was used at all.

`value:` The value it has when parsed. For instance in "--foo=200" foo.value = "200". The value will always be a string.

`ikind:` This is used internally to differentiate between different kinds of flag and value kinds.

## Parsing

There is no automatic type parsing of the string values. This is left to the user to handle.

## Help

Using --help will show a summary of all available arguments. As well as print the version at the top.

## Version

Using --version will show a string that is left to the user to define completely. This is defined when
using `parse_args`, for instance `parse_args("My Program (version 1.2.3)"). If no version is provided
then it will use a default "No version information." string. So it's advised to always fill this.