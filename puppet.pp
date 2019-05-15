class testInstall{
  # execute 'yum-update'
  exec { 'yum-update':
    logoutput => on_failure,
    path => [ "/bin/", "/usr/bin/" ],
    command => '/usr/bin/yum -y update'
  }
  # install httpd package
  package { ['httpd','git']:
    require => Exec['yum-update'],
    ensure => present,
  }
  #ensure httpd service is running
  service { 'httpd':
    require => Package['httpd'],
    ensure => running,
  }
  #Create index.php file for website
  file { '/var/www/html/index.php':
    ensure => file,
    content => '<?php  phpinfo(); ?>',    # phpinfo code
    require => Package['httpd'],        # require 'httpd' package before creating
  }

  # install php5 package
  package { 'php':
    require => Exec['yum-update'],        # require 'yum-update' before installing
    ensure => installed,
  }

  define testdefine ($data) {
      file {"$title":
        ensure  => file,
        content => $data,
      }
  }

  testdefine {'/var/tmp/puppetfile1':
    data => "The name of the file is puppetfile1 and it is created by puppet\n",
  }

  testdefine {'/var/tmp/puppetfile2':
    data => "The name of the file is puppetfile2 and it is created by puppet\n",
  }

  file { 'source_script':
          path => "/home/ec2-user/test.sh",
          ensure => file,
          replace => true,
          owner => "root",
          group => "root",
          mode => "664",
          content => "#!/bin/bash\ncd /home/ec2-user\necho hello >> test.txt\nexit 0",
  }
  file { 'test_script':
          require => file['source_script'],
          ensure => file,
          replace => true,
          source => "/home/ec2-user/test.sh",
          path   => '/usr/local/bin/target.sh',
          owner  => 'root',
          group  => 'root',
          mode   => '0700', # Use 0700 if it is sensitive
          notify => Exec['run_target_script'],
        }
  exec { 'run_target_script':
          command     => '/usr/local/bin/target.sh',
          refreshonly => true,
  }
  # install jdk package
  # package { 'puppetlabs-java':
  #   require => Exec['yum-update'],        # require 'yum-update' before installing
  #   ensure => installed,
  # }
}
include testInstall
