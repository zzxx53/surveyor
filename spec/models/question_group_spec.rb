require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe QuestionGroup do
  before(:each) do
    @question_group = Factory(:question_group)
  end

  it "should be valid" do
    @question_group.should be_valid
  end
  it "should have defaults" do
    @question_group = QuestionGroup.new
    @question_group.display_type.should == "inline"
    @question_group.renderer.should == :inline
    @question_group.display_type = nil
    @question_group.renderer.should == :default
  end
  it "should return its custom css class" do
    @question_group.custom_class = "foo bar"
    @question_group.css_class(Factory(:response_set)).should == "foo bar"
  end
  it "should return its dependency class" do
    @dependency = Factory(:dependency)
    @question_group.dependency = @dependency
    @dependency.should_receive(:is_met?).and_return(true)
    @question_group.css_class(Factory(:response_set)).should == "g_dependent"

    @dependency.should_receive(:is_met?).and_return(false)
    @question_group.css_class(Factory(:response_set)).should == "g_dependent g_hidden"

    @question_group.custom_class = "foo bar"
    @dependency.should_receive(:is_met?).and_return(false)
    @question_group.css_class(Factory(:response_set)).should == "g_dependent g_hidden foo bar"
  end
  it "should protect api_id, timestamps" do
    saved_attrs = @question_group.attributes
    if defined? ActiveModel::MassAssignmentSecurity::Error
      lambda {@question_group.update_attributes(:created_at => 3.days.ago, :updated_at => 3.hours.ago)}.should raise_error(ActiveModel::MassAssignmentSecurity::Error)
      lambda {@question_group.update_attributes(:api_id => "NEW")}.should raise_error(ActiveModel::MassAssignmentSecurity::Error)
    else
      @question_group.attributes = {:created_at => 3.days.ago, :updated_at => 3.hours.ago} # automatically protected by Rails
      @question_group.attributes = {:api_id => "NEW"} # Rails doesn't return false, but this will be checked in the comparison to saved_attrs
    end
    @question_group.attributes.should == saved_attrs
  end
  
end
