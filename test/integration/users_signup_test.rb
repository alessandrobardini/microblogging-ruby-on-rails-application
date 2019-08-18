require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest

  def setup
    ActionMailer::Base.deliveries.clear
  end

  test "when creating a user, /signup route is called" do
    get signup_path
    assert_select 'form[action="/signup"]'
  end

  test "valid signup information with account activation" do
    get signup_path
    assert_difference 'User.count', 1 do
      post users_path, params: { user: { name:  "Example User",
                                         email: "user@example.com",
                                         password:              "password",
                                         password_confirmation: "password" } }
    end
    assert_equal 1, ActionMailer::Base.deliveries.size
    user = assigns(:user)
    assert_not user.activated?
    # Try to log in before activation.
    log_in_as(user)
    assert_not is_logged_in?
    # Invalid activation token
    get edit_account_activation_path("invalid token", email: user.email)
    assert_not is_logged_in?
    # Valid token, wrong email
    get edit_account_activation_path(user.activation_token, email: 'wrong')
    assert_not is_logged_in?
    # Valid activation token
    get edit_account_activation_path(user.activation_token, email: user.email)
    assert user.reload.activated?
    follow_redirect!
    assert_template 'users/show'
    assert is_logged_in?
  end

  test "user is not created if the name is blank" do
    assert_no_difference 'User.count' do
      post signup_path, params: { user: { name:  "",
                                         email: "valid_mail@valid.com",
                                         password:              "foobar",
                                         password_confirmation: "foobar" } }
    end
    assert_template 'users/new'
    assert_select "div#error_explanation div", "The form contains 1 error."
    assert_select "div#error_explanation li", "Name can't be blank"
    assert_select 'div.field_with_errors', 'Name'
  end

  test "user is not created if the email is blank" do
    assert_no_difference 'User.count' do
      post signup_path, params: { user: { name:  "Valid Name",
                                         email: "",
                                         password:              "foobar",
                                         password_confirmation: "foobar" } }
    end
    assert_template 'users/new'
    assert_select "div#error_explanation div", "The form contains 2 errors."
    assert_select "div#error_explanation li", "Email can't be blank"
    assert_select "div#error_explanation li", "Email is invalid"
    assert_select 'div.field_with_errors', 'Email'
  end

  test "user is not created if the email is invalid" do
    assert_no_difference 'User.count' do
      post signup_path, params: { user: { name:  "Valid Name",
                                         email: "invalid@invalid",
                                         password:              "foobar",
                                         password_confirmation: "foobar" } }
    end
    assert_template 'users/new'
    assert_select "div#error_explanation div", "The form contains 1 error."
    assert_select "div#error_explanation li", "Email is invalid"
    assert_select 'div.field_with_errors', 'Email'
  end

  test "user is not created if the password is blank" do
    assert_no_difference 'User.count' do
      post signup_path, params: { user: { name:  "Valid Name",
                                         email: "valid_mail@valid.com",
                                         password:              "",
                                         password_confirmation: "" } }
    end
    assert_template 'users/new'
    assert_select "div#error_explanation div", "The form contains 1 error."
    assert_select "div#error_explanation li", "Password can't be blank"
    assert_select 'div.field_with_errors', 'Password'
  end

  test "user is not created if the password does not match the confirmation password" do
    assert_no_difference 'User.count' do
      post signup_path, params: { user: { name:  "Valid Name",
                                         email: "valid_mail@valid.com",
                                         password:              "foobar",
                                         password_confirmation: "another_foobar" } }
    end
    assert_template 'users/new'
    assert_select "div#error_explanation div", "The form contains 1 error."
    assert_select "div#error_explanation li", "Password confirmation doesn't match Password"
    assert_select 'div.field_with_errors', 'Confirmation'
  end
end
