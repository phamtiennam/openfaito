CFLAGS := -Wall
CC=$(TARGET_CC)
TARGETS := $(patsubst sh/lib/faito/%,%,$(wildcard sh/lib/faito/*))

all: shc create_x.c  $(TARGETS)
	mv $(TARGETS) bin/lib/faito	

shc: shc_busybox.c
	gcc -o $@ $<
create_x.c: 
	for var in $$(ls -f sh/lib/faito/*);do ./shc -r -B -f $$var ;done
	cp sh/lib/faito/*.x.c .
	mkdir -p bin/lib/faito

setcron.sh: setcron.sh.x.c
	$(CC) $(CFLAGS) -o $@ $<
getdhcp43: getdhcp43.x.c
	$(CC) $(CFLAGS) -o $@ $<
update_settings_nodes.sh_new: update_settings_nodes.sh_new.x.c
	$(CC) $(CFLAGS) -o $@ $<
reorder_ssid_2n3: reorder_ssid_2n3.x.c
	$(CC) $(CFLAGS) -o $@ $<
update_user.sh: update_user.sh.x.c
	$(CC) $(CFLAGS) -o $@ $<
rc.local: rc.local.x.c
	$(CC) $(CFLAGS) -o $@ $<
kickuser.sh: kickuser.sh.x.c
	$(CC) $(CFLAGS) -o $@ $<
main-loop: main-loop.x.c
	$(CC) $(CFLAGS) -o $@ $<
powerup_or_rebooted: powerup_or_rebooted.x.c
	$(CC) $(CFLAGS) -o $@ $<

checkxl2tp.sh: checkxl2tp.sh.x.c
	$(CC) $(CFLAGS) -o $@ $<
add_ssid: add_ssid.x.c
	$(CC) $(CFLAGS) -o $@ $<
delete_ssid: delete_ssid.x.c
	$(CC) $(CFLAGS) -o $@ $<
apply_new_settingsB.sh: apply_new_settingsB.sh.x.c
	$(CC) $(CFLAGS) -o $@ $<
every1minutes.sh: every1minutes.sh.x.c
	$(CC) $(CFLAGS) -o $@ $<
luci-hostname-APc.sh: luci-hostname-APc.sh.x.c
	$(CC) $(CFLAGS) -o $@ $<

init.d.default: init.d.default.x.c
	$(CC) $(CFLAGS) -o $@ $<
apply_new_settings.sh: apply_new_settings.sh.x.c
	$(CC) $(CFLAGS) -o $@ $<
lengthlog: lengthlog.x.c
	$(CC) $(CFLAGS) -o $@ $<
rescuel2tp.sh: rescuel2tp.sh.x.c
	$(CC) $(CFLAGS) -o $@ $<
update_current_settings.sh: update_current_settings.sh.x.c
	$(CC) $(CFLAGS) -o $@ $<
update_settings_nodes.sh: update_settings_nodes.sh.x.c
	$(CC) $(CFLAGS) -o $@ $<


clean:
	rm -fr bin/
