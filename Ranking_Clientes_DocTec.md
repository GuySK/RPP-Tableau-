Proyecto Piloto de Tableau en Rosental S.A.
===

Tablero de Ranking de Clientes
---

### Objetivo

Se trata de realizar una tablero de ranking de clientes para los clientes del área de Mercado. Los datos provienen del sistema de gestión de las operaciones de mercado StockBroker (SB) desarrollado en Genexus y con bases de datos en SQL Server. El objetivo es probar la factibilidad de utilizar Tableau como herramienta de BI para todas las aplicaciones de la compañía.

### Descripción

Se debe confeccionar un tablero que muestre el ranking de clientes según dos aspectos: 

1. Ingresos por Comisiones
1. Assets under Management (internamente, Posición)

Los ingresos por comisiones son de 4 tipos diferentes.

1. Comisiones por Boletos
1. Coisiones por Mantenimiento de Cuenta
1. Comisiones por Dividendos
1. Comisiones por Nd y NC varias.

### Fuentes de datos

Para desarrollar el tablero se realizó la exportación de las bases de datos de testing del sistema SB a archivos de tipo csv. Una vez que el tablero estuvo creado y pre-testeado , estas fuentes de datos fueron reemplazadas por las DB de testing de SB para la prueba. Esto sirvió para testear la factibilidad de desarrollo en ambientes externos sin conexión.

Las tablas utilizadas en el proyecto fueron:

* OPER.                      Contiene datos de los boletos.
* PERSONAS.                  Contiene datos de las personas físicas relacionadas con los movimientos.
* DIVRA.                     Contiene la fecha de liquidación de dividendos.
* DIVRA4.                    Contiene información sobre las comisiones por dividendos.
* CUENTACORRIENTE.           Contiene movimientos de cuenta corriente.
* COMPMOV.                   Contiene información de comprobantes, entre ellos ND y NC
* OPERICO.                   Contiene la posición del cliente a una fecha determinada.

### Pre-proceso de datos (ETL)

Para la confección del tablero en base a las tablas exportadas en formato csv hubo que realizar las siguientes operaciones de transformación de datos.

1. Eliminación de las últimas 4 lineas de todos los archivos  (generado por la exportación)
1. Fill automático de registros con nro de separadores incorrectos (varios casos, múltiples archivos)
1. Transfromación de fechas a formato POSIX
1. Cambio del formato de punto decimal (de '.' a ',') (depende de la configuración local desktop)
1. Re-creación del campo PersApellido de la tabla PERSONAS para facilitar la inteligibilidad de las pruebas.



### Reglas de negocio

A continuación se detallan las reglas utilizadas para la generación del tablero.

#### Comisiones por Boletos

##### Fuentes de datos.
Se utilizan las tablas OPER y PERSONAS. Estas tablas se unen por el campo **ComiCodigo** que corresponde al número de Cuenta Comitente.

Existen una o más personas físicas por Cuenta Comitente. El porcentaje de participación en la Cuenta Comitente esta dado por el campo **PERSONAS.PersPorPar**.

##### Período de cálculo. 
Determinado por el campo **OPER.OperFecCon**.

##### Filtro. 
Se seleccionan los registros **OPER.OperFecAnul = 01/01/1753**. Todo registro con una fecha distinta a ésta corresponden a operaciones anuladas.

##### Cálculo. 
Se calcula como 

    SUMA[OPER.OperComiCMonto * (PERSONAS.PersPorPar / 100)] 

para cada persona identificada por **PERSONAS.PersApellido** y **PERSONAS.PersNumeroDoc**.

#### Comisiones por Dividendos

##### Fuentes de datos.
Se utilizan las tablas DIVRA, DIVRA4 y PERSONAS. 

DIVRA y DIVRA4 se unen por el campo **DRAID**. 

DIVRA y PERSONAS se unen por el campo **ComiCodigo** que corresponde al número de Cuenta Comitente. 

