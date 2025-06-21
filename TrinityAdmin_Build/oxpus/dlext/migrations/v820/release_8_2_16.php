<?php
namespace oxpus\dlext\migrations;

class release_8_2_16 extends \phpbb\db\migration\migration
{	
	protected $dl_ext_version = '8.2.16';

	public function effectively_installed()
	{
		return isset($this->config['dl_ext_version'])
			&& version_compare($this->config['dl_ext_version'], $this->dl_ext_version, '>=');
	}
	
	public static function depends_on()
	{
		return ['oxpus\dlext\migrations\v820\release_8_2_15'];
	}

	public function update_data()
	{
		return [
			// 0 = uploads normaux permis ; 1 = seuls les liens externes pour les non-admins
			['config.add', ['dlext_external_only', 0]],
			['config.update', ['dl_ext_version',      $this->dl_ext_version]],
		];
	}
}