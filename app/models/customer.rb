class Customer < ApplicationRecord
  has_many :subscriptions, :dependent => :delete_all
  has_many :plans, :through => :subscriptions


  validates_presence_of :first_name,
                        :last_name,
                        :address,
                        :city,
                        :state,
                        :zip


##Noticed that I do my customer validation after i validate my transaction. This order needs to be reversed. Customer should be saved to database, then transaction is validated, and then authorization token should be saved to that customer. 
  def self.store_token(object, params, customer_data)
    customer = Customer.new(customer_data)
    begin
      customer.save!
      plan = Plan.find(params[:plan_id])
      self.set_plan(customer,plan, object)
    rescue ActiveRecord::RecordInvalid => e
      return {:error => e.to_s, message: "Customer not saved to the database", status: :record_invalid}
    end
  end

  def self.set_plan(customer, plan, object)
    customer.plans << plan
    self.set_token_and_save(customer, object)
  end

  def self.set_token_and_save (customer, object)
    customer.token = object[:token]
    self.save_and_return_success_hash(customer)
  end

  def self.save_and_return_success_hash(customer)
    customer.save
    return {:status =>  "You have successfully loaded a customer into the database"}
  end



end
