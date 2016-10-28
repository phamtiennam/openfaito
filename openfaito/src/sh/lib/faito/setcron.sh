#!/bin/sh
# FAITO - 2013 by NamPham <tn_pham@compex.com.sg>
#/lib/faito/setcron.sh  
	[ ! -f /etc/crontabs/root -o  "$(grep -w "/lib/faito/every1minutes.sh" /etc/crontabs/root)" == "" ] && echo "*/1     *       *       *       * /lib/faito/every1minutes.sh" >> /etc/crontabs/root
        [ "$(grep -w "/lib/faito/rescuel2tp.sh" /etc/crontabs/root)" == ""  ] && echo "*/1     *       *       *       * /lib/faito/rescuel2tp.sh" >> /etc/crontabs/root
