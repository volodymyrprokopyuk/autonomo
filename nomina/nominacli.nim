import nominamodel, nominacalc, nominayaml, nominaview

var nominaEntrada: NominaEntrada
"nomina/nomina-entrada.yaml".load(nominaEntrada)
let nominaSalida = nominaEntrada.calcularNomina
nominaSalida.dump("nomina/nomina-salida.yaml")
render(nominaEntrada, nominaSalida, "nomina/nomina-document.html")
