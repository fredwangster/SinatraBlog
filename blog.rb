#blog.rb
require 'rubygems'
require 'sinatra'
require 'data_mapper'
require 'time'

DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/db/my_way_development")

class Article 
	include  DataMapper::Resource
	property :title, Text, :key => true
	property :text, Text
	property :posted_by, String
	property :permalink, Serial
	property :created_at, DateTime
	property :updated_at, DateTime
end

Article.auto_migrate!

get '/articles' do
	@articles = Article.all :limit => 10,
				:order => :created_at.desc
	haml :articles
end

get '/article/:permalink' do
	@article = Article.find (:permalink => params[:permalink])
	haml :article
end

get '/articles/new' do
	haml :article_new
end

post '/articles/create' do
	@article = Article.new  :title      => params[:article_title],
				:text       => params[:article_text],
				:posted_by  => params[:article_posted_by]
				
	if @article.save
		redirect "/article/#{@article.permalink}"
	else
		redirect "/articles"
	end
end

get '/articles/edit/:permalink' do 
	@article = Article.find :first,
				:permalink => params[:permalink]
	haml :article_edit
end

post '/article/update/:permalink' do
	@article = Article.find :first,
				:permalink => params[:permalink]
	if @article
		@article.title = params[:article_title]
		@article.text = params[:article_text]
		@article.posted_by = params[:article_posted_by]
		@article.updated_at = Time.now
		if @article.save
			redirect "/articles/#@article.permalink}"
		else
			redirect "/articles"
		end
	else
		redirect "/articles"
	end
end

#helper to sub in "view" for haml view. makes it easy to switch to erb
