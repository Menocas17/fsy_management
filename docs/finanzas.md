# Módulo de Finanzas — plan

Estado: **fases 1 y 2 implementadas**. Menú: el ítem «Finanzas», hoy deshabilitado.

## Alcance

Gastos del evento contra un presupuesto aprobado por categoría, en córdobas y dólares.
Fuera por ahora: cuotas de los jóvenes, fondos entregados (caja chica) e ingresos o donaciones.

## Quién hace qué

| Quién | Presenta | Aprueba | Consolida | Presupuesto, categorías y tipo de cambio |
|---|---|---|---|---|
| Logística del área **Finanzas** (`logistics_areas.finance`) | Sí | Sí¹ | Sí¹ | Ve |
| **Director de logística** | Sí | Sí¹ | Sí¹ | Define |
| Dirección y coordinación | Solo ven | | | Ven |
| Superadmin | Solo ve | | | Ve |
| Resto del staff | No ve Finanzas | | | |

¹ **Nunca la misma persona que dio el paso anterior**: quien presenta un gasto no lo aprueba, y quien
escribe una justificación no la aprueba. Lo hacen las dos personas de siempre: la de Finanzas y el
director de logística.

## Ciclo de un gasto

```
presentado ──aprobar──▶ aprobado ──subir factura──────────────────────────▶ consolidado
     │                      │
  rechazar              justificar (sin factura) ──▶ justificación pendiente ──aprobar──▶ consolidado
     ▼                                                        │
 rechazado                                                rechazar ──▶ vuelve a «aprobado» (falta la factura)
```

1. **Presentación.** Antes de comprar: concepto, monto estimado, moneda, categoría, área que lo pide,
   proveedor (si se sabe) y fecha prevista. Mientras está presentado se puede editar o retirar.
2. **Aprobación.** Otra persona lo aprueba o lo rechaza con motivo. Aprobado, el monto queda
   **comprometido** contra el presupuesto de su categoría.
3. **Consolidación.** Hecha la compra, se sube la **foto de la factura** con el **monto real** (puede
   diferir del estimado) y la fecha real. Con eso el gasto queda consolidado y el monto pasa de
   comprometido a **ejecutado**.
   - Si no hay factura, se escribe una **justificación** que otra persona debe aprobar. La app insiste
     en que cada gasto lleve comprobante: la justificación es la excepción y se ve marcada en los
     reportes.

Un gasto consolidado no se edita ni se borra: un error se corrige con otro movimiento (devolución o
ajuste), como en el inventario, para que totales e historial nunca se contradigan. Cada paso queda en el
Historial (categoría nueva «Finanzas»).

## Moneda y tipo de cambio

- Moneda base: **córdobas (C$)**. El presupuesto y todos los totales se muestran en C$.
- Cada gasto guarda su moneda original (C$ o US$) y el **tipo de cambio** usado.
- El director de logística fija el tipo de cambio del evento **antes de la semana del evento**; se
  precarga en cada gasto en dólares y **se puede cambiar en un gasto puntual** si el de la factura es
  otro. No se consulta en línea (funciona sin señal).

## Presupuesto

Un **presupuesto general** del evento, en C$, siempre. Además se pueden **agregar categorías** y, si se
quiere, darles **presupuesto propio**; sin categorías (o sin presupuesto propio) todo cuenta solo contra
el general. Un gasto sin categoría figura como «General». Una categoría con gastos no se puede borrar.

Para el general y cada categoría con presupuesto, el panel muestra:

- **Presupuesto** — lo aprobado.
- **Comprometido** — gastos aprobados que aún no se consolidan (monto estimado).
- **Ejecutado** — gastos consolidados (monto real).
- **Disponible** — presupuesto − comprometido − ejecutado. Ámbar desde el 80 %, rojo al pasarse.
- Aparte, lo **presentado** sin aprobar, para ver lo que viene.

Si los presupuestos de las categorías suman más que el general, el panel lo avisa.

## Pantallas

1. **Panel de Finanzas**: totales del evento y una tarjeta por categoría con su barra.
2. **Gastos**: lista con filtros por etapa, categoría, área, moneda y fecha. A cada aprobador le salen
   primero los que esperan su firma.
3. **Presentar gasto**: formulario pensado para el teléfono.
4. **Detalle del gasto**: su línea de tiempo (quién presentó, aprobó y consolidó, cuándo), la factura en
   grande y los botones del paso que toca.
5. **Presupuesto y tipo de cambio**: categorías, montos y la tasa del evento.

## Reportes (fase 2)

En el panel de Finanzas («Rendición PDF», «Excel») y en Reportes → Logística y finanzas. Los ve quien ve
Finanzas.

- **PDF de rendición** (`ExpensesReport`, horizontal): resumen del presupuesto, por categoría, ejecutado
  por área, detalle numerado de los gastos consolidados (con quién presentó, aprobó y consolidó), los
  aprobados que aún esperan factura, los justificados sin factura con su justificación, y un anexo por
  factura (foto reducida a JPEG, así entran las HEIC del iPhone; una factura en PDF queda indicada para
  adjuntarla aparte).
- **Excel** (`ExpensesWorkbook`, gema caxlsx): hojas «Resumen», «Gastos» (todos, cualquier etapa, montos
  como números, con filtro y encabezado fijo) y «Por categoría».

## Fases

1. Presupuesto, tipo de cambio, gastos con sus tres etapas, facturas, justificaciones y panel.
2. PDF de rendición y Excel.
3. Avisos push al acercarse al límite de una categoría o cuando un gasto espera aprobación, y
   reembolsos a quien pagó de su bolsillo.

## Pendiente (fase 1)

- Corregir un gasto ya consolidado con otro movimiento (devolución o ajuste): por ahora no hay pantalla.
