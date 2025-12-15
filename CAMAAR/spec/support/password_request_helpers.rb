module PasswordRequestHelpers
  def get_set_password_form(email)
    get set_password_path(email: email)
  end

  def post_set_password(email:, password:, password_confirmation:)
    post set_password_path, params: {
      email: email,
      password: password,
      password_confirmation: password_confirmation
    }
  end

  def expect_password_form_rendered
    expect(response).to have_http_status(:success)
    ['form', 'Senha', 'Confirmar'].each do |text|
      expect(response.body).to include(text)
    end
  end

  def expect_password_set_success(message: "Password set successfully")
    expect(response).to redirect_to(login_path)
    follow_redirect_if_needed
    expect(response.body).to include(message)
  end

  private

  def follow_redirect_if_needed
    follow_redirect! if response.status == 302
  end

  def expect_password_error(message)
    follow_redirect! if response.status == 302
    expect(response.body).to include(message)
  end

  def expect_password_not_set(user)
    user.reload
    expect(user.password_digest).to be_nil
  end

  def expect_password_set(user)
    user.reload
    expect(user.password_digest).not_to be_nil
  end

  def expect_password_authenticates(user, password)
    user.reload
    expect(user.authenticate(password)).to eq(user)
  end

  def expect_password_unchanged(user)
    original_digest = user.password_digest
    yield
    user.reload
    expect(user.password_digest).to eq(original_digest)
  end
end

RSpec.configure do |config|
  config.include PasswordRequestHelpers, type: :request
end
