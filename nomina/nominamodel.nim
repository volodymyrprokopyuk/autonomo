import std/times

type
  Empresa* = object
    nombre*: string
    domicilio*: string
    cif*: string # Código de identificación fiscal (empresa o persona jurídica)
    ccc*: string # Código de cuenta de cotización

  Empleado* = object
    nombre*: string
    apellidos*: string
    domicilio*: string
    nif*: string # Númedo de identificación fiscal (persona física, DNI o NIE)
    nss*: string # Número de Seguridad Social
    categoriaProfesional*: string # Referido al puesto de trabajo
    grupoCotizacion*: string # Determina la base de cotización
    profesion*: string # Descripción del puesto de trabajo

  CondicionesSalariales* = object
    salarioBrutoAnual*: float # Según el contrato de trabajo
    numeroPagas*: int # Según el contrato de trabajot
    salarioBase*: float # Según el convenio colectivo correspondiente

  TipoCotizacion* = object
     empleado*: float
     empresa*: float

  CotizacionSS* = object # Régimen general de la SS
    baseCC*: float # Base de cotización por contingencias comunes
    baseCP*: float # Base de cotización por contingencias profesionales
    cc*: TipoCotizacion # Contingencias comunes
    desempleo*: TipoCotizacion
    fp*: TipoCotizacion # Formación profesional
    atyep*: TipoCotizacion # Accidente de trabajo, enfermedad profesional
    fogasa*: TipoCotizacion # Fondo de garantía salarial

  TiposRetencion* = object # Tipos de retención de la SS y la AT
    cotizacionSS*: CotizacionSS
    tipoIRPF*: float # Tipo IRPF en la AT

  NominaEntrada* = object
    empresa*: Empresa
    empleado*: Empleado
    periodoLiquidacion*: Slice[Time]
    condicionesSalariales*: CondicionesSalariales
    tiposRetencion*: TiposRetencion

  PercepcionSalarial* = object # Sujeta a cotización a la SS
    salarioBase*: float # Según el convenio colectivo correspondiente
    complementoSalarial*: float # Plus de convenio colectivo

  Devengos* = object # Remuneración percibida = salario bruto mensual
    totalDevengado*: float
    totalDevengadoP*: float

  Deduccion* = object
    base*: float
    tipo*: float
    importe*: float

  CotizacionEmpleado* = object
    # Enfermedad común, accidente no laboral, maternidad, paternidad, jubilación
    cc*: Deduccion # Contingencias comunes
    desempleo*: Deduccion # Derecho al paro* = seguro de trabajo
    fp*: Deduccion # Formacion profesional
    totalAportacion*: float
    totalAportacionP*: float

  RetencionIRPF* = object
    irpf*: Deduccion # Retención de IRPF

  Deducciones* = object # Cotización e impuestos
    cotizacionEmpleado*: CotizacionEmpleado
    retencionIRPF*: RetencionIRPF
    totalDeducir*: float
    totalDeducirP*: float

  AportacionEmpresa* = object # Apartado meramente informativo
    cc*: Deduccion # Contingencias comunes aportación de empresa
    atyep*: Deduccion # Accidente de trabajo, enfermedad profesional
    desempleo*: Deduccion # Seguro de trabajo aportación de empresa
    fp*: Deduccion # Formacion profesional aportación de empresa
    fogasa*: Deduccion # Fondo de garantía salarial
    totalAportacionEmpresa*: float
    totalAportacionEmpresaP*: float

  NominaSalida* = object
    tituloDocumento*: string
    diasLiquidacion*: int # Del período de liquidación
    percepcionSalarial*: PercepcionSalarial
    devengos*: Devengos
    deducciones*: Deducciones
    liquidoPercibir*: float # Salario neto abonado a la cuenta bancaria
    liquidoPercibirP*: float
    aportacionEmpresa*: AportacionEmpresa
