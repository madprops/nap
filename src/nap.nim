import os
import parseopt
import strutils
import strformat
import terminal

# Argument object
type NapArg* = object
  name*: string
  kind*: string
  ikind*: string
  required*: bool
  help*: string
  value*: string
  used*: bool

# Used for argument checking
var num_arguments = 0
var num_required_arguments = 0

# Rest of arguments
var tail: seq[string]

# Array that holds all the arguments
var opts: seq[NapArg]

# Available kinds of arguments
var kinds = ["flag", "value", "argument"]

# Centralized termination echo
proc bye(message: string) =
  echo message
  quit(0)

# Register an argument to be considered
proc add_arg*(name:string="", kind:string="", required:bool=false, help:string="") =
  var name = name.strip()
  var kind = kind.strip()
  var help = help.strip()

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
    if name.len() == 1:
      ikind = "sflag"
    else:
      ikind = "lflag"
    
  elif kind == "value":
    if name.len() == 1:
      ikind = "svalue"
    else:
      ikind = "lvalue"
  
  elif kind == "argument":
      ikind = "argument"
      inc(num_arguments)
      if required:
        inc(num_required_arguments)
  
  opts.add(NapArg(name:name, kind:kind, ikind:ikind, 
    required:required, help:help, value:"", used:false))

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
      break

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
            echo &"'{opt.name}' needs a value."
            exit = true
    
    # Check for unecessary values
    elif opt.kind == "flag":
      if opt.value != "":
        echo &"'{opt.name}' does not accept a value."
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

# Print the supplied user defined version
proc print_version(version: string) =
  echo &"{ansiStyleCode(styleBright)}{ansiForegroundColorCode(fgGreen)}{version}{ansiResetCode}"

# Print all the arguments and the help strings
proc print_help(version: string) =
  echo ""
  print_version(version)
  echo ""

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
    echo &"{ansiStyleCode(styleBright)}{ansiForegroundColorCode(fgBlue)}",
      &"Flags:{ansiResetCode}\n"
    for opt in sflags:
        echo &"  -{opt.name}"
        echo &"  {ansiForegroundColorCode(fgCyan)}{opt.help}{ansiResetCode}\n"
    for opt in lflags:
        echo &"  --{opt.name}"
        echo &"  {ansiForegroundColorCode(fgCyan)}{opt.help}{ansiResetCode}\n"

  # Print values
  if svalues.len() > 0 or lvalues.len() > 0:
    echo &"{ansiStyleCode(styleBright)}{ansiForegroundColorCode(fgBlue)}",
      &"Values:{ansiResetCode}\n"
    for opt in svalues:
        echo &"  -{opt.name}"
        echo &"  {ansiForegroundColorCode(fgCyan)}{opt.help}{ansiResetCode}\n"
    for opt in lvalues:
        echo &"  --{opt.name}"
        echo &"  {ansiForegroundColorCode(fgCyan)}{opt.help}{ansiResetCode}\n"
  
  # Print arguments
  if arguments.len() > 0:
    echo &"{ansiStyleCode(styleBright)}{ansiForegroundColorCode(fgBlue)}",
      &"Arguments:{ansiResetCode}\n"
    for opt in arguments:
        echo &"  {opt.name}"
        echo &"  {ansiForegroundColorCode(fgCyan)}{opt.help}{ansiResetCode}\n"
    
# Parse the arguments
# Accepts a version string
# and an optional list of params
proc parse_args*(version="No version information.", 
  params:seq[TaintedString]=commandLineParams(), ) =

  if params.contains("--version"):
    print_version(version)
    quit(0)
  elif params.contains("--help"):
    print_help(version)
    quit(0)

  var p = initOptParser(params)
  
  while true:
    p.next()
    if p.kind == cmdEnd: 
      break
    else: 
      update_arg(p)
  
  check_args()

# Return an argument object
proc arg*(key:string): NapArg =
  for opt in opts:
    if key == opt.name:
      return opt

proc argtail*(): seq[string] =
  return tail