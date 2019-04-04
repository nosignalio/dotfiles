# dotfiles
> Laptop configs, software bundles and the bits that makes the flat box tick.

The point of this is to allow me to refresh a Mac (or start from a new Mac),
clone a single repo, run a single script and then bugger off for a cup of tea
while my MacBook pretty much makes itself.

## Usage

To configure stuff and install things:

```
$ git clone git@github.com:nosignalio/dotfiles.git dotfiles
$ cd $_
$ ./setup.sh
```

## What's covered?

It's an opinionated build of a MacBook Pro, so it:

* Sets Finder to list view mode.
* Enables the firewall in super seekrit squirrel mode.
* Switches on Filevault.
* Installs Homebrew.
* Installs and configures Oh My ZSH.
* Taps various kegs, installs casks in `/Applications` and installs brews.
* Grabs SSH assets from a specific backup directory, copies them to `~/.ssh/` and sets permissions.
* Installs a comfortable version of Python 3 using `pyenv` and the `pyenv-virtualenv` wrapper.
* Configures Go.
* Configures `~/.zshrc`.
* Configures iTerm2 the way I like it (`zsh` + Agnoster + DimmedMonokai) (meh...kind of does this...)

## Copyright

Copyright &copy; 2019 Paul Stevens. All rights reserved.
