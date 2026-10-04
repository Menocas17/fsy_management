---
name: FSY Management
description: La herramienta con la que el comité organiza FSY 2026 Managua-Caribe, para el escritorio y el teléfono.
colors:
  primary: "oklch(39% 0.105 258)"
  primary-deep: "oklch(33% 0.095 258)"
  primary-soft: "oklch(93% 0.025 245)"
  primary-mist: "oklch(97% 0.012 245)"
  sun: "oklch(78% 0.14 78)"
  ink: "oklch(24% 0.02 260)"
  ink-muted: "oklch(40% 0.018 260)"
  ink-quiet: "oklch(56% 0.015 260)"
  surface: "oklch(99% 0.003 260)"
  canvas: "oklch(96.5% 0.006 258)"
  line: "oklch(90% 0.008 258)"
  line-soft: "oklch(93.5% 0.006 258)"
  cat-blue: "oklch(62% 0.13 230)"
  cat-blue-ink: "oklch(47% 0.12 230)"
  cat-blue-solid: "oklch(56% 0.13 230)"
  cat-indigo: "oklch(55% 0.16 275)"
  cat-indigo-ink: "oklch(45% 0.16 275)"
  cat-indigo-solid: "oklch(52% 0.16 275)"
  cat-green: "oklch(62% 0.15 148)"
  cat-green-ink: "oklch(46% 0.13 148)"
  cat-green-solid: "oklch(56% 0.14 148)"
  cat-amber: "oklch(72% 0.14 70)"
  cat-amber-ink: "oklch(50% 0.12 70)"
  cat-amber-solid: "oklch(62% 0.14 70)"
  cat-rose: "oklch(60% 0.17 15)"
  cat-rose-ink: "oklch(48% 0.17 15)"
  cat-rose-solid: "oklch(55% 0.17 15)"
  cat-teal: "oklch(60% 0.1 195)"
  cat-teal-ink: "oklch(46% 0.09 195)"
  cat-teal-solid: "oklch(56% 0.1 195)"
  danger: "oklch(52% 0.17 25)"
typography:
  stat:
    fontFamily: "Onest, sans-serif"
    fontSize: "34px"
    fontWeight: 800
    lineHeight: 1
    letterSpacing: "-0.02em"
  display:
    fontFamily: "Onest, sans-serif"
    fontSize: "22px"
    fontWeight: 800
    lineHeight: 1.2
    letterSpacing: "-0.01em"
  title:
    fontFamily: "Onest, sans-serif"
    fontSize: "15px"
    fontWeight: 700
    lineHeight: 1.35
  body:
    fontFamily: "Onest, sans-serif"
    fontSize: "13px"
    fontWeight: 500
    lineHeight: 1.5
  label:
    fontFamily: "Onest, sans-serif"
    fontSize: "12px"
    fontWeight: 600
    lineHeight: 1.4
  meta:
    fontFamily: "Onest, sans-serif"
    fontSize: "11px"
    fontWeight: 700
    lineHeight: 1.4
    letterSpacing: "0.07em"
rounded:
  avatar-sm: "7px"
  inner: "7px"
  avatar: "10px"
  control: "11px"
  tile: "13px"
  card: "18px"
  panel: "22px"
  pill: "999px"
spacing:
  gutter-phone: "16px"
  gutter-desktop: "32px"
  section-gap: "20px"
  card-padding: "24px"
components:
  button-primary:
    backgroundColor: "{colors.primary}"
    textColor: "{colors.surface}"
    rounded: "{rounded.control}"
    height: "40px"
    padding: "0 16px"
  button-primary-hover:
    backgroundColor: "{colors.primary-deep}"
  button-secondary:
    backgroundColor: "{colors.surface}"
    textColor: "{colors.ink-muted}"
    rounded: "{rounded.control}"
    height: "40px"
    padding: "0 16px"
  card:
    backgroundColor: "{colors.surface}"
    rounded: "{rounded.card}"
    padding: "24px"
  stat-tile-icon:
    backgroundColor: "{colors.cat-green-solid}"
    textColor: "{colors.surface}"
    rounded: "{rounded.tile}"
    size: "52px"
  section-heading-icon:
    backgroundColor: "{colors.primary-soft}"
    textColor: "{colors.primary}"
    rounded: "{rounded.tile}"
    size: "34px"
  chip:
    rounded: "{rounded.pill}"
    typography: "{typography.label}"
    height: "24px"
    padding: "0 10px"
  input:
    backgroundColor: "{colors.surface}"
    textColor: "{colors.ink}"
    rounded: "{rounded.control}"
    height: "40px"
