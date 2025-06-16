# RuneKeeper 🔐✨
A terminal-based minimalist password manager for those who value security and TUIs
<img src="assets/screencast.gif" width=600 alt="">
## 📜 Description
RuneKeeper is a Ruby-powered TUI password manager. Like a dwarven vaultkeeper guarding ancient runes, it securely stores your credentials in an encrypted local file, allowing you to manage multiple accounts per service with ease.

## 🌟 Features
🔒 AES-256 Encryption – Passwords are stored securely using industry-standard encryption.

📁 Local Storage – No cloud dependencies; your data stays on your machine.

🔄 Multi-Account Support – Store multiple logins for the same service (e.g., personal/work emails).

⚡ Quick Search – Filter entries by service name or username.

🗝️ Master Password – Single secure key to unlock your vault.

## 🔮 Roadmap
- Firefox/Chrome extensions for forms autofill

- Password Generator – Create strong passwords inside the Keeper.

- Backup/Restore – Export/import encrypted vaults.

- CLI Mode – Support headless usage for scripting.

## 🛡️ Security Notes
Passwords are encrypted using AES-256 with a key derived from your master password via SHA256.

The vault file (~/.runekeeper/vault) is readable only by your user account.

Never share your master password! RuneKeeper cannot recover it if lost.

## 🤝 Contributing
Pull requests are welcome! For major changes, open an issue first.

## 📜 License
MIT License – "Wield this rune wisely."
