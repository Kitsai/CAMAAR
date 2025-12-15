module FormServiceHelpers
  def expect_form_requests_assigned_to(*users)
    user_ids = FormRequest.last(users.count).pluck(:user_id)
    expect(user_ids).to contain_exactly(*users.map(&:id))
  end
end

RSpec.configure do |config|
  config.include FormServiceHelpers, type: :service
end
