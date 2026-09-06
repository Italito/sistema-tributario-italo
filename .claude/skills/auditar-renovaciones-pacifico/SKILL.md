---
name: auditar-renovaciones-pacifico
description: "Audita el entregable del Benchmark de Renovaciones de Pacífico Vehicular - el archivo que devuelve el procesamiento interno o el que Be Quarks va a enviar al cliente. Nueve chequeos en orden fijo antes de opinar nada."
---

# Auditar el entregable de Renovaciones - Pacífico Vehicular

Se dispara cuando aparece un archivo del Benchmark de Renovaciones: el que devuelve el procesamiento interno, el que se va a adjuntar al correo, o uno ya enviado que hay que revisar.

**Regla de la skill: los nueve chequeos se corren SIEMPRE, en este orden, antes de mirar cualquier otra cosa.** No se improvisa qué revisar. Los primeros cinco deciden si el archivo sirve, y si el 1 falla, todo lo demás se estaría midiendo sobre un listado que no correspondía.

Renovaciones no es Autos Regular ni SOAT. Comparte cuenta y contacto, pero tiene base propia, columnas propias y una unidad de conteo propia. Los formatos de esas otras dos líneas están en la skill `auditar-scraping-pacifico` y no se mezclan con estos.

## Estado del servicio - leer antes de auditar

El 27/08/2026 Pacífico comunicó la **suspensión del servicio de Renovaciones de Autos (Tarifario Renovaciones)**. La causa declarada por el cliente: Legal y Cumplimiento identificaron riesgos por el uso de información de clientes Pacífico para cotizar con otras aseguradoras. El último servicio es el archivo entregado el **05/08/2026, Listado 11-2026**, que se recibe en agosto y se factura en septiembre. Italo formalizó la aceptación de la suspensión el mismo 27/08.

Fuente: correo de Gabriela Matto Arias (Data Governance Expert, Pacífico) del 27/08/2026, y respuesta de Italo del mismo día.

Esto no invalida la skill. Significa dos cosas:
- Si aparece un archivo de Renovaciones **posterior** al 11-2026, lo primero que se dice es que el servicio está suspendido y se pregunta de dónde salió, antes de auditar nada.
- El chequeo 4 dejó de ser un control de forma y pasó a ser el centro del asunto. Léelo con eso en mente.

## Paso 0 - La ficha del encargo

Antes de auditar hay que saber qué se pidió. Si no existe la ficha, se pregunta y no se avanza a ciegas.

| Dato | Ejemplo verificado (Listado 11-2026) |
|---|---|
| Base recibida y de quién | Base del Listado 11-2026, correo de Christian Andía, 15/07/2026 |
| Vehículos con datos en la base | 1,774 (el archivo llegaba hasta la fila 5,529) |
| Correlativos | Del 1 al 5,160, salteados y sin duplicados |
| Aseguradoras a relevar | Rímac, Mapfre, La Positiva |
| Perfiles esperados | 1,774 × 3 = 5,322 |
| Nombre de archivo pedido | `Bench Renovaciones 11-2026.xlsx` |
| Fecha de entrega | Lunes 17/08/2026 |

La ficha sale del correo con que Italo pasa la base a procesamiento. Si no se escribió, hay que reconstruirla de ese correo y decir de dónde salió.

**El contrato firmado en julio 2026 incorpora Interseguro como cuarta aseguradora** (116,000 observaciones/mes sobre 4 aseguradoras). El Listado 11-2026 se corrió con tres. Antes de dar por incompleto un archivo por falta de Interseguro, verificar contra la ficha del encargo qué se pidió ese mes.

## Los nueve chequeos

### 1. ¿Se trabajó sobre el listado correcto?

Comparar la columna `CORRELATIVO` del archivo devuelto contra la base recibida de Pacífico, **valor por valor**, no solo por cantidad.

