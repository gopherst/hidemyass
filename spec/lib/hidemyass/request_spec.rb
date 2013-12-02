require "spec_helper"

describe HideMyAss::Request do

  let(:url)     { "127.0.0.1" }
  let(:res)     { double(on_complete: nil).as_null_object }
  let(:hydra)   { double.as_null_object }
  let(:proxies) { [{host: "1.2.3.4", port: "80"}] }
  let(:proxy)   { "http://#{proxies[0][:host]}:#{proxies[0][:port]}" }

  before do
    HideMyAss.stub(:hydra).and_return(hydra)
    HideMyAss.stub(:proxies).and_return(proxies)
  end

  [:get, :post, :put, :delete].each do |http_method|
    describe ".#{http_method}" do
      it "passes :#{http_method} message to typhoeus" do
        Typhoeus::Request.should_receive(:new).
          with(url, { :method => http_method }.merge(proxy: proxy)).
          and_return(res)

        HideMyAss.send(http_method, url)
      end
    end
  end

end