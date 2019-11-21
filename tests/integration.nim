# File used to test the libarary

import nap

# Register arguments

add_arg(name="a", kind="flag", help="Annotate a notation")
let boo = use_arg(name="boo", kind="flag", help="Scare for life")
add_arg(name="x", kind="value", required=false, help="Cut scissors")
let foo = use_arg(name="foo", kind="value", required=true, help="Fork the fork")
add_arg(name="path", kind="argument", required=true)
let tree = use_arg(name="tree", kind="argument", help="For the health", value="palmera")

# Process arguments

parse_args("My Program (v1.24)")

# Use the result

echo ""
print_help()
echo ""

let a = arg("a")
echo "a:"
echo a.used
echo ""

echo "boo:"
echo boo.used
echo ""

if foo.used:
  echo "foo:"
  echo foo.value
  echo ""

let x = arg("x")
if x.used:
  echo "x:"
  echo x.value
  echo ""

let path = arg("path")
if path.used:
  echo "path:"
  echo path.value
  echo ""

echo "tree:"
tree.value.add(" (modified)")
echo tree.value
echo ""

# Rest of 
# the arguments
echo "tail:"
echo argtail()
echo ""

echo "argval tests:"
echo argval_int("x", 22)
echo argval_float("x", 324.3)
echo argval_bool("x", false)
echo argval_string("x", "rainforest")

echo ""

print_version()

echo ""