Los correlativos vienen salteados: en el Listado 11-2026 iban del 1 al 5,160 para 1,774 vehículos. Que el máximo sea 5,160 y haya 1,774 vehículos no es un error, es cómo llega la base. Lo que sí es error es un correlativo del archivo que no exista en la base, o un correlativo duplicado.

Reportar: cuántos de los N correlativos de la base aparecen en el archivo, cuántos sobran y cuántos faltan.

Si el archivo corresponde a otro listado, se detiene la auditoría de contenido.

### 2. ¿Está el universo completo?

Este es el cambio que Italo instaló a partir del Listado 11-2026 y que conviene no perder: **no se elimina ninguna fila**. Antes se entregaban solo las cotizaciones exitosas y el resto se borraba. Ahora cada vehículo tiene una fila por aseguradora, **cotice o no**.

El control es una multiplicación: vehículos × aseguradoras = perfiles únicos exactos. En el 11-2026, 1,774 × 3 = 5,322. Si el número no es ese, hay algo mal y se dice antes de seguir.

Ojo con la trampa de conteo: **5,322 perfiles no son 5,322 filas**. El archivo del 11-2026 tenía 9,488 filas físicas, porque cada cotización exitosa abre una fila por cada plan ofrecido. Los 2,494 perfiles cotizados se abrieron en 6,660 filas; los 2,828 no cotizados mantuvieron una fila cada uno. 6,660 + 2,828 = 9,488.

**Pacífico nunca se releva.** Es el cliente. Si aparece como aseguradora, es un desvío.

Nombres normalizados exactos: **Rímac** (con tilde), **Mapfre**, **La Positiva** (con espacio), **Interseguro**.

### 3. ¿Están las 30 columnas, con el nombre exacto y en el orden exacto?

Orden verificado contra el entregable real `Bench_Renovaciones_11-2026.xlsx`, hoja `Detalle Renovaciones 11-2026`:

`CORRELATIVO` · `DNI` · `USO` · `FECHA DE NACIMIENTO` · `DEPARTAMENTO` · `PROVINCIA` · `DISTRITO` · `VEHÍCULO MARCA` · `VEHÍCULO MODELO` · `AÑO FABRICACION` · `TIPO DE VEHICULO` · `GAS` · `ES 0KM` · `GPS` · `NOMBRE ASEGURADORA` · `DIA COTIZACIÓN` · `MES COTIZACIÓN` · `AÑO COTIZACIÓN` · `FECHA COTIZACIÓN` · `SUMA ASEGURADA` · `PRECIO MENSUAL` · `PRECIO MENSUAL CON DESCUENTO` · `PRECIO MENSUAL FINAL` · `PRECIO ANUAL` · `TASA BRUTA` · `TASA NETA` · `PLAN` · `PODRÍA CAMBIAR EL MONTO ASEGURADO?` · `ESTADO` · `Link Captura`

Detalles que se pasan por alto y hay que mirar:
- Es `VEHÍCULO MARCA` y `VEHÍCULO MODELO`, no `MARCA` y `MODELO` como en Autos Regular.
- Es `FECHA DE NACIMIENTO`, no `FEC_NAC_ASEGURADO`.
- Es `Link Captura` en minúsculas mezcladas, no `LINK CAPTURA`.
- `PODRÍA CAMBIAR EL MONTO ASEGURADO?` lleva el signo de interrogación de cierre y no existe en las otras líneas.

**La columna `PLAN` va siempre.** Es la que permite leer el archivo, porque las filas de un mismo perfil se distinguen solo por el plan.

**El nombre del archivo y el de la hoja son parte del entregable.** El pedido del 11-2026 era `Bench Renovaciones 11-2026.xlsx`; el archivo recibido del procesamiento llegó como `06-2026 Bench Renovaciones.xlsx`. La hoja no debe conservar nombres técnicos del proceso.

### 4. ¿Hay datos personales que no deben salir?

