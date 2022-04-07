import std/[strformat, os]
import pkg/nimja/parser
import nominamodel

func money(value: float): string = fmt "{value:.2f}"
let percent = money

proc render*(ne: NominaEntrada, ns: NominaSalida): string =
  compileTemplateFile(getScriptDir() / "nomina-document.nwt")

proc render*(ne: NominaEntrada, ns: NominaSalida, file: string) =
  file.writeFile(render(ne, ns))
