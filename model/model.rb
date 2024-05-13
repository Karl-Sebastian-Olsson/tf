#Övergripande modul för metoderna

module Modules
    # Definierar och returnerar en databasanslutning
    #
    # @return [SQLite3::Database] En instans av SQLite3-databasen, inställd för att returnera hashar

    def db_define()
        db = SQLite3::Database.new("model/db/store.db")
        db.results_as_hash = true
        db.execute('PRAGMA foreign_keys = ON')
        return db
    end

    # Kontrollerar användarens roll i systemet
    #
    # @param db [SQLite3::Database] Databasanslutningen
    # @param uid [Integer] Användar-ID
    # @return [String] Användarens roll i systemet eller "Guest" om användaren inte är identifierad

    def authorize(db, uid)
        if uid != 0
            return db.execute("SELECT Role FROM Users WHERE Uid = ?", uid).first["Role"]
        else 
            return "Guest"
        end
    end 

    # Hämtar alla bilder och deras associerade information från databasen
    #
    # @param session_id [Integer] Användarens session-ID
    # @return [String] Renderar en vy som listar alla bilder med tillhörande detaljer och användarroll

    def show_all_images(session_id)
        db = db_define()
        result = db.execute("SELECT * FROM Images") 
        role = authorize(db, session_id.to_i)
        like = db.execute("SELECT * FROM User_image_junction WHERE Uid=?", session_id.to_i)
        slim(:"images/index", locals:{result:result, role:role, like:like})
    end

    # Skapar en ny bildpost i databasen
    #
    # @param title [String] Titeln på bilden
    # @param desc [String] Beskrivning av bilden
    # @param url [String] URL till bildens lagringsplats
    # @param session_id [Integer] Användarens session-ID
    # @return [Redirect] Omdirigerar användaren till galleriet efter att bilden skapats

    def create_new_image(title, desc, url, session_id)
        db = db_define()
        db.execute("INSERT INTO Images (Title, Desc, Url, Uid) VALUES (?, ?, ?, ?)", title, desc, url, session_id)
        redirect('/gallery')
    end

    # Tar bort en bild från databasen baserat på dess ID
    #
    # @param image_id [Integer] ID för bilden som ska tas bort
    # @return [Redirect] Omdirigerar användaren till galleriet efter att bilden tagits bort

    def delete_image(image_id)
        db = db_define()
        db.execute("DELETE FROM Images WHERE Iid = ?", image_id)
        redirect('/gallery')
    end

    # Uppdaterar en befintlig bild i databasen
    #
    # @param image_id [Integer] ID för bilden som ska uppdateras
    # @param title [String] Ny titel för bilden
    # @param desc [String] Ny beskrivning av bilden
    # @param url [String] Ny URL för bildens lagringsplats
    # @return [Redirect] Omdirigerar användaren till galleriet efter att uppdateringen genomförts

    def update_image(image_id, title, desc, url)
        db = db_define()
        db.execute("UPDATE Images SET Title=?, Desc=?, Url=? WHERE Iid = ?", title, desc, url, image_id)
        redirect('/gallery')
    end

    # Hämtar detaljerad information om en specifik bild
    #
    # @param image_id [Integer] ID för bilden som detaljerna avser
    # @param session_id [Integer] Användarens session-ID
    # @return [String] Renderar en vy med detaljer om den specifika bilden

    def get_image_details(image_id, session_id)
        db = db_define()
        role = authorize(db, session_id.to_i)
        result = db.execute("SELECT * FROM Images WHERE Iid = ?", image_id).first
        like = db.execute("SELECT * FROM User_image_junction WHERE Uid=?", session_id.to_i)
        slim(:"images/show", locals:{result:result, role:role, like:like})
    end

    # Hanterar registreringsprocessen för nya användare
    #
    # @param username [String] Användarnamnet
    # @param email [String] Användarens e-postadress
    # @param pswd [String] Användarens lösenord
    # @param pswd_confirm [String] Bekräftelse av användarens lösenord
    # @return [Redirect/String] Omdirigerar till startsidan om registreringen lyckas, annars visas ett felmeddelande

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

    # Hanterar inloggningsprocessen för användare
    #
    # @param username [String] Användarnamnet
    # @param pswd [String] Användarens lösenord
    # @param session [Hash] Session-hash som håller användarens ID om inloggningen lyckas
    # @return [Redirect/String] Omdirigerar till startsidan om inloggningen lyckas, annars visas ett felmeddelande

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

    # Hanterar "like"- eller "unlike"-åtgärder för en specifik bild
    #
    # @param session_id [Integer] Användarens session-ID
    # @param image_id [Integer] Bildens ID som ska "likes" eller "unlikes"
    # @param action [String] Åtgärden att utföra ('like' eller 'unlike')
    # @return [Redirect] Omdirigerar tillbaka till den specifika bildsidan

    def manage_like(session_id, image_id, action)
        db = db_define()
        if action == 'like'
            db.execute("INSERT INTO User_image_junction (Uid, Iid) VALUES (?, ?)", session_id, image_id)
        elsif action == 'unlike'
            db.execute("DELETE FROM User_image_junction WHERE Uid = ? AND Iid = ?", session_id, image_id)
        end
        redirect("/gallery/#{image_id}")
    end

    # Hämtar alla bilder som tillhör en specifik användare
    #
    # @param session_id [Integer] Användarens session-ID
    # @return [String] Renderar en vy med alla bilder som användaren har lagt till

    def user_gallery(session_id)
        db = db_define()
        result = db.execute("SELECT * FROM Images WHERE Uid=?", session_id.to_i)
        role = authorize(db, session_id.to_i)
        like = db.execute("SELECT Iid FROM User_image_junction WHERE Uid=?", session_id.to_i)
        liked = db.execute("SELECT * FROM Images JOIN User_image_junction ON Images.Iid = User_image_junction.Iid WHERE User_image_junction.Uid = ?", session_id.to_i)
        slim(:"users/index", locals:{result:result, role:role, like:like, liked:liked})
    end
end