Este chequeo dejó de ser rutinario. **El entregable del Listado 11-2026 lleva `DNI` y `FECHA DE NACIMIENTO` en claro**, verificado en el archivo. Y el motivo que Pacífico dio para suspender el servicio fue el uso de información de clientes; en la comunicación previa del 07/08/2026, Alejandro Rollandi lo nombró así: *"Legales y data nos bloquearon el archivo de renovación pq se comparten datos sensibles (dni y placa)"*.

Lo que corresponde hacer con eso:

- **Declarar siempre** si `DNI` está presente y en cuántas filas, sin adjetivos y sin decidir nada.
- **No presentarlo como incumplimiento de una regla interna**, porque a diferencia de Autos Regular no hay una instrucción escrita de Be Quarks que prohíba el DNI en este producto. Lo que hay es un cliente que suspendió el servicio por esto.
- **No proponer borrar la columna por cuenta propia.** El seguimiento del archivo va por `CORRELATIVO`, pero quitar el DNI cambia lo que el cliente pidió y esa decisión no es de la auditoría.
- Marco legal aplicable: Ley N.° 29733 de protección de datos personales y su reglamento D.S. 016-2024-JUS, principio de minimización. Se cita, no se sentencia.

Todo lo demás que no esté en las 30 columnas sobra: placa, número de documento distinto del DNI, número de serie, celular, correo, y la columna `VALORES DE ENTRADA`.

### 5. ¿Hay correlativo y enlace de captura en el 100% de las filas?

Sin `CORRELATIVO` no hay trazabilidad ni unidad de facturación. Sin `Link Captura` no se puede comprobar ningún precio.

El enlace va también en las filas que no cotizaron, no solo en las exitosas. En el 11-2026 se verificó que las filas con `Modelo de vehículo no encontrado` y `Error de plataforma` sí traían enlace.

**Enlace presente no es captura válida.** En el 11-2026 Camila reportó registros marcados `Exitoso` cuyo enlace abría una captura en blanco, y la auditoría encontró además un enlace incompleto. Si el archivo se va a enviar, hay que decir que ese conteo está pendiente de resolver, y decirlo aunque el 100% de las filas tenga algo en la columna.

Los enlaces apuntan a `https://pacifico-analytics.bequarks.pe/bench/Screenshot/<id>`. Un enlace que no siga esa forma se cuenta aparte.

### 6. Cobertura, y dónde se cae

**Se cuenta sobre perfiles únicos, o sea vehículo por aseguradora. Nunca filas.** Este es el error más fácil de cometer en este producto y el más caro, porque infla el resultado.

El cuadro que sale del procesamiento suele mezclar unidades: la fila `Exitoso` cuenta planes mientras las filas de no cotización cuentan perfiles. Sumadas dan un total que no significa nada. El cuadro correcto tiene como denominador los perfiles ofrecidos.

Cobertura verificada del Listado 11-2026, sobre 5,322 perfiles:

| Estado | La Positiva | Mapfre | Rímac | Total |
|---|---|---|---|---|
| Cotizado | 1,103 | 603 | 788 | 2,494 |
| Modelo de vehículo no encontrado | 577 | 1,161 | 868 | 2,606 |
| No se proporcionaron planes | 85 | — | 105 | 190 |
| Error de plataforma | 9 | 10 | 13 | 32 |
| **Perfiles ofrecidos** | **1,774** | **1,774** | **1,774** | **5,322** |
| **Cobertura** | **62.2%** | **34.0%** | **44.4%** | **46.9%** |

**La meta que Pacífico planteó es 95% de cobertura de entrega.** Un 46.9% está muy por debajo y eso se dice con el número, sin calificarlo.

Medir por aseguradora y además por bloques de mil correlativos consecutivos. Un fallo parejo entre bloques es un fallo normal. Un bloque que cae a cero es otra cosa, y hay que decir en qué correlativo empieza.

Decir siempre "deja de devolver precio", no "se cae": eso último es una causa que no se midió.

### 7. ¿Se cumplen las fórmulas?

Verificadas contra filas exitosas del entregable del 11-2026:

