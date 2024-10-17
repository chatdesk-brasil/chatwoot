# app/services/integrations/base_service.rb
class Integrations::CustomApi::ImportOrderBaseService
  pattr_initialize [:custom_api!]
  require 'net/http'
  require 'json'
  attr_reader :base_url, :api_key

  def import_orders
    raise 'Overwrite this method in child class'
  end

  def perform_request(endpoint:)
    uri = URI("#{custom_api['base_url']}#{endpoint}")
    req = Net::HTTP::Get.new(uri)
    req['Authorization'] = "Basic #{custom_api['api_key']}"

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == 'https') do |http|
      http.request(req) do |res|
        open('t.tmp', 'w') do |f|
          res.read_body do |chunk|
            f.write chunk.force_encoding('UTF-8')
          end
        end
      end
    end
    data = File.read('t.tmp', encoding: 'UTF-8')
    handle_response(response, data)
  end

  private

  def handle_response(response, data)
    case response.code.to_i
    when 200..299
      JSON.parse(data)
    else
      raise "API Error: #{response.code} - #{response.body}"
    end
  end

  def to_timestamp(date)
    Time.parse(date).to_i
  end

  def update_orders_last_update
    custom_api.update(orders_last_update: Time.zone.now)
  end
end
