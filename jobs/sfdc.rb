require 'net/https'
require "rubygems"
require 'json'
require 'restforce'

client = Restforce.new :host => 'test.salesforce.com'

# :first_in sets how long it takes before the job is first run. In this case, it is run immediately
SCHEDULER.every '1m', :first_in => 0 do |job|

  cases = client.query("select CaseNumber, Priority from Case where RecordTypeId = '01270000000YSPVAA4' and Priority = 'Critical' and Status = 'New'")
  data = cases.map{|c| {label: c.CaseNumber , value: c.Priority}}


  ccases = client.query("select CaseNumber, Owner.Name, Priority from Case where RecordTypeId = '01270000000YSPVAA4' and Priority = 'Critical' and Status != 'Closed'")
  cdata = ccases.map{|c| [:label => c.CaseNumber, :value => c.Owner.Name]}

  send_event( "sfdc", { items: data })
  send_event( "sfdccritical", { items: cdata })

end