- `PRECIO MENSUAL FINAL` = `PRECIO MENSUAL CON DESCUENTO` cuando esa columna tiene valor, y `PRECIO MENSUAL` cuando está vacía. La Positiva llega sin descuento; Mapfre y Rímac sí lo traen.
- `PRECIO ANUAL` = `PRECIO MENSUAL FINAL` × 12
- `TASA BRUTA` = `PRECIO ANUAL` / `SUMA ASEGURADA`

**Excepción observada y no explicada.** En el 11-2026 hay filas de La Positiva con plan `DAÑO A TERCEROS` donde `PRECIO MENSUAL` y `PRECIO MENSUAL CON DESCUENTO` vienen vacíos, `PRECIO MENSUAL FINAL` es 0.00 y `PRECIO ANUAL` es 50.00. Ahí la fórmula del anual no se cumple. Se cuenta y se declara como discrepancia abierta. No inventar una explicación.

`TASA NETA`: la regla de cálculo la define Be Quarks y **está pendiente de confirmar**. Lo medido es que la neta ronda 0.822 a 0.825 de la bruta en las tres aseguradoras, consistente con el 0.8228 observado en Autos Regular. No inventar una explicación para ese número.

`TASA BRUTA` y `TASA NETA` van en número plano con **seis decimales**, guardadas como fracción: `0.043400` es 4.34%. En el 11-2026 llegaron con cuatro decimales como máximo y en formato General. Si el cotizador solo entrega cuatro, se documenta y **no se agregan ceros para simular precisión**.

### 8. Valores sospechosos

Cada uno se cuenta y se reporta con su alcance:

- **Modelo cortado a 30 caracteres.** Es el defecto recurrente de este producto. En el 11-2026 afectó a 15 vehículos (14 truncados, 1 sin acento) y los 45 intentos asociados salieron todos como `Modelo de vehículo no encontrado`. Ejemplo verificado: `NUEVO TIGUAN TRENDLINE 1.4TSI DSG` salió como `NUEVO TIGUAN TRENDLINE 1.4TSI`. Correlativos afectados en ese lote: 452, 632, 1891, 2279, 2354, 2580, 2827, 3173, 3218, 3362, 3429, 3501, 3745, 4610, 4613.
- **Aseguradora sin normalizar.** `Rimac` sin tilde apareció en 2,423 filas del archivo recibido; `Lapositiva` sin espacio también se ha visto.
- **Fecha de nacimiento distinta a la base.** En el 11-2026, 9 correlativos traían una fecha distinta a la del origen: 228, 2354, 2597, 2798, 3011, 4682, 4957, 5062, 5097.
- **Tasas con menos decimales de los pedidos**, o con formato General en vez de número.
- **Ceros a la izquierda perdidos** en el DNI guardado como número.
- **Precios en 0** y centinelas tipo `999999999.00`.
- **Celdas de precio convertidas en fecha** por Excel.
- **Un dato en la columna de otro.**
- **`ESTADO` vacío o con "No definido"**, que es exactamente lo que el pedido excluye.
- **Moneda mezclada** dentro de una misma comparación.

### 9. ¿El perfil cotizado es el que se pidió?

Comparar contra la base lo que efectivamente se usó para cotizar: marca, modelo, año y fecha de nacimiento.

Separar y no sumar entre sí: marca distinta, modelo distinto, año distinto, fecha de nacimiento distinta.

**El caso de la edad merece su propia línea.** En el 11-2026, los 603 perfiles exitosos de Mapfre usaron marzo como mes de nacimiento en el campo `birthdate`, y en 600 de ellos eso dejó al perfil con **un año más** del que le correspondía. Una cotización con edad equivocada es una cotización de otro riesgo. Se reporta como cifra propia, separada de los modelos.

Cuando el archivo ya se usó para cotizar, **las fechas no se corrigen a mano en el entregable**: el resultado dejaría de coincidir con lo que realmente se envió al cotizador. Se declara y se corrige la parametrización para el siguiente lote.

