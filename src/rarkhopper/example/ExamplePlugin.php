<?php

declare(strict_types=1);

namespace rarkhopper\example;

use pocketmine\plugin\PluginBase;
use pocketmine\utils\TextFormat as TF;

class ExamplePlugin extends PluginBase
{
    public function onEnable(): void
    {
        $this->getLogger()->info(TF::GREEN . "Example has been enabled!");
    }

    public function onDisable(): void
    {
        $this->getLogger()->info(TF::RED . "Example has been disabled!");
    }
}
