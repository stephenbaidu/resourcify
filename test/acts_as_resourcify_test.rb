require 'test_helper'

class ActsAsResourcifyTest < ActiveSupport::TestCase

  def test_some_model_resourcified_should_be_true
    assert_equal true, Foo.new.resourcified?
  end

  def test_pundit_api_policy_class_name_on_model_without_policy_class
    assert_equal "ApiPolicy", Foo.new.policy_class
  end

  def test_pundit_custom_policy_class_name_on_model_with_policy_class
    assert_equal "FooBarPolicy", FooBar.new.policy_class
  end
end