---

# Design System: FSY Management

## Overview

**Creative North Star: "Casa abierta"**

FSY Management es la casa donde trabaja el comité de un evento de jóvenes: coordinadores, consejeros, registradores y logística entran a la misma puerta, muchos desde el teléfono, de pie y a pleno sol durante la semana. La casa tiene que sentirse acogedora y ordenada a la vez: el azul marino es la institución que sostiene todo, el sol es lo que está pasando ahora, y los colores de categoría ayudan a reconocer cosas (una estaca, un área, un tipo de actividad) sin convertir cada pantalla en un tablero de luces.

La calidez vive en los detalles, no en el ruido: frases completas y amables en español, estados vacíos que dicen qué hacer, banners con la cuenta regresiva y la escritura, avatares cuadrados como fotos de credencial. La densidad es la de una herramienta de trabajo diario: tarjetas con aire, letra pequeña pero nunca diminuta, y un solo botón principal por pantalla.

Todas las páginas comparten el mismo marco, el mismo encabezado de sección y las mismas piezas, para que pasar de Jóvenes a Finanzas se sienta como cambiar de cuarto dentro de la misma casa, no como entrar a otra aplicación.

**Key Characteristics:**
- Azul marino institucional, sol para "ahora", seis colores de categoría con tinte, tinta y relleno sólido.
- Onest en toda la interfaz; cinco tamaños de letra y una cifra grande.
- Superficies claras con sombras suaves y esquinas generosas; nada salta.
- Dos anchos de página: ancho para listas y tableros, angosto y centrado para formularios.
- Pensada primero para el teléfono durante el evento: botones de 44 px o más, letra que crece sola en pantallas chicas.

## Colors

Un azul marino que sostiene, un sol que marca el momento y una paleta de categorías que siempre aparece en una de tres intensidades.

### Primary
- **Azul FSY** (oklch(39% 0.105 258)): botones principales, enlaces, la marca. El banner y el panel de marca usan su degradado más profundo.
- **Azul FSY profundo** (oklch(33% 0.095 258)): hover del botón principal y texto sobre tintes azules.
- **Neblina azul** (oklch(97% 0.012 245)) y **azul suave** (oklch(93% 0.025 245)): fondo de la opción activa del menú, mosaicos de encabezado neutros, hover de filas.

### Secondary
- **Sol** (oklch(78% 0.14 78)): solo para lo que pasa ahora (la opción activa, la cuenta regresiva, lo de hoy). Se usa poco a propósito.

### Tertiary
- **Categorías** (azul, índigo, verde, ámbar, rosa, verde azulado): cada una tiene tres formas. El **tinte** (el color al 15 %) es el fondo de mosaicos de encabezado, chips y estados; la **tinta** (`-ink`) es el texto y el ícono encima de ese tinte; el **sólido** (`-solid`) es el relleno de las cifras clave y las barras, con ícono blanco.

### Neutral
- **Tinta** (oklch(24% 0.02 260)): títulos y cifras. **Tinta media** (oklch(40% 0.018 260)): texto de cuerpo. **Tinta quieta** (oklch(56% 0.015 260)): texto secundario y cejas.
- **Superficie** (oklch(99% 0.003 260)): tarjetas. **Lienzo** (oklch(96.5% 0.006 258)): el fondo de la página y los bloques internos.
- **Línea** y **línea suave**: bordes de campos y divisores dentro de tarjetas.
- **Peligro** (oklch(52% 0.17 25)): solo botones de borrar y anular.

### Named Rules
**La regla de color.** Sólido solo para las cifras clave que abren un módulo, la acción principal y lo seleccionado. Tinte al 15 % para encabezados de sección, categorías, estados y chips. Neutro para todo lo demás. Si una pantalla tiene más de cuatro rellenos sólidos, sobra alguno.

**La regla del color propio.** Lo que la persona colorea a su gusto (un inventario, una categoría de gasto) conserva su relleno sólido: ese color es su identidad, no una categoría de la paleta. Es la única excepción a la regla de color, y solo en el mosaico de ese elemento.

