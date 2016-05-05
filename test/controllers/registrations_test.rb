require 'test_helper'

class RegistrationsControllerControllerTest < ActionController::TestCase
  def setup
    @controller = Devise::RegistrationsController.new
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  test "new user" do
    post :create, user:{name: "Me", email: "me@example.com",
                        organization: "example",
                        password: "password",
                        password_confirmation: "password"}
    tmp = User.find_by email:"me@example.com"
    assert_not_nil tmp
  end

end
