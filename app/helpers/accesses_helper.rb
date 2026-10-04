module AccessesHelper
  RESULT_CHIPS = {
    "success" => "bg-cat-green/15 text-cat-green-ink",
    "failed" => "bg-cat-rose/15 text-cat-rose-ink",
    "blocked" => "bg-cat-amber/20 text-cat-amber-ink"
  }.freeze

  # «ahora», «hace 12 min», «hace 3 h»; más atrás, la fecha y hora.
  def ago_label(time)
    seconds = Time.current - time
    if seconds < 60 then "ahora"
    elsif seconds < 1.hour then "hace #{(seconds / 60).floor} min"
    elsif seconds < 1.day then "hace #{(seconds / 3600).floor} h"
    else SpanishDates.short_with_time(time)
    end
  end

  def login_result_chip(attempt)
    tag.span(attempt.result_label, class: "inline-flex items-center px-2.5 py-1 rounded-full text-meta font-bold whitespace-nowrap #{RESULT_CHIPS.fetch(attempt.result)}")
  end

  def account_label(user)
    user.participant ? "#{user.participant.full_name} · #{user.role_label}" : user.role_label
  end
end
