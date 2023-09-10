# Example usage

source prql-cli.sh

prql-mod "import project\n\nfrom project__favorite_artists"

prql-mod - __ <<EOF | prqlc compile
import project

from project__favorite_artists
EOF
