require 'nokogiri'
require 'open-uri'
require_relative 'notifications'

user_agents = File.readlines("#{__dir__}/res/user_agents.txt")

def precio_to_float(precio)
  precio[2..-1].gsub(",",".").to_f
end

@previous_value_compra = nil
@previous_value_venta = nil

@history_file = "#{__dir__}/../#{Time.now.getutc.to_i.to_s}.csv"
open(@history_file, 'w') { |f|
  f.puts "timestamp,dolar_compra,dolar_venta,variacion,euro_compra,euro_venta"
}

while true do
  document = Nokogiri::HTML.parse(open("http://www.dolarhoy.com/", "User-Agent" => user_agents.sample))

  #Dolar
  section_dolar = document.xpath("//h4/span")
  precio_compra = precio_to_float(section_dolar.children[0].text)
  precio_venta = precio_to_float(section_dolar.children[1].text)

  #Euro
  section_euro = document.xpath('/html/body/div/div/div/div[1]/div[8]/table/tbody/tr[1]')
  precio_compra_euro = precio_to_float(section_euro.children[3].text)
  precio_venta_euro = precio_to_float(section_euro.children[5].text)

  variacion = 0.0
  message = "Compra: $ #{precio_compra} - Venta: $ #{precio_venta}"
  if @previous_value_venta != nil
    variacion = (precio_venta * 100 / @previous_value_venta - 100).round(2)
    if precio_venta > @previous_value_venta
      message = message + " ⇧ - Variación #{variacion}%"
      notify_sube(precio_venta, variacion)
    elsif precio_venta < @previous_value_venta
      message = message + " ⇩ - Variación #{variacion}%"
      notify_baja(precio_venta, variacion)
    else
      message = message + " - Variación #{variacion}%"
    end
  end
  puts message

  @previous_value_compra = precio_compra
  @previous_value_venta = precio_venta

  timestamp = Time.now.getutc.to_i
  open(@history_file, 'a') { |f|
    f.puts "#{timestamp},#{precio_compra},#{precio_venta},#{variacion},#{precio_compra_euro},#{precio_venta_euro}"
  }

  sleep 60.0
end
