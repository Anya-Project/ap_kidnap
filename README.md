# Cinematic Kick & Ban System for QBCore

**ap_kidnap** is a FiveM resource designed for the QBCore Framework. This script transforms the standard, boring `/kick` and `/ban` admin commands into an immersive and cinematic kidnapping scene, complete with multiple NPCs, visual effects, and full integration with the QBCore banning system.

This isn't just a utility; it's an experience.

[![Watch Demo ap_kidnap](https://github.com/NAMA_ANDA/NAMA_REPO_ANDA/blob/main/demo/demo_thumbnail.png?raw=true)]([https://www.youtube.com/watch?v=S7kKaCfmpxo)

## 🎬 Key Features

This script has been built from the ground up with a focus on stability, immersion, and advanced features not found in similar scripts:

*   **Dual Functionality:** Supports both `/kidnapkick` for warnings and `/kidnapban` for serious offenses, all within one immersive package.
*   **Full QBCore Ban Integration:** Bans are correctly logged to the database and are **visible in `qb-adminmenu`**, maintaining server data consistency.
*   **Dynamic Multi-NPC Scene:** The scene involves **two SWAT NPCs** with different roles: one handles dragging the player, while the other stands guard with a weapon, creating a realistic ambush scenario.
*   **Complete Cinematic Package:**
    *   **Locked Gameplay Camera:** The player's camera remains in the normal third-person view but is locked, preventing them from looking away and breaking the immersion.
    *   **Widescreen Effect (Letterbox):** Cinematic black bars appear during the scene for a movie-like feel.
    *   **Camera Shake:** A impactful jolt effect when the player is "captured," enhancing the physical sensation.
*   **"The Setup" Scenario:** Instead of entities spawning out of thin air, the screen fades, and the player fades back in to find themselves already ambushed, creating a dramatic surprise effect.
*   **Intelligent Entity Spawning:** Utilizes `GetClosestVehicleNode` and `PlaceObjectOnGroundProperly` to spawn entities in logical, stable positions on the roadside, reducing visual bugs.
*   **Multi-Layered Protection (Robustness):**
    *   **Anti-Spam:** Prevents admins from accidentally running the command twice on the same target.
    *   **Condition Checks:** The scene will safely abort if the target is already dead, bleeding, or inside a vehicle.
    *   **Automatic Cleanup:** Entities are properly networked and will be automatically cleaned up if the target disconnects mid-scene, preventing "orphan" entities.

---

## 🚀 Commands

*   **Kick a Player:**
    ```
    /kidnapkick [ID]
    ```
*   **Ban a Player:**
    ```
    /kidnapban [ID] [Duration in Hours] [Reason]
    ```
    *   **Permanent Ban Example:** `/kidnapban 10 0 Major Violation`
    *   **24-Hour Ban Example:** `/kidnapban 10 24 RDM`

---

## 🔧 Installation

1.  Download or clone this repository.
2.  Place the `ap_kidnap` folder into your server's `resources` directory.
3.  Add `ensure ap_kidnap` to your `server.cfg` file, making sure it is placed **after** `qb-core`.
4.  Restart your server.

---

## 🔗 Dependencies

*   [**qb-core**](https://github.com/qbcore-framework/qb-core)
*   [**oxmysql**](https://github.com/overextended/oxmysql) (or mysql-async if you adjust the server-side code)

---

## ⚙️ Configuration

All major settings (command names, permissions, messages) can be easily changed in the `config.lua` file.

```lua
Config = {}

-- Command names
Config.CommandName = 'kidnapkick'
Config.BanCommandName = 'kidnapban'

-- Required permissions (as per your QBCore permissions system)
Config.Permission = 'admin'
Config.BanPermission = 'god'

-- Messages the player will receive
Config.KickMessage = 'You have been taken care of. See you next time.'
Config.BanMessageDefault = 'You have been removed from this city.'

