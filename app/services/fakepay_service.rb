class FakepayService

  attr_reader :conn

  def self.conn
    @conn ||= Faraday.new("https://www.fakepay.io/")
  end

  def self.post_json(url, options)
    conn.post do |c|
      c.url url
      c.headers["Authorization"] = "Token token=#{ENV["fakepay_api_key"]}"
      c.params['amount'] = options['amount']
      c.params['card_number'] = options["card_number"]
      c.params['cvv'] = options['cvv']
      c.params['expiration_month'] = options['expiration_month']
      c.params['expiration_year'] = options['expiration_year']
      c.params['zip_code'] = options['zip_code']
      c.params['token'] = options['token']
    end
  end

  def self.parse_json(payload)
    JSON.parse(payload, symbolize_names: true)
  end

  def self.check_amount_with_plan(object)
    plan = object[:plan_id]
    amount = object[:amount]
    if Subscription.validate_pricing[plan].include?(amount) != true
      render json: { :error =>  "The payment amount does not align with the price of the selected plan. Please check your POST request"}
      exit
    end
  end
end
