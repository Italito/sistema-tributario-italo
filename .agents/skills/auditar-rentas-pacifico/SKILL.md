---
name: auditar-rentas-pacifico
description: "Audita el entregable mensual del Benchmark de Rentas Particulares de Pacífico Seguros, sea el archivo antes de enviarlo o el ya enviado al cliente. Nueve chequeos en orden fijo antes de opinar nada."
---

# Auditar el entregable mensual - Pacífico Rentas Particulares

Se dispara cuando aparece el Excel del Benchmark de Rentas Particulares de Pacífico: el archivo que se va a adjuntar, el ya enviado, o el consolidado del levantamiento antes de armarlo.

**Regla de la skill: los nueve chequeos se corren SIEMPRE, en este orden, antes de mirar cualquier otra cosa.** No se improvisa qué revisar. Si el 1 falla, la auditoría se detiene: todo lo demás se estaría midiendo sobre un archivo que no es el entregable.

Esta cuenta es **Pacífico Rentas**, del área de Vida, y es independiente de Pacífico Vehicular. No comparte contactos, ni grilla, ni formato con Autos, SOAT ni Renovaciones. Tampoco se mezcla con Protecta, aunque el producto se parezca: la grilla, las columnas y hasta la escritura de los rótulos son distintas. Protecta aquí es una aseguradora que se releva, no el cliente.

## La grilla cambió a partir de septiembre 2026

Este es el dato que más fácil hace equivocarse hoy, porque el entregable de septiembre es el primero bajo la grilla nueva.

**Grilla vigente desde septiembre 2026** — pedida por Astrid Mendoza el 28/08/2026 y confirmada por Italo el 29/08/2026:

| Dimensión | Valores |
|---|---|
| Aseguradoras (3) | Rímac · Protecta · Interseguro |
| Montos en soles (5) | S/ 1,000,000 · S/ 500,000 · S/ 300,000 · S/ 150,000 · S/ 75,000 |
| Montos en dólares (5) | US$ 300,000 · US$ 150,000 · US$ 100,000 · US$ 45,000 · US$ 20,000 |
| Plazos (4) | 3 · 5 · 7 · 10 años |
| **Total** | 3 × 10 × 4 = **120 cotizaciones mensuales** |

Cada monto se cotiza en las tres aseguradoras y en los cuatro plazos. Bimestral pasa de 280 a **240**.

**Grilla hasta agosto 2026**, para auditar meses anteriores:

| Dimensión | Valores |
|---|---|
| Aseguradoras (5) | Rímac · Interseguro · La Positiva · Mapfre · Protecta |
| Montos en soles (4) | S/ 100,000 · S/ 300,000 · S/ 500,000 · S/ 1,000,000 |
| Montos en dólares (4) | US$ 25,000 · US$ 100,000 · US$ 150,000 · US$ 300,000 |
| Plazos (4) | 5 · 7 · 10 · 15 años |
| Base | 5 × 8 × 4 = 160 |
| Diferimiento, solo Rímac | 6 montos (S/ 300K, 500K, 1M · US$ 100K, 150K, 300K) × 4 plazos × 2 diferimientos (2 y 3 años) = 48 |
| **Total** | 160 + 48 = **208** |

En esa grilla el volumen alternaba: 208 un mes y 72 al siguiente, que es como se llegaba a las 280 bimestrales. Abril 208, mayo 72, junio 208, julio 72, agosto 208. **La composición del mes de 72 no está documentada en lo verificado**; si toca auditar uno, se pregunta antes de medir cobertura.

**Punto abierto que bloquea la grilla de septiembre.** Interseguro no emite cotizaciones por debajo de S/ 130,000.01 ni de US$ 45,000.01. Eso rompe tres montos de la grilla nueva:

- S/ 75,000 se cotiza sobre S/ 130,000.01.
- US$ 20,000 se cotiza sobre US$ 45,000.01.
- US$ 45,000 queda un céntimo por debajo del mínimo, así que también iría a US$ 45,000.01.

