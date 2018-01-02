file { "${home_dir}/.bash_profile":
  ensure => 'link',
  target => "${dotfiles_dir}/home/.bash_profile",
  backup => true,
}

file { "${home_dir}/.vim":
  ensure => 'link',
  target => "${dotfiles_dir}/home/.vim",
  backup => true,
}

file { "${home_dir}/.tmux.conf":
  ensure => 'link',
  target => "${dotfiles_dir}/home/.tmux.conf",
  backup => true,
}

file { "${home_dir}/.gitignore_global":
  ensure => 'link',
  target => "${dotfiles_dir}/home/.gitignore_global",
  backup => true,
}

file { "${home_dir}/.vimpagerrc":
  ensure => 'link',
  target => "${dotfiles_dir}/home/.vimpagerrc",
  backup => true,
}

file { "${home_dir}/.vimrc":
  ensure => 'link',
  target => "${dotfiles_dir}/home/.vimrc",
  backup => true,
}
