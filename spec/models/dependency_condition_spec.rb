require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')


describe DependencyCondition do
  it "should have a list of operators" do
    %w(== != < > <= >=).each do |operator|
      DependencyCondition.operators.include?(operator).should be_true
    end
  end

  describe "instance" do
    before(:each) do
      @dependency_condition = DependencyCondition.new(
        :dependency_id => 1, :question_id => 45, :operator => "==",
        :answer_id => 23, :rule_key => "A")
    end

    it "should be valid" do
      @dependency_condition.should be_valid
    end

    it "should be invalid without a parent dependency_id, question_id" do
      # this causes issues with building and saving
      # @dependency_condition.dependency_id = nil
      # @dependency_condition.should have(1).errors_on(:dependency_id)
      # @dependency_condition.question_id = nil
      # @dependency_condition.should have(1).errors_on(:question_id)
    end

    it "should be invalid without an operator" do
      @dependency_condition.operator = nil
      @dependency_condition.should have(2).errors_on(:operator)
    end

    it "should be invalid without a rule_key" do
      @dependency_condition.should be_valid
      @dependency_condition.rule_key = nil
      @dependency_condition.should_not be_valid
      @dependency_condition.should have(1).errors_on(:rule_key)
    end

    it "should have unique rule_key within the context of a dependency" do
      @dependency_condition.should be_valid
      DependencyCondition.create(
        :dependency_id => 2, :question_id => 46, :operator => "==",
        :answer_id => 14, :rule_key => "B")
      @dependency_condition.rule_key = "B" # rule key uniquness is scoped by dependency_id
      @dependency_condition.dependency_id = 2
      @dependency_condition.should_not be_valid
      @dependency_condition.should have(1).errors_on(:rule_key)
    end

    it "should have an operator in DependencyCondition.operators" do
      DependencyCondition.operators.each do |o|
        @dependency_condition.operator = o
        @dependency_condition.should have(0).errors_on(:operator)
      end
      @dependency_condition.operator = "#"
      @dependency_condition.should have(1).error_on(:operator)
    end

    it "should protect timestamps" do
      saved_attrs = @dependency_condition.attributes
      if defined? ActiveModel::MassAssignmentSecurity::Error
        lambda {@dependency_condition.update_attributes(:created_at => 3.days.ago, :updated_at => 3.hours.ago)}.should raise_error(ActiveModel::MassAssignmentSecurity::Error)
      else
        @dependency_condition.attributes = {:created_at => 3.days.ago, :updated_at => 3.hours.ago} # automatically protected by Rails
      end
      @dependency_condition.attributes.should == saved_attrs
    end

  end

  it "returns true for != with no responses" do
    question = Factory(:question)
    dependency_condition = Factory(:dependency_condition, :rule_key => "C", :question => question)
    rs = Factory(:response_set)
    dependency_condition.to_hash(rs).should == {:C => false}
  end

  describe "evaluate '==' operator" do
    before(:each) do
      @a = Factory(:answer)
      @b = Factory(:answer, :question => @a.question)
      @r = Factory(:response, :question => @a.question, :answer => @a)
      @rs = @r.response_set
      @dc = Factory(:dependency_condition, :question => @a.question, :answer => @a, :operator => "==", :rule_key => "D")
      @dc.as(:answer).should == @r.as(:answer)
    end

    it "with checkbox/radio type response" do
      @dc.to_hash(@rs).should == {:D => true}
      @dc.answer = @b
      @dc.to_hash(@rs).should == {:D => false}
    end

    it "with string value response" do
      @a.update_attributes(:response_class => "string")
      @r.update_attributes(:string_value => "hello123")
      @dc.string_value = "hello123"
      @dc.to_hash(@rs).should == {:D => true}
      @r.update_attributes(:string_value => "foo_abc")
      @dc.to_hash(@rs).should == {:D => false}
    end

    it "with a text value response" do
      @a.update_attributes(:response_class => "text")
      @r.update_attributes(:text_value => "hello this is some text for comparison")
      @dc.text_value = "hello this is some text for comparison"
      @dc.to_hash(@rs).should == {:D => true}
      @r.update_attributes(:text_value => "Not the same text")
      @dc.to_hash(@rs).should == {:D => false}
    end

    it "with an integer value response" do
      @a.update_attributes(:response_class => "integer")
      @r.update_attributes(:integer_value => 10045)
      @dc.integer_value = 10045
      @dc.to_hash(@rs).should == {:D => true}
      @r.update_attributes(:integer_value => 421)
      @dc.to_hash(@rs).should == {:D => false}
    end

    it "with a float value response" do
      @a.update_attributes(:response_class => "float")
      @r.update_attributes(:float_value => 121.1)
      @dc.float_value = 121.1
      @dc.to_hash(@rs).should == {:D => true}
      @r.update_attributes(:float_value => 130.123)
      @dc.to_hash(@rs).should == {:D => false}
    end
  end

  describe "evaluate '!=' operator" do
    before(:each) do
      @a = Factory(:answer)
      @b = Factory(:answer, :question => @a.question)
      @r = Factory(:response, :question => @a.question, :answer => @a)
      @rs = @r.response_set
      @dc = Factory(:dependency_condition, :question => @a.question, :answer => @a, :operator => "!=", :rule_key => "E")
      @dc.as(:answer).should == @r.as(:answer)
    end

    it "with checkbox/radio type response" do
      @dc.to_hash(@rs).should == {:E => false}
      @dc.answer_id = @a.id.to_i+1
      @dc.to_hash(@rs).should == {:E => true}
    end

    it "with string value response" do
      @a.update_attributes(:response_class => "string")
      @r.update_attributes(:string_value => "hello123")
      @dc.string_value = "hello123"
      @dc.to_hash(@rs).should == {:E => false}
      @r.update_attributes(:string_value => "foo_abc")
      @dc.to_hash(@rs).should == {:E => true}
    end

    it "with a text value response" do
      @a.update_attributes(:response_class => "text")
      @r.update_attributes(:text_value => "hello this is some text for comparison")
      @dc.text_value = "hello this is some text for comparison"
      @dc.to_hash(@rs).should == {:E => false}
      @r.update_attributes(:text_value => "Not the same text")
      @dc.to_hash(@rs).should == {:E => true}
    end

    it "with an integer value response" do
      @a.update_attributes(:response_class => "integer")
      @r.update_attributes(:integer_value => 10045)
      @dc.integer_value = 10045
      @dc.to_hash(@rs).should == {:E => false}
      @r.update_attributes(:integer_value => 421)
      @dc.to_hash(@rs).should == {:E => true}
    end

    it "with a float value response" do
      @a.update_attributes(:response_class => "float")
      @r.update_attributes(:float_value => 121.1)
      @dc.float_value = 121.1
      @dc.to_hash(@rs).should == {:E => false}
      @r.update_attributes(:float_value => 130.123)
      @dc.to_hash(@rs).should == {:E => true}
    end
  end

  describe "evaluate the '<' operator" do
    before(:each) do
      @a = Factory(:answer)
      @b = Factory(:answer, :question => @a.question)
      @r = Factory(:response, :question => @a.question, :answer => @a)
      @rs = @r.response_set
      @dc = Factory(:dependency_condition, :question => @a.question, :answer => @a, :operator => "<", :rule_key => "F")
      @dc.as(:answer).should == @r.as(:answer)
    end

    it "with an integer value response" do
      @a.update_attributes(:response_class => "integer")
      @r.update_attributes(:integer_value => 50)
      @dc.integer_value = 100
      @dc.to_hash(@rs).should == {:F => true}
      @r.update_attributes(:integer_value => 421)
      @dc.to_hash(@rs).should == {:F => false}
    end

    it "with a float value response" do
      @a.update_attributes(:response_class => "float")
      @r.update_attributes(:float_value => 5.1)
      @dc.float_value = 121.1
      @dc.to_hash(@rs).should == {:F => true}
      @r.update_attributes(:float_value => 130.123)
      @dc.to_hash(@rs).should == {:F => false}
    end
  end

  describe "evaluate the '<=' operator" do
    before(:each) do
      @a = Factory(:answer)
      @b = Factory(:answer, :question => @a.question)
      @r = Factory(:response, :question => @a.question, :answer => @a)
      @rs = @r.response_set
      @dc = Factory(:dependency_condition, :question => @a.question, :answer => @a, :operator => "<=", :rule_key => "G")
      @dc.as(:answer).should == @r.as(:answer)
    end

    it "with an integer value response" do
      @a.update_attributes(:response_class => "integer")
      @r.update_attributes(:integer_value => 50)
      @dc.integer_value = 100
      @dc.to_hash(@rs).should == {:G => true}
      @r.update_attributes(:integer_value => 100)
      @dc.to_hash(@rs).should == {:G => true}
      @r.update_attributes(:integer_value => 421)
      @dc.to_hash(@rs).should == {:G => false}
    end

    it "with a float value response" do
      @a.update_attributes(:response_class => "float")
      @r.update_attributes(:float_value => 5.1)
      @dc.float_value = 121.1
      @dc.to_hash(@rs).should == {:G => true}
      @r.update_attributes(:float_value => 121.1)
      @dc.to_hash(@rs).should == {:G => true}
      @r.update_attributes(:float_value => 130.123)
      @dc.to_hash(@rs).should == {:G => false}
    end

  end

  describe "evaluate the '>' operator" do
    before(:each) do
      @a = Factory(:answer)
      @b = Factory(:answer, :question => @a.question)
      @r = Factory(:response, :question => @a.question, :answer => @a)
      @rs = @r.response_set
      @dc = Factory(:dependency_condition, :question => @a.question, :answer => @a, :operator => ">", :rule_key => "H")
      @dc.as(:answer).should == @r.as(:answer)
    end

    it "with an integer value response" do
      @a.update_attributes(:response_class => "integer")
      @r.update_attributes(:integer_value => 50)
      @dc.integer_value = 100
      @dc.to_hash(@rs).should == {:H => false}
      @r.update_attributes(:integer_value => 421)
      @dc.to_hash(@rs).should == {:H => true}
    end

    it "with a float value response" do
      @a.update_attributes(:response_class => "float")
      @r.update_attributes(:float_value => 5.1)
      @dc.float_value = 121.1
      @dc.to_hash(@rs).should == {:H => false}
      @r.update_attributes(:float_value => 130.123)
      @dc.to_hash(@rs).should == {:H => true}
    end
  end

  describe "evaluate the '>=' operator" do
    before(:each) do
      @a = Factory(:answer)
      @b = Factory(:answer, :question => @a.question)
      @r = Factory(:response, :question => @a.question, :answer => @a)
      @rs = @r.response_set
      @dc = Factory(:dependency_condition, :question => @a.question, :answer => @a, :operator => ">=", :rule_key => "I")
      @dc.as(:answer).should == @r.as(:answer)
    end

    it "with an integer value response" do
      @a.update_attributes(:response_class => "integer")
      @r.update_attributes(:integer_value => 50)
      @dc.integer_value = 100
      @dc.to_hash(@rs).should == {:I => false}
      @r.update_attributes(:integer_value => 100)
      @dc.to_hash(@rs).should == {:I => true}
      @r.update_attributes(:integer_value => 421)
      @dc.to_hash(@rs).should == {:I => true}
    end

    it "with a float value response" do
      @a.update_attributes(:response_class => "float")
      @r.update_attributes(:float_value => 5.1)
      @dc.float_value = 121.1
      @dc.to_hash(@rs).should == {:I => false}
      @r.update_attributes(:float_value => 121.1)
      @dc.to_hash(@rs).should == {:I => true}
      @r.update_attributes(:float_value => 130.123)
      @dc.to_hash(@rs).should == {:I => true}
    end
  end

  describe "evaluating with response_class string" do
    it "should compare answer ids when the string_value is nil" do
      @a = Factory(:answer, :response_class => "string")
      @b = Factory(:answer, :question => @a.question)
      @r = Factory(:response, :question => @a.question, :answer => @a, :string_value => "")
      @rs = @r.response_set
      @dc = Factory(:dependency_condition, :question => @a.question, :answer => @a, :operator => "==", :rule_key => "J")
      @dc.to_hash(@rs).should == {:J => true}
    end

    it "should compare strings when the string_value is not nil, even if it is blank" do
      @a = Factory(:answer, :response_class => "string")
      @b = Factory(:answer, :question => @a.question)
      @r = Factory(:response, :question => @a.question, :answer => @a, :string_value => "foo")
      @rs = @r.response_set
      @dc = Factory(:dependency_condition, :question => @a.question, :answer => @a, :operator => "==", :rule_key => "K", :string_value => "foo")
      @dc.to_hash(@rs).should == {:K => true}

      @r.update_attributes(:string_value => "")
      @dc.string_value = ""
      @dc.to_hash(@rs).should == {:K => true}
    end
  end

  describe "evaluate 'count' operator" do
    before(:each) do
      @q = Factory(:question)
      @dc = DependencyCondition.new(:operator => "count>2", :rule_key => "M", :question => @q)
      @as = []
      3.times do
        @as << Factory(:answer, :question => @q, :response_class => "answer")
      end
      @rs = Factory(:response_set)
      @as.slice(0,2).each do |a|
        Factory(:response, :question => @q, :answer => a, :response_set => @rs)
      end
      @rs.save
    end

    it "with operator with >" do
      @dc.to_hash(@rs).should == {:M => false}
      Factory(:response, :question => @q, :answer => @as.last, :response_set => @rs)
      @rs.reload.responses.count.should == 3
      @dc.to_hash(@rs.reload).should == {:M => true}
    end

    it "with operator with <" do
      @dc.operator = "count<2"
      @dc.to_hash(@rs).should == {:M => false}
      @dc.operator = "count<3"
      @dc.to_hash(@rs).should == {:M => true}
    end

    it "with operator with <=" do
      @dc.operator = "count<=1"
      @dc.to_hash(@rs).should == {:M => false}
      @dc.operator = "count<=2"
      @dc.to_hash(@rs).should == {:M => true}
      @dc.operator = "count<=3"
      @dc.to_hash(@rs).should == {:M => true}
    end

    it "with operator with >=" do
      @dc.operator = "count>=1"
      @dc.to_hash(@rs).should == {:M => true}
      @dc.operator = "count>=2"
      @dc.to_hash(@rs).should == {:M => true}
      @dc.operator = "count>=3"
      @dc.to_hash(@rs).should == {:M => false}
    end

    it "with operator with !=" do
      @dc.operator = "count!=1"
      @dc.to_hash(@rs).should == {:M => true}
      @dc.operator = "count!=2"
      @dc.to_hash(@rs).should == {:M => false}
      @dc.operator = "count!=3"
      @dc.to_hash(@rs).should == {:M => true}
    end
  end
end
