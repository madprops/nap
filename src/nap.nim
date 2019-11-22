import os
import nre
import parseopt
import strutils
import strformat
import terminal

# Argument object
type NapArg* = ref object
  name*: string
  kind*: string
  ikind*: string
  required*: bool
  help*: string
  value*: string
  used*: bool

method val*(this:NapArg): string =
  return this.value

# Example object
type Example = ref object
  title: string
  content: string

# Holds the headers
var xheaders: seq[string]

# Holds the notes
var xnotes: seq[string]

# Holds examples
var xexamples: seq[Example]

# Used for argument checking
var num_arguments = 0
var num_required_arguments = 0

# Rest of arguments
var tail: seq[string]

# Array that holds all the arguments
var opts: seq[NapArg]

# Available kinds of arguments
let kinds = ["flag", "value", "argument"]

# Centralized termination echo
proc bye(message: string) =
  echo message
  quit(0)

# Return an argument object
proc arg*(key:string): NapArg =
  for opt in opts:
    if key == opt.name:
      return opt
  return NapArg(name:"--undefined--")

# Return all argument objects
proc args*(): seq[NapArg] =
  return opts

# Register an argument to be considered
proc add_arg*(name="", kind="", required=false, help="", value="") =
  var name = name.strip()
  var kind = kind.strip()
  var help = help.strip()

  if arg(name).name != "--undefined--":
    bye(&"{name} argument can't be registered twice.")

  if name == "":
    bye("Argument's name can't be empty.")
    
  if kind == "":
    bye("Argument's kind can't be empty.")

  if name.contains(" "):
    bye(&"'{name}' argument name can't have spaces.")

  if not kinds.contains(kind):
    bye(&"{kind} is not a valid argument type.")

  # Get the internal kind 
  # s=short l=long
  var ikind: string
    
  if kind == "flag":
    ikind = if name.len() == 1: "sflag"
      else: "lflag"
    
  elif kind == "value":
    ikind = if name.len() == 1: "svalue"
      else: "lvalue"

  elif kind == "argument":
      ikind = "argument"
      inc(num_arguments)
      if required:
        inc(num_required_arguments)
  
  opts.add(NapArg(name:name, kind:kind, ikind:ikind, 
    required:required, help:help, value:value, used:false))

# Same as add_arg but returns a reference to the argument object
proc use_arg*(name="", kind="", required=false, help="", value=""): NapArg =
  add_arg(name, kind, required, help, value)
  arg(name.strip())

# Util to change kinds to strings
proc argstr(p: OptParser): (string, string) =
  if p.kind == cmdShortOption:
    if p.val == "":
      return (&"-{p.key}", "flag")
    else:
      return (&"-{p.key}", "value flag")
  elif p.kind == cmdLongOption:
    if p.val == "":
      return (&"--{p.key}", "flag")
    else:
      return (&"--{p.key}", "value flag")
  else:
    return (p.key, "argument")
        
# Util to change kinds to strings
proc argstr2(p: NapArg): (string, string) =
  if p.kind == "flag":
    if p.ikind == "sflag":
      return (&"-{p.name}", "flag")
    elif p.ikind == "lflag":
      return (&"--{p.name}", "flag")
  elif p.kind == "value":
    if p.ikind == "svalue":
      return (&"-{p.name}", "value flag")
    elif p.ikind == "lvalue":
      return (&"--{p.name}", "value flag")
  else:
    return (p.name, "argument")

# Some util functions for printing

proc print(s:string, kind:string) =
  case kind
  of "header":
    echo &"{ansiStyleCode(styleBright)}{ansiForegroundColorCode(fgGreen)}{s.strip()}{ansiResetCode}"
  of "title":
    echo &"\n{ansiStyleCode(styleBright)}{ansiForegroundColorCode(fgBlue)}{s.strip()}:{ansiResetCode}\n"
  of "content":
    for line in s.splitLines:
      echo &"  {ansiForegroundColorCode(fgCyan)}{line.strip()}{ansiResetCode}"
  of "content2":
    echo &"   {ansiForegroundColorCode(fgCyan)}{s.strip()}{ansiResetCode}"
  of "comment":
    let s2 = s.replace(re"^#", "").strip()
    echo &"   {ansiStyleCode(styleItalic)}{s2}{ansiResetCode}"
  else: echo s

proc rs(required: bool): string =
  if required: " (Required)" else: ""

proc hs(help: string): string =
  if help != "": help else: "I don't know what this does"

# Prints header items
proc print_header*() =
  for header in xheaders:
    print(header, "header")

