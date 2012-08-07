require 'json'

class AdminController < ApplicationController
  unloadable
  layout 'admin'

  def to_json
	@rs1=ResponseSet.find_by_access_code(params[:response_set_code])
	if @rs1.blank?
	  @json1="[]"
	else
	  @json1=JSON.generate ({:created_at=>@rs1.created_at, :completed_at=>@rs1.completed_at, :survey_title=>@rs1.survey.access_code})
	end
  end

  def export_response
	@rs1=ResponseSet.find_by_access_code(params[:response_set_code])
	if @rs1.blank?
	@json1= "{}".html_safe
	else
	  @res=Response.where(:response_set_id => @rs1.id).reorder('question_id')
	  #find smallest question & answer id in this survey
	  temp_aid=Array.new
	  temp_qid=Array.new
	  for i in 0..@res.length-1 do
	    temp_qid[i]=@res[i].question_id
	    temp_aid[i]=@res[i].answer_id
	  end
	  min_qid=temp_qid.min
	  min_aid=temp_aid.min
	  #get all answers into an array
	  @output=Array.new
	  for i in 0..@res.length-1 do
	    pair1=QAPair.new
		qid=@res[i].question_id
		qid=qid-min_qid+1
		pair1.qid=qid.to_s
		aid=@res[i].answer_id
		aid=aid-min_aid+1
		pair1.aid=aid.to_s
		
		if @res[i].question.pick!="none" 
		  pair1.qtext=@res[i].question.text
		elsif @res[i].question.answers.count>1
		  pair1.qtext=@res[i].answer.text
		else
		  pair1.qtext=@res[i].question.text
		end
		
	    if @res[i].question.pick!="none"
		  pair1.atext=@res[i].answer.text
		else
		  pair1.atext=@res[i].datetime_value.to_s+@res[i].integer_value.to_s+@res[i].float_value.to_s+@res[i].text_value.to_s+@res[i].string_value.to_s
		end  
		@output[i]=pair1
	  end
	  @json1= @output.to_json.html_safe
	end
  end
  
end

class QAPair
  def qid
    @qid
  end
  def qid=(qid)
    @qid=qid
  end
  def aid
    @aid
  end
  def aid=(aid)
   @aid=aid
  end 
  def qtext
    @qtext
  end
  def qtext=(qtext)
   @qtext=qtext
  end 
  def atext
    @atext
  end
  def atext=(atext)
   @atext=atext
  end 
end