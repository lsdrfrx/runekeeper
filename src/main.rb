require "tty-prompt"
require "shell"

@sh = Shell.cd("~")
@prompt = TTY::Prompt.new(quiet: true)
@passwords = {}

@sh.mkdir(".runekeeper") unless @sh.exist?(".runekeeper")
unless @sh.exist?(".runekeeper/data") then
  f = @sh.open(".runekeeper/data", "w")
  f.close
end

if @sh.exist?(".runekeeper/.master")
  password = @prompt.mask("Enter master password:")

  f = @sh.open(".runekeeper/.master", "r")
  pass = f.read
  if password != pass then
    @prompt.error "Wrong password. Exit."
    exit
  end
else
  password = @prompt.mask("Create master password:")
  repeat = @prompt.mask("Repeat password:")

  if password == repeat then
    f = @sh.open(".runekeeper/.master", "w")
    f.print password
    f.close
  else
    @prompt.error "Password does not match. Exit."
  end
end

def list_passwords()
  if @passwords.empty?
    @prompt.say("There is no passwords :c")
    @prompt.keypress("Press any key to continue")
  else
    app = @prompt.select("Choose app", @passwords.keys + ["Exit"], filter: true, per_page: 4)
    if app == "Exit"
      return
    end

    login = @prompt.select("Choose account", @passwords[app].collect {|account| account[:login]}, filter: true, per_page: 4)
    @prompt.warn("Password for #{app}:#{login}: #{@passwords[app].select {|account| account[:login] == login}[0][:password]}")
    @prompt.keypress("Press any key to continue")
  end
end

# TODO: Add input validation
def add_new_password()
  app_name = @prompt.ask("Enter app name:")
  login = @prompt.ask("Enter login:")
  password = @prompt.mask("Enter password:")
  @passwords[app_name] = Array.new unless @passwords.keys.include?(app_name)
  @passwords[app_name] << {login: login, password: password}
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
