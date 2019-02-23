require 'nokogiri'
require 'open-uri'
require 'libnotify'

user_agents = File.readlines('user_agents.txt')

def precio_to_float(precio)
  precio[2..-1].gsub(",",".").to_f
end

#Linux Desktop Notification helpers
@should_notify = ARGV[0] == "-n" ? true : false

def notify_linux(title, body)
  Libnotify.show(:body => body, :summary => title, :timeout => 5.0)
end

def notify_sube(precio, variacion)
  notify_linux("Subió el dólar", "El dólar subío a $#{precio}. Una suba del #{variacion}% respecto de la última cotización")
end

def notify_baja(precio, variacion)
  notify_linux("Bajó el dólar", "El dólar bajó a $#{precio}. Una baja del #{variacion}% respecto de la última cotización")
end

@precios_compra = []
@precios_venta = []

@history_file = "#{Time.now.getutc.to_i.to_s}.csv"
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

  @precios_compra.push precio_compra
  @precios_venta.push precio_venta

  variacion = 0.0
  message = "Compra: $ #{precio_compra} - Venta: $ #{precio_venta}"
  if @precios_venta[-2] != nil
    variacion = precio_venta * 100 / @precios_venta[-2] - 100
    if precio_venta > @precios_venta[-2]
      message = message + " ⇧ - Variación #{variacion}%"
      if @should_notify then notify_sube(precio_venta, variacion) end
    elsif precio_venta < @precios_venta[-2]
      message = message + " ⇩ - Variación #{variacion}%"
      if @should_notify then notify_baja(precio_venta, variacion) end
    else
      message = message + " - Variación #{variacion}%"
    end
  end
  puts message

  timestamp = Time.now.getutc.to_i
  open(@history_file, 'a') { |f|
    f.puts "#{timestamp},#{precio_compra},#{precio_venta},#{variacion},#{precio_compra_euro},#{precio_venta_euro}"
  }

  sleep 60.0
end
