require "json"

class VaultManager
  def initialize(username, encryption_service)
    @username = username
    @encryption_service = encryption_service

    Dir.mkdir("vaults") unless Dir.exist?("vaults")
    @vault_file = File.join("vaults", "#{username}.enc")

    @entries = []
  end

  def load_vault
    return unless File.exist?(@vault_file)

    encrypted_data = File.binread(@vault_file)
    decrypted_json = @encryption_service.decrypt(encrypted_data)

    if decrypted_json.nil?
      puts "Warning: Could not decrypt vault. Wrong password or corrupted file."
      return
    end

    data = JSON.parse(decrypted_json)
    @entries = data.map do |entry|
      VaultEntry.new(entry["account_name"], entry["username"], entry["password"])
    end
  end

  def save_vault
    data = @entries.map(&:to_h).to_json
    encrypted = @encryption_service.encrypt(data)
    File.binwrite(@vault_file, encrypted)
  end

  def add_entry(entry)
    @entries << entry
  end

  def entries
    @entries
  end

  def get_entry(index)
    @entries[index]
  end
end