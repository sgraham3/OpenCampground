class RememberLogin < ActiveRecord::Base
  belongs_to :user

  def reset_token
    @token_expires = 2.weeks.from_now
  end
end
