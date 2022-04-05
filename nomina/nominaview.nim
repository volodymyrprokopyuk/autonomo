import std/os
import pkg/nimja/parser
import nominamodel

proc render*(ne: NominaEntrada, ns: NominaSalida): string =
  compileTemplateFile(getScriptDir() / "nomina-document.nwt")

proc render*(ne: NominaEntrada, ns: NominaSalida, file: string) =
  file.writeFile(render(ne, ns))
