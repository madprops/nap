# File used to test the libarary

import nap

# Add arguments
add_arg(name="a", kind="flag", help="Annotate a notation", alt="acorn")
let boo = add_arg(name="boo", kind="flag", help="Scare for life", alt="o")
add_arg(name="x", kind="value", required=false, help="Cut scissors")
let foo = add_arg(name="foo", kind="value", required=true, help="Fork the fork", alt="f")
let zoobar = add_arg(name="zoobar", kind="value", help="Fork the forkz", alt="b")
let zoob = add_arg(name="zoob", kind="value", help="Fork the forkerz", alt="B")
add_arg(name="path", kind="argument", help="Path to rain", required=true)
let tree = add_arg(name="tree", kind="argument", value="palmera")
let names = add_arg(name="names", kind="value", multiple=true, values=["jaja", "jojo"], alt="n")
var intie = add_arg(name="intie", kind="value", value="2")
var floatie = add_arg(name="floatie", kind="value", value="3.0")
add_arg(name="boolie", kind="value", value="true")
# add_arg(name="acorn", alt="z", kind="flag")

# Add examples
add_example(title="Make a directory", content="mkdir somedir\n#This will create a dir\n#It cooks the dinner")
add_example(title="Remove a directory", content="rmdir somedir\n#This will remove a dir\nrmdir -zx path\n#This eats burgers")
add_example(title="Show an item", content="show item -xyz")

# Add headers
add_header("MyProgram")
add_header("Version 1.3.5")

# Add Notes
add_note("Licensed under the FreeBeer public license")
add_note("Made with industrial boots by squirrels")

# Process arguments
parse_args()

# Use the result

print_help()
echo ""

let a = arg("a")
echo "a:"
echo a.used
echo ""

let ac = argalt("acorn")
echo "acorn:"
echo ac.used
echo ""

echo "boo:"
echo boo.used
echo boo.count
echo ""

if foo.used:
  echo "foo:"
  echo foo.value
  echo ""

if zoobar.used:
  echo "zoobar:"
  echo zoobar.value
  echo ""

if zoob.used:
  echo "zoob:"
  echo zoob.value
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

echo "arg parse tests:"
echo intie.getInt()
echo floatie.getFloat()
echo arg("boolie").getBool()
echo ""

echo "names:"
echo names.values
echo ""

print_header()

echo ""