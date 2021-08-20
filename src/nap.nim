import std/[os, parseopt, strformat, strutils]
import types, utils
export types

# Array that holds all the arguments
var opts: seq[NapArg]

# Return an argument object
proc get_arg*(name:string): NapArg =
  for opt in opts:
    if name == opt.name:
      return opt
    if name == opt.alt:
      return opt    

  return NapArg(name:"--undefined--")

# Return all argument objects
proc get_args*(): seq[NapArg] =
  return opts

# Rest of arguments
var tail: seq[string]

# Return the rest of  the arguments
proc get_argtail*(): seq[string] =
  return tail

# Holds the headers
var xheaders: seq[string]

# Holds the notes
var xnotes: seq[string]

# Holds examples
var xexamples: seq[Example]

# Used for argument checking
var num_arguments = 0
var num_required_arguments = 0

# Available kinds of arguments
let kinds = ["flag", "value", "argument"]

# Centralized termination echo
proc bye(message: string) =
  echo message
  quit(0)

# Register an argument to be considered
proc add_arg*(name="", kind="", required=false, help="", value="", alt="",
  multiple=false, values:openarray[string]=[]): NapArg {.discardable.} =
    var name = name.strip()
    var kind = kind.strip()
    var help = help.strip()

    if get_arg(name).name != "--undefined--":
      bye(&"'{name}' is already being used")
    
    if alt != "":
      if get_arg(alt).name != "--undefined--":
        bye(&"'{alt}' is already being used")

    if name == "":
      bye("Names can't be empty.")
      
    if kind == "":
      bye("Kind can't be empty.")

    if name.contains(" "):
      bye(&"'{name}' name can't have spaces.")

    if not kinds.contains(kind):
      bye(&"'{kind}' is not a valid kind.")
      
    if multiple and kind != "value":    
        bye(&"Only values can be set as multiple.")
    
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
    
    var aikind = ""

    if alt != "":
      if kind != "flag" and kind != "value":
        bye("Alts can only be set on flags and values.")

      if alt.contains(" "):
        bye(&"Alt '{name}' name can't have spaces.")
      
      if ikind == "lflag" and alt.len != 1:
        bye("Long flags can only have short flag alts.")
        
      if ikind == "sflag" and alt.len == 1:
        bye("Short flags can only have long flag alts.")
        
      if ikind == "lvalue" and alt.len != 1:
        bye("Long values can only have short value alts.")
        
      if ikind == "svalue" and alt.len != 1:
        bye("Short values can only have long value alts.")
        
      aikind = case ikind
      of "sflag": "lflag"
      of "lflag": "sflag"
      of "svalue": "lvalue"
      of "lvalue": "svalue"
      else: ""
    
    var vals = newSeq[string]()
    for val in values:
      vals.add(val)
  
    opts.add(NapArg(name:name, kind:kind, ikind:ikind, required:required, help:help, 
      value:value, used:false, alt:alt, aikind:aikind, multiple:multiple, values:vals, count:0))
    
    return get_arg(name)

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
      echo &"\n  {ex.title}:"
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
      echo &"\n  -{opt.name}{xalt(opt.alt)}{xrequired(opt.required)}"
      print(opt.help, "content")
    for opt in lflags:
      echo &"\n  --{opt.name}{xalt(opt.alt)}{xrequired(opt.required)}"
      print(opt.help, "content")

  # Print values
  if svalues.len() > 0 or lvalues.len() > 0:
    print("Values", "title")
    for opt in svalues:
      echo &"\n  -{opt.name}{xalt(opt.alt)}{xrequired(opt.required)}"
      print(opt.help, "content")
    for opt in lvalues:
      echo &"\n  --{opt.name}{xalt(opt.alt)}{xrequired(opt.required)}"
      print(opt.help, "content")
  
  # Print arguments
  if arguments.len() > 0:
    print("Arguments", "title")
    for opt in arguments:
      echo &"\n  {opt.name}{xrequired(opt.required)}"
      print(opt.help, "content")
  
  if xnotes.len > 0:
    print("Notes", "title")
    for note in xnotes:
      echo ""
      print(note, "content")
  
  echo ""

