import std/[editdistance, strformat, strutils, parseopt, terminal, nre]
import types

# Find the similarity between two strings
# Closest to 1 is more similar
proc string_similarity*(s1:string, s2:string): float =
  var
    longer = s1
    shorter = s2

  if s1.len < s2.len:
    longer = s2
    shorter = s1
  
  if longer.len == 0:
    return 1.0
  
  return float(longer.len - editDistance(longer, shorter)) / float(longer.len)

# Different kinds of prints
proc print*(s:string, kind:string) =
  if s == "": return
  
  case kind
  of "header":
    echo &"{ansiStyleCode(styleBright)}{ansiForegroundColorCode(fgGreen)}{s.strip()}{ansiResetCode}"
  of "title":
    echo &"\n{ansiStyleCode(styleBright)}{ansiForegroundColorCode(fgBlue)}{s.strip()}:{ansiResetCode}"
  of "content":
    for line in s.splitLines:
      echo &"  {ansiForegroundColorCode(fgCyan)}{line.strip()}{ansiResetCode}"
  of "content2":
    echo &"   {ansiForegroundColorCode(fgCyan)}{s.strip()}{ansiResetCode}"
  of "comment":
    let s2 = s.replace(re"^#", "").strip()
    echo &"   {ansiStyleCode(styleItalic)}{s2}{ansiResetCode}"
  else: echo s

# Conditional required message in help
proc xrequired*(required: bool): string =
  if required: " (Required)" else: ""

# Conditional alt message in help
proc xalt*(alt:string): string =
  if alt != "":
    let dash = if alt.len > 1: "--" else: "-"
    return &" (or {dash}{alt})" 
  else: 
    return ""

# Util to change kinds to strings
proc argstr*(p: OptParser): (string, string) =
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
proc argstr_2*(p: NapArg): (string, string) =
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