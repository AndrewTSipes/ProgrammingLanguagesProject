require "json"
require "digest"

class UserManager
  USERS_FILE = "users.json"

  def initialize
    @users = load_users
  end

  def load_users
    if File.exist?(USERS_FILE)
      JSON.parse(File.read(USERS_FILE))
    else
      {}
    end
  end

  def save_users
    File.write(USERS_FILE, JSON.pretty_generate(@users))
  end

  def user_exists?(username)
    @users.key?(username)
  end

  def register_user(username, password)
    return false if user_exists?(username)

    password_hash = hash_password(password)
    @users[username] = { "password_hash" => password_hash }
    save_users
    true
  end

  def authenticate(username, password)
    return false unless user_exists?(username)

    stored_hash = @users[username]["password_hash"]
    hash_password(password) == stored_hash
  end

  private

  def hash_password(password)
    Digest::SHA256.hexdigest(password)
  end
end