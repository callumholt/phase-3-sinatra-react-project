require 'sinatra'
require 'rack/cors'
require 'json'
require 'bundler/setup'
require 'sinatra/activerecord'
require 'yaml'
require 'psych'

config = Psych.load_file('/Users/callumholt/Development/code/phase_3/phase3_project/phase-3-sinatra-react-project/config/database.yml')



# deal with CORS Policy
use Rack::Cors do
  puts "Applying Rack::Cors middleware"
  allow do
    origins '*' # Add any other allowed origins here
    resource '*', headers: :any, methods: [:get, :post, :options],
      expose: ['access-token', 'expiry', 'token-type', 'uid', 'client'],
      max_age: 0
  end
end


set :database, { adapter: 'sqlite3', database: 'db.sqlite3' }

class Todo < ActiveRecord::Base
end

before do
    puts "in before headers"

  headers 'Access-Control-Allow-Origin' => '*',
          'Access-Control-Allow-Methods' => ['OPTIONS', 'GET', 'POST']
end

options "*" do
  response.headers["Allow"] = "HEAD,GET,PUT,POST,DELETE,OPTIONS"

  # Needed for CORS
  response.headers["Access-Control-Allow-Headers"] = "X-Requested-With, X-HTTP-Method-Override, Content-Type, Cache-Control, Accept"
  halt HTTP_STATUS_OK
end

post '/todo' do
    begin
    
    
    puts "Received TODO request to /todo"
    puts "Params: #{params.inspect}"
    # puts "Received request with body: #{request.body.read}"
    json_request_body = request.body.read
    puts "this is the json request body: #{json_request_body}"


    content_type :json
  
    # Check if the users table exists, and create it if it doesn't exist
    unless ActiveRecord::Base.connection.table_exists?(:todos)
      ActiveRecord::Base.connection.create_table :todos, id: false do |t|
        t.primary_key :id
        t.string :todo
        t.string :category
        t.string :user
      end
    end
    
    
    # Parse the request body to JSON
    # my_hash = JSON.parse('{"hello": "goodbye"}')

    puts "this is stillll the json request body: #{json_request_body}"
    # request_body = JSON.parse(json_request_body)

    request_body = JSON.parse(json_request_body)
    puts "this is the request_body: #{request_body}"
    todo_value = request_body["todo"]
    category_value = request_body["category"]
    user_value = request_body["user"]

    # puts "this is what will be added to db:  + #{todo} + #{category} + #{user}"
  

    # Create a new todo
    New_todo = Todo.create(todo: todo_value, category: category_value, user: user_value)
    puts = "this is the todo: #{New_todo}"
    if New_todo.valid?
        New_todo.to_json
    else
      halt 400, New_todo.errors.full_messages.join(', ')
    end

    rescue JSON::ParserError => e
    puts "JSON parse error: #{e.message}"
    halt 400, "Invalid JSON data: #{e.message}"
    end

end

get '/todos/:user' do
    user = params[:user]
    todos = Todo.select(:id, :todo, :category).where(user: user)
    todos.to_json
  end

# LINE BREAK #

put '/todos/:id' do
    begin
      id = params[:id]
      todo = Todo.find(id)
  
      if todo.update(todo: params[:todo], category: params[:category], user: params[:user])
        todo.to_json
      else
        halt 400, todo.errors.full_messages.join(', ')
      end
  
    rescue ActiveRecord::RecordNotFound
      halt 404, "Todo not found with id #{id}"
    end
  end
  
  delete '/todos/:id' do
    begin
      id = params[:id]
      todo = Todo.find(id)
      todo.destroy
      "Todo with id #{id} deleted"
  
    rescue ActiveRecord::RecordNotFound
      halt 404, "Todo not found with id #{id}"
    end
end
  
  
