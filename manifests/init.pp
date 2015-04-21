define drupal_site ($enable) {
  include apache

  if (defined("apache::vhost")) {
    # Set some default values for vhosts.
    Apache::Vhost {
      port     => '80',
      override => 'All',
      notify   => Service['httpd'],
    }

    apache::vhost { "${name}":
      docroot => "/var/www/html/${name}",
    }
  }

  if (defined(Class["mysql::server"])) {
    mysql_database { "${name}-db":
      require => Class['mysql::server'],
      name    => $name,
      ensure  => present,
    }

    mysql_user { "${name}@localhost":
      require       => Class['mysql::server'],
      name          => "${name}@localhost",
      password_hash => mysql_password($name)
    }

    mysql_grant { "${name}@localhost/${name}.*":
      require    => Class['mysql::server'],
      user       => "${name}@localhost",
      table      => "${name}.*",
      privileges => ["ALL"],
      ensure     => "present"
    }
  }
}
