{pkgs, ...}: {
  home.packages = with pkgs; [
    (writeShellScriptBin "conv" ''
      for f in *; do
      # Skip hidden files (optional)
      [[ "$f" == "." || "$f" == ".." ]] && continue

      # Build output filename
      output_file="/run/media/lucas/9282048d-b2a4-47b7-b0f4-14c877d494d0/convert/''${f}.mp4"

      # Execute ffmpeg command with VAAPI encoding (use single quotes)
        ${pkgs.ffmpeg}/bin/ffmpeg -hwaccel vaapi -hwaccel_output_format vaapi -vaapi_device /dev/dri/renderD128 -y -i "$f" -c:v av1_vaapi -global_quality 90 "$output_file" && rm -v "$f"
      done
    '')
    (writeShellScriptBin "conv_old" ''
      for f in *; do
      # Skip hidden files (optional)
      [[ "$f" == "." || "$f" == ".." ]] && continue

      # Build output filename
      output_file="/run/media/lucas/9282048d-b2a4-47b7-b0f4-14c877d494d0/convert/''${f}.mp4"

      # Execute ffmpeg command with VAAPI encoding (use single quotes)
        ${pkgs.ffmpeg}/bin/ffmpeg -y -i "$f"  "$output_file" && rm -v "$f"
      done
    '')
  ];
}
