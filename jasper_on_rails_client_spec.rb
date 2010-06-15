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
      @http.should_receive(:request).with(@get).and_return(mock(:read_body => nil))

      @client.request_report(:format => :pdf, :data => 'data to report',
                              :report => 'my_report')
    end

    it 'should deal with parameters' do
      Net::HTTP.stub!(:new).and_return(@http)
      Net::HTTP::Get.stub!(:new).and_return(@get)
      @http.stub!(:request).and_return(mock(:read_body => nil))

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

  context 'response' do
    before :each do # stub request
      http = mock
      get = mock
      Net::HTTP.stub!(:new).and_return(http)
      Net::HTTP::Get.stub!(:new).and_return(get)
      get.stub!(:form_data=)
      @response = mock
      http.stub!(:request).and_return(@response)
    end

    it 'should retrieve report data' do
      client = JasperOnRailsClient.new('localhost', 3000)
      @response.stub!(:read_body => 'result!')
      client.request_report({}).report_data.should == 'result!'
    end

    it 'should save report data to a file' do
      client = JasperOnRailsClient.new('localhost', 3000)
      @response.should_receive(:read_body).and_return('report data')
      file = mock
      File.should_receive(:open).and_yield(file)
      file.should_receive(:print).with('report data')
      client.request_report({}).save_to_file('result.pdf')
    end
  end

end

