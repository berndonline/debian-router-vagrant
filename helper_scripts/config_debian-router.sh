sudo apt-get update
sudo apt-get upgrade -y

wget https://github.com/FRRouting/frr/releases/download/frr-3.0.3/frr_3.0.3-1_debian9.1_amd64.deb
wget https://github.com/FRRouting/frr/releases/download/frr-3.0.3/frr-pythontools_3.0.3-1_debian9.1_all.deb
wget https://github.com/FRRouting/frr/releases/download/frr-3.0.3/frr-doc_3.0.3-1_debian9.1_all.deb
sudo dpkg -i frr_3.0.3-1_debian9.1_amd64.deb frr-pythontools_3.0.3-1_debian9.1_all.deb frr-doc_3.0.3-1_debian9.1_all.deb
sudo apt-get install -f -y

sudo bash -c 'cat << EOF > /etc/frr/daemons
zebra=yes
bgpd=yes
ospfd=no
ospf6d=no
ripd=no
ripngd=no
isisd=no
pimd=no
ldpd=no
nhrpd=no
EOF'

sudo systemctl enable frr
sudo systemctl start frr

sudo apt-get install -y strongswan-swanctl charon-systemd

sudo bash -c 'cat << EOF > /etc/strongswan.d/charon/connmark.conf
connmark {
 
    # Disable connmark plugin
    # Needed for tunnels - see https://wiki.strongswan.org/projects/strongswan/wiki/RouteBasedVPN
    load = no
 
}
EOF'
sudo bash -c 'cat << EOF > /etc/strongswan.d/charon.conf
charon {
 
    # Cisco IKEv2 wants to use reauth - need to set make_before_break otherwise
    # strongSwan will have a very brief outage during IKEv2 reauth
    make_before_break = yes
 
    # Needed for tunnels - see https://wiki.strongswan.org/projects/strongswan/wiki/RouteBasedVPN
    install_routes = no
 
}
EOF'

sudo systemctl enable strongswan-swanctl
sudo systemctl start strongswan-swanctl

sudo bash -c 'cat << EOF > /etc/network/interfaces
source-directory /etc/network/interfaces.d
auto lo
iface lo inet loopback

auto lo:1
iface lo:1 inet static
      address 10.255.0.1
      netmask 255.255.255.255

auto ens5
iface ens5 inet dhcp

auto ens6
iface ens6 inet static
      address 10.0.0.1
      netmask 255.255.255.0

auto gre1
iface gre1 inet tunnel
      address 192.168.0.1
      netmask 255.255.255.0
      mode gre
      endpoint 10.0.0.2
      up ip route add 10.255.0.2/32 via 192.168.0.2
EOF'

sudo systemctl restart networking

sudo bash -c 'cat << EOF > /etc/swanctl/swanctl.conf
connections {
    my-vpn {
        remote_addrs = 10.0.0.2
        version = 1
        proposals = aes256-sha1-modp1536
        reauth_time = 1440m
        local-1 {
            auth = psk
            id = debian-router.domain.com
        }
        remote-1 {
            # id field here is inferred from the remote address
            auth = psk
        }
        children {
            my-vpn-1 {
                local_ts = 10.0.0.1/32[gre]
                remote_ts = 10.0.0.2/32[gre]
                mode = transport
                esp_proposals = aes128-sha1-modp1536
                rekey_time = 60m
                start_action = trap
                dpd_action = restart
            }
        }
    }

}
secrets {
    ike-my-vpn-1 {
        id-1 = cisco-iosxe.domain.com
        id-2 = 10.0.0.2
        secret = "secret"
    }
}
EOF'

sudo systemctl restart strongswan-swanctl
