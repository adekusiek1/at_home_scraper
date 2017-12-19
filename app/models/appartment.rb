class Appartment < ApplicationRecord
  has_many :links, dependent: :destroy
  # return the ratio of profit / original_price
  def delta_gain
    # return 100 in order to hide data that is not updated
    return 100 if self.pre_monthly_rent.nil? || self.delta_monthly_rent.nil?
    original_rent = self.pre_monthly_rent - self.delta_monthly_rent
    gained_ratio = self.delta_monthly_rent / original_rent
    return gained_ratio
  end

  def round_to_10K
    out = self.delta_monthly_rent / 10000.0
    return out.round(2)
  end
end
