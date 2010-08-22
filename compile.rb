system "ocra lib/spooner_ld_18.rbw"

File.delete("alpha_channel.exe") if File.exists? "alpha_channel.exe"

File.rename "spooner_ld_18.exe", "alpha_channel.exe"
