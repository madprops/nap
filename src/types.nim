import strutils

# Argument object
type NapArg* = ref object
  name*: string
  kind*: string
  ikind*: string
  required*: bool
  help*: string
  value*: string
  used*: bool
  alt*: string
  aikind*: string
  multiple*: bool 
  values*: seq[string]
  count*: int

proc getInt*(a:NapArg): int =
  return a.value.parseInt()
      
proc getFloat*(a:NapArg): float =
  return a.value.parseFloat()

proc getBool*(a:NapArg): bool =
  return a.value.parseBool()

# Example object
type Example* = ref object
  title*: string
  content*: string