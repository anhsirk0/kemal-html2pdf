require "kemal"
require "json"
require "wkhtmltopdf-crystal"

module Kemal_Html2pdf
  VERSION = {{ `shards version #{__DIR__}`.chomp.stringify }}
  Kemal.config.port = 8000

  pdf = Wkhtmltopdf::WkPdf.new "", true

  at_exit do
    pdf.deinitialize
  end

  post "/html2pdf" do |env|
    payload = Payload.from_json env.request.body.not_nil!
    # pdf.object_setting "footer.right", "[page] / [topage]" # Set page counter on footer
    pdf.convert payload.markup

    if (buf = pdf.buffer)
      env.response.content_type = "application/pdf"
      io = IO::Memory.new
      io.write(buf)
      io.to_s
    else
      {status: 500, message: "Internal Server Error"}.to_json
    end
  end
  
  Kemal.run
end

class Payload
  include JSON::Serializable

  property markup : String
end
