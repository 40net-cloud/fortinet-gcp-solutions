Content-Type: multipart/mixed; boundary="12345"
MIME-Version: 1.0

--12345
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="license"


LICENSE-TOKEN: ${flexvm_token}

--12345
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="config"

config system global
  set hostname ${hostname}
end
config system global
    set admintimeout 50
end

config system interface
  edit port2
    set dhcp-classless-route-addition enable
  next
  edit port3
    set dhcp-classless-route-addition enable
  next
end

config system sdn-connector
    edit "gcp"
        set type gcp
        set ha-status enable
    next
end
config system dns
  set primary 169.254.169.254
  set protocol cleartext
  unset secondary
end

config system ha
    set session-pickup enable
    set session-pickup-connectionless enable
    set session-pickup-nat enable
end

config system standalone-cluster
    set group-member-id ${ha_indx}
    config cluster-peer
        %{ for peer in ha_peers }
        edit 0
        set peerip ${peer}
        next
        %{ endfor }
    end
end

config router static
  edit 0
    set dst ${right_subnet}
    set device port2
    set gateway ${right_gw}
  next
end

config router route-map
    edit "cross-reg-med"
        set comments "Discriminate cross-regional routes"
        config rule
            edit 1
                set match-metric 100
                set set-metric 100
            next
            edit 2
                set set-metric 12000
            next
        end
    next
end

config router prefix-list
    edit "fgt-nets"
        config rule
            edit 1
                set action deny
                set prefix 172.20.0.0 255.255.255.240
                unset ge
                unset le
            next
            edit 2
                set action deny
                set prefix 172.20.0.16 255.255.255.240
                unset ge
                unset le
            next
            edit 3
                set action deny
                set prefix 172.20.1.0 255.255.255.240
                unset ge
                unset le
            next
            edit 4
                set action deny
                set prefix 172.20.1.16 255.255.255.240
                unset ge
                unset le
            next
            edit 5
                set prefix any
                unset ge
                unset le
            next
        end
    next
end

config router bgp
  set as ${my_asn}
  set ebgp-multipath enable
  set graceful-restart enable

  config neighbor
    edit ${left_nic0}
      set remote-as ${left_asn}
      set ebgp-enforce-multihop enable
      set interface port1
      set soft-reconfiguration enable
      set prefix-list-out fgt-nets
    next
    edit ${left_nic1}
      set remote-as ${left_asn}
      set ebgp-enforce-multihop enable
      set interface port1
      set soft-reconfiguration enable
      set prefix-list-out fgt-nets
    next
    edit ${right_nic0}
      set remote-as ${right_asn}
      set ebgp-enforce-multihop enable
      set interface port2
      set soft-reconfiguration enable
      set route-map-out cross-reg-med
      set prefix-list-out fgt-nets
    next
    edit ${right_nic1}
      set remote-as ${right_asn}
      set ebgp-enforce-multihop enable
      set interface port2
      set soft-reconfiguration enable
      set route-map-out cross-reg-med
      set prefix-list-out fgt-nets
    next
  end
end

${fgt_config}

--12345--