Los dos tramos en dólares terminan en el mismo monto. Italo propuso a Astrid el 29/08 mantener uno en US$ 45,000.01 y llevar el otro a US$ 60,000 o US$ 75,000. **Al momento de escribir esta skill no hay respuesta de Astrid.** Antes de medir cobertura de septiembre en Interseguro hay que saber qué se decidió; si no se sabe, se dice que no se pudo medir y no se cuenta como faltante.

## Paso 0 - La ficha del mes

Antes de auditar hay que saber qué se pidió. Si no está, se reconstruye de la fuente y se dice de dónde salió.

| Dato | Dónde se lee |
|---|---|
| Mes en evaluación | Asunto del correo de entrega, "Benchmark Rentas Particulares - <Mes> <Año>" |
| Archivo que llegó al cliente | Adjunto real de ese correo en Gmail, nunca la copia del proyecto ni la del Drive |
| Grilla del mes | Correo de Astrid Mendoza que la fijó, más la confirmación de Italo |
| Ruta del levantamiento | `Ruta Rentas Part <Mes> Pacifico-italo.xlsx`, que trae los perfiles y los DNI usados |
| Trabajo de campo | Fechas declaradas en la ficha técnica de la hoja Resumen |
| Excepciones autorizadas | Correos de Astrid o Luis Alonso Saco, con fecha |

El entregable enviado manda sobre cualquier documento interno, sobre la ruta y sobre esta misma skill. Si el archivo real dice otra cosa, gana el archivo y se corrige la referencia.

Destinatarios habituales: **Luis Alonso Saco Schaefer** y **Astrid Mendoza Ronquillo**, con copia a **Carol Abusabbah** y **Orly Sandoval**.

## Los nueve chequeos

### 1. ¿Es este el archivo que se envió, y cubre la grilla del mes?

Esta cuenta no recibe base de entrada del cliente. Lo que hace de base es la grilla acordada, y el archivo de verdad es el que salió adjunto por correo.

Dos comparaciones, las dos fila por fila:

1. **Contra el adjunto enviado.** Sacar el correo del mes de Gmail, extraer el adjunto y comparar `ID Resultado` uno a uno contra el archivo en mano. Reportar cuántos IDs coinciden y cuáles sobran y faltan en cada lado.
2. **Contra la grilla vigente ese mes.** Aseguradora × monto × plazo (× diferimiento cuando aplique), cada celda exactamente una vez.

Si el archivo en mano no es el enviado, se detiene la auditoría de contenido y se dice cuál de los dos se va a auditar.

### 2. ¿Están las aseguradoras de la grilla vigente?

Desde septiembre 2026 son tres: **Rímac** · **Protecta** · **Interseguro**. Antes eran cinco, sumando **La Positiva** y **Mapfre**.

**Pacífico es el cliente y no se releva.** Si aparece en la columna `Aseguradora`, es un desvío. Esto distingue esta cuenta de la de Protecta, donde Pacífico sí es una de las seis relevadas.

Nombres exactos como salen en el archivo: **Rímac** con tilde, **La Positiva** con espacio, **Interseguro**, **Mapfre**, **Protecta**.

Todas las filas con `Estado` = **Aprobado**. Cualquier otro valor se cuenta y se dice a cuántas filas afecta.

Productos verificados en el entregable de agosto 2026: Rímac `Renta Garantizada` · Interseguro `Renta Particular Plus` · La Positiva `Renta Particular` · Mapfre `Certirenta`. El de Protecta no quedó a la vista en lo verificado; se lee del archivo del mes y no se supone.

### 3. ¿Están las 20 columnas, con el nombre exacto y en el orden exacto?

**Dos hojas: `Resumen` y `Detalle Cotizaciones`.** Aquí sí van las dos, a diferencia de Protecta, donde el resumen se sacó del archivo y va en el cuerpo del correo.

Orden verificado contra el entregable real `Rentas Pacífico Report 08_2026.xlsx`, hoja `Detalle Cotizaciones`:

`ID Resultado` · `Fecha de carga` · `Estado` · `Aseguradora` · `DNI` · `Género` · `Fecha Nacimiento` · `Edad` · `Fecha Solicitud Cotización` · `Producto Contratado` · `Moneda` · `Prima` · `Devolución de Prima` · `Pensión Inicial` · `Años Diferimiento` · `Plazo (años)` · `Tasa (%)` · `Pensiones Proyectadas Totales` · `Gastos de Sepelio` · `Soporte documental`

