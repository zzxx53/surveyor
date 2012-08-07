# About this project
This project is a customized version of NUBIC Surveyor (https://github.com/NUBIC/surveyor), which is tailored to the specific requirements of linking a survey system to another management system. The major changes are as follows: 

#1: The program now reads the survey identifier ("access code" / "response set code") as a parameter in the URL. One can set their own response set id as follows: 
    ^/surveys/?id=(some id)
	This is useful if one wants the management system to set the survey identifier, and later use it to recognize who the user is from without asking use for any identifying information. 

#2: The program now has two JSON interfaces for exporting survey status and responses. 
	^/survey_admin/to_json/(some id)  -displays survey status for a response set in JSON
    ^/survey_admin/export/(some id)  - to export questions and user responses of a response set in JSON
	This is done so that if one wants the management system to fetch responses directly from the surveyor server, rather than having to do it under the server's command line. 
	
	
# Installation guide for Windows
0. Install GitHub (http://git-scm.com/downloads); choose "Run git from windows command prompt"
1. get Ruby & RubyGem from rubyinstaller.org/downloads; install
2. get DevKit (same page); expand it under ruby install dir
3. install DevKit: 
	(1) "ruby dk.rb init"
	(2) "ruby dk.rb install"
4. install rails: "gem install rails -v 3.2.2"
5. create new rails project: 
	(1) "cd c:\project\sample" (or any directory of choice)
	(2) "rails new sample"
6. add to gemfile (under c:\project\sample): 
gem 'surveyor', :git => 'git://github.com/zzxx53/surveyor.git' 

7. "cd c:\project\sample"  "bundle install"
8. "rails generate surveyor:install"
9. "bundle exec rake db:migrate'
10. "bundle exec rake surveyor FILE=surveys/kitchen_sink_survey.rb" (to use sample survey)
11. start server: "rails server" (be sure to "cd c:\project\sample" first!)
access "http://localhost:3000/surveys" for sample survey

For more information on how to define surveys using Surveyor DSL, see Surveyor readme at https://github.com/NUBIC/surveyor . 
