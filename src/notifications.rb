require 'libnotify'

@should_notify = ARGV[0] == "-n" ? true : false

def notify_linux(title, body)
  if @should_notify
    Libnotify.show(:body => body, :summary => title, :timeout => 5.0)
  end
end

def notify_sube(precio, variacion)
  notify_linux("Subió el dólar", "El dólar subío a $#{precio}. Una suba del #{variacion}% respecto de la última cotización")
end

def notify_baja(precio, variacion)
  notify_linux("Bajó el dólar", "El dólar bajó a $#{precio}. Una baja del #{variacion}% respecto de la última cotización")
end