Rótulos que se confunden con los de Protecta y hay que mirar con cuidado, porque aquí llevan tilde y allá no:

| Pacífico Rentas | Protecta Rentas |
|---|---|
| `Género` | `Genero` |
| `Devolución de Prima` | `Devolucion Prima` |
| `Tasa (%)` | `Tasa` |
| `Soporte documental` | `Link` |
| `Años Diferimiento` | no existe |

La hoja `Resumen` lleva ficha técnica del levantamiento y los cuadros de cotizaciones por aseguradora y moneda, más tasa promedio por plazo en soles y en dólares.

**Moneda** se escribe `Soles` y `Dólares`, en palabra completa. En el producto vehicular se usan códigos; aquí no.

**Formato de fecha.** Las tres columnas de fecha (`Fecha de carga`, `Fecha Nacimiento`, `Fecha Solicitud Cotización`) deben ir en `dd/mm/yyyy`. Esto no es estable entre versiones del mismo mes: en agosto 2026 la copia en Google Sheets mostraba `13/08/2026` y `01/01/1961`, y el xlsx adjunto mostraba `8/9/2026` y `1/5/1961`, que se lee como mes/día. Con ese formato el 09/08 se lee como 8 de septiembre. Se comprueba en el archivo que va al cliente, no en la copia.

### 4. ¿Hay datos personales que no deben salir?

Minimización de datos, Ley N.° 29733 y su reglamento **D.S. 016-2024-JUS**.

El entregable lleva `DNI`, `Género`, `Fecha Nacimiento` y `Edad` de los perfiles usados por los mystery shoppers. Contar y reportar, sin decidir por Italo:

- Filas con valor en `DNI`, y cuántos documentos distintos son.
- Filas con valor en `Fecha Nacimiento`.
- Cualquier columna añadida con nombre, apellido, teléfono, correo o dirección del shopper. La ruta sí trae nombres y apellidos; **el entregable no debe llevarlos**.

El seguimiento va por `ID Resultado`, que es la llave de trazabilidad y no identifica a nadie.

Hay un antecedente que conviene tener presente aunque sea de otra línea: en agosto 2026 Pacífico suspendió el servicio de Renovaciones de Autos por riesgos con datos de clientes. Rentas es distinto, porque los perfiles son de shoppers y no de clientes de Pacífico, pero el equipo de Gobierno de Datos que lo evaluó es el mismo (Gabriela Matto) y ya hizo un relevamiento de data externa sobre Be Quarks. La skill declara qué datos salen; no decide ni alarma.

### 5. ¿Hay llave y evidencia en el 100% de las filas?

- `ID Resultado` presente, entero y sin repetidos en todas las filas.
- `Soporte documental` presente en todas, con el enlace al respaldo en la plataforma de Be Quarks.
- El enlace apunta al respaldo de esa fila. Se comprueba fila por fila, no por muestreo.

En el entregable de agosto la columna se rinde como el texto `Ver cotización` con el enlace detrás. **Texto visible no es enlace**: hay que comprobar que el hipervínculo exista y no solo la palabra.

Sin respaldo la fila no sirve como evidencia frente a una aseguradora supervisada por la SBS.

### 6. Cobertura: la grilla completa, celda por celda

**La unidad de conteo es la cotización, que es una combinación única de aseguradora × moneda × monto de prima × plazo, más el diferimiento cuando aplique.** Una fila es una cotización. Si el archivo trajera varias filas por cotización, se cuentan combinaciones únicas y nunca filas.

Se mide el total y además por bloques. Para la grilla vigente desde septiembre:

| Bloque | Esperado |
|---|---|
| Total | 120 |
| Por aseguradora | 40 cada una |
| Por moneda | 60 soles y 60 dólares |
| Por plazo | 30 en cada uno de 3, 5, 7 y 10 años |
| Por aseguradora y moneda | 20 cada celda |
| Por monto de prima | 12 cada uno |

Para la grilla hasta agosto 2026: 208 en total, Rímac 80 y las otras cuatro 32 cada una, 104 por moneda, y las 48 de Rímac con diferimiento aisladas por la columna `Años Diferimiento`.

