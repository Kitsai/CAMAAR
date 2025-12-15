require 'rails_helper'

RSpec.describe User, type: :model do
  describe "validations" do
    it "is valid with factory" do
      user = build(:user)
      expect(user).to be_valid
    end

    include_examples "requires presence of", :email
    include_examples "requires unique", :email, :user

    describe "password validations" do
      it "allows user creation without password" do
        user = User.create(email: "test@example.com")
        expect(user).to be_persisted
        expect(user.password_digest).to be_nil
      end

      it "is valid with matching password and confirmation" do
        user = User.new(
          email: "test@example.com",
          password: "password123",
          password_confirmation: "password123"
        )
        expect(user).to be_valid
      end

      it "cannot update password without matching confirmation" do
        user = User.create!(email: "test@example.com")
        expect_password_update_fails(user, "password123", "different")
      end
    end
  end

  describe "password setup" do
    let(:user) { User.create!(email: "test@example.com") }

    it "can set password after creation" do
      expect_no_password_set(user)
      set_user_password(user, "newpassword")
      expect_password_set(user)
    end

    it "can authenticate after setting password" do
      set_user_password(user, "newpassword")
      expect_user_authenticates(user, "newpassword")
    end

    it "cannot authenticate with wrong password" do
      set_user_password(user, "newpassword")
      expect_authentication_fails(user, "wrongpassword")
    end
  end

  describe "associations" do
    it "has taught_courses association" do
      expect(User.reflect_on_association(:taught_courses)).to be_present
    end

    it "has enrollments association" do
      expect(User.reflect_on_association(:enrollments)).to be_present
    end

    it "has courses association" do
      expect(User.reflect_on_association(:courses)).to be_present
    end

    it "has admin association" do
      expect(User.reflect_on_association(:admin)).to be_present
    end

    it "has form_requests association" do
      expect(User.reflect_on_association(:form_requests)).to be_present
    end

    it "has forms association" do
      expect(User.reflect_on_association(:forms)).to be_present
    end
  end

  describe "#admin?" do
    it "returns true when user has admin record" do
      user = create(:user, :admin)
      expect(user.admin?).to be true
    end

    it "returns false when user has no admin record" do
      user = create(:user)
      expect(user.admin?).to be false
    end
  end
end
