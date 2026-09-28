# «iPhone · Safari», «Android · Chrome»… lo suficiente para reconocer un dispositivo en una lista.
module DeviceLabel
  module_function

  def for(user_agent)
    ua = user_agent.to_s
    os = case ua
    when /iPhone/ then "iPhone"
    when /iPad/ then "iPad"
    when /Android/ then "Android"
    when /Macintosh/ then "Mac"
    when /Windows/ then "Windows"
    when /Linux/ then "Linux"
    else "Otro"
    end
    browser = case ua
    when /Edg\// then "Edge"
    when /SamsungBrowser/ then "Samsung Internet"
    when /CriOS|Chrome\// then "Chrome"
    when /FxiOS|Firefox\// then "Firefox"
    when /Safari\// then "Safari"
    end
    [ os, browser ].compact.join(" · ")
  end
end
