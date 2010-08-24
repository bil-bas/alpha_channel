= Alpha Channel

Spooner's entry for Ludum Dare 18 - "Enemies as weapons"

This is my first LD. This game is quite simple, but has some concepts it may take a couple of games to understand.
By taking control of your enemies, you can block and kill the other enemies that are nearly as tough as you are.
Unfortunately, while controlling an enemy, the other enemies will continue to attack you so you need to protect yourself
AND make sure you don't run out of energy, freeing your slave! Sometimes running away for a bit is the best plan...

Best, though, is play and figure it out for yourself! Press F1 for in-game help.

License: GPL v3
Author: Bil Bas (http://spooner.github.com) (bil dot bagpuss {at} gmail.com)

== How to run the game

Windows: alpha_channel.exe
OS X: alpha_channel.app
Linux: "ruby lib/spooner_ld_18.rbw" (see below under _compatibility_ for requirements).

== Ingame help (View by pressing F1)

    It is hell being a pixel. Why can't they all just get along?


    = How to play =

      * Red is evil; Red wants to hurt you!

      * Take control of Red, when it comes near, and use it to protect yourself from the other Reds!

      * Controlling Red is strenuous and will use up your limited energy reserves (Blueness).

      * All colours hurt colours that aren't the same. Green isn't too painful, though :)


    = Controls =

      * Arrow keys or WASD: Move self (or a controlled Red).

      * Space or Return: Take/relinquish control of Red.

      * P: Pause

      * Control+Q: Exit game.


== Compatibility

Runs in a 640x480 window.

* Windows: Native executable (.exe) available.
* OS X: Native executable (.app) available.
* Linux: Can run from Ruby source + libraries + Ruby gems 
  * Install Ruby 1.9.2 (or 1.9.1 or 1.8.7)
  * Install libraries needed by Gosu (see http://code.google.com/p/gosu/wiki/GettingStartedOnLinux) 
  * Install ruby libraries "sudo gem install gosu chingu".
  * "ruby lib/spooner_ld_18.rbw"


== Where to get a copy of the game from

* Project: http://github.com/Spooner/spooner_ld_18
* Downloads (including Windows exe): http://github.com/Spooner/spooner_ld_18/downloads
* Repository: git://github.com/Spooner/spooner_ld_18.git


== Tools used

* Ruby 1.9.2 (will also run on 1.9.1 or 1.8.7)
* Developed using JetBrains RubyMine IDE
* Sounds created with dfxr
* Windows executable created with the Ocra gem.


== External assets

* Gosu and Chingu gems (libraries) for graphics and sound [Included in executable versions].
* fmod.dll (used indirectly via Gosu; uses SDL when not on Windows) [INCLUDED]
* pixelated.ttf (Free font found at http://www.adobeflash.com/download/fonts/pixel/) [INCLUDED]


== License

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.

Full text of the license is provided in COPYING.txt
