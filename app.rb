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

# KOLLA OM UNSERNAME REDAN FINNS ELLER INTE -- UTVECKLA DET SOM FINNS 
# LÄGG TILL "MY POSTS" SIDA 
# FLYTTA TILL MODELS
# LÄGG TIL LATT MAN KAN UPPLOADA BILDER ISTÄLLET FÖR LÄNKAR på bilder 

get('/gallery') do 
    db = db_define()
    result = db.execute("SELECT * FROM Images") 
    role = authorize(db, session[:id].to_i)
    like = db.execute("SELECT * FROM User_image_junction WHERE Uid=?", session[:id].to_i)
    slim(:"images/index", locals:{result:result, role:role, like:like})
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
    db = db_define()
    role = authorize(db, session[:id].to_i)
    result = db.execute("SELECT * FROM Images WHERE Iid = ?", id).first
    like = db.execute("SELECT * FROM User_image_junction WHERE Uid=?", session[:id].to_i)
    slim(:"images/show", locals:{result:result, role:role, like:like})
end 

post('/gallery/:id/delete') do 
    id = params[:id].to_i
    db = SQLite3::Database.new("model/db/store.db")
    db.execute("DELETE FROM Images WHERE Iid = ?", id)
    redirect('/gallery')
end 

get('/gallery/:id/edit') do 
    id = params[:id].to_i
    db = db_define()
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
    db = db_define()
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
    db = db_define()
    result = db.execute("SELECT * FROM Users WHERE name = ?", username).first
    pswd_digest = result["Pswd"]
    id = result["Uid"]
    if BCrypt::Password.new(pswd_digest) == pswd
        session[:id] = id
        redirect('/')
    else
        "<p>FEL INLOGG NOOB</p>" 
    end 
end 

get('/logout') do
    session.clear
    redirect('/')
end

get('/user') do
    db = db_define()
    result = db.execute("SELECT * FROM Images WHERE Uid=?", session[:id].to_i)
    role = authorize(db, session[:id].to_i)
    like = db.execute("SELECT Iid FROM User_image_junction WHERE Uid=?", session[:id].to_i)
    liked = db.execute("SELECT * FROM Images JOIN User_image_junction ON Images.Iid = User_image_junction.Iid WHERE User_image_junction.Uid = 1")
    slim(:"users/index", locals:{result:result, role:role, like:like, liked:liked})
end 

post('/gallery/:id/like') do
    db = db_define()
    uid = session[:id].to_i
    iid = params[:id].to_i
    db.execute("INSERT INTO User_image_junction (Uid, Iid) VALUES (?, ?)", uid, iid)
    redirect("/gallery/#{iid}")
end 

post('/gallery/:id/unlike') do
    db = db_define()
    uid = session[:id].to_i
    iid = params[:id].to_i
    db.execute("DELETE FROM User_image_junction WHERE Uid = ? AND Iid = ?", uid, iid)
    redirect("/gallery/#{iid}")
end 