Existen una o más personas físicas por Cuenta Comitente. El porcentaje de participación en la Cuenta Comitente esta dado por el campo **PERSONAS.PersPorPar**.

##### Período de cálculo. 
Determinado por el campo **DIVRA.DRAFecPos**.

##### Filtro. 
Se seleccionan los registros **DIVRA4.TiCdId = 4** que corresponde a las comisiones.

##### Cálculo. 
Se calcula como 

    SUMA[DIVRA4.DivComMonto * (PERSONAS.PersPorPar / 100)] 

para cada persona identificada por **PERSONAS.PersApellido** y **PERSONAS.PersNumeroDoc**.

#### Comisiones por Mantenimiento de Cuenta

##### Fuentes de datos.
Se utilizan las tablas CUENTACORRIENTE y PERSONAS. 

CUENTACORRIENTE y PERSONAS se unen por el campo **ComiCodigo** que corresponde al número de Cuenta Comitente. 

Existen una o más personas físicas por Cuenta Comitente. El porcentaje de participación en la Cuenta Comitente esta dado por el campo **PERSONAS.PersPorPar**.

##### Período de cálculo. 
Determinado por el campo **CUENTACORRIENTE.CuCoFecConcertacion**.

##### Filtro. 
Se seleccionan los registros **CUENTACORRIENTE.CompId = 5** que corresponde a las comisiones por mantenimiento de cuenta.

##### Cálculo. 
Se calcula como 

    SUMA[CUENTACORRIENTE.CuCoImporte * (PERSONAS.PersPorPar / 100)] 

para cada persona identificada por **PERSONAS.PersApellido** y **PERSONAS.PersNumeroDoc**.

#### Comisiones por NC y ND

##### Fuentes de datos.
Se utilizan las tablas COMPMOV y PERSONAS. 

COMPMOV y PERSONAS se unen por el campo **ComiCodigo** que corresponde al número de Cuenta Comitente. 

Existen una o más personas físicas por Cuenta Comitente. El porcentaje de participación en la Cuenta Comitente esta dado por el campo **PERSONAS.PersPorPar**.

##### Período de cálculo. 
Determinado por el campo **COMPMOV.CompFecha**.

##### Filtro. 
Se seleccionan los registros con los siguientes criterios 

* **COMPMOV.CompId = 18**  que corresponde a Notas de Débito por comisiones.
* **COMPMOV.CompId = 19**  que corresponde a Notas de Crédito por comisiones.

##### Cálculo. 
Para los comprobantes correspondientes a ND se toma el importe del campo **COMPMOV.CompImporte**. Para los de NC se invierte el signo de este mismo campo.

    SUMA[(+/- 1) * COMPMOV.CompImporte * (PERSONAS.PersPorPar / 100)] 

para cada persona identificada por **PERSONAS.PersApellido** y **PERSONAS.PersNumeroDoc**.

#### Ranking de Clientes basado en AuM (Posición)

##### Fuentes de datos.
Se utilizan las tablas OPERICO y PERSONAS. 

OPERICO y PERSONAS se unen por el campo **ComiCodigo** que corresponde al número de Cuenta Comitente. 

Existen una o más personas físicas por Cuenta Comitente. El porcentaje de participación en la Cuenta Comitente esta dado por el campo **PERSONAS.PersPorPar**.

##### Período de cálculo. 
Determinado por el campo **OPERICO.ICoFecha**.

##### Filtro. 
Se toman todos los registros.

##### Cálculo. 
Se calcula como.

    SUMA[OPERICO.ICoPosGlb * (PERSONAS.PersPorPar / 100)] 

para cada persona identificada por **PERSONAS.PersApellido** y **PERSONAS.PersNumeroDoc**.

### Comentarios
No se tomaron en cuenta las ND y NC de movimientos en moneda extranjera.

Sólo se tomaron en cuentas las personas físicas.

