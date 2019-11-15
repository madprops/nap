# File used to test the libarary

import nap

# Register arguments

add_arg(name="a", kind="flag", help="Annotate a notation")
add_arg(name="boo", kind="flag", help="Scare for life")
add_arg(name="x", kind="value", required=false, help="Cut scissors")
add_arg(name="foo", kind="value", required=true, help="Fork the fork")
add_arg(name="path", kind="argument", required=true)
add_arg(name="tree", kind="argument", required=false, help="For the health")

# Process arguments

parse_args("My Program (v1.24)")

# Use the result

echo ""

let a = arg("a")
echo "a:"
echo a.used
echo ""

let boo = arg("boo")
echo "boo:"
echo boo.used
echo ""

let foo = arg("foo")
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

let tree = arg("tree")
if tree.used:
    echo "tree:"
    echo tree.value
    echo ""

# Rest of 
# the arguments
echo "tail:"
echo argtail()

echo ""