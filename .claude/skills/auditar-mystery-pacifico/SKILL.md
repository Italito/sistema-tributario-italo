---
name: auditar-mystery-pacifico
description: "Audita un entregable de Mystery Shopper de Pacífico Vehicular - el checklist de precio o el checklist de evaluación de vendedores - antes de enviarlo al cliente o al revisar uno ya enviado. Nueve chequeos en orden fijo antes de opinar nada."
---

# Auditar un entregable de Mystery Shopper - Pacífico Vehicular

Se dispara cuando aparece un checklist de Mystery Shopper de Pacífico Vehicular: el de **precio** o el de **evaluación de vendedores**, vaya a salir hacia el cliente o esté ya enviado. Los dos salen del mismo relevamiento de campo, así que se auditan con esta skill; el producto a efectos de auditoría es el relevamiento, no cada checklist por separado.

**Regla de la skill: los nueve chequeos se corren SIEMPRE, en este orden, antes de opinar nada.** No se improvisa qué revisar. Si el 1 falla, todo lo demás se estaría midiendo sobre un relevamiento que no correspondía, y se dice así.

Esto es **Mystery Shopper de Pacífico Vehicular**, un relevamiento de campo sobre cómo venden los canales (call center, corredores, concesionarios). No es el web scraping de Autos Regular ni SOAT: esos van en `auditar-scraping-pacifico`, tienen otra base y otro formato. Tampoco es el Mystery Shopper de Mapfre, que vive en `auditar-entregable-mapfre` con sus propias columnas.

## La diferencia que invierte la regla de siempre

En los benchmarks tarifarios **Pacífico nunca se releva, es el cliente**. En el Mystery Shopper es al revés: **Pacífico SÍ se releva**. El estudio observa qué ofrece cada vendedor —qué aseguradora recomienda primero, a qué precio, con qué plan— y Pacífico es uno de los objetos de la comparación, no un excluido. Quien traiga la regla del benchmark a este producto marcaría la presencia de Pacífico como un desvío, y sería un error.

Aseguradoras que aparecen en el relevamiento, verificadas en los entregables: **Rímac** (con tilde), **Mapfre**, **La Positiva** (con espacio), **Pacífico** (con tilde), **Qualitas**. Nota abierta: la skill de Mapfre escribe **Quálitas** con tilde; en los archivos de este producto sale **Qualitas** sin tilde. Confirmar cuál usa el entregable del mes antes de normalizar.

## Estado del servicio - leer antes de auditar

Los entregables concretos verificados son de **julio 2025** (`2. Vehicular_Checklist_Precio_Report_Mystery_Shoppers` y `3. Vehicular_Checklists_Evaluacion_Vendedor_Mystery_Shopper`). El Mystery Shopper está dentro de la **propuesta de renovación 2026 de Pacífico Vehicular** (correo de Alejandro Rollandi del 21/07/2026, "Mystery Shoppers según...") y hay calculadoras de costo de julio 2026, pero **no está verificado un entregable 2026 con formato fijo**. Lo que sigue es el formato de 2025.

Consecuencia práctica: al auditar el primer entregable de 2026, el chequeo 3 no da por sentado el formato; **se contrasta contra el archivo del mes y, si difiere del de 2025, se corrige esta skill y se dice que cambió**. Si el archivo llega antes de que la renovación esté firmada, se pregunta bajo qué acuerdo se está entregando antes de medir cobertura.

## Paso 0 - La ficha del encargo

Sin esto no se avanza. Si falta, se reconstruye del correo o del pedido y se dice de dónde salió.

| Dato | Dónde vive |
|---|---|
| Ciclo y mes | Asunto del correo de entrega o del pedido |
| Canales pedidos | Televentas, Corredores, Concesionarios (Dealers) - cuáles entran este ciclo |
| Ámbito | Lima o provincias, y qué departamentos |
| Aseguradoras del alcance | Rímac, Mapfre, La Positiva, Pacífico, Qualitas |
| Perfiles / placas | Archivo de preparación del ciclo |
| Los dos checklists esperados | precio + evaluación de vendedores |

Contactos de la cuenta: Alejandro Rollandi (decisor), Jharelly Lulimache (Pricing), Miller Sarsoza (Data), Erik Poma (Operaciones).

## Los nueve chequeos

### 1. ¿Se trabajó sobre el relevamiento correcto?

