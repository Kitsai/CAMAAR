require "test_helper"

class QuestionSetTest < ActiveSupport::TestCase
  def setup
    @question_set = QuestionSet.new(
      data: [
        { question: "What is your name?", type: "text" },
        { question: "Choose color", type: "radio", options: ["Red", "Blue"] }
      ]
    )
  end

  test "should be valid with valid data" do
    assert @question_set.valid?
  end

  test "should require data" do
    @question_set.data = nil
    assert_not @question_set.valid?
    assert_includes @question_set.errors[:data], "can't be blank"
  end

  test "should require data to be an array" do
    @question_set.data = "not an array"
    assert_not @question_set.valid?
    assert_includes @question_set.errors[:data], "must be a non-empty array of questions"
  end

  test "should not allow empty array" do
    @question_set.data = []
    assert_not @question_set.valid?
    assert_includes @question_set.errors[:data], "must be a non-empty array of questions"
  end

  test "should have one template association" do
    assert_respond_to @question_set, :template
  end

  test "should have many forms association" do
    assert_respond_to @question_set, :forms
  end

  test "should create copy when updated if used by forms" do
    # Save the question_set
    @question_set.save!

    # Create a template and form that uses this question_set
    admin = admins(:one)
    template = Template.create!(name: "Test", admin: admin, question_set: @question_set)
    course = courses(:one)
    form = Form.create!(admin: admin, course: course, question_set: @question_set)

    # Try to update the question_set
    original_id = @question_set.id
    @question_set.data = [{ question: "Updated question", type: "text" }]

    # The update should be aborted (copy-on-write)
    result = @question_set.save

    # The update returns false because of throw :abort
    assert_not result

    # The original question_set should remain unchanged
    @question_set.reload
    assert_equal 2, @question_set.data.length
  end

  test "should update normally when not used by forms" do
    @question_set.save!

    # Create only a template (no forms)
    admin = admins(:one)
    Template.create!(name: "Test", admin: admin, question_set: @question_set)

    # Update the question_set
    @question_set.data = [{ question: "Updated", type: "text" }]

    # Should update successfully since no forms use it
    # Note: copy-on-write only triggers when forms exist
    assert @question_set.save
  end
end
