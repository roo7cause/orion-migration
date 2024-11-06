# Orion Browser Migration Tool

A script to migrate your profile data, extensions, and settings from Orion Browser to Orion RC Browser on macOS.

## What Gets Migrated

This tool migrates the following data:
- 🔒 User Profiles
- 🧩 Extensions and their settings
- 📚 Bookmarks
- 🔍 Browser settings
- 📱 Web Apps
- 🔌 Native Messaging Hosts
- 📝 Browser state and snapshots

## Prerequisites

- macOS operating system
- Orion Browser installed and run at least once
- Orion RC Browser installed and run at least once
- Terminal access

## Installation

1. Download the migration script:
```bash
curl -O https://raw.githubusercontent.com/davidschlachter/orion-migration/main/import.zsh
```

2. Make the script executable:
```bash
chmod +x import.zsh
```

## Usage

1. Close both Orion Browser and Orion RC Browser completely
2. Open Terminal
3. Navigate to the directory containing the script
4. Run the script:
```bash
./import.zsh
```
5. Launch Orion RC Browser to see your imported data

## What to Expect

The script will:
1. Check if your Orion Browser installation exists
2. Create necessary directories in Orion RC
3. Copy your profile data and extensions
4. Migrate browser settings and states
5. Show progress with color-coded status messages

## Troubleshooting

### Existing Orion RC Installation

When running the script, if an existing Orion RC directory is detected, you'll be presented with three options:

1. **Backup existing data and continue**
   - Creates a timestamped backup of your current Orion RC data
   - Backup will be stored as `Orion RC_backup_YYYYMMDD_HHMMSS`
   - Proceeds with migration
   - Safest option if you want to keep your existing data

2. **Remove existing data and continue**
   - Deletes all existing Orion RC data
   - Proceeds with fresh migration
   - Use this if you want a clean migration

3. **Exit**
   - Cancels the migration
   - No changes are made to your system
   - Use this if you need to backup data manually

To manually handle existing data:
```bash
# Backup existing data
mv "${HOME}/Library/Application Support/Orion RC" "${HOME}/Library/Application Support/Orion RC_backup"

# Or remove existing data
rm -rf "${HOME}/Library/Application Support/Orion RC"
```

**Note:** If you experience issues after migration, you can restore your backup by reversing the backup process:
```bash
rm -rf "${HOME}/Library/Application Support/Orion RC"
mv "${HOME}/Library/Application Support/Orion RC_backup" "${HOME}/Library/Application Support/Orion RC"
```

### Extensions Not Showing Up
- Make sure both browsers are completely closed before running the script
- Launch Orion RC and check the extensions page
- You might need to re-enable some extensions manually

### Profile Data Missing
- Verify that you've launched both browsers at least once before migration
- Check if the source directory exists: `~/Library/Application Support/Orion`
- Ensure you have read permissions on the source directory

### Script Permission Denied
```bash
chmod +x import.zsh
```

## Directory Structure

The script works with the following directory structure:
```
~/Library/Application Support/Orion/
├── [UUID] (Profile Directory)
│   ├── Extensions/
│   ├── Extension State/
│   └── ... (other profile data)
├── Defaults/
├── WebApps/
└── ... (other browser data)
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Thanks to the Orion Browser team for their excellent browser
- Community members who tested and provided feedback

## Disclaimer

This is an unofficial migration tool. Always backup your data before running migration scripts. The author is not responsible for any data loss or issues that may arise from using this script.

---
Made with ❤️ by David Kasabji