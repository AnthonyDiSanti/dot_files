file { "$homedir/.bash_profile":
  ensure => 'link',
  target => "$homedir/code/dot_files/.bash_profile",
}