# Try to find a close enough arg
proc closest_arg(p:OptParser): (string, string) =
  var highest: NapArg
  var highest_n = 0.0

  for opt in opts:
    let n = string_similarity(p.key, opt.name)
    if n > highest_n:
      highest = opt
      highest_n = n
  
  if highest_n >= 0.7:
    return argstr_2(highest)
  
  return ("", "")

# Check if prefix is partially matched
# And there are no conflicts
# This is for flags and values
proc prefix_match(p:OptParser, opt:NapArg): (bool, string) =
  var lname = ""
  var sname = ""
  var lkind = ""
  var skind = ""

  if opt.ikind == "lflag" or
  opt.ikind == "lvalue":
    lname = opt.name
    lkind = opt.ikind
    sname = opt.alt
    skind = opt.aikind
  elif opt.alt != "":
    lname = opt.alt
    lkind = opt.aikind
    sname = opt.name
    skind = opt.ikind
  
  if p.kind == cmdShortOption:
    if p.key == sname:
      return (true, skind)
  
  else:
    if p.key == lname:
      return (true, lkind)
    
    let valid = lname.startsWith(p.key)
    if not valid: return (false, "")
    
    for o in opts:
      if o.name == opt.name:
        continue
      
      if o.used: continue

      if((o.ikind == "lflag" or o.ikind == "lvalue") and (o.name.startsWith(p.key))) or
      ((o.aikind == "lflag" or o.aikind == "lvalue") and (o.alt.startsWith(p.key))):
        if opt.required and not o.required:
          continue
        else: return (false, "")
    
    return (true, lkind)

# Check and update a supplied argument
proc update_arg(p: OptParser) =
  if p.kind == cmdArgument:
    if num_arguments <= 0:
      tail.add(p.key.strip())
      return

  for opt in opts.mitems:
    let pm = prefix_match(p, opt)
    if ( ( not opt.used or opt.kind == "flag" ) or opt.multiple ) and 
    ( opt.kind == "argument" or pm[0] ):

      # Do some checks

      let kind = pm[1]

      if p.kind == cmdShortOption:
        if kind != "sflag" and
          kind != "svalue":
            continue
      elif p.kind == cmdLongOption:
        if kind != "lflag" and
          kind != "lvalue":
            continue
      elif p.kind == cmdArgument:
        if opt.kind != "argument":
          continue
      
      # Update

      if p.kind == cmdArgument:
        opt.value = p.key.strip()
        dec(num_arguments)
      else:
        let v = p.val.strip()
        if v.len != 0:
          if opt.multiple:
            if not opt.used and opt.values.len > 0:
              opt.values.setLen(0)
            opt.values.add(v)
          else: opt.value = v
      
      opt.used = true
      inc(opt.count)
      return
    
  # If no match then exit
  var msg = ""
  let ax = argstr(p)
  let opt = get_arg(p.key)
  if opt.name == "--undefined--":
    msg = &"'{ax[0]}' is not a valid {ax[1]}."
    let closest = closest_arg(p)
    if closest[0] != "":
      msg.add(&" Maybe you meant {closest[0]} {closest[1]} ?")
  else:
    if opt.used: 
      msg = &"'{ax[0]}' was already used and is not set to multiple."
  bye(msg)

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
        if (opt.required and not opt.used) or 
          (not opt.multiple and opt.used and opt.value == "") or
          (opt.multiple and opt.used and opt.values.len == 0):
            echo &"'{argstr_2(opt)[0]}' needs a value."
            exit = true
    
    # Check for unecessary values
    elif opt.kind == "flag":
      if opt.value != "":
        echo &"'{argstr_2(opt)[0]}' does not accept a value."
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

# Adds a header
proc add_header*(header:string) =
  xheaders.add(header)

# Adds a note
proc add_note*(note:string) =
  xnotes.add(note)

# Adds an example
proc add_example*(title:string, content:string) =
  xexamples.add(Example(title:title, content:content))