# vault_entry.rb

require "json"

class VaultEntry
  attr_accessor :account_name, :username, :password

  def initialize(account_name, username, password)
    @account_name = account_name
    @username     = username
    @password     = password
  end

  # Convert this entry into a JSON friendly hash
  def to_h
    {
      account_name: @account_name,
      username:     @username,
      password:     @password
    }
  end

  # Convert to JSON string (used when saving the vault)
  def to_json(*_args)
    to_h.to_json
  end

  # Build a VaultEntry from a hash (used when loading the vault)
  def self.from_h(hash)
    new(
      hash["account_name"],
      hash["username"],
      hash["password"]
    )
  end
end