# macos setup

1. Configure ssh access
1. Clone dotfiles repo in home directory with `git clone -n --depth=1 --filter=tree:0 git@github.com:LeszekBlazewski/dotfiles.git --single-branch && cd dotfiles && git sparse-checkout set --no-cone macos && git checkout`
1. Run macos.sh script
1. Install packages via brew dump `brew bundle install`
1. Stow needed packages with `stow $PACKAGE_NAME -t $HOME`
1. Confgure brew auto update and auto upgrade
1. Configure vscode (simply sign in)
1. Load iterm2 profile
1. Karabinier, remap right command to option
