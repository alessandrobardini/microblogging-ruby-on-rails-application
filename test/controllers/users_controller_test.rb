require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
    @other_user = users(:archer)
  end

  test "should get new" do
    get signup_url
    assert_response :success
  end

  test "should redirect edit when not logged in" do
    get edit_user_path(@user)
    assert_not flash.empty?
    assert_redirected_to login_path
  end

  test "should redirect update when not logged in" do
    patch user_path(@user), params: { user: { name:  "Michael",
                                              email: "foo@example.com",
                                              password:              "foobar",
                                              password_confirmation: "foobar" } }
    assert_not flash.empty?
    assert_redirected_to login_path
  end

  test "should redirect edit when not logged as the right user" do
    log_in_as(@user)
    get edit_user_path(@other_user)
    assert flash.empty?
    assert_redirected_to root_url
  end

  test "should redirect update when not logged as the right user" do
    log_in_as(@user)
    patch user_path(@other_user), params: { user: { name:  "Michael",
                                            email: "foo@example.com",
                                            password:              "foobar",
                                            password_confirmation: "foobar" } }
    assert flash.empty?
    assert_redirected_to root_url
  end

  test "should redirect index when not logged in" do
    get users_path
    assert_redirected_to login_url
  end
end
