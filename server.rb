require 'net/http'
require 'sinatra'
require 'json'
require 'uri'

hyper_switch_api_key = 'HYPERSWITCH_API_KEY'
hyper_switch_api_base_url = 'https://sandbox.hyperswitch.io/payments'

set :static, true
set :port, 4242

# Securely calculate the order amount
def calculate_order_amount(_items)
  # Replace this constant with a calculation of the order's amount
  # Calculate the order total on the server to prevent
  # people from directly manipulating the amount on the client
  1400
end

# An endpoint to start the payment process
post '/create-payment' do

  data = JSON.parse(request.body.read)
  
  # If you have two or more “business_country” + “business_label” pairs configured in your Hyperswitch dashboard,
  # please pass the fields business_country and business_label in this request body.
  # For accessing more features, you can check out the request body schema for payments-create API here :
  # https://api-reference.hyperswitch.io/docs/hyperswitch-api-reference/60bae82472db8-payments-create
         
  payload = { amount: calculate_order_amount(data['items']), currency: 'USD', customer_id: 'hyperswitch_customer' }.to_json
  uri = URI.parse(hyper_switch_api_base_url)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  request = Net::HTTP::Post.new(uri.path,
                                'Content-Type' => 'application/json',
                                'Accept' => 'application/json',
                                'api-key' => hyper_switch_api_key)
  request.body = payload
  response = http.request(request)
  response_data = JSON.parse(response.body)
  {
    client_secret: response_data['client_secret']
  }.to_json

end
