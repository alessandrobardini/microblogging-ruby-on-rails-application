require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest

  test "when creating a user, /signup route is called" do
    get signup_path
    assert_select 'form[action="/signup"]'
  end

  test "user is created" do
    assert_difference 'User.count', 1 do
      post signup_path, params: { user: { name:  "Alessandro Bardini",
                                         email: "alessandro@gmail.com",
                                         password:              "foobar",
                                         password_confirmation: "foobar" } }
    end
    follow_redirect!
    #assert_template 'users/show'
    #assert_equal flash[:success], "Welcome to the Sample App!"
    #assert is_logged_in?
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
