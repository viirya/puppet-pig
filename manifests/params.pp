# /etc/puppet/modules/pig/manafests/params.pp

class pig::params {

	include java::params

	$version = $::hostname ? {
		default			=> "0.12.1",
	}

 	$pig_user = $::hostname ? {
		default			=> "hduser",
	}
 
 	$hadoop_group = $::hostname ? {
		default			=> "hadoop",
	}
        
	$java_home = $::hostname ? {
		default			=> "${java::params::java_base}/jdk${java::params::java_version}",
	}

	$hadoop_base = $::hostname ? {
		default			=> "/opt/hadoop",
	}
 
	$hadoop_conf = $::hostname ? {
		default			=> "${hadoop_base}/hadoop/conf",
	}
 
	$pig_base = $::hostname ? {
		default			=> "/opt/pig",
	}

    $pig_user_path = $::hostname ? {
        default         => "/home/${pig_user}",
    }
 
}
