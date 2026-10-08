# Pruebas de carga

Dos scripts en Ruby, sin gemas, que entran a la app como lo haría un teléfono: inician sesión por el
formulario real y piden pantallas. Solo leen (GET), así que no cambian datos.

- `pantallas.rb`: cuánto tarda cada pantalla y cada PDF con el servidor tranquilo.
- `usuarios.rb`: muchos usuarios a la vez, cada uno con una pausa entre pantalla y pantalla.

## Qué hace falta

Tres cuentas de prueba (una de dirección o superadmin, una de consejero con compañía, una de joven) con la
misma contraseña, y dos ids. En el servidor (`bin/kamal console`):

```ruby
c = User.find_by(email_address: "cuenta-del-consejero@…").participant
puts "COMPANIA_ID=#{c.company_id} JOVEN_DE_LA_COMPANIA_ID=#{Participant.joven.where(company_id: c.company_id).first.id}"
```

## Cómo correrlas

Desde **otra máquina en la misma región** que el droplet (un droplet por horas sirve): desde la casa se
mediría la subida del internet propio, no el servidor. Hace falta Ruby (`apt install ruby`).

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

## Referencia (octubre de 2026)

Medido con los datos de prueba del evento (`datos:sembrar`: 593 fichas, todas con foto), en una máquina de 4
vCPU y 15 GB con la configuración de `config/deploy.yml` (4 procesos de Puma detrás de Thruster), sin YJIT
(el droplet sí lo tiene, así que debería rendir algo mejor), con el generador en la misma máquina:

| Escenario | Peticiones/s | Mediana | p95 | Errores |
|-----------|--------------|---------|-----|---------|
| Pantallas de jóvenes y consejeros, una a la vez | — | 28–75 ms | — | — |
| 650 usuarios, una acción cada ~12 s | 54 | 87–96 ms | 235–291 ms | 0 |
| 650 usuarios, una acción cada ~8 s | 77 | ~0.45 s | 1–1.4 s | 0 |
| PDF de gafetes de todos | — | 5.6 s | — | — |

Con el servidor recién arrancado (sin calentar), la primera prueba de 650 usuarios dio p95 de ~0.65 s.
