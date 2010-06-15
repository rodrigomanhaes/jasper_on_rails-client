require 'net/http'

class JasperOnRailsClient

  def initialize(server, port)
    @server, @port = server, port
  end

  def request_report(options)
    data, report, format = options[:data], options[:report], options[:format]
    http = Net::HTTP.new(@server, @port)
    get = Net::HTTP::Get.new("/relatorio/#{report}.#{format}", nil)
    params = {}
    if options[:params]
      options[:params].each_pair do |param_name, param_value|
        params["report_params[#{param_name}]"] = param_value
      end
    end
    get.form_data = {:dados => data}.merge(params)
    http.request(get)
  end

end