Si el archivo no guarda el perfil que reconoció la aseguradora, decir que no se pudo medir y que hay que capturarlo de pantalla.

## Catálogo de ESTADO

Los únicos textos válidos, siempre iguales y nunca en blanco:

- `Exitoso`
- `Modelo de vehículo no encontrado`
- `No se proporcionaron planes`
- `Vehículo fuera de política de suscripción`
- `Error de plataforma`

En el 11-2026 se usaron los primeros tres más `Error de plataforma`; no hubo casos fuera de política. Queda por definir si el catálogo oficial dice `Error de plataforma` o `Error de plataforma / timeout`: el pedido usó la segunda forma y el archivo la primera. Es una discrepancia menor que se declara, no se resuelve sola.

Si aparece un caso que no encaja en ninguno, no se fuerza: se consulta con Italo y se define el motivo.

## Planes de referencia vistos en el 11-2026

| Aseguradora | Planes |
|---|---|
| La Positiva | AUTO WEB · AUTO DIGITAL · DAÑO A TERCEROS · ROBO TOTAL |
| Mapfre | FULL COBERTURA PREMIUM I · FULL COBERTURA PREMIUM RED WEB · FULL COBERTURA PREMIUM KM WEB · DAÑO TOTAL |
| Rímac | Oro · Plata |

Es un registro de lo observado, no una lista cerrada. Un plan nuevo no es un hallazgo por sí solo.

## De dónde sale cada referencia

| Dato | Fuente |
|---|---|
| 30 columnas, orden y nombres | `Bench_Renovaciones_11-2026.xlsx`, hoja `Detalle Renovaciones 11-2026` |
| 1,774 vehículos, 5,322 perfiles, catálogo de ESTADO, modelo completo, 6 decimales, nombre de archivo, entrega 17/08 | Correo de Italo a Camila del Carpio, 16/07/2026, "Listado Mensual Renovaciones 11-2026 - base para procesamiento" |
| Cobertura por aseguradora, 9,488 filas, 6,660 exitosas, meta 95%, correlativos de modelos y fechas, edad Mapfre | Correo de Italo a Camila del Carpio, 05/08/2026, "criterios para próximos procesamientos" |
| Capturas en blanco | Reporte de Camila del Carpio, 04/08/2026 |
| Bloqueo por datos sensibles | Correo de Alejandro Rollandi, 07/08/2026 |
| Suspensión del servicio | Correo de Gabriela Matto Arias, 27/08/2026 |
| Cuarta aseguradora y volumen contratado | Propuesta final de Alejandro Rollandi, 21/07/2026, y conformidad de Italo, 22/07/2026 |

## Cómo se reporta

Cómo se entrega el resultado está en la skill `entregar-auditoria-bequarks`. Esta skill dice qué medir; esa dice cómo se presenta. Lo específico de esta cuenta:

**Sin calificativos.** Nada de "grave", "crítico" ni "urgente". Cada hallazgo dice qué pasa y a cuántos perfiles o filas afecta. La gravedad la decide Italo.

**Cada cifra dice si es perfiles o filas.** En este producto los dos números existen y significan cosas distintas. Un hallazgo sin unidad no sirve.

**Cada cifra dice de dónde salió.** Archivo, hoja, correlativo. Si no puede, no entra.

**En la columna de qué hay que corregir va el síntoma, no la causa supuesta.** "El modelo usado no coincide con la base" sí. "Revisar el límite de caracteres del campo" solo si se vio dónde se corta.

## Los tres límites

**No reemplaza abrir las capturas.** Ningún chequeo puede decir si el precio del Excel es el que salía en pantalla. Eso exige abrir las imágenes y se declara aparte.

**No decide sobre el DNI.** El chequeo 4 declara qué hay. Qué se hace con eso es de Italo, y hoy además está atado a la evaluación que Pacífico tiene abierta.

**No decide.** Entrega qué pasa y a cuánto afecta. Aceptar, corregir o devolver el archivo es de Italo.