Los dos checklists comparten la llave `ID Resultado` (precio) / `Número Correlativo - ID` (evaluación) y ambos referencian el mismo ciclo. Comparar los IDs del archivo en mano contra la base del ciclo y contra el otro checklist del mismo mes, para confirmar que son del mismo relevamiento.

Si los IDs no calzan con la base del ciclo, se detiene la auditoría de contenido: el resto se estaría midiendo sobre un relevamiento que no correspondía.

### 2. ¿Están los canales y las aseguradoras del alcance?

**Por canal.** Los valores de `Canal de Ventas` verificados son **Televentas**, **Corredores** y **Dealers**. Contra la ficha del ciclo, uno por uno: si el pedido incluía tres canales y el archivo trae dos, se dice cuál falta y con cuántas filas.

**Por aseguradora.** Las cinco del alcance, con su escritura exacta. **Pacífico entra en el conteo** porque es objeto del estudio (ver arriba). Si aparece una aseguradora fuera de las cinco, se cuenta aparte y se pregunta.

Todas las filas con `Estado` = **Aprobado**. Cualquier otro valor se cuenta y se dice a cuántas filas afecta.

### 3. ¿Están las columnas, con el nombre exacto y en el orden exacto?

**Checklist de precio, 29 columnas.** Orden verificado contra `2. Vehicular_Checklist_Precio_Report_Mystery_Shoppers - 30.07.2025.xlsx`:

`ID Resultado` · `Fecha de carga` · `Estado` · `Aseguradora` · `Canal de Ventas` · `Tipo Cliente` · `Género` · `Edad` · `Placa` · `Empresa Intermediaria` · `Uso` · `Vehiculo Tipo` · `Vehiculo Marca` · `Vehiculo Modelo` · `Vehiculo Año` · `Moneda` · `Monto Asegurado` · `Ofrecieron descuento` · `Descuento Cyber` · `Descuento con evidencia` · `Porcentaje descuento` · `Tarifa anual sin descuento` · `Tarifa anual con descuento` · `Numero de cuotas` · `Precio cuota` · `Producto Contratado` · `Intereses Cuota` · `Tasa Neta` · `Link`

Diferencias con el checklist de precio de Mapfre, que es fácil confundir: aquí es **`Empresa Intermediaria`**, no `Corredor`; **`Producto Contratado`**, no `Plan de Seguro`; y **no lleva** `DNI`, `RUC`, `Fecha de nacimiento`, `Perfil`, `Agrupamiento` ni `ID Grupo`. Es un formato más corto. No se justifica agregar columnas de Mapfre porque el shopper sea el mismo.

**Checklist de evaluación de vendedores.** Hoja `Checklists_Evaluacion_Pacifico`. Primeras columnas verificadas: `Número Correlativo - ID` · `% de Evaluación` · `Fecha Cotización` · `Canal de Ventas` · `Empresa Intermediaria` · `Compañía`, seguidas de las preguntas del cuestionario CX con su enunciado completo como encabezado. El resto de las preguntas se listan en la sección "Cuestionario CX de referencia".

**Enlace de evidencia.** En los dos checklists el respaldo va a `https://pacifico-analytics.bequarks.pe/Attachments?id=<n>`, donde `<n>` es el `ID Resultado` de la fila. **No es `mapfre.bequarks.pe`**: si el enlace apunta a la plataforma de Mapfre, el archivo es de la cuenta equivocada y se detiene.

### 4. ¿Hay datos personales o de terceros que no deben salir?

Minimización de datos, Ley N.° 29733 y su reglamento D.S. 016-2024-JUS.

Este producto trae menos datos personales que el de Mapfre, y así debe quedar. Contar y reportar, sin decidir por Italo:

- **Nombre del vendedor o de la intermediaria en claro.** En el entregable de 2025 la columna `Empresa Intermediaria` va anonimizada como `Nombre Aseguradora` (Televentas) o `Nombre del Dealer` (Dealers). Si el archivo trae el nombre real del corredor, del asesor o del concesionario, se cuenta cuántas filas y se declara: identifica a un tercero.
- Cualquier columna añadida con `DNI`, teléfono, correo o dirección del vendedor o del shopper.

El seguimiento va por `ID Resultado`. `Placa`, `Género` y `Edad` corresponden al perfil del vehículo cotizado, no al vendedor; se dejan salvo que la ficha del ciclo diga otra cosa.

### 5. ¿Hay llave y evidencia en el 100% de las filas?

