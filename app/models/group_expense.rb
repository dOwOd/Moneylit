class GroupExpense < ApplicationRecord
  belongs_to :group
  belongs_to :expense, optional: true

end
