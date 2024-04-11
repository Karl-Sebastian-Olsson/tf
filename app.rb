require 'sinatra'
require 'sinatra/reloader'
require 'slim'
require 'sqlite3'
require 'bcrypt'
require_relative './model/model.rb'

enable :sessions 

get('/') do 
    slim(:start)
end 

# KOLLA OM UNSERNAME REDAN FINNS ELLER INTE 
# LÄGG TILL "MY POSTS" SIDA 
# Tags images MANY TO MANY
# LÄGG TIL LATT MAN KAN UPPLOADA BILDER ISTÄLLET FÖR LÄNKAR 

get('/gallery') do 
    db = SQLite3::Database.new("model/db/store.db")
    db.results_as_hash = true
    result = db.execute("SELECT * FROM Images") 
    role = authorize(db, session[:id].to_i)
    slim(:"images/index", locals:{result:result, role:role})
end 

get('/gallery/new') do 
    slim(:"images/new")
end 

post('/gallery/new') do 
    title = params[:title]
    desc = params[:desc]
    url = params[:url]
    db = SQLite3::Database.new("model/db/store.db")
    db.execute("INSERT INTO Images (Title, Desc, Url, Uid) VALUES (?, ?, ?, ?)", title, desc, url, session[:id].to_i)
    redirect('/gallery')
end 

get('/gallery/:id') do 
    id = params[:id].to_i
    db = SQLite3::Database.new("model/db/store.db")
    db.results_as_hash = true
    role = authorize(db, session[:id].to_i)
    result = db.execute("SELECT * FROM Images WHERE Iid = ?", id).first
    slim(:"images/show", locals:{result:result, role:role})
end 

post('/gallery/:id/delete') do 
    id = params[:id].to_i
    db = SQLite3::Database.new("model/db/store.db")
    db.execute("DELETE FROM Images WHERE Iid = ?", id)
    redirect('/gallery')
end 

get('/gallery/:id/edit') do 
    id = params[:id].to_i
    db = SQLite3::Database.new("model/db/store.db")
    db.results_as_hash = true
    result = db.execute("SELECT * FROM Images WHERE Iid = ?", id).first
    slim(:"/images/edit",locals:{result:result})
end 

post('/gallery/:id/update') do 
    id = params[:id].to_i
    title = params[:title]
    desc = params[:desc]
    url = params[:url]
    db = SQLite3::Database.new("model/db/store.db")
    db.execute("UPDATE Images SET Title=?, Desc=?, Url=? WHERE Iid = ?", title, desc, url, id)
    redirect('/gallery')
end 

get('/user/new') do 
    slim(:"register")
end 

post('/user/new') do
    username = params[:user]
    email = params[:email]
    pswd = params[:pswd]
    pswd_confirm = params[:pswd_confirm]
    db = SQLite3::Database.new("model/db/store.db")
    db.results_as_hash = true
    usernames = db.execute("SELECT Name FROM Users")

    username_exists = usernames.any? {|x| x["Name"] == username}

    if !username_exists && pswd == pswd_confirm
        pswd_digest = BCrypt::Password.create(pswd)
        db.execute("INSERT INTO Users (Name, Email, Pswd, Role) VALUES (?, ?, ?, 'User')", username, email, pswd_digest)
        redirect('/')
    else 
        "<p>Något gjorde du fel scrub</p>"
    end 
end 

get('/login') do
    slim(:"login")
end 

post('/login') do 
    username = params[:user]
    pswd = params[:pswd]
    db = SQLite3::Database.new("model/db/store.db")
    db.results_as_hash = true
    result = db.execute("SELECT * FROM Users WHERE name = ?", username).first
    pswd_digest = result["Pswd"]
    id = result["Uid"]
    if BCrypt::Password.new(pswd_digest) == pswd
        session[:id] = id
        redirect('/')
    else
        "FEL INLOGG NOOB" 
    end 
end 

get('/logout') do
    session.clear
    redirect('/')
end