require 'mechanize'
require 'nokogiri'
require 'open-uri'

class Ads
  def self.survey(surveyUrl, skipped=false)
    return {} if skipped == "true"
    doc = get_doc(surveyUrl)
    survey = doc.xpath("//ol[@class='survey']")[0].to_html
    auth_token = doc.xpath("//input[@name='authenticity_token']")[0]['value']
    ad_id = doc.xpath("//input[@name='ad_id']")[0]['value']
    { survey: survey,
      auth_token:auth_token,
      ad_id:ad_id
    }
  end

  def self.response(url, data)
    post url, data
  end

  def self.sample(adUrl)
    doc = get_doc(adUrl)
    mp4 = doc.xpath('//source[@type="video/mp4"]')[0]['src']
    webm = doc.xpath('//source[@type="video/webm"]')[0]['src']
    offer_id = doc.xpath('//div[contains(@class,"a2maonline")]')[0]['data-offering-id']
    duration = doc.xpath('//div[contains(@class,"a2maonline")]')[0]['data-duration']
    title =  doc.xpath('//h3').text.chop.reverse.chop.reverse
    ad_id = doc.xpath('//input[@id="ad_id"]')[0]['value']
    go_to_site_url = doc.xpath('//a[contains(@class,"go_to_site")]')[0]['href']
    content_container_url = doc.xpath('//div[contains(@class,"content-container")]')[0]['data-url']
    {
      mp4:mp4,
      webm:webm,
      offer_id:offer_id,
      duration:duration,
      title:title,
      ad_id:ad_id,
      go_to_site_url:go_to_site_url,
      content_container_url:content_container_url
    }
  end
  private
  #url must contain authentication_token
  def self.get_doc(url)
    robot = Mechanize.new
    sample = robot.get(url)
    Nokogiri::HTML sample.body
  end
  def self.post(url, data)
    robot = Mechanize.new
    sample = robot.post(url, data)
    sample.body
  end

end