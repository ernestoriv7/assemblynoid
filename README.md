# 🕹️ Assemblynoid
![Gameplay Screenshot](Screenshot%202025-11-02%20184959.png)

A classic **Breakout-style game** written entirely in **ARM64 Assembly**, designed to run on **Android devices** using **Termux** and the GNU assembler (`as`).

Repository URL: [https://github.com/ernestoriv7/assemblynoid](https://github.com/ernestoriv7/assemblynoid)

---

## 📝 Introduction
**Assemblynoid** is a minimalist retro game built from scratch in **64-bit ARM Assembly language**. It demonstrates low-level programming concepts while delivering a playable experience directly in the terminal. The game runs inside **Termux** on Android, making it a perfect example of how assembly can interact with modern environments without relying on high-level languages.

---

## ✅ Features
- Pure **ARM64 Assembly** implementation
- Runs in **Termux** using `as` and `ld`
- Classic **brick-breaking gameplay** with score, lives, and rounds
- ASCII-based graphics for a nostalgic feel

---

## 🔧 Installation
### Requirements
- Android device with **Termux** installed
- GNU assembler (`as`) and linker (`ld`) available in Termux

Install required packages in Termux:
```bash
pkg install binutils
```

Clone the repository:
```bash
git clone https://github.com/ernestoriv7/assemblynoid.git
cd assemblynoid
```

Assemble and link:
```bash
as -o assemblynoid.o assemblynoid.s
ld -o assemblynoid assemblynoid.o
```

Run the game:
```bash
./assemblynoid
```

---

## 🎮 Controls
- **Left / Right**: Move paddle
- **Space**: Launch ball
- **Q**: Quit game

---

## 📷 Screenshots
![Assemblynoid Title](Screenshot%202025-11-02%20184737.png)


---

## 🧠 Game Logic Overview
The game is built using low-level memory manipulation and system calls. Key components include:
- **Ball physics**: Calculated using simple vector logic
- **Collision detection**: Paddle, walls, and bricks
- **Score tracking**: Incremented on brick hits
- **Lives system**: Player loses a life when the ball falls below the paddle

---

## 🤝 Contributing
Contributions are welcome! Feel free to fork the repository, submit issues, or create pull requests to improve the game or port it to other environments.

---

## 📄 License
This project is licensed under the MIT License.
