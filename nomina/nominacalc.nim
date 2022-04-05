import std/[times, math]
import nominamodel

let esLocale = DateTimeLocale(
  MMM: ["Ene", "Feb", "Mar", "Abr", "May", "Jun",
        "Jul", "Ago", "Sep", "Oct", "Nov", "Dec"],
  MMMM: ["Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio",
         "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"],
  ddd: ["Lun", "Mar", "Mie", "Jue", "Vie", "Sab", "Dom"],
  dddd: ["Luens", "Martes", "Miércoles", "Jueves", "Viernes",
         "Sábado", "Domingo"])

proc tituloDocumento(periodoLiquidacion: Slice[Time]): string =
  "Nómina " & periodoLiquidacion.a.local.format("MMM YYYY", esLocale)

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
