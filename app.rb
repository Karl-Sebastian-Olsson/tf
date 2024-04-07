require 'sinatra'
require 'sinatra/reloader'
require 'slim'
require 'sqlite3'
require 'bcrypt'
require_relative './model/model.rb'

get('/') do 
    slim(:start)
end 
 
# I DATABASEN LÄGG TILL BILDBESKRIVNING AKA TEXT TILL BILDEN MAN LADDAR UPP
# VARJE BILD SKA HA ETT USER ID ATTACHED SÅ VI VET VEM SOM UPLOADADE VAD 


get('/gallery') do 
    db = SQLite3::Database.new("model/db/store.db")
    db.results_as_hash = true
    result = db.execute("SELECT * FROM Images")
    slim(:"images/index", locals:{result:result})
end 

get('/gallery/new') do 
    slim(:"images/new")
end 

post('/gallery/new') do 
    title = params[:title]
    url = params[:url]
    # HÄR VEM SOM POSTAR TA UID
    # OCKSÅ TEXT TILLÄGG 
    db = SQLite3::Database.new("model/db/store.db")
    db.execute("INSERT INTO Images (Title, Url) VALUES (?, ?)", title, url)
    redirect('/gallery')
end 

get('/gallery/:id') do 
    id = params[:id].to_i
    db = SQLite3::Database.new("model/db/store.db")
    db.results_as_hash = true
    result = db.execute("SELECT * FROM Images WHERE Iid = ?", id).first
    slim(:"images/show", locals:{result:result})
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
    url = params[:url]
    db = SQLite3::Database.new("model/db/store.db")
    db.execute("UPDATE Images SET Title=?,Url=? WHERE Iid = ?",title, url, id)
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
    if (pswd == pswd_confirm) 
        pswd_digest = BCrypt::Password.create(pswd)
        db = SQLite3::Database.new("model/db/store.db")
        db.execute("INSERT INTO Users (Name, Email, Pswd) VALUES (?, ?, ?)", username, email, pswd_digest)
        redirect('/')
    else 
        "FELAKTIGT LÖSENORD BRUH"
    end 
end 

post('/login') do 
    d
end 