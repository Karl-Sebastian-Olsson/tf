module Modules
    def db_define()
        db = SQLite3::Database.new("model/db/store.db")
        db.results_as_hash = true
        return db
    end

    def authorize(db, uid)
        if uid != 0
            return db.execute("SELECT Role FROM Users WHERE Uid = ?", uid).first["Role"]
        else 
            return "Guest"
        end
    end 

    def show_all_images(session_id)
        db = db_define()
        result = db.execute("SELECT * FROM Images") 
        role = authorize(db, session_id.to_i)
        like = db.execute("SELECT * FROM User_image_junction WHERE Uid=?", session_id.to_i)
        slim(:"images/index", locals:{result:result, role:role, like:like})
    end

    def create_new_image(title, desc, url, session_id)
        db = db_define()
        db.execute("INSERT INTO Images (Title, Desc, Url, Uid) VALUES (?, ?, ?, ?)", title, desc, url, session_id)
        redirect('/gallery')
    end

    def delete_image(image_id)
        db = db_define()
        db.execute("DELETE FROM Images WHERE Iid = ?", image_id)
        redirect('/gallery')
    end

    def update_image(image_id, title, desc, url)
        db = db_define()
        db.execute("UPDATE Images SET Title=?, Desc=?, Url=? WHERE Iid = ?", title, desc, url, image_id)
        redirect('/gallery')
    end

    def get_image_details(image_id, session_id)
        db = db_define()
        role = authorize(db, session_id.to_i)
        result = db.execute("SELECT * FROM Images WHERE Iid = ?", image_id).first
        like = db.execute("SELECT * FROM User_image_junction WHERE Uid=?", session_id.to_i)
        slim(:"images/show", locals:{result:result, role:role, like:like})
    end

    def manage_user_registration(username, email, pswd, pswd_confirm)
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

    def user_login(username, pswd, session)
        db = db_define()
        result = db.execute("SELECT * FROM Users WHERE Name = ?", username).first
        if result && BCrypt::Password.new(result["Pswd"]) == pswd
            session[:id] = result["Uid"]
            redirect('/')
        else
            "<p>FEL INLOGG NOOB</p>"
        end
    end

    def manage_like(session_id, image_id, action)
        db = db_define()
        if action == 'like'
            db.execute("INSERT INTO User_image_junction (Uid, Iid) VALUES (?, ?)", session_id, image_id)
        elsif action == 'unlike'
            db.execute("DELETE FROM User_image_junction WHERE Uid = ? AND Iid = ?", session_id, image_id)
        end
        redirect("/gallery/#{image_id}")
    end

    def user_gallery(session_id)
        db = db_define()
        result = db.execute("SELECT * FROM Images WHERE Uid=?", session_id.to_i)
        role = authorize(db, session_id.to_i)
        like = db.execute("SELECT Iid FROM User_image_junction WHERE Uid=?", session_id.to_i)
        liked = db.execute("SELECT * FROM Images JOIN User_image_junction ON Images.Iid = User_image_junction.Iid WHERE User_image_junction.Uid = ?", session_id.to_i)
        slim(:"users/index", locals:{result:result, role:role, like:like, liked:liked})
    end
end


# module Modules
#     def db_define()
#         db = SQLite3::Database.new("model/db/store.db")
#         db.results_as_hash = true
#         return db
#     end

#     def authorize(db, uid)
#         if uid != 0
#             return db.execute("SELECT Role FROM Users WHERE Uid = ?", uid).first["Role"]
#         else 
#             return "Guest"
#         end
#     end 

#     def show_all_images(session_id)
#         db = db_define()
#         result = db.execute("SELECT * FROM Images") 
#         role = authorize(db, session_id.to_i)
#         like = db.execute("SELECT * FROM User_image_junction WHERE Uid=?", session[:id].to_i)
#         slim(:"images/index", locals:{result:result, role:role, like:like})
#     end

#     def create_new_image(title, desc, url)
#         db = db_define()
#         db.execute("INSERT INTO Images (Title, Desc, Url, Uid) VALUES (?, ?, ?, ?)", title, desc, url, session[:id].to_i)
#         redirect('/gallery')
#     end




# end