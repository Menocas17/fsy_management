# Cargas masivas de prueba

Datos inventados (correos `@example.com`, teléfonos al azar) para probar la carga masiva de punta a punta.
Los archivos de personas siguen el formato oficial de la Iglesia, más la columna «Nombre» que le falta.

Antes de empezar, crea en **Logística › Áreas** estas cuatro áreas con su bandera:
Finanzas (finanzas), Registro (registro), Alimentación (alimentación) y Enfermería (enfermería).
Si no existen, la logística queda en espera con el aviso «El área no existe».

Súbelos en este orden, desde **Carga masiva**:

| # | Archivo | Pestaña | Qué trae |
|---|---------|---------|----------|
| 1 | `1_companias.xlsx` | Compañías | 25 compañías en 5 compañías auxiliares (Alfa…Épsilon, 5 cada una); 1–13 en Salón Nicaragua, 14–25 en Salón Las Américas |
| 2 | `2_direccion_y_logistica.xlsx` | Jóvenes (manda la columna Rol) | Matrimonio director, coordinadores y directores de logística (cada pareja, contacto de emergencia del otro); 10 auxiliares (un hombre y una mujer por compañía auxiliar); 15 de logística: 1 Finanzas, 5 Registro, 5 Alimentación, 4 Enfermería |
| 3 | `3_consejeros.xlsx` | Consejeros | 50 consejeros: un hombre y una mujer por compañía |
| 4 | `4_jovenes.xlsx` | Jóvenes | 512 jóvenes de 14 a 18 años (mitad hombres, mitad mujeres) de las cuatro estacas, sin compañía: se reparten después |

Con la base vacía, las 618 filas entran directo, sin ninguna en espera. Subir un archivo dos veces deja
todas sus filas en espera como duplicados.

Para no subirlos a mano, `bin/rails datos:sembrar` borra los datos y carga estos cuatro archivos de una vez,
con los jóvenes ya repartidos en compañías y cuartos (ver `docs/deploy_render.md`).
