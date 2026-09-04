{ pkgs, ... }:

{
  # Sets up some GTK configuration, mainly to set up the bookmarks for the file manager.
  gtk = {
    enable = true;
    iconTheme = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
    };
    gtk2.force = true;
  };

  home.file."/.config/gtk-3.0/bookmarks".text = ''
    file:///mnt/nas/Hacklings Hacklings
    file:///mnt/nas/Inventors-Guild Inventors Guild
    file:///mnt/nas/manuhiri manuhiri
    file:///mnt/nas/mema mema
  '';

  home.file."/.config/gtk-4.0/bookmarks".text = ''
    file:///mnt/nas/Hacklings Hacklings
    file:///mnt/nas/Inventors-Guild Inventors Guild
    file:///mnt/nas/manuhiri manuhiri
    file:///mnt/nas/mema mema
  '';
}
