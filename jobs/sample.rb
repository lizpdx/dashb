#current_valuation = 0
#current_karma = 0

#SCHEDULER.every '60s' do
#  last_valuation = current_valuation
#  last_karma     = current_karma
#  current_valuation = rand(100)
#  current_karma     = rand(200000)

#  send_event('valuation', { current: current_valuation, last: last_valuation })
#  send_event('karma', { current: current_karma, last: last_karma })
#  send_event('synergy',   { value: rand(100) })
#end

require "net/http"
require "json"

symbol = "AMZN"
query  = URI::encode "select * from yahoo.finance.quotes where symbol='#{symbol}'&format=json&env=http://datatables.org/alltables.env&callback="

SCHEDULER.every "30s", :first_in => 0 do |job|
  http     = Net::HTTP.new "query.yahooapis.com"
  request  = http.request Net::HTTP::Get.new("/v1/public/yql?q=#{query}")
  response = JSON.parse request.body
  results  = response["query"]["results"]["quote"]

  if results
  quote = {
        name: results['Name'],
        symbol: results['Symbol'],
        price: results['LastTradePriceOnly'],
        change: results['Change'],
        percentchange:  results['PercentChange'],
        lasttradetime: results['LastTradeTime']
    }
  
    send_event "valuation", quote
  end
end
