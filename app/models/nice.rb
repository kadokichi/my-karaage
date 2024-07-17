class Nice < ApplicationRecord
  belongs_to :user
  belongs_to :review
  counter_culture :review, column_name: "nices_count", touch: true
end
