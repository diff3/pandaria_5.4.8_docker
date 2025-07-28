#!/bin/sh
# Default command can be overridden with ENV START_CMD
CMD=${START_WORLD}

# Execute the command (pass through any extra args from `docker run`)
exec $CMD "$@"