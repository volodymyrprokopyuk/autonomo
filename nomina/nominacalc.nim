import std/[strformat, times, math]
import nominamodel

let esLocale = DateTimeLocale(
  MMM: ["ene", "feb", "mar", "abr", "may", "jun",
        "jul", "ago", "sep", "oct", "nov", "dec"],
  MMMM: ["enero", "febrero", "marzo", "abril", "mayo", "junio",
         "julio", "agosto", "septiembre", "octubre", "noviembre", "diciembre"],
  ddd: ["lun", "mar", "mie", "jue", "vie", "sab", "dom"],
  dddd: ["luens", "martes", "miércoles", "jueves", "viernes",
         "sábado", "domingo"])

proc tituloDocumento(periodoLiquidacion: Slice[Time]): string =
  let a = periodoLiquidacion.a.local.format("MMMM YYYY", esLocale)
  fmt "Nómina {a}"

proc periodoLiquidacionF(periodoLiquidacion: Slice[Time]): string =
  let
    timeFormat = "d' de 'MMMM' de 'YYYY"
    a = periodoLiquidacion.a.local.format(timeFormat, esLocale)
    b = periodoLiquidacion.b.local.format(timeFormat, esLocale)
  fmt "del {a} al {b}"

func diasLiquidacion(periodoLiquidacion: Slice[Time]): int =
  (periodoLiquidacion.b - periodoLiquidacion.a).inDays.int + 1

func percepcionSalarial(cs: CondicionesSalariales): PercepcionSalarial =
  let salarioBruto = (cs.salarioBrutoAnual / cs.numeroPagas.float).round(2)
  result.salarioBase = cs.salarioBase
  result.complementoSalarial = salarioBruto - cs.salarioBase

func totalDevengado(ps: PercepcionSalarial): float =
  ps.salarioBase + ps.complementoSalarial

func importeDeduccion(base, tipo: float): Deduccion =
  result.base = base
  result.tipo = tipo
  result.importe = (base * tipo / 100).round(2)

func totalAportacion(ce: CotizacionEmpleado): float =
  result = ce.cc.importe + ce.desempleo.importe + ce.fp.importe

func porcentaje(parte, todo: float): float =
  (parte / todo * 100).round(2)

func cotizacionEmpleado(css: CotizacionSS): CotizacionEmpleado =
  result.cc = importeDeduccion(css.baseCC, css.cc.empleado)
  result.desempleo = importeDeduccion(css.baseCC, css.desempleo.empleado)
  result.fp = importeDeduccion(css.baseCC, css.fp.empleado)
  result.totalAportacion = totalAportacion(result)

func retencionIRPF(dev: Devengos, tipoIRPF: float): RetencionIRPF =
  result.irpf = importeDeduccion(dev.totalDevengado, tipoIRPF)

func totalDeducir(ded: Deducciones): float =
  (ded.cotizacionEmpleado.totalAportacion +
    ded.retencionIRPF.irpf.importe).round(2)

func liquidoPercibir(dev: Devengos, ded: Deducciones): float =
  dev.totalDevengado - ded.totalDeducir

func totalAportacionEmpresa(ae: AportacionEmpresa): float =
  (ae.cc.importe + ae.atyep.importe + ae.desempleo.importe +
    ae.fp.importe + ae.fogasa.importe).round(2)

func aportacionEmpresa(css: CotizacionSS): AportacionEmpresa =
  result.cc = importeDeduccion(css.baseCC, css.cc.empresa)
  result.atyep = importeDeduccion(css.baseCP, css.atyep.empresa)
  result.desempleo = importeDeduccion(css.baseCP, css.desempleo.empresa)
  result.fp = importeDeduccion(css.baseCP, css.fp.empresa)
  result.fogasa = importeDeduccion(css.baseCP, css.fogasa.empresa)
  result.totalAportacionEmpresa = totalAportacionEmpresa(result)

proc calcularNomina*(ne: NominaEntrada): NominaSalida =
  result.tituloDocumento =
    tituloDocumento(ne.periodoLiquidacion)
  result.periodoLiquidacionF =
    periodoLiquidacionF(ne.periodoLiquidacion)
  result.diasLiquidacion =
    diasLiquidacion(ne.periodoLiquidacion)
  result.percepcionSalarial =
    percepcionSalarial(ne.condicionesSalariales)
  result.devengos.totalDevengado =
    totalDevengado(result.percepcionSalarial)
  let totalDevengado = result.devengos.totalDevengado
  result.devengos.totalDevengadoP = 100.00
  result.deducciones.cotizacionEmpleado =
    cotizacionEmpleado(ne.tiposRetencion.cotizacionSS)
  result.deducciones.cotizacionEmpleado.totalAportacionP =
    porcentaje(
      result.deducciones.cotizacionEmpleado.totalAportacion, totalDevengado)
  result.deducciones.retencionIRPF =
    retencionIRPF(result.devengos, ne.tiposRetencion.tipoIRPF)
  result.deducciones.totalDeducir =
    totalDeducir(result.deducciones)
  result.deducciones.totalDeducirP =
    porcentaje(result.deducciones.totalDeducir, totalDevengado)
  result.liquidoPercibir =
    liquidoPercibir(result.devengos, result.deducciones)
  result.liquidoPercibirP =
    porcentaje(result.liquidoPercibir, totalDevengado)
  result.aportacionEmpresa =
    aportacionEmpresa(ne.tiposRetencion.cotizacionSS)
  result.aportacionEmpresa.totalAportacionEmpresaP =
    porcentaje(result.aportacionEmpresa.totalAportacionEmpresa, totalDevengado)
