module UserModelHelpers
  def expect_no_password_set(user)
    expect(user.password_digest).to be_nil
  end

  def expect_password_set(user)
    expect(user.password_digest).not_to be_nil
  end

  def set_user_password(user, password)
    user.update(password: password, password_confirmation: password)
  end

  def expect_password_update_fails(user, password, wrong_confirmation)
    result = user.update(password: password, password_confirmation: wrong_confirmation)
    expect(result).to be_falsey
    expect(user.errors[:password_confirmation]).to be_present
  end

  def expect_user_authenticates(user, password)
    expect(user.authenticate(password)).to eq(user)
  end

  def expect_authentication_fails(user, wrong_password)
    expect(user.authenticate(wrong_password)).to be_falsey
  end
end

RSpec.configure do |config|
  config.include UserModelHelpers, type: :model
end