**Un faltante se dice con la celda exacta de la grilla que quedó vacía**, no como porcentaje del total. "Falta Interseguro, dólares, US$ 150,000, plazo 7" sirve; "cobertura 98%" no.

### 7. ¿Se cumplen las fórmulas y los cuadros del resumen?

Cuando el entregable o el correo declaren cuadros o promedios, se recalculan desde la hoja de detalle antes de darlos por buenos. El correo de entrega repite los mismos cuadros del resumen: los dos tienen que coincidir con la base.

**Fórmula verificada** contra el entregable de agosto 2026, incluidas filas con diferimiento:

`Pensiones Proyectadas Totales` = `Pensión Inicial` × 12 × `Plazo (años)` + `Devolución de Prima`

Comprobada sin excepción en los casos revisados, en soles y en dólares, con diferimiento 0, 2 y 3. El diferimiento **no** entra en la fórmula: el multiplicador es el plazo.

`Devolución de Prima` es igual a `Prima` en todas las filas verificadas, que es la devolución del 100% que define el producto.

**Tasa promedio del resumen** = media simple de `Tasa (%)` sobre las filas de esa aseguradora, esa moneda y ese plazo. En Rímac el promedio del cuadro **incluye** las cotizaciones con diferimiento; está declarado así en la nota del resumen y hay que recalcularlo de la misma forma o el número no va a cuadrar.

**Relación medida, no fórmula.** El cociente entre la pensión anualizada y la tasa cotizada, `(Pensión Inicial × 12 / Prima) / (Tasa (%) / 100)`, cayó entre 0.964 y 0.971 en las filas de Rímac y Mapfre que se pudieron revisar del entregable de agosto. **Es una muestra parcial, no una línea base.** Antes de usarla para levantar hallazgos hay que calcularla sobre el archivo completo y por compañía, porque cada compañía tiene su propio nivel. Comparar contra una banda única del conjunto produce falsas alarmas; ya pasó en la cuenta de Protecta. No inventar una explicación para el nivel de cada una.

`Gastos de Sepelio` se comportó como constante por moneda en agosto 2026: S/ 5,000.00 en soles y US$ 1,500.00 en dólares. Un valor distinto no es error por sí solo, pero se cuenta y se dice.

### 8. Valores sospechosos

Cada uno se cuenta y se reporta con las filas que afecta:

- **Ceros a la izquierda perdidos en el DNI.** Defecto verificado: el perfil `06885234` de la ruta de agosto sale como `6885234` en el entregable. El documento queda con 7 dígitos en vez de 8. Se cuenta cuántos DNI tienen menos de 8 dígitos.
- **Monto cotizado distinto del monto pedido.** Cuando una aseguradora no emite por debajo de un mínimo, el archivo debe dejar identificado el monto solicitado y el efectivamente cotizado. Italo se comprometió a eso con Astrid el 29/08. Si el archivo solo trae uno de los dos, se dice.
- **Prima fuera de la grilla exacta.** Un monto que no esté en la lista del mes se reporta con su valor, sin corregirlo.
- **Celdas en blanco.** Nunca van vacías: cuando la aseguradora no muestra el dato va `no aplica`.
- **Constantes donde debería haber variedad**, con la fila donde empieza.
- **Textos con encoding roto.** En la ruta de agosto aparece `ormeÑo` con Ñ mayúscula dentro de texto en minúsculas.
- **Pensión o tasa en 0** y centinelas tipo `999999999`.
- **Celdas de importe convertidas en fecha** por Excel.
- **Un dato en la columna de otro.**
- **Moneda mezclada** dentro de una misma comparación.
- **Filas duplicadas** o `ID Resultado` repetido.
- **Restos del export**: filas en blanco después del último registro y rango de hoja extendido más allá de los datos.

### 9. ¿Lo entregado corresponde a lo que se pidió, caso por caso?

**Las cotizaciones deben ser del mes en evaluación.** Se mide sobre `Fecha Solicitud Cotización` y se reporta también el rango de `Fecha de carga`, porque son cosas distintas: en agosto 2026 la carga fue del 09 al 13 y las solicitudes del 05 al 09.

