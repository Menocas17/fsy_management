# Pruebas de carga

Dos scripts en Ruby, sin gemas, que entran a la app como lo haría un teléfono: inician sesión por el
formulario real y piden pantallas. Solo leen (GET), así que no cambian datos.

- `pantallas.rb`: cuánto tarda cada pantalla y cada PDF con el servidor tranquilo.
- `usuarios.rb`: muchos usuarios a la vez, cada uno con una pausa entre pantalla y pantalla.

## Qué hace falta

Tres cuentas de prueba (una de dirección o superadmin, una de consejero con compañía, una de joven) con la
misma contraseña, y dos ids. En una consola de Rails conectada a esa base (en el droplet, `bin/kamal console`):

```ruby
c = User.find_by(email_address: "cuenta-del-consejero@…").participant
puts "COMPANIA_ID=#{c.company_id} JOVEN_DE_LA_COMPANIA_ID=#{Participant.joven.where(company_id: c.company_id).first.id}"
```

## Usar toda la máquina

Por defecto la app corre como para Render gratis (512 MB): un solo proceso de Puma y una foto a la vez. En
una máquina con más núcleos y memoria (tu laptop, un servidor propio), estas dos variables la aprovechan:

```bash
WEB_CONCURRENCY=auto        # un proceso de Puma por núcleo (Ruby usa un núcleo por proceso)
IMAGE_JOB_CONCURRENCY=auto  # fotos procesadas a la vez: todos los núcleos menos uno
```

En desarrollo, `IMAGE_JOB_CONCURRENCY=auto bin/dev` ya acelera las miniaturas; el resto del modo desarrollo
recarga el código en cada cambio y siempre será más lento que producción.

## Cómo correrlas

Contra un servidor remoto (el droplet), desde **otra máquina en la misma región** (una máquina virtual por horas sirve):
desde la casa se mediría la subida del internet propio, no el servidor. Contra la app en tu propia máquina,
`BASE_URL=http://127.0.0.1:3000`. Hace falta Ruby (`apt install ruby`).

```bash
export BASE_URL=https://<APP_HOST> PASSWORD=… \
       EMAIL_ADMIN=… EMAIL_CONSEJERO=… EMAIL_JOVEN=… COMPANIA_ID=… JOVEN_DE_LA_COMPANIA_ID=…
ruby -Iscript/carga script/carga/pantallas.rb
USUARIOS=650 PAUSA=12 SEGUNDOS=60 ruby -Iscript/carga script/carga/usuarios.rb   # una acción cada ~12 s
USUARIOS=650 PAUSA=8 SEGUNDOS=60 ruby -Iscript/carga script/carga/usuarios.rb    # el pico: cada ~8 s
```

El inicio de sesión admite 10 intentos cada 3 minutos por IP: `usuarios.rb` entra una vez por rol y reparte
esa sesión entre todos sus usuarios. Si el servidor se acaba de desplegar, corre una prueba corta antes de
medir: los primeros minutos Ruby todavía está agrandando su memoria y las pausas de limpieza son más largas.

## Con k6

[k6](https://grafana.com/docs/k6/) hace lo mismo que `usuarios.rb` (`script/carga/k6.js`: 60 % jóvenes, 30 %
consejeros, 10 % dirección, solo GET, una sesión por rol) pero con miles de usuarios desde una máquina chica, y
al final da mediana, p90, p95 y máximo **de cada pantalla**. Instalarlo: `brew install k6` en Mac, o
`sudo apt install k6` con el repositorio de Grafana en Linux (ver su guía).

```bash
k6 run -e BASE_URL=https://<APP_HOST> -e PASSWORD=… \
       -e EMAIL_ADMIN=… -e EMAIL_CONSEJERO=… -e EMAIL_JOVEN=… \
       -e COMPANIA_ID=… -e JOVEN_DE_LA_COMPANIA_ID=… \
       -e USUARIOS=650 -e PAUSA=12 -e DURACION=2m script/carga/k6.js
```

Los usuarios entran durante un minuto, se quedan `DURACION` todos a la vez y salen en 30 s. Si el p95 de
alguna pantalla pasa de 1.5 s o más del 1 % de las respuestas no es 200, k6 lo marca con ✗ y termina con
error. Con `--out web-dashboard` (o `K6_WEB_DASHBOARD=true`) abre gráficas en vivo en http://127.0.0.1:5665.

Desde tu casa se mide también tu internet: para números del servidor, córrelo en un droplet de 6 dólares en la
misma región (y bórralo después), o con Grafana Cloud k6 (`k6 cloud run`), que genera la carga desde sus
servidores.

## Referencia (octubre de 2026)

Medido con los datos de prueba del evento (`datos:sembrar`: 593 fichas, todas con foto), en modo producción
en una máquina de 4 vCPU y 15 GB, con `WEB_CONCURRENCY=4 IMAGE_JOB_CONCURRENCY=3` (4 procesos de Puma detrás
de Thruster, como en la imagen de Docker), sin YJIT (la imagen de Docker sí lo trae, así que ahí debería rendir
algo mejor), con el generador en la misma máquina:

| Escenario | Peticiones/s | Mediana | p95 | Errores |
|-----------|--------------|---------|-----|---------|
| Pantallas de jóvenes y consejeros, una a la vez | — | 28–75 ms | — | — |
| 650 usuarios, una acción cada ~12 s | 54 | 87–96 ms | 235–291 ms | 0 |
| 650 usuarios, una acción cada ~8 s | 77 | ~0.45 s | 1–1.4 s | 0 |
| PDF de gafetes de todos | — | 5.6 s | — | — |

Con el servidor recién arrancado (sin calentar), la primera prueba de 650 usuarios dio p95 de ~0.65 s.