**Las otras dos excepciones.** Los avatares de iniciales usan su propia paleta de quince tonos (AvatarComponent): su trabajo es distinguir a una persona de otra, no categorizar. Los visores de cámara (registro, escanear, inventario) van sobre azul FSY profundo (primary-950), que se queda oscuro en los dos modos.

**La regla del sol.** El sol nunca decora: marca lo que está ocurriendo ahora. Una pantalla tiene como mucho un elemento de sol.

**La regla de la tinta.** Texto sobre un tinte siempre en su tinta (`text-cat-*-ink`), nunca en el tono base: en letra chica no llega a 4.5:1.

## Typography

**Display Font:** Onest (con sans-serif)
**Body Font:** Onest (con sans-serif)

**Character:** Una sola familia, redonda y clara, que se lee bien en un teléfono a pleno sol. La jerarquía la dan el peso y el tamaño, no otra fuente.

### Hierarchy
- **Stat** (800, 34px, 1): la cifra grande de un mosaico de cifra. Solo ahí.
- **Display** (800, 22px, 1.2): el título de la página en la barra superior y los títulos de diálogos.
- **Title** (700, 15px, 1.35): títulos de tarjetas y secciones.
- **Body** (500, 13px, 1.5): texto de cuerpo, celdas de tabla, valores.
- **Label** (600, 12px, 1.4): etiquetas de campos, chips, botones chicos, texto de apoyo.
- **Meta** (700, 11px, 0.07em, mayúsculas): cejas y encabezados de tabla.

### Named Rules
**La regla de los cinco tamaños.** Fuera de la cifra grande, solo existen 11, 12, 13, 15 y 22 (`text-meta`, `text-label`, `text-body`, `text-title`, `text-display`). Nada por debajo de 11. Los tamaños sueltos de medio píxel (`text-[12.5px]`, `text-[13.5px]`) se irán reemplazando por el más cercano.

**La regla de la letra que crece.** En pantallas de menos de 768 px toda la escala se multiplica por 1.15, y «Texto grande» la sube otro escalón. Por eso los tamaños de la escala son tokens, no píxeles fijos.

## Layout

Cada página vive en el mismo marco: 16 px de margen lateral en el teléfono y 32 px en escritorio, 24 px arriba (32 en escritorio) y 40 abajo. Hay exactamente dos anchos:

- **Ancho** (hasta 1400 px, `max-w-page`): listas, tablas, el inicio, la agenda, áreas, finanzas, inventario, historial.
- **Formulario** (768 px centrado, `max-w-form`): crear y editar, ajustes, una alerta, notificaciones.

Bajo la barra superior, una página empieza con su encabezado: una frase corta o un conteo a la izquierda y las acciones a la derecha (una principal como mucho). Luego, si el módulo tiene cifras clave, una fila de mosaicos de cifra; después las tarjetas. Entre bloques, 20 px.

En el teléfono todo se apila a una columna, las filas de filtros se deslizan de lado dentro de su fila (nunca la página entera), las tablas se vuelven tarjetas y las explicaciones largas se pliegan.

## Elevation & Depth

Un sistema de capas suaves: el lienzo gris claro al fondo, las tarjetas blancas encima con una sombra difusa, y los menús y diálogos un nivel más arriba. La profundidad separa capas; no se usa para decorar ni para llamar la atención.

### Shadow Vocabulary
- **Reposo** (`box-shadow: 0 1px 2px oklch(20% 0.02 260 / 0.06)`): campos y mosaicos chicos.
- **Tarjeta** (`box-shadow: 0 6px 20px -6px oklch(20% 0.03 260 / 0.14), 0 1px 2px oklch(20% 0.02 260 / 0.06)`): toda tarjeta de contenido.
- **Flotante** (`box-shadow: 0 20px 40px -12px oklch(20% 0.05 260 / 0.22)`): menús desplegables, diálogos, avisos.

### Named Rules
**La regla de los tres niveles.** Solo existen reposo, tarjeta y flotante (`shadow-sm`, `shadow-md`, `shadow-lg`). Nada de `shadow-xl` ni `shadow-2xl`.

## Shapes

