{ pkgs, config, inputs, ... }:


{

  programs.obs-studio = {
    enable = true;
    enableVirtualCamera = true;
    # This enables NVIDIA NVENC support for your 4080
    package = pkgs.obs-studio.override {
      cudaSupport = true;
    };
    plugins = with pkgs.obs-studio-plugins; [
      wlrobs                # Wayland screen capture
      obs-pipewire-audio-capture # Capture specific app audio (like Vesktop/Games)
      obs-vkcapture         # Zero-latency game capture for Vulkan games
      obs-vaapi             # Hardware encoding backup
      obs-backgroundremoval # Blur/remove background without a green screen
      obs-gstreamer         # Extra format support
    ];
  };

  


}