- `ID Resultado` / `Número Correlativo - ID` presente, entero y sin repetidos.
- `Link` presente en todas las filas del checklist de precio, con la forma y el dominio del chequeo 3, y el `<n>` igual al `ID Resultado` de la fila. Se comprueba fila por fila, no por muestreo.
- El checklist de evaluación se cruza con el de precio por `ID Asociado` / correlativo: cada evaluación debe poder amarrarse a su cotización.

Sin enlace la fila no sirve como evidencia. Enlace presente no es captura válida: si el respaldo abre en blanco, se declara aparte aunque la columna tenga texto.

### 6. Cobertura, y dónde se cae

**La unidad de conteo es la observación única**, o sea una combinación de vendedor × aseguradora × canal dentro del ciclo. No filas sueltas si el formato repartiera una observación en varias filas.

Se mide el total y además por bloques: **por canal** (Televentas / Corredores / Dealers), **por aseguradora**, y **por departamento** cuando el ciclo es de provincias. El total esconde la dispersión: un canal o un departamento que cae a cero se dice con su nombre, no como porcentaje global.

En Mystery Shopper hay además una tasa de respuesta propia: cuántos corredores/vendedores del universo habilitado efectivamente respondieron. En el ciclo de junio 2026 (de Mapfre, como referencia de método) el resumen medía "corredores que respondieron / corredores habilitados". Si el entregable de Pacífico trae ese universo, la cobertura se reporta también contra él y se nombra a los que no respondieron solo si existe la lista de habilitados; si no, se dice que no se puede nombrar.

### 7. ¿Se cumplen las fórmulas y los puntajes?

**Checklist de precio.** Cuando la aseguradora aplica descuento, `Tarifa anual con descuento` es menor que `Tarifa anual sin descuento`; cuando no, son iguales. `Precio cuota` × `Numero de cuotas` debe aproximar la tarifa con descuento cuando hay cuotas; con una sola cuota, `Precio cuota` = tarifa. `Tasa Neta` va en número plano con seis decimales. Valores sospechosos de tasa (por ejemplo 0.82 cuando el resto ronda 0.04-0.07) se cuentan y se declaran, no se explican.

**Checklist de evaluación.** La columna `% de Evaluación` es un puntaje por fila. **Su denominador depende de las preguntas aplicables al canal**: en Televentas, preguntas como "¿Qué aseguradora le ofreció primero?" salen "No Aplica" y no cuentan; en Dealers y Corredores sí. Por eso el porcentaje varía entre filas (22.22%, 33.33%, 55.56%, 77.78% ...). **La regla exacta de puntaje no está en lo verificado**: antes de recalcular el `% de Evaluación` hay que pedir el rúbrica de puntaje a quien arma el checklist. Sin ella, se reporta que el porcentaje no se pudo verificar, no se inventa la fórmula.

### 8. Valores sospechosos

Cada uno se cuenta y se reporta con las filas que afecta:

- **Nombre de vendedor sin anonimizar** donde debería ir `Nombre Aseguradora` o `Nombre del Dealer` (ver chequeo 4).
- **`¿Qué aseguradora le ofreció primero?` con valor real en filas de Televentas**, donde corresponde "No Aplica"; o con "No Aplica" en Dealers/Corredores, donde corresponde una aseguradora.
- **Canal fuera del catálogo** (algo distinto de Televentas / Corredores / Dealers).
- **Celdas en blanco** donde la política pide un valor fijo; nunca vacías.
- **Tasa Neta con menos de seis decimales** o en formato General.
- **Precios en 0** y centinelas tipo `999999999`.
- **Moneda mezclada** dentro de una misma comparación.
- **`ID Resultado` repetido** o filas duplicadas.
- **`% de Evaluación` fuera de 0-100** o con un denominador que no calza con el canal.

### 9. ¿Lo relevado corresponde a lo que se pidió?

Las observaciones deben ser del ciclo en evaluación: se mide sobre `Fecha de carga` / `Fecha Cotización` y se declara el rango. Fuera del mes, se cuenta y se dice.

Se contrastan contra la ficha del ciclo, una por una, las condiciones fijas: el perfil del vehículo, el canal declarado, las aseguradoras del alcance y el ámbito geográfico. Lo que la base no permita comprobar se dice en la sección de lo no comprobado.

**No reemplaza abrir las capturas.** Ningún chequeo puede decir si lo que registró el checklist es lo que el vendedor efectivamente dijo o mostró en pantalla. Eso exige abrir las evidencias una por una y se declara aparte.

