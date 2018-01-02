file { "${home_dir}/.bash_profile":
  ensure => 'link',
  target => "${dotfiles_dir}/home/.bash_profile",
}

file { "${home_dir}/.vim":
  ensure => 'link',
  target => "${dotfiles_dir}/home/.vim",
}

file { "${home_dir}/.tmux.conf":
  ensure => 'link',
  target => "${dotfiles_dir}/home/.tmux.conf",
}

file { "${home_dir}/.gitignore_global":
  ensure => 'link',
  target => "${dotfiles_dir}/home/.gitignore_global",
}

file { "${home_dir}/.vimpagerrc":
  ensure => 'link',
  target => "${dotfiles_dir}/home/.vimpagerrc",
}

file { "${home_dir}/.vimrc":
  ensure => 'link',
  target => "${dotfiles_dir}/home/.vimrc",
}
