# Genera los íconos de la PWA a partir del logo: el mismo azul de la ficha de marca de la barra lateral
# (`--background-image-brand-tile` en app/assets/tailwind/application.css) con el logo encima.
#
#   bundle exec ruby script/pwa_icons.rb
#
# Lee el logo de `script/pwa_icons/logo.png` (PNG con fondo transparente; mientras más grande, más nítido
# queda el ícono) y escribe en public/:
#   icon-192.png, icon-512.png       cuadrado redondeado sobre transparente ("purpose": "any")
#   icon-maskable-512.png            a sangre, sin esquinas, logo dentro de la zona segura ("maskable")
#   apple-touch-icon.png (180)       a sangre y sin transparencia; iOS redondea las esquinas solo
#
# public/icon.png no se toca: es el logo suelto con fondo transparente (de ahí sale logo.png) y las
# notificaciones push lo usan de `badge`, que Android pinta solo por su silueta.
require "vips"
require "pathname"

ROOT = Pathname.new(File.expand_path("..", __dir__))

SOURCE = ROOT.join("script/pwa_icons/logo.png")
OUT = ROOT.join("public")

# Los dos extremos del degradado de la ficha de marca, pasados de oklch a sRGB:
# oklch(46% 0.115 255) → oklch(27% 0.085 258), a 155°.
def oklch_to_srgb(l, c, h)
  a = c * Math.cos(h * Math::PI / 180)
  b = c * Math.sin(h * Math::PI / 180)
  l_ = (l + 0.3963377774 * a + 0.2158037573 * b)**3
  m_ = (l - 0.1055613458 * a - 0.0638541728 * b)**3
  s_ = (l - 0.0894841775 * a - 1.2914855480 * b)**3
  linear = [
    4.0767416621 * l_ - 3.3077115913 * m_ + 0.2309699292 * s_,
    -1.2684380046 * l_ + 2.6097574011 * m_ - 0.3413193965 * s_,
    -0.0041960863 * l_ - 0.7034186147 * m_ + 1.7076147010 * s_
  ]
  linear.map do |v|
    v = v.clamp(0.0, 1.0)
    (v <= 0.0031308 ? 12.92 * v : 1.055 * v**(1 / 2.4) - 0.055) * 255
  end
end

FROM = oklch_to_srgb(0.46, 0.115, 255)
TO = oklch_to_srgb(0.27, 0.085, 258)
ANGLE = 155 * Math::PI / 180

# Degradado lineal como el de CSS: 0° apunta arriba, 90° a la derecha.
def background(size)
  dx = Math.sin(ANGLE)
  dy = -Math.cos(ANGLE)
  length = size * (dx.abs + dy.abs)
  xy = Vips::Image.xyz(size, size)
  t = ((xy[0] - size / 2.0) * dx + (xy[1] - size / 2.0) * dy) / length + 0.5
  t = (t < 0).ifthenelse(0, t)
  t = (t > 1).ifthenelse(1, t)
  bands = FROM.zip(TO).map { |from, to| t * (to - from) + from }
  bands[0].bandjoin(bands[1..]).cast(:uchar).copy(interpretation: :srgb)
end

# El logo recortado a su contenido y escalado para que su lado mayor ocupe `ratio` del ícono.
def logo(size, ratio)
  image = Vips::Image.new_from_file(SOURCE.to_s)
  image = image.colourspace(:srgb)
  image = image.bandjoin(255) unless image.has_alpha?
  left, top, width, height = image.extract_band(3).find_trim(threshold: 0, background: [ 0 ])
  image = image.crop(left, top, width, height)
  image.resize(size * ratio / [ width, height ].max, kernel: :lanczos3)
end

def compose(size, ratio)
  mark = logo(size, ratio)
  bg = background(size).bandjoin(255)
  bg.composite2(mark, :over, x: (size - mark.width) / 2, y: (size - mark.height) / 2)
end

# Máscara de cuadrado redondeado (radio ~22 %, como los íconos de iOS/Android) para la versión "any".
def rounded(image)
  size = image.width
  radius = (size * 0.22).round
  svg = %(<svg xmlns="http://www.w3.org/2000/svg" width="#{size}" height="#{size}">) +
        %(<rect width="#{size}" height="#{size}" rx="#{radius}" fill="#fff"/></svg>)
  mask = Vips::Image.svgload_buffer(svg).extract_band(3)
  image.extract_band(0, n: 3).bandjoin(mask)
end

abort "Falta el logo en #{SOURCE}" unless SOURCE.exist?

{ "icon-192.png" => 192, "icon-512.png" => 512 }.each do |name, size|
  rounded(compose(size, 0.66)).write_to_file(OUT.join(name).to_s)
end
# La zona segura de un ícono maskable es el círculo central de 80 % de diámetro: el logo va más chico.
compose(512, 0.56).write_to_file(OUT.join("icon-maskable-512.png").to_s)
compose(180, 0.66).flatten.write_to_file(OUT.join("apple-touch-icon.png").to_s)

puts "Íconos escritos en #{OUT}"
