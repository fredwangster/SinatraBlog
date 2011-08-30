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
	property :permalink, Text
	property :created_at, DateTime
	property :updated_at, DateTime
end

Article.auto_migrate!

get '/application.css' do
  header 'Content-Type' => 'text/css; charset=utf-8'
  sass :style
end

get '/articles' do
	@articles = Article.all :limit => 10,
				:order => 'created_at desc'
	haml :articles
end

get '/articles/:permalink' do
	@article = Article.find :first,
				:permalink => params[:permalink]
	view :article
end

get '/articles/new' do
	view :article_new
end
post '/articles/create' do
	@article = Article.new  :title      => params[:article_title],
				:text       => params[:article_text],
				:posted_by  => params[:article_posted_by],
				:permalink  => create_permalink(params[:article_title])

	if @article.save
		redirect "/article/#{@article.permalink}"
	else
		redirect "/articles"
	end
end

get '/articles/edit/:permalink' do 
	@article = Article.find :first,
				:permalink => params[:permalink]
	view :article_edit
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
helpers do
	def view(view)
		haml view
		#erb view
	end
end
