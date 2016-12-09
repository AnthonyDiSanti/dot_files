file { "${home_dir}/.bash_profile":
  ensure => 'link',
  target => "${dotfiles_dir}/.bash_profile",
}