Esquinas generosas y consistentes por función: los controles (botones, campos, pestañas) a 11 px, los mosaicos y bloques internos a 13 px, las tarjetas a 18 px y los paneles grandes (el banner, la ficha) a 22 px. Las opciones dentro de un control con relleno (un conmutador) usan 7 px, para que la curva acompañe a la de afuera. Los chips son píldoras. Los avatares son cuadrados con la proporción de la foto de la ficha: 10 px a 40 px y 7 px a 28 px.

**La regla de los tokens de esquina.** Toda esquina sale de un token (`rounded-control`, `rounded-inner`, `rounded-tile`, `rounded-card`, `rounded-panel`, `rounded-avatar`, `rounded-full` para chips y puntos). `rounded-lg`, `rounded-xl` y valores sueltos como `rounded-[10px]` no se usan.

## Components

Firmes y tranquilos: responden al toque con una presión leve, no saltan ni brillan.

### Buttons
- **Shape:** esquina de control (11px), 40 px de alto (44 en el teléfono).
- **Primary:** azul FSY con texto blanco, semibold. Uno por pantalla.
- **Secondary:** superficie con borde de línea y tinta media. Para todo lo demás.
- **Danger:** borde rosa y tinta rosa en reposo; relleno de peligro solo dentro de la confirmación.
- **Hover / Focus:** hover cambia el fondo un paso; foco con anillo azul de 2 px. Al presionar se encoge a 0.97.

### Chips
- **Style:** píldora de 24 px, letra label en negrita, fondo de tinte y texto en su tinta. Gris (lienzo y tinta media) para lo informativo como «Solo lectura».
- **State:** no son botones; los filtros aplicados usan la misma forma con una X.

### Cards / Containers
- **Corner Style:** card (18px).
- **Background:** superficie, con borde de línea suave.
- **Shadow Strategy:** la sombra de tarjeta.
- **Internal Padding:** 24 px (20 en tarjetas de lista, 16 en el teléfono).

### Section heading
Mosaico teñido de 34 px con esquina tile y el ícono en su tinta, seguido del título (15, bold). A la derecha, como mucho una acción o un conteo. Es el único encabezado de sección de la aplicación.

### Stat tile
- **Grande:** tarjeta con mosaico sólido de 52 px e ícono blanco, la cifra (34) y su etiqueta (13). Las 3 o 4 cifras que abren un módulo. Si lleva a otra página, una flecha a la derecha.
- **Chico:** bloque de lienzo con mosaico teñido de 34 px, cifra de 22 y etiqueta de 12. Cifras de apoyo dentro de una tarjeta.

### Empty state
Recuadro de borde punteado, mosaico teñido de 40 px, un título corto, una frase que dice qué hacer y, si la persona puede, un botón secundario. Uno solo para toda la aplicación.

### Inputs / Fields
- **Style:** superficie, borde de línea, esquina de control, 40 px de alto (16 px de letra en el teléfono para que Safari no haga zoom).
- **Focus:** borde azul y anillo azul al 30 %.

### Navigation
Menú lateral con grupos plegables, la opción activa en neblina azul con una barra de sol a la izquierda. En el teléfono, el mismo menú en un cajón. La barra superior lleva la ceja del grupo y el título de la página.

## Do's and Don'ts

### Do:
- **Do** usar el marco de página con uno de sus dos anchos (`max-w-page` o `max-w-form`).
- **Do** abrir cada sección de una tarjeta con el encabezado de sección (mosaico teñido de 34 px y título de 15).
- **Do** dar a las cifras clave de un módulo el mosaico de cifra grande con su color sólido.
- **Do** usar el estado vacío común cuando no hay nada que mostrar, con la acción que corresponde.
- **Do** escribir el texto sobre un tinte en su tinta (`text-cat-*-ink`).

### Don't:
- **Don't** usar colores sueltos de Tailwind (`bg-emerald-600`, `text-amber-700`, `slate-*`): todo color sale de los tokens. Para el modo oscuro, `muted` (hover y rellenos neutros) y `sunken` (bloques hundidos) ya traen su valor oscuro.
- **Don't** poner más de un botón principal en una pantalla.
- **Don't** usar rellenos sólidos para encabezados de sección, chips o decoración.
- **Don't** usar letra de menos de 11 px.
- **Don't** fijar un `max-w-*` propio en una página; el ancho lo decide el marco.
