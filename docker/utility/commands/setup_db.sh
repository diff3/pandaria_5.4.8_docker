#!/bin/sh
set -e

echo "=== Setting up full database ==="

# Step 1: Initialize databases and user
/bin/commands/init_db.sh

# Step 2: Populate databases with base SQL dumps
/bin/commands/populate_db.sh

# Step 3: Update world and apply SQL updates
/bin/commands/update_db.sh

# Step 4: Finalize (create admin account, configure realm)
/bin/commands/finalize_db.sh

echo "=== Database setup complete! ==="