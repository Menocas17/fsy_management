# frozen_string_literal: true

# Lo que se ve mientras llega algo que se pide aparte (un turbo-frame perezoso): la forma de lo que viene,
# con un brillo que pasa (.skeleton en application.css). Solo donde se sabe qué forma tiene lo que llega; una
# página entera no lleva esqueleto, la barra de progreso de arriba ya avisa. Para los lectores de pantalla
# es un «Cargando…» y nada más.
#
#   :rows     filas de lista con su ícono a la izquierda (la campanita)
#   :details  filas de info_row: ícono, etiqueta y valor (el detalle de una actividad de la agenda)
#   :qr       el código QR con el nombre debajo («Mi QR»)
class SkeletonComponent < ViewComponent::Base
  VARIANTS = %i[rows details qr].freeze

  def initialize(variant:, count: 3, label: "Cargando…")
    raise ArgumentError, "variante desconocida: #{variant}" unless VARIANTS.include?(variant)

    @variant = variant
    @count = count
    @label = label
  end

  def call
    tag.div(role: "status", class: "skeleton-in", data: { skeleton: @variant }) do
      safe_join([ tag.span(@label, class: "sr-only"), tag.div(send(@variant), aria: { hidden: true }) ])
    end
  end

  private

  def bar(classes)
    tag.span(class: "skeleton block rounded-full #{classes}")
  end

  def rows
    tag.div(class: "divide-y divide-line-soft") do
      safe_join(Array.new(@count) do |index|
        tag.div(class: "flex items-start gap-3 px-5 py-3.5") do
          tag.span(class: "skeleton mt-0.5 size-9 shrink-0 rounded-control") +
            tag.div(class: "min-w-0 flex-1 flex flex-col gap-2 pt-1") do
              bar("h-3.5 #{index.odd? ? "w-1/2" : "w-3/5"}") + bar("h-3 w-full") + bar("h-3 w-4/5")
            end
        end
      end)
    end
  end

  def details
    tag.div(class: "flex flex-col") do
      safe_join(Array.new(@count) do |index|
        tag.div(class: "flex items-start gap-3 py-3 first:pt-0 last:pb-0 border-t first:border-t-0 border-line-soft") do
          tag.span(class: "skeleton size-[34px] shrink-0 rounded-control") +
            tag.div(class: "min-w-0 flex-1 flex flex-col gap-2 pt-1") do
              bar("h-3 w-16") + bar("h-3.5 #{%w[w-2/3 w-1/2 w-3/4][index % 3]}")
            end
        end
      end)
    end
  end

  def qr
    tag.div(class: "flex flex-col items-center") do
      bar("h-4 w-3/5 mb-5 mt-1") +
        tag.span(class: "skeleton block size-[200px] rounded-tile") +
        bar("h-6 w-28 mt-4") + bar("h-3.5 w-40 mt-3") + bar("h-3 w-52 mt-2")
    end
  end
end
