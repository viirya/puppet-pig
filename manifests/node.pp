# /etc/puppet/modules/pig/manifests/master.pp

class pig::node {

    require pig::params
    require pig

}
