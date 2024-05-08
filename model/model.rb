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
        like = db.execute("SELECT * FROM User_image_junction WHERE Uid=?", session[:id].to_i)
        slim(:"images/index", locals:{result:result, role:role, like:like})
    end







    
end