require 'spec_helper'

describe ContentController do

  before (:each) do
    @user = FactoryGirl.create(:user)
    sign_in @user
    @user.add_role :silver # gives the user a role. tests pass regardless of role
  end

  describe "GET 'member'" do
    it "returns http success" do
      get 'member'
      response.should @user.has_role?(:member) ? be_success : redirect_to(root_url)
    end
  end

end
