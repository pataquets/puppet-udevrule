# == Class: udevrule
#
# Manages udev rules (one per file) at /etc/udev/rules.d/
# Notifies service for rule reload. Only tested on Ubuntu Precise.
#
# === Parameters
#
# Rules paramers are strings, you should escape " to not break them.
# Parameters for udev rules that can be matched and setted have
# different _match, _add or _set endings (for ==, += and = ops).
# See resource definition.
#
# === Examples
#
#	This udev rule matches a particular USB vendor:product id
#	for a flash drive, then beeps when inserted and also
#	adds another symlink for the device.
#
#	udevrule { 'myUSBstick1':
#		kernel => 'sd*',
#		action => 'add',
#		subsystem => 'block',
#		subsystems => 'usb',
#		attrs =>
#		[
#			{
#				'idVendor' => '058f',
#				'idProduct' => '6387',
#				#Other attrs:
#				#'vendor' => 'Microsoft',
#				#'model' => 'Intellimouse',
#				#'serial' => '1234567890',
#			},
#		],
#		run_cmd => '/usr/bin/beep', # full path
#		symlink_add	=> 'Puppet-myUSBStick1-%k',
#	}
#
# === Authors
#
# Alfonso Montero López <amontero@tinet.org>
#
define udevrule (
	$ensure			= present,
	$kernel			= false,
	$driver			= false,
	$devpath		= false,
	$action			= false,
	$subsystem		= false,
	$subsystems		= false,
	$name_match		= false,
	$symlink_match	= false,
	$name_set		= false,
	$symlink_add	= false,
	$attrs			= false,
	$run_cmd		= false,
	$owner			= false,
	$group			= false,
	$mode			= false,
	$options		= false,
) {

	if $ensure == present {
		$file_ensure = file
	} else {
		$file_ensure = absent
	}

	include udev::service

	file { $name:
		ensure	=> $file_ensure,
		path    => "/etc/udev/rules.d/${name}.rules",
		content => template('udevrule/udevrule.erb'),
		owner   => root,
		group   => root,
		mode	=> 644,
		notify	=> Service['udev'],
	}

}

class udev::service ( $ensure = running )
{
	service { ['udev']:
		ensure	=> $ensure,
		restart	=> 'udevadm control --reload-rules',
	}
}
