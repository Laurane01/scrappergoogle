# require 'nokogiri'
# require 'open-uri'
# require 'json'


class Scrapper

  @@name_and_email = []

  def url_and_name
    url = "http://annuaire-des-mairies.com/val-d-oise.html"
    doc = Nokogiri::HTML(open(url))
    url_path = doc.css("a[href].lientxt")
    name_and_url = []

    url_path.map do |value|
      url_ville = value["href"]
      url_ville[0] = ""
      name_and_url << { "name" => value.text, "url" => "http://annuaire-des-mairies.com" + url_ville }
    end
    name_and_url
  end

  def get_townhall_email(url)
    doc = Nokogiri::HTML(open(url))
    email = doc.xpath("/html/body/div/main/section[2]/div/table/tbody/tr[4]/td[2]").text
  end

  def get_all_email(name_and_url)
    @@name_and_email = []

    name_and_url.map.with_index do |value, i|
      @@name_and_email << {value["name"] => get_townhall_email(value["url"])}
    end
    @@name_and_email
  end

  def save_to_JSON 
    json = File.open('/home/laurane/Desktop/THP/Ma2201/db/email.json', "w") do |f|
      f.write(@@name_and_email.to_json)
    end 
  end 


  def save_to_spreadsheets
    session = GoogleDrive::Session.from_config("config.json")
    ws = session.spreadsheet_by_key("1WxhzpA3Si9N_9E8bLiEs1Otl4IfAThpDn7IBSBc7C5Q").worksheets[0]
    ws[1, 1] = "name"
    ws[1, 2] = "email"
i=2 # on bloque le i a 2 car on ne veut pas copier sur 1 qui concerne les titres alors on fixe a 2.
@@name_and_email.each do |town|
  ws[i, 1] = town.keys.join 
  ws[i, 2] = town.values.join
  i=i+1
end 
ws.save

end


 def save_as_csv 
  # on met b veut dire binaire pour eviter des erreurs de format.

        CSV.open("./db/emails.csv", "wb") do |csv|

          @@name_and_email.each do |element|

            csv << [element.keys.join.to_s, element.values.join.to_s]
# on rajoute tout to_s car on peut pas faire le .join sur un array.
          end

        end

    end

def perform
  puts get_all_email(url_and_name())
  save_to_spreadsheets
  save_as_csv
end
end 


# scrap = Scrapper.new
# scrap.perform