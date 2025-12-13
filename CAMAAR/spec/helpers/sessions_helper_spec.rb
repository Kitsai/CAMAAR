require 'rails_helper'

RSpec.describe SessionsHelper, type: :helper do
  describe "#current_user" do
    context "when user is logged in" do
      let(:user) { create(:user) }

      it "returns the current user" do
        session[:user_id] = user.id
        expect(helper.current_user).to eq(user)
      end

      it "memoizes the current user" do
        session[:user_id] = user.id
        expect(User).to receive(:find_by).once.and_return(user)
        2.times { helper.current_user }
      end
    end

    context "when user is not logged in" do
      it "returns nil" do
        expect(helper.current_user).to be_nil
      end
    end
  end

  describe "#logged_in?" do
    context "when user is logged in" do
      let(:user) { create(:user) }

      it "returns true" do
        session[:user_id] = user.id
        expect(helper.logged_in?).to be true
      end
    end

    context "when user is not logged in" do
      it "returns false" do
        expect(helper.logged_in?).to be false
      end
    end
  end

  describe "#admin?" do
    context "when current user is an admin" do
      let(:admin_user) { create(:user, :admin) }

      it "returns true" do
        session[:user_id] = admin_user.id
        expect(helper.admin?).to be true
      end
    end

    context "when current user is not an admin" do
      let(:user) { create(:user) }

      it "returns false" do
        session[:user_id] = user.id
        expect(helper.admin?).to be false
      end
    end

    context "when user is not logged in" do
      it "returns false" do
        expect(helper.admin?).to be false
      end
    end
  end

  describe "#log_in" do
    let(:user) { create(:user) }

    it "sets the user_id in session" do
      helper.log_in(user)
      expect(session[:user_id]).to eq(user.id)
    end
  end

  describe "#log_out" do
    let(:user) { create(:user) }

    before do
      session[:user_id] = user.id
      helper.instance_variable_set(:@current_user, user)
    end

    it "deletes the user_id from session" do
      helper.log_out
      expect(session[:user_id]).to be_nil
    end

    it "clears the current_user instance variable" do
      helper.log_out
      expect(helper.instance_variable_get(:@current_user)).to be_nil
    end
  end
end
