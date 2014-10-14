module PlastApp
  require 'sinatra'
  require 'sinatra/activerecord'
  require 'json'
  require 'rest_client'
  require 'rubygems'
  require 'json/ext' # required for .to_json
  require 'sinatra/cross_origin'
  require 'sinatra/asset_pipeline'

  class YunakQuiz < Sinatra::Base

    register Sinatra::AssetPipeline
    register Sinatra::ActiveRecordExtension
    register Sinatra::CrossOrigin
    Dir.glob('./config/*.rb').each {|file| require file}
    Dir.glob('./models/*.rb').each {|file| require file}

    configure do
        enable :sessions
    end

    get '/' do
        erb :index
    end
    
    options '/*' do
      	'*'
    end
    
    get '/access' do
      	if session[:user_id]
        	user = User.find(session[:user_id])
        	return [200, user.username]
    	  end
      		return [401, "unauthorized"]
    end

    post '/login' do
      data = JSON.parse request.body.read
      user = User.authenticate(data['username'], data['password'])
      if !user.nil?
        if data['remember']
           session[:user_id] = user.id
        end
        return [200, user.username]
      end
        return [401, "unauthorized"]
    end

    post '/assessments/:id' do
      cross_origin
      content_type :json
      {response: "Updated to #{params['id']} assessment"}.to_json
    end

    get '/logout' do
      session.clear
      return [200, "ok"]
    end

  end
end
