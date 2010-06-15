require 'net/http'
require 'jasper_on_rails_client'

describe JasperOnRailsClient do

  context 'request' do
    before :each do
      @client = JasperOnRailsClient.new('localhost', 3000)
      @http = mock
      @get = mock
    end

    it 'should submit request to jasper_on_rails' do
      Net::HTTP.should_receive(:new).with('localhost', 3000).and_return(@http)
      Net::HTTP::Get.should_receive(:new).with("/relatorio/my_report.pdf", nil).
        and_return(@get)
      @get.should_receive(:form_data=).with(:dados => 'data to report')
      @http.should_receive(:request).with(@get)

      @client.request_report(:format => :pdf, :data => 'data to report',
                              :report => 'my_report')
    end

    it 'should deal with parameters' do
      Net::HTTP.stub!(:new).and_return(@http)
      Net::HTTP::Get.stub!(:new).and_return(@get)
      @http.stub!(:request)

      @get.should_receive(:form_data=).with(
        :dados => 'data to report',
        'report_params[param_1]' => 'valor1',
        'report_params[param_2]' => 'valor2')

      @client.request_report(:format => :any, :data => 'data to report',
                             :report => 'anything',
                             :params => {
                               'param_1' => 'valor1', 'param_2' => 'valor2' })
    end
  end

end

