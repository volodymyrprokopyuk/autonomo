import std/[streams, times]
import pkg/yaml/serialization
import nominamodel

proc constructObject(
  s: var YamlStream, c: ConstructionContext, o: var Slice[Time]) =
  if s.next.kind != yamlStartSeq:
    raise newException(YamlConstructionError, "Expected sequence start")
  var a, b: Time
  constructChild(s, c, a)
  constructChild(s, c, b)
  o = a..b
  if s.next.kind != yamlEndSeq:
    raise newException(YamlConstructionError, "Expected sequence end")

proc load*(file: string, ne: var NominaEntrada) =
  let s = file.newFileStream(fmRead)
  defer: s.close
  s.load(ne)

proc dump*(ns: NominaSalida, file: string) =
  let s = file.newFileStream(fmWrite)
  defer: s.close
  ns.dump(s)
