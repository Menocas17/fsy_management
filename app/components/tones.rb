# frozen_string_literal: true

# Los colores de las piezas comunes, en un solo lugar (DESIGN.md, «regla de color»). TINT es el fondo al 15 %
# con el texto en su tinta (encabezados, categorías, chips); SOLID es el relleno con ícono blanco, solo para
# las cifras clave y lo seleccionado. El ámbar va al 20 %: al 15 % casi no se distingue del lienzo.
# Las clases van escritas enteras para que Tailwind las encuentre.
module Tones
  TINT = {
    primary: "bg-primary-100 text-primary-700 dark:bg-primary-700/30 dark:text-primary-100",
    blue: "bg-cat-blue/15 text-cat-blue-ink",
    indigo: "bg-cat-indigo/15 text-cat-indigo-ink",
    green: "bg-cat-green/15 text-cat-green-ink",
    amber: "bg-cat-amber/20 text-cat-amber-ink",
    rose: "bg-cat-rose/15 text-cat-rose-ink",
    teal: "bg-cat-teal/15 text-cat-teal-ink",
    neutral: "bg-canvas text-ink-700 dark:bg-slate-700 dark:text-slate-200"
  }.freeze

  SOLID = {
    primary: "bg-primary-700 text-white",
    blue: "bg-cat-blue-solid text-white",
    indigo: "bg-cat-indigo-solid text-white",
    green: "bg-cat-green-solid text-white",
    amber: "bg-cat-amber-solid text-white",
    rose: "bg-cat-rose-solid text-white",
    teal: "bg-cat-teal-solid text-white",
    neutral: "bg-ink-500 text-white"
  }.freeze

  def self.tint(tone) = TINT.fetch(tone.to_sym)
  def self.solid(tone) = SOLID.fetch(tone.to_sym)
end
