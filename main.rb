require_relative "password_generator"
require_relative "vault_entry"
require_relative "vault_manager"
require_relative "encryption_service"
require_relative "user_manager"

def prompt(message)
  print "#{message}: "
  gets.chomp
end

def prompt_integer(message)
  loop do
    print "#{message}: "
    input = gets.chomp
    return input.to_i if input.match?(/^\d+$/)
    puts "Please enter a valid number."
  end
end

def build_password_from_user_input
  length = prompt_integer("Enter total password length")

  # Uppercase
  allow_uppercase = prompt("Allow uppercase letters? (y/n)").downcase == "y"
  min_uppercase = allow_uppercase ? prompt_integer("Minimum uppercase letters") : 0

  # Numbers
  allow_numbers = prompt("Allow numbers? (y/n)").downcase == "y"
  min_numbers = allow_numbers ? prompt_integer("Minimum numbers") : 0

  # Symbols
  allow_symbols = prompt("Allow special characters? (y/n)").downcase == "y"
  min_symbols = allow_symbols ? prompt_integer("Minimum special characters") : 0

  # Validate totals
  if min_uppercase + min_numbers + min_symbols > length
    puts "Error: Sum of minimums is greater than total length."
    return nil
  end

  generator = PasswordGenerator.new(
    length: length,
    min_uppercase: min_uppercase,
    min_numbers: min_numbers,
    min_symbols: min_symbols,
    allow_symbols: allow_symbols
  )

  generator.generate
end

def main_menu
  puts
  puts "=== SecurePass Password Manager ==="
  puts "1. Generate password"
  puts "2. Add entry to vault"
  puts "3. List entries"
  puts "4. Exit"
  print "Choose an option: "
  gets.chomp
end

def run_app
  puts "Welcome to SecurePass"
  puts
  puts "1. Sign in"
  puts "2. Create new account"
  print "Choose an option: "
  login_choice = gets.chomp
  puts

  user_manager = UserManager.new
  username = nil
  password = nil

  case login_choice
  when "1"  # --- SIGN IN ---
    username = prompt("Username")
    password = prompt("Password")

    unless user_manager.authenticate(username, password)
      puts "Invalid username or password."
      return
    end

    puts "Login successful."
    puts

  when "2"  # --- CREATE NEW ACCOUNT ---
    username = prompt("Choose a username")

    if user_manager.user_exists?(username)
      puts "That username already exists."
      return
    end

    password = prompt("Create a password")
    user_manager.register_user(username, password)

    puts "Account created successfully."
    puts

  else
    puts "Invalid choice."
    return
  end

  # Encryption key = user's password
  encryption = EncryptionService.new(password)

  # Load the correct vault for this user
  vault = VaultManager.new(username, encryption)
  vault.load_vault

  # --- MAIN MENU LOOP ---
  loop do
    choice = main_menu
    puts

    case choice
    when "1"
      password = build_password_from_user_input
      puts "Generated password: #{password}" if password

    when "2"
      account  = prompt("Account name (e.g., Gmail)")
      username_field = prompt("Username / email")
      use_generated = prompt("Generate password? (y/n)").downcase == "y"

      password =
        if use_generated
          pwd = build_password_from_user_input
          if pwd.nil?
            puts "Password generation failed."
            next
          end
          pwd
        else
          prompt("Enter password")
        end

      entry = VaultEntry.new(account, username_field, password)
      vault.add_entry(entry)
      vault.save_vault
      puts "Entry added and saved."

    when "3"
      entries = vault.entries
      if entries.empty?
        puts "No entries in vault."
      else
        puts "=== Stored Entries ==="
        entries.each_with_index do |e, i|
          puts "#{i + 1}. #{e.account_name} (#{e.username})"
          puts "   Password: #{e.password}"
        end
      end

    when "4"
      vault.save_vault
      puts "Vault saved. Goodbye!"
      break

    else
      puts "Invalid choice. Please try again."
    end

    puts
  end
end

run_app