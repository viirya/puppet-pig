# /etc/puppet/modules/pig/manafests/init.pp

class pig {

    require pig::params
    
    group { "${pig::params::hadoop_group}":
        ensure => present,
        gid => "800"
    }
    
    user { "${pig::params::pig_user}":
        ensure => present,
        comment => "Hadoop",
        password => "!!",
        uid => "800",
        gid => "800",
        shell => "/bin/bash",
        home => "${pig::params::pig_user_path}",
        require => Group["hadoop"],
    }
    
    file { "${pig::params::pig_user_path}":
        ensure => "directory",
        owner => "${pig::params::pig_user}",
        group => "${pig::params::hadoop_group}",
        alias => "${pig::params::pig_user}-home",
        require => [ User["${pig::params::pig_user}"], Group["hadoop"] ]
    }
 
    file {"${pig::params::pig_base}":
        ensure => "directory",
        owner => "${pig::params::pig_user}",
        group => "${pig::params::hadoop_group}",
        alias => "pig-base",
    }

    exec { "download ${pig::params::pig_base}/pig-${pig::params::version}.tar.gz":
        command => "wget http://apache.stu.edu.tw/pig/pig-${pig::params::version}/pig-${pig::params::version}.tar.gz",
        cwd => "${pig::params::pig_base}",
        alias => "download-pig",
        user => "${pig::params::pig_user}",
        before => Exec["untar-pig"],
        require => File["pig-base"],
        path    => ["/bin", "/usr/bin", "/usr/sbin"],
        #onlyif => "test -d ${pig::params::pig_base}/pig-${pig::params::version}",
        creates => "${pig::params::pig_base}/pig-${pig::params::version}.tar.gz",
    }

    file { "${pig::params::pig_base}/pig-${pig::params::version}.tar.gz":
        mode => 0644,
        ensure => present,
        owner => "${pig::params::pig_user}",
        group => "${pig::params::hadoop_group}",
        alias => "pig-source-tgz",
        before => Exec["untar-pig"],
        require => [File["pig-base"], Exec["download-pig"]],
    }
    
    exec { "untar pig-${pig::params::version}.tar.gz":
        command => "tar xfvz pig-${pig::params::version}.tar.gz",
        cwd => "${pig::params::pig_base}",
        creates => "${pig::params::pig_base}/pig-${pig::params::version}",
        alias => "untar-pig",
        onlyif => "test 0 -eq $(ls -al ${pig::params::pig_base}/pig-${pig::params::version} | grep -c bin)",
        user => "${pig::params::pig_user}",
        before => [ File["pig-symlink"], File["pig-app-dir"]],
        path    => ["/bin", "/usr/bin", "/usr/sbin"],
    }

    file { "${pig::params::pig_base}/pig-${pig::params::version}":
        ensure => "directory",
        mode => 0644,
        owner => "${pig::params::pig_user}",
        group => "${pig::params::hadoop_group}",
        alias => "pig-app-dir",
        require => Exec["untar-pig"],
    }
        
    file { "${pig::params::pig_base}/pig":
        force => true,
        ensure => "${pig::params::pig_base}/pig-${pig::params::version}",
        alias => "pig-symlink",
        owner => "${pig::params::pig_user}",
        group => "${pig::params::hadoop_group}",
        require => File["pig-app-dir"],
    }

    exec { "set pig_home":
        command => "echo 'export PIG_HOME=${pig::params::pig_base}/pig-${pig::params::version}' >> /etc/profile.d/hadoop.sh",
        alias => "set-pighome",
        user => "root",
        require => [File["pig-app-dir"]],
        path    => ["/bin", "/usr/bin", "/usr/sbin"],
        onlyif => "test 0 -eq $(grep -c PIG_HOME /etc/profile.d/hadoop.sh)",
    }
 
    exec { "set pig_classpath":
        command => "echo 'export PIG_CLASSPATH=${pig::params::hadoop_conf}' >> /etc/profile.d/hadoop.sh",
        alias => "set-pigclasspath",
        user => "root",
        require => [File["pig-app-dir"]],
        path    => ["/bin", "/usr/bin", "/usr/sbin"],
        onlyif => "test 0 -eq $(grep -c PIG_CLASSPATH /etc/profile.d/hadoop.sh)",
    }
 
    exec { "set pig path":
        command => "echo 'export PATH=\$PATH:${pig::params::pig_base}/pig-${pig::params::version}/bin' >> /etc/profile.d/hadoop.sh",
        alias => "set-pigpath",
        user => "root",
        before => Exec["set-pighome"],
        path    => ["/bin", "/usr/bin", "/usr/sbin"],
        onlyif => "test 0 -eq $(grep -c '${pig::params::pig_base}/pig-${pig::params::version}/bin' /etc/profile.d/hadoop.sh)",
    }

   
    #exec { "set pig_home":
    #    command => "echo 'export PIG_HOME=${pig::params::pig_base}/pig-${pig::params::version}' >> ${pig::params::pig_user_path}/.bashrc",
    #    alias => "set-pighome",
    #    user => "${pig::params::pig_user}",
    #    require => [File["pig-app-dir"]],
    #    path    => ["/bin", "/usr/bin", "/usr/sbin"],
    #    onlyif => "test 0 -eq $(grep -c PIG_HOME ${pig::params::pig_user_path}/.bashrc)",
    #}
    #
    #exec { "set pig_classpath":
    #    command => "echo 'export PIG_CLASSPATH=${pig::params::hadoop_conf}' >> ${pig::params::pig_user_path}/.bashrc",
    #    alias => "set-pigclasspath",
    #    user => "${pig::params::pig_user}",
    #    require => [File["pig-app-dir"]],
    #    path    => ["/bin", "/usr/bin", "/usr/sbin"],
    #    onlyif => "test 0 -eq $(grep -c PIG_CLASSPATH ${pig::params::pig_user_path}/.bashrc)",
    #}
    #
    #exec { "set pig path":
    #    command => "echo 'export PATH=\$PATH:${pig::params::pig_base}/pig-${pig::params::version}/bin' >> ${pig::params::pig_user_path}/.bashrc",
    #    alias => "set-pigpath",
    #    user => "${pig::params::pig_user}",
    #    before => Exec["set-pighome"],
    #    path    => ["/bin", "/usr/bin", "/usr/sbin"],
    #    onlyif => "test 0 -eq $(grep -c '${pig::params::pig_base}/pig-${pig::params::version}/bin' ${pig::params::pig_user_path}/.bashrc)",
    #}

}

