require "spec_helper"

describe HideMyAss::IP do

  # Typically we would use webmock here to fake the http request,
  # but hidemyass.com seems to be changing their encoding strategy often.
  # By having real data we ensure this gem is working.
  it "decodes encoded address" do
    html = HideMyAss.send(:get_hma_body)

    expect(HideMyAss::IP.new(html.at_xpath('//table[@id="listable"]/tbody/tr/td[2]/span')))
      .to be_valid
  end
end