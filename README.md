# Git Shorts (gs)

**Git Shorts** is a lightweight command‑line helper that wraps common Git workflows into short, memorable commands using a single entry point: `gs`.

Stop typing long git commands and start shipping faster.

---

## 🚀 Features

| Command                      | Description                                                                   |
| ---------------------------- | ----------------------------------------------------------------------------- |
| `gs clone <repo>`            | Clone one of your GitHub repositories.                                        |
| `gs clone <repo> <username>` | Clone another user's repository.                                              |
| `gs init <repo>`             | Initialize a new repository, optionally create README.md, and push to GitHub. |
| `gs commit`                  | Stage all changes, commit, and push.                                          |
| `gs -p`                      | Pull latest changes.                                                          |
| `gs -m`                      | Merge branches interactively.                                                 |
| `gs -s`                      | Show `git status`.                                                            |
| `gs conf`                    | Update local configuration (username, installer).                             |
| `gs -v`                      | Show the currently installed version.                                         |
| `gs -h` or `gs -H`           | View help.                                                                    |

---

## ✅ Key Benefits

* Fast repo cloning with automatic dependency installation
* Quickly initialize repos and push to GitHub in one step
* Useful merge / pull / commit wrappers
* Automatically persists username + package installer
* Built‑in colored help output for quick reference

---

## 📦 Installation

1. Download `gs` (this script).
2. Place it somewhere in your PATH, for example:

```bash
mv gs /usr/local/bin/gs
chmod +x /usr/local/bin/gs
```

3. (Optional) Export the function for shell use:

```bash
export -f gs
```

---

## 🧠 Setup

The first time you run any `gs` command, you will be guided through a one‑time setup:

* GitHub username
* Preferred package installer (`npm`, `pnpm`, `bun`, etc.)

This information is stored in:

```
~/.gitshorts_config
```

To update your config at any time:

```bash
gs conf
```

---

## 🌱 Examples

Clone one of *your* repos and install dependencies:

```bash
gs clone my-repo
```

Clone someone else's repo:

```bash
gs clone cool-library torvalds
```

Create a new repo, commit, push, and generate README.md:

```bash
gs init my-new-project
```

Commit everything and push:

```bash
gs commit
```

---

## 🔧 Config File

Stored at: `~/.gitshorts_config`

Example:

```
USERNAME=yourGitHubName
INSTALLER=npm
```

---

## 🛠 Requirements

* Bash
* Git installed and configured
* SSH access to GitHub

---

## 🤝 Contributing

Feel free to fork the repo and submit PRs.

Bug reports / ideas welcome.

---

## 📄 License

MIT License. Use freely and break things.

---

**Happy coding!** ✨

```
gs commit
# literally all you need
```
