#!/bin/sh
#Faito-2015 .NamPham
#check xl2tpd memory usage

pid=$(/bin/pidof xl2tpd)
[ $pid != "" ]&&{
      usedmem=$(/bin/ps | awk '$5 == "xl2tpd" {print $3}')
      [ $usedmem -gt 7000 ]&&{                  #limit 7000 VSZ for xl2tpd
              echo $(date) >> /tmp/Restart_xl2tp_log
              echo "xl2tpd used $usedmem VSZ of MEM.Need to restart it..." >> /tmp/Restart_xl2tp_log

              /etc/init.d/xl2tpd restart   >>  /tmp/Restart_xl2tp_log
              echo "-----------------------------"    >>  /tmp/Restart_xl2tp_log
                
              /usr/bin/tail -n 100  /tmp/Restart_xl2tp_log > /tmp/tmpxl2tp
              mv -f /tmp/tmpxl2tp /tmp/Restart_xl2tp_log
      }
                              
}
                              
