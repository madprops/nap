import std/editdistance

proc string_similarity*(s1:string, s2:string): float =
  var longer = s1
  var shorter = s2

  if s1.len < s2.len:
    longer = s2
    shorter = s1
  
  if longer.len == 0:
    return 1.0
  
  return float(longer.len - editDistance(longer, shorter)) / float(longer.len)