Se contrasta la ficha técnica del resumen contra la base: si declara "trabajo de campo del 03 al 13 de agosto", ninguna fecha de solicitud debe caer fuera.

Condiciones fijas del perfil, verificadas contra la base una por una:

| Campo | Valor esperado |
|---|---|
| `Estado` | `Aprobado` en todas |
| `Género` | uniforme en el mes, `Masculino` en agosto 2026 |
| `Edad` | dentro del rango declarado en la ficha, 64-65 en agosto 2026 |
| `Devolución de Prima` | igual a `Prima` |
| `Años Diferimiento` | `0` salvo en las filas de Rímac con diferimiento declarado |

Si la ficha técnica declara un perfil, un rango de edad o un periodo, se contrasta contra la base. Lo que la base no permita comprobar se dice en la sección de lo no comprobado.

## Tensión comercial abierta

No es materia de auditoría, pero condiciona qué se puede afirmar y conviene tenerlo a la vista:

- La renovación está en negociación. Astrid informó restricciones presupuestales el 24/06/2026; Luis Alonso planteó reducir volumen o mantener precio.
- La propuesta de Italo del 04/08/2026 era mantener las condiciones de 2026 con 280 cotizaciones bimestrales y sin reducir compañías, y conversar la nueva etapa desde enero de 2027.
- La grilla nueva reduce a 240 bimestrales y de 5 aseguradoras a 3, sin que la tarifa se haya renegociado. Carol pidió reunión para revisar tarifas el 31/08/2026.
- La demo de la plataforma sigue pendiente.

Una auditoría no opina sobre esto. Si una cifra del entregable se va a usar en la negociación, se marca de dónde salió y se deja que la use Italo.

## De dónde sale cada referencia

| Referencia | Fuente |
|---|---|
| Las 20 columnas, las dos hojas, la ficha técnica | `Rentas Pacífico Report 08_2026.xlsx`, adjunto del correo "Benchmark Rentas Particulares - Agosto 2026" del 16/08/2026 |
| Grilla vigente desde septiembre 2026 | Correo de Astrid Mendoza Ronquillo del 28/08/2026 y confirmación de Italo del 29/08/2026 |
| Mínimos de Interseguro y el cruce en dólares | Correo de Italo a Astrid y Luis Alonso del 29/08/2026 |
| Grilla hasta agosto 2026 y las 48 con diferimiento | Hoja `Resumen` del entregable de agosto y `Ruta Rentas Part Agosto Pacifico-italo.xlsx` |
| Fórmula de pensiones proyectadas | Recalculada sobre filas de la hoja `Detalle Cotizaciones` de agosto 2026 |
| Perfiles y DNI del levantamiento | `Ruta Rentas Part Agosto Pacifico-italo.xlsx` |
| Volumen bimestral y alternancia 208/72 | Correos de entrega de abril a agosto de 2026 |
| Restricciones presupuestales | Correo de Astrid Mendoza del 24/06/2026 |

Cada referencia se vuelve a comprobar contra el entregable del mes en curso. Si cambia, se corrige aquí y se dice que cambió.

## Cómo se reporta

Seguir la skill **entregar-auditoria-bequarks**. Es la misma para todas las cuentas. Lo específico de esta:

**Sin calificativos.** Cada hallazgo dice qué pasa y a cuántas filas o celdas de la grilla afecta. La gravedad la decide Italo.

**Cada cifra dice contra qué grilla se midió**, la vigente desde septiembre o la anterior. Un conteo sin esa referencia no significa nada, porque el total esperado cambió de 208 a 120.

**Cada cifra dice de dónde salió.** Archivo, hoja, fila. Si no puede, no entra.

## Los tres límites

**No reemplaza abrir los respaldos.** Ningún chequeo puede decir si la tasa del Excel es la que salió en pantalla del shopper. Eso exige abrir las evidencias una por una y se declara aparte.

**No cierra la grilla de septiembre.** Mientras Astrid no responda qué monto va en el segundo tramo en dólares de Interseguro, esa celda no se cuenta como faltante: se dice que está pendiente de definición.

**No decide.** Entrega qué pasa y a cuánto afecta. Enviar, corregir o parar la entrega es de Italo.
