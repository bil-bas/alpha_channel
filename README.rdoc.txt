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

Windows: "alpha_channel.exe" (or "alpha_channel_full_screen.bat" to play full-screen).
OS X: "alpha_channel.app [--full-screen]"
Linux: "ruby lib/spooner_ld_18.rbw [--full-screen]" (see below under _compatibility_ for requirements).

== Ingame help (View by pressing F1)

    It is hell being a pixel. Why can't they all just get along?


    = How to play =

      * Red is evil; Red wants to hurt Blue!
        Yellow is so nasty, it makes Red look nice by comparison!
        Thankfully, Green is too busy thinking to even notice Blue.

      * Take control of other pixels, and use them to protect yourself!

      * Controlling is very strenuous and will use up your limited
        energy reserves (Blueness).

      * Pixels hurt pixels that aren't the same colour.
        It has always been like that, but no-one knows exactly why...
        Yellow is so dangerous, that even Red avoids it, but Green is more
        interested in musing on the nature of the Great Electron Gun.


    = Controls =

      * ARROW KEYS OR WASD: Move self (or a controlled Pixel).

      * SPACE OR RETURN: Take/relinquish control of a another Pixel.

      * P: Pause

      * CONTROL+Q: Exit game.

== Compatibility

Runs in a 640x480 window (or full-screen at that resolution).

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
* pixelated.ttf (font by Affinity and Epsilon - benepsilon {at} gmail.com) [INCLUDED]


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
