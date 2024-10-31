# Stoic-WeaponSave

![GitHub issues](https://img.shields.io/github/issues/Thestoicbear/Stoic-WeaponSave)
![GitHub forks](https://img.shields.io/github/forks/Thestoicbear/Stoic-WeaponSave)
![GitHub stars](https://img.shields.io/github/stars/Thestoicbear/Stoic-WeaponSave)
![License](https://img.shields.io/badge/license-MIT-green)

Stoic-WeaponSave is a **FiveM resource** that allows players to save, retrieve, and manage their weapons within the game. Built for compatibility with various frameworks like **QBCore**, **ESX**, and **NDCore**, this resource streamlines weapon management and enhances player experience by ensuring their weapon collections are easily saved and restored.

---

<details>
<summary><strong>🔧 Features</strong></summary>
- **Save** player's weapons to a database.
- **Retrieve** saved weapons.
- **Delete** specific weapons or all weapons from the player's inventory.
- **Notification system** to inform players about actions taken (e.g., saving, deleting weapons).
- **Compatibility** with various server frameworks.
</details>

---

<details>
<summary><strong>🚀 Installation</strong></summary>

1. **Download the ZIP**:
   - Click the green "Code" button on the repository page, and select **Download ZIP**.

2. **Extract the ZIP file**:
   - Unzip the downloaded file to access the `Stoic-WeaponSave` folder.

3. **Add to your resources**:
   - Place the `Stoic-WeaponSave` folder in your `resources` directory of your FiveM server.

4. **Add to your `server.cfg`**:
   ```start Stoic-WeaponSave```

<details> <summary><strong>💡 Usage</strong></summary>
Commands

/saveWeapons: Saves the player's current weapons to the database.
/retrieveWeapons: Retrieves and gives back the player's saved weapons.
/deleteAllWeapons: Deletes all weapons from the player's inventory.
Notifications The resource includes a notification system that will inform players when weapons are saved, retrieved, or deleted.

Events

lib.notify: Custom notifications that can be triggered from both the client and server sides.
sendWeaponsToClient: Event for sending weapons back to the player after retrieval.
</details>
<details> <summary><strong>⚙️ Configuration</strong></summary> Modify the `Config` file in the resource folder to customize weapon names, notification settings, and other parameters. </details>
<details> <summary><strong>📋 Requirements</strong></summary> - **FiveM** server - **MariaDB** or **MySQL** database - Compatible with **QBCore**, **ESX**, and **NDCore** frameworks </details>
<details> <summary>
