import std/times

type
  Empresa = object
    nombre: string
    domicilio: string
    cif: string # Código de identificación fiscal (empresa o persona jurídica)
    ccc: string # Código de cuenta de cotización

  Empleado = object
    nombre: string
    apellidos: string
    domicilio: string
    nif: string # Númedo de identificación fiscal (persona física, DNI o NIE)
    nss: string # Número de Seguridad Social
    categoriaProfesional: string # Referido al puesto de trabajo
    grupoCotizacion: string # Determina la base de cotización
    profesion: string # Descripción del puesto de trabajo

  PercepcionSalarial = object # Sujeta a cotización a la SS
    salarioBase: float # Según el convenio colectivo correspondiente
    complementoSalarial: float # Plus de convenio colectivo

  NominaEntrada = object
    empresa: Empresa
    empleado: Empleado
    priodoLiquidacion: Slice[Time]
    percepcionSalarial: PercepcionSalarial

  Devengos = object # Remuneración percibida = salario bruto mensual
    percepcionSalarial: PercepcionSalarial
    totalDevengado: float

  Deduccion = object
    concepto: string
    base: float
    tipo: float
    importe: float

  CotizacionSS = object
    baseCC: float # Base de cotización por contingencias comunes
    # Enfermedad común, accidente no laboral, maternidad, paternidad, jubilación
    cc: Deduccion # Contingencias comunes
    desempleo: Deduccion # Derecho al paro = seguro de trabajo
    fp: Deduccion # Formacion profesional
    totalAportacion: float

  RetencionIRPF = object
    baseIRPF: float # Base sujeta a la retención de IRPF
    irpf: Deduccion # Retención de IRPF

  Deducciones = object # Cotización e impuestos
    cotizacionSS: CotizacionSS
    retencionIRPF: RetencionIRPF
    totalDeducir: float

  AportacionEmpresa = object # Apartado meramente informativo
    baseCC: float # Base de cotización por contingencias comunes
    cc: Deduccion # Contingencias comunes aportación de empresa
    baseCP: float # Base de cotización por contingencias profesionales
    aTyEP: Deduccion # Accidente de trabajo, enfermedad profesional
    desempleo: Deduccion # Seguro de trabajo aportación de empresa
    fp: Deduccion # Formacion profesional aportación de empresa
    fOGASA: Deduccion # Fondo de garantía salarial
    totalAportacionEmpresa: float

  NominaSalida = object
    nominaEntrada: NominaEntrada
    diasNaturales: int # Del período de liquidación
    devengos: Devengos
    deducciones: Deducciones
    liquidoPercibir: float # Salario neto abonado a la cuenta bancaria
    aportaciónEmpresa: AportacionEmpresa

  TipoCotizacion = object
     concepto: string
     empleado: float
     empresa: float

  TiposCotizacionSS = object # Régimen general de la SS
    cc: TipoCotizacion # Contingencias comunes
    desempleo: TipoCotizacion
    fp: TipoCotizacion # Formación profesional
    aTyEP: TipoCotizacion # Accidente de trabajo, enfermedad profesional
    fOGASA: TipoCotizacion # Fondo de garantía salarial

  TipoIRPF = object # Tipo IRPF en la AT
    irpf: float
