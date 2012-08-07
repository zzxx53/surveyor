Rails.application.routes.draw do
  match 'surveys', :to => 'surveyor#new', :as => 'available_surveys', :via => :get
  match 'surveys/:survey_code/:response_set_code', :to => 'surveyor#create', :as => 'take_survey', :via => :post
  match 'surveys/:survey_code', :to => 'surveyor#export', :as => 'export_survey', :via => :get
  match 'surveys/:survey_code/:response_set_code', :to => 'surveyor#show', :as => 'view_my_survey', :via => :get
  match 'surveys/:survey_code/:response_set_code/take', :to => 'surveyor#edit', :as => 'edit_my_survey', :via => :get
  match 'surveys/:survey_code/:response_set_code', :to => 'surveyor#update', :as => 'update_my_survey', :via => :put
  match 'survey_admin/to_json/:response_set_code', :to => 'admin#to_json', :as => 'to_json', :via => :get
  match 'survey_admin/export/:response_set_code', :to => 'admin#export_response', :as => 'export_response', :via => :get
end
