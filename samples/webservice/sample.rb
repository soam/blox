#!/usr/bin/ruby -w

require 'webservice'

server :port => 8000 do

  get '/' do
    'Welcome!'
  end

  get '/form' do 

    form :action => '/greet', :method => 'get' do
      text "Your name: "
      text_input 'name'

      submit 'Click Here'
    end

  end

  get '/greet' do
    'Hello there, ' + cleaned_query('name') + '!'
  end

end
