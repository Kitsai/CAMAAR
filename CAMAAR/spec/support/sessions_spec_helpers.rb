module SessionsSpecHelpers
  def login_user(user)
    session[:user_id] = user.id
  end

  def expect_memoization_of_current_user(user, call_count: 2)
    login_user(user)
    expect(User).to receive(:find_by).once.and_return(user)
    call_count.times { helper.current_user }
  end
end

RSpec.configure do |config|
  config.include SessionsSpecHelpers, type: :helper
end