# Prints all available information
proc print_help*() =
  echo ""
  print_header()

  # Print examples
  if xexamples.len > 0:
    print("Examples", "title")
    var i = 0
    for ex in xexamples:
      if i > 0:
        echo &"\n  {ex.title}:"
      else: 
        echo &"  {ex.title}:"
      inc(i)
      for line in ex.content.splitLines:
        if line.startsWith("#"):
          print(line, "comment")
        else: 
          print(line, "content2")

  if opts.len() == 0:
    echo "\n(No arguments registered)\n"
    quit(0)
  
  # Fill seqs with each kind

  var sflags: seq[NapArg]
  var lflags: seq[NapArg]
  var svalues: seq[NapArg]
  var lvalues: seq[NapArg]
  var arguments: seq[NapArg]

  for opt in opts:
    case opt.ikind
    of "sflag":
        sflags.add(opt)
    of "lflag":
        lflags.add(opt)
    of "svalue":
        svalues.add(opt)
    of "lvalue":
        lvalues.add(opt)
    of "argument":
      arguments.add(opt)
  
  # Print flags
  if sflags.len() > 0 or lflags.len() > 0:
    print("Flags", "title")
    for opt in sflags:
      echo &"  -{opt.name}{rs(opt.required)}"
      print(hs(opt.help), "content")
    for opt in lflags:
      echo &"  --{opt.name}{rs(opt.required)}"
      print(hs(opt.help), "content")

  # Print values
  if svalues.len() > 0 or lvalues.len() > 0:
    print("Values", "title")
    for opt in svalues:
      echo &"  -{opt.name}{rs(opt.required)}"
      print(hs(opt.help), "content")
    for opt in lvalues:
      echo &"  --{opt.name}{rs(opt.required)}"
      print(hs(opt.help), "content")
  
  # Print arguments
  if arguments.len() > 0:
    print("Arguments", "title")
    for opt in arguments:
      echo &"  {opt.name}{rs(opt.required)}"
      print(hs(opt.help), "content")
  
  if xnotes.len > 0:
    print("Notes", "title")
    for note in xnotes:
      print(note, "content")
  
  echo ""

# Check and update a supplied argument
proc update_arg(p: OptParser) =
  if p.kind == cmdArgument:
    if num_arguments <= 0:
      tail.add(p.key.strip())
      return

  for opt in opts.mitems:
    if not opt.used and (opt.kind == "argument" or
      p.key == opt.name):

      # Do some checks

      if p.kind == cmdShortOption:
        if opt.ikind != "sflag" and
          opt.ikind != "svalue":
            continue
      elif p.kind == cmdLongOption:
        if opt.ikind != "lflag" and
          opt.ikind != "lvalue":
            continue
      elif p.kind == cmdArgument:
        if opt.kind != "argument":
          continue
      
      # Update

      opt.used = true

      if p.kind == cmdArgument:
        opt.value = p.key.strip()
        dec(num_arguments)
      else:
        opt.value = p.val.strip()
      return
    
  # If no match then exit
  let ax = argstr(p)
  bye(&"'{ax[0]}' is not a valid {ax[1]}.")

# Check for missing or
# unecessary values or
# missing arguments
proc check_args() =
  var exit = false
  var nargs = 0
  for opt in opts:

    if opt.kind == "argument":
      if opt.used: inc(nargs)

    # Check for required values
    if opt.kind == "value":
        if (opt.used and opt.value == "") or
          (opt.required and not opt.used):
            echo &"'{argstr2(opt)[0]}' needs a value."
            exit = true
    
    # Check for unecessary values
    elif opt.kind == "flag":
      if opt.value != "":
        echo &"'{argstr2(opt)[0]}' does not accept a value."
        exit = true
  
  if num_required_arguments > nargs:
    var n = num_required_arguments
    for opt in opts:
      if opt.kind == "argument":
        if not opt.used and n > 0:
          echo &"'{opt.name}' argument is required."
          dec(n)
    exit = true
      
  if exit: quit(0)
    
# Parse the arguments
# and an optional list of params
proc parse_args*(params:seq[TaintedString]=commandLineParams()) =
  if params.contains("--version"):
    print_header()
    quit(0)
  elif params.contains("--help"):
    print_help()
    quit(0)

  var p = initOptParser(params)
  
  while true:
    p.next()
    if p.kind == cmdEnd: 
      break
    else: 
      update_arg(p)
  
  check_args()

# Return the rest of  the arguments
proc argtail*(): seq[string] =
  return tail

# Used to check if argvals have a value
proc argval_check(o:NapArg): bool =
  return o.used and o.value != ""

# Return argument's value if used
# if not used then return default
# if it fails to parse to int return default
proc argval_int*(key:string, default:int): int =
  let o = arg(key)
  if argval_check(o):
    try:
      return parseInt(o.value)
    except: discard
  return default

# Return argument's value if used
# if not used then return default
# if it fails to parse to float return default
proc argval_float*(key:string, default:float): float =
  let o = arg(key)
  if argval_check(o):
    try:
      return parseFloat(o.value)
    except: discard
  return default

# Return argument's value if used
# if not used then return default
# if it fails to parse to bool return default
proc argval_bool*(key:string, default:bool): bool =
  let o = arg(key)
  if argval_check(o):
    try:
      return parseBool(o.value)
    except: discard
  return default

# Return argument's value if used
# if not used then return default
proc argval_string*(key:string, default:string): string =
  let o = arg(key)
  if argval_check(o): o.value else: default

# Adds a header
proc add_header*(header:string) =
  xheaders.add(header)

# Adds a note
proc add_note*(note:string) =
  xnotes.add(note)

# Adds an example
proc add_example*(title:string, content:string) =
  xexamples.add(Example(title:title, content:content))