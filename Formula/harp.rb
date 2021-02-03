# Code generated by Harp build tool
class Harp < Formula
  desc "Secret management toolchain"
  homepage "https://github.com/elastic/harp"
  license "Apache 2.0"
  bottle :unneeded

  # Stable build
  stable do
    if OS.mac?
      url "https://github.com/elastic/harp/releases/download/cmd%2Fharp%2Fv0.1.9/harp-darwin-amd64-v0.1.9.tar.xz"
      sha256 "488b86e4fef39332b7c7d732f0a150b06bbdf5dcca4639e9410c3ed119eca1c5"
    elsif OS.linux?
      url "https://github.com/elastic/harp/releases/download/cmd%2Fharp%2Fv0.1.9/harp-linux-amd64-v0.1.9.tar.xz"
      sha256 "b1bdcbf3ed9a5d3c334f6025a55eeef1b52cebfbe353d738729ef9ffcb01d1ff"
    end
  end

  # Source definition
  head do
    url "https://github.com/elastic/harp.git", :branch => "main"

    # build dependencies
    depends_on "go" => :build
    depends_on "mage" => :build
  end

  def install
    ENV.deparallelize

    unless build.head?
      # Install binaries
      if OS.mac?
        bin.install "harp-darwin-amd64" => "harp"
      elsif OS.linux?
        bin.install "harp-linux-amd64" => "harp"
      end
    else
      # Prepare build environment
      ENV["GOPATH"] = buildpath
      (buildpath/"src/github.com/elastic/harp").install Dir["{*,.git,.gitignore}"]

      # Mage tools
      ENV.prepend_path "PATH", buildpath/"tools/bin"

      # In github.com/elastic/harp command
      cd "src/github.com/elastic/harp/cmd/harp" do
        system "go", "mod", "vendor"
        system "mage", "compile"
      end

      # Install builded command
      cd "src/github.com/elastic/harp/cmd/harp/bin" do
        # Install binaries
        if OS.mac?
          bin.install "harp-darwin-amd64" => "harp"
        elsif OS.linux?
          bin.install "harp-linux-amd64" => "harp"
        end
      end
    end

    # Final message
    ohai "Install success!"
  end

  def caveats
    <<~EOS
      If you have previously built harp from source, make sure you're not using
      $GOPATH/bin/harp instead of this one. If that's the case you can simply run
      rm -f $GOPATH/bin/harp
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/harp version")
  end
end
