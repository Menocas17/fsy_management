# Montos en centavos (enteros, nunca float) y su texto: «C$ 1,234.50», «US$ 20.00».
module Money
  CURRENCIES = { "NIO" => "C$", "USD" => "US$" }.freeze
  CURRENCY_LABELS = { "NIO" => "Córdobas (C$)", "USD" => "Dólares (US$)" }.freeze

  module_function

  # «1,234.50», «1234,5», «C$ 1 234», «1.234» → centavos. El último punto o coma es decimal solo si le
  # siguen uno o dos dígitos; si no, separa miles. nil si no hay número.
  def parse(text)
    cleaned = text.to_s.gsub(/[^\d.,]/, "")
    return nil unless cleaned.match?(/\d/)

    separator = cleaned.rindex(/[.,]/)
    if separator && cleaned.length - separator - 1 <= 2
      whole = cleaned[0...separator].delete(".,")
      fraction = cleaned[(separator + 1)..].ljust(2, "0")
    else
      whole = cleaned.delete(".,")
      fraction = "00"
    end
    whole.to_i * 100 + fraction.to_i
  end

  def format(cents, currency = "NIO")
    return "—" if cents.nil?

    amount = cents.abs / 100.0
    whole, fraction = Kernel.format("%.2f", amount).split(".")
    whole = whole.reverse.scan(/\d{1,3}/).join(",").reverse
    "#{"-" if cents.negative?}#{CURRENCIES.fetch(currency, currency)} #{whole}.#{fraction}"
  end

  # Para rellenar un campo de formulario: «1234.50».
  def to_input(cents)
    cents && Kernel.format("%.2f", cents / 100.0)
  end
end