## Cuestionario CX de referencia

Estructura verificada contra `Vehicular - CX Estructura Evaluacion Vendedor - Pacifico 2025.xlsx`. Cada pregunta indica a qué canales aplica (Televentas / Corredores / Dealers).

| Sección | Pregunta |
|---|---|
| General | ID Asociado |
| Canal de Ventas | Elegir canal de ventas a evaluar |
| Compañía | Compañía Aseguradora |
| Indagación de Necesidades | ¿El asesor indagó por el tipo de uso que le dará al vehículo? |
| Indagación de Necesidades | ¿El asesor hizo preguntas sobre cuántos kilómetros recorría a diario? |
| Indagación de Necesidades | ¿El asesor hizo preguntas sobre aspectos particulares del auto? |
| Indagación de Necesidades | ¿Qué aseguradora le ofreció primero? (no aplica a Televentas) |
| Indagación de Necesidades | ¿El asesor explicó que había distintos tipos de seguros vehiculares? |
| Indagación de Necesidades | ¿El asesor le sugirió algún plan en particular? / ¿Cuál fue el plan? |
| Indagación de Necesidades | ¿El asesor le explicó por qué el plan era el indicado? (no aplica a Televentas) |
| Cotización | ¿Le indicaron si había algún descuento? / ¿Le ofrecieron descuento luego de preguntar? |
| Cotización | ¿El descuento dependía de alguna condición? / ¿Cuál era la condición? |
| Beneficios y Promociones | ¿El asesor ofreció algún beneficio adicional? / especifique |
| Beneficios y Promociones | ¿Tienen actualmente alguna promoción? / especifique |

**Discrepancia abierta a declarar.** El entregable de julio 2025 trae una pregunta que **no** está en el archivo de estructura: `¿Cuánto tiempo esperó para ser atendido por un consultor o asesor de ventas?` (valores: Menos de 1 minuto / Entre 1 y 5 minutos / Más de 5 minutos / N/A). El formato entregado manda sobre el de estructura, pero se declara la diferencia.

## De dónde sale cada referencia

| Referencia | Fuente |
|---|---|
| 29 columnas del checklist de precio | `2. Vehicular_Checklist_Precio_Report_Mystery_Shoppers - 30.07.2025.xlsx` |
| Columnas y `% de Evaluación` del checklist de evaluación | `3. Vehicular_Checklists_Evaluacion_Vendedor_Mystery_Shopper - 30.07.2025.xlsx`, hoja `Checklists_Evaluacion_Pacifico` |
| Cuestionario CX, secciones y aplicabilidad por canal | `Vehicular - CX Estructura Evaluacion Vendedor - Pacifico 2025.xlsx` |
| Dominio del enlace de evidencia | Columna `Link` de ambos checklists (`pacifico-analytics.bequarks.pe`) |
| Mystery Shopper dentro de la renovación 2026 | Propuesta de Alejandro Rollandi del 21/07/2026 y calculadoras de costo de julio 2026 |
| Método de tasa de respuesta por corredores | Resumen de corredores del ciclo junio 2026 (referencia de método) |

Cada referencia se vuelve a comprobar contra el entregable del mes en curso. Si cambia, se corrige aquí y se dice que cambió.

## Cómo se reporta

Cómo se entrega el resultado está en la skill `entregar-auditoria-bequarks`. Esta skill dice qué medir; esa dice cómo se presenta. Lo específico de esta cuenta:

**Sin calificativos.** Cada hallazgo dice qué pasa y a cuántas filas u observaciones afecta. La gravedad la decide Italo.

**Cada cifra dice de qué checklist y de qué canal salió.** Precio y evaluación son cosas distintas, y Televentas no se compara con Dealers sin decir que son canales distintos.

**Cada cifra dice de dónde salió.** Archivo, hoja, fila. Si no puede, no entra.

## Los tres límites

**No reemplaza abrir las capturas.** Está en el chequeo 9 y se repite: el precio y la respuesta del vendedor en el Excel no valen como verificados hasta abrir la evidencia.

**No recalcula el `% de Evaluación` sin la rúbrica.** Mientras no exista la regla de puntaje por escrito, ese porcentaje se reporta como no verificado.

**No decide.** Entrega qué pasa y a cuánto afecta. Enviar, corregir o parar la entrega es de Italo.
