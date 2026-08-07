# dotfiles

Managed with [GNU Stow](https://www.gnu.org/software/stow/). Each top-level
directory is a **package** whose contents mirror the path relative to `$HOME`.

## The core idea

Stow symlinks a package's files into `$HOME`, preserving the internal directory
structure. So to figure out where a package's files go, just prepend `~/` to the
path *inside* the package directory:

```
dotfiles/ghostty/.config/ghostty/config   ->   ~/.config/ghostty/config
dotfiles/aerospace/.aerospace.toml         ->   ~/.aerospace.toml
dotfiles/nvim/.config/nvim/init.lua        ->   ~/.config/nvim/init.lua
```

## Adding a new config

Say you want to add a tool whose config lives at `~/.config/foo/foo.toml`.

1. **Recreate the target path inside a new package directory:**

   ```sh
   mkdir -p ~/dotfiles/foo/.config/foo
   ```

   The `foo/` package dir mirrors `$HOME`, so `.config/foo/` inside it maps to
   `~/.config/foo/`. For a config that lives directly in home (like
   `~/.aerospace.toml`), just drop the file at `~/dotfiles/foo/.aerospace.toml`.

2. **Add your config file** at the mirrored location:

   ```sh
   ~/dotfiles/foo/.config/foo/foo.toml
   ```

3. **Make sure nothing already exists at the target**, or stow will refuse to
   overwrite it:

   ```sh
   ls -la ~/.config/foo   # should not exist yet
   ```

   If a real (non-symlink) config already lives there, move it into the package
   dir first, then delete the original.

4. **Stow it** from the dotfiles root:

   ```sh
   cd ~/dotfiles
   stow foo
   ```

   This creates the symlinks. Because stow links directories when it can, any
   files you add to the package later (e.g. `keymap.toml`) show up automatically
   without re-stowing.

### When *not* to let stow link a whole directory

That directory-linking ("tree folding") is only safe for paths this repo fully
owns, like `~/.config/foo`. It is a trap for **shared** directories that other
tools also write into — `~/.local/bin` above all, where `pipx`, `pip --user`,
`cargo` and `npm -g` drop binaries.

If `~/.local/bin` is a symlink to a package dir, every one of those tools writes
straight into this git repo. Keep it a **real directory** so stow links the
individual files instead:

```sh
mkdir -p ~/.local/bin     # create the dir *before* stowing
cd ~/dotfiles && stow fzf
ls -la ~/.local/bin       # want individual file symlinks, not one dir symlink
```

Verify with `[ -L ~/.local/bin ] && echo folded`. Stow will not re-fold a
directory that already exists, so this survives `stow -R` and `stow -D`.

## Handy commands

Run these from `~/dotfiles`:

```sh
stow foo          # link the foo package into ~
stow -R foo       # restow (unlink + relink) after moving files around
stow -D foo       # unlink the foo package
stow -n -v foo    # dry run — show what would happen without doing it
```

## Existing packages

`aerospace`, `fzf`, `ghostty`, `lazygit`, `nvim`, `omp`, `p10k`, `spicetify`,
`spotify-player`, `tmux`, `wezterm`, `yazi`, `zsh`
