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

# Example object
type Example* = ref object
  title*: string
  content*: string