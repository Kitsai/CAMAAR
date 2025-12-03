require "test_helper"

class TemplateTest < ActiveSupport::TestCase
  def setup
    @admin = admins(:one)
    @question_set = question_sets(:one)
    @template = Template.new(
      name: "Test Template",
      admin: @admin,
      question_set: @question_set
    )
  end

  test "should be valid with valid attributes" do
    assert @template.valid?
  end

  test "should require name" do
    @template.name = nil
    assert_not @template.valid?
    assert_includes @template.errors[:name], "can't be blank"
  end

  test "should require question_set" do
    @template.question_set = nil
    assert_not @template.valid?
    assert_includes @template.errors[:question_set], "can't be blank"
  end

  test "should belong to admin" do
    assert_respond_to @template, :admin
    assert_equal @admin, @template.admin
  end

  test "should belong to question_set" do
    assert_respond_to @template, :question_set
    assert_equal @question_set, @template.question_set
  end

  test "should validate question_set has questions" do
    empty_question_set = QuestionSet.new(data: [])
    @template.question_set = empty_question_set
    assert_not @template.valid?
    assert_includes @template.errors[:question_set], "must have at least one question"
  end

  test "should accept nested attributes for question_set" do
    template = Template.new(
      name: "Nested Test",
      admin: @admin,
      question_set_attributes: { data: [{ question: "Test?", type: "text" }] }
    )
    assert template.valid?
  end
end
