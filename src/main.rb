require "tty-prompt"
require "shell"
require "json"
require "crypt/rijndael"
require "digest"

@sh = Shell.cd("~")
@prompt = TTY::Prompt.new(quiet: true)
@passwords = {}

def get_master_key()
  f = @sh.open(".runekeeper/.master", "r")
  pass = f.read
  f.close

  return pass
end

def generate_hash(key)
  Digest::SHA256.hexdigest key
end

def encrypt_data(key, data)
  rijndael = Crypt::Rijndael.new(key)
  rijndael.encrypt_string(data)
end

def decrypt_data(key, data)
  rijndael = Crypt::Rijndael.new(key)
  rijndael.decrypt_string(data)
end

def save_vault(data)
  key = get_master_key
  f = @sh.open(".runekeeper/vault", "w")
  stringified = JSON.generate data
  encrypted = encrypt_data(key, stringified)
  f.print encrypted
  f.close
end

def read_vault()
  key = get_master_key
  f = @sh.open(".runekeeper/vault", "r")
  data = f.read
  f.close

  data = decrypt_data(key, data)
  JSON.parse data
end

@sh.mkdir(".runekeeper") unless @sh.exist?(".runekeeper")

if @sh.exist?(".runekeeper/.master")
  password = @prompt.mask("Enter master password:")

  pass = get_master_key
  if generate_hash(password) != pass then
    @prompt.error "Wrong password. Exit."
    exit
  end
else
  password = @prompt.mask("Create master password:")
  repeat = @prompt.mask("Repeat password:")

  if password == repeat then
    password = generate_hash(password)
    f = @sh.open(".runekeeper/.master", "w")
    f.print password
    f.close
  else
    @prompt.error "Password does not match. Exit."
  end
end

unless @sh.exist?(".runekeeper/vault") then
  vault = {}
  save_vault vault
end

def list_passwords()
  vault = read_vault
  if vault.empty?
    @prompt.say("There is no passwords :c")
    @prompt.keypress("Press any key to continue")
  else
    app = @prompt.select("Choose app", vault.keys + ["Back"], filter: true, per_page: 4)
    if app == "Exit"
      return
    end

    login = @prompt.select("Choose account", vault[app].collect {|account| account["login"]}, filter: true, per_page: 4)
    password = vault[app].select {|account| account["login"] == login}[0]["password"]

    show_credentials_info(app, login, password)
  end
end

def show_credentials_info(app, login, password)
  vault = read_vault

  @prompt.warn("Credentials for #{app}:\n[Login   ] #{login}\n[Password] #{password}")

  action = @prompt.select("", ["Copy password", "Edit password", "Delete credentials", "Back"])
  case action
  when "Copy password"
    system "wl-copy #{password}"

    @prompt.say("Password moved to clipboard")
    @prompt.keypress("Press any key to continue")

  when "Edit password"
    new_password = @prompt.ask("Enter new password: ")
    account = vault[app].find { |account| account["login"] == login && account["password"] == password }
    vault[app] = vault[app].delete_if { |account| account["login"] == login && account["password"] == password }
    account["password"] = new_password
    vault[app] << account

    save_vault vault
    @prompt.say("Password changed successfully")
    @prompt.keypress("Press any key to continue")

    system "clear"
    return show_credentials_info(app, login, new_password)
  when "Delete credentials"
    vault[app] = vault[app].delete_if { |account| account["login"] == login && account["password"] == password }
    if vault[app].length == 0
      vault.delete(app)
    end
    save_vault vault

    @prompt.say("Credentials deleted successfully")
    @prompt.keypress("Press any key to continue")
    return
  when "Back"
    return
  end

  system "clear"
  show_credentials_info(app, login, password)
end

# TODO:
# Add input validation
# Add password generation option
def add_new_password()
  app = @prompt.ask("Enter app name:")
  login = @prompt.ask("Enter login:")
  password = @prompt.mask("Enter password:")

  vault = read_vault

  vault[app] = Array.new unless vault.keys.include?(app)
  vault[app] << {login: login, password: password}

  save_vault vault
end

# TODO: Add going back to previous menu on pressing escape
loop do
  system "clear"
  action = @prompt.select("Select action", [ "List passwords", "Add new password", "Exit" ])
  if action == "Exit"
    exit
  elsif action == "List passwords"
    list_passwords
  elsif action == "Add new password"
    add_new_password
